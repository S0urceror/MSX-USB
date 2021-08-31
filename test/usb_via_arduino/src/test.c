/**
 * Skeleton for a USB device implementation with a CH372/375/376.
 * 
 * No real device functionality is implemented,
 * only the standard USB requests over the control endpoint.
 */

#include "constants.h"


/*************
 * Variables *
 *************/

bool unlocked;
bool handlingSetupRequest;
byte* dataToTransfer;
int dataToTransferIndex;
int dataLeftToTransfer;
bool sendingData;
byte addressToSet;
bool configured;

void ResetState()
{
  handlingSetupRequest = false;
  dataLeftToTransfer = 0;
  addressToSet = 0;
  configured = false;
}


/*******************
 * Descriptor data *
 *******************/

byte deviceDescriptor[] = {
  0x12, //Length
  USB_DESC_DEVICE,
  0x10, 0x01, //USB version,
  0x00, 0x00, 0x00, //Class, subclass, protocol
  EP0_PIPE_SIZE, //Max packet size for EP0
  0x09, 0x12, //VID (https://pid.codes)
  0x02, 0x00, //PID (testing)
  0x00, 0x01, //Device release number
  STRING_DESC_MANUFACTURER, //Manufacturer string id
  STRING_DESC_PRODUCT, //Product string id
  0x00, //Serial number string id
  0x01  //Number of configurations
};

byte configurationDescriptor[] = {
  0x09, //Length
  USB_DESC_CONFIGURATION,
  0x12, 0x00, //Total length
  0x01, //Number of interfaces
  0x01, //Configuration value
  0x00, //String descriptor for configuration
  0x80, //Attributes (no self-powered, no remote wake-up)
  50, //Max power (100mA)

  //Interface descriptor

  0x09, //Length
  USB_DESC_INTERFACE,
  0x00, //Interface number
  0x00, //Alternate setting
  0x00, //Number of endpoints
  0xFF, 0xFF, 0xFF, //Class, subclass, protocol
  STRING_DESC_PRODUCT //String descriptor for interface
};

byte languagesDescriptor[] = {
  0x04, //Length
  USB_DESC_STRING,
  0x09, 0x04 //English (US)
};

byte productStringDescriptor[] = {
  0x1A, //length,
  USB_DESC_STRING,
  //"NestorDevice"
  0x4E, 0x00, 0x65, 0x00, 0x73, 0x00, 0x74, 0x00, 0x6F, 0x00,
  0x72, 0x00, 0x44, 0x00, 0x65, 0x00, 0x76, 0x00, 0x69, 0x00,
  0x63, 0x00, 0x65, 0x00
};

byte manufacturerStringDescriptor[] = {
  0x2A, //length,
  USB_DESC_STRING,
  //"Konamiman Industries"
  0x4B, 0x00, 0x6F, 0x00, 0x6E, 0x00, 0x61, 0x00, 0x6D, 0x00, 
  0x69, 0x00, 0x6D, 0x00, 0x61, 0x00, 0x6E, 0x00, 0x20, 0x00, 
  0x49, 0x00, 0x6E, 0x00, 0x64, 0x00, 0x75, 0x00, 0x73, 0x00,
  0x74, 0x00, 0x72, 0x00, 0x69, 0x00, 0x65, 0x00, 0x73, 0x00
};

byte oneOneByte[] = {1};
byte oneZeroByte[] = {0};
byte twoZeroBytes[] = {0,0};


/****************
 * setup & loop *
 ****************/

void setup()
{
    printf_begin();
    Serial.begin(115200);
    ResetState();
    SetPins();
    
    bool initOk = CH376Init();
    if(initOk) {
      attachInterrupt(digitalPinToInterrupt(CH_INT), HandleInterrupt, FALLING);
    }
}

void loop()
{
  /*
  As an alternative to the "attachInterrupt" call in setup,
  the following code can be used in loop:

  if((CH_ReadStatus() & 0x80) == 0)
    HandleInterrupt();
  */  
}


/************************
 * USB protocol handler *
 ************************/

void HandleInterrupt()
{
  unlocked = false;

  CH_WriteCommand(GET_STATUS);
  byte interruptType = CH_ReadData();

  if((interruptType & USB_BUS_RESET_MASK) == USB_BUS_RESET) {
    interruptType = USB_BUS_RESET;
  }

  PrintInterruptName(interruptType);

  switch(interruptType)
  {
      case USB_INT_USB_SUSPEND:
        CH_WriteCommand(ENTER_SLEEP);
        ResetState();
        break;
      case USB_BUS_RESET:
        ResetState();
        break;
      case USB_INT_EP0_SETUP:
        HandleSetupToken();
        break;
      case USB_INT_EP0_IN:
        HandleControlInToken();
        break;
      case USB_INT_EP0_OUT:
        //Nothing to do since we don't implement
        //control OUT requests. We're going to receive
        //this interrupt only as the status phase of IN requests,
        //where there will be no data received.
        handlingSetupRequest = false;
        break;  
  }

  if(!unlocked && interruptType != USB_INT_USB_SUSPEND) {
    CH_WriteCommand(UNLOCK_USB);
  }
}

void HandleSetupToken()
{
  CH_WriteCommand(RD_USB_DATA0);
  byte length = CH_ReadData();
  if(length != SETUP_COMMAND_SIZE) {
    SetEndpoint(0, SET_ENDP_TX, SET_ENDP_STALL);
    printf("  *** Bad setup data length: %i\r\n", length);
    return;
  }

  byte requestBytes[SETUP_COMMAND_SIZE];
  printf("  ");
  for(int i=0; i<SETUP_COMMAND_SIZE; i++) {
    requestBytes[i] = CH_ReadData();
    printf("0x%02X ", requestBytes[i]);
  }
  printf("\r\n");

  byte bmRequestType = requestBytes[0];
  byte bRequest = requestBytes[1];
  int wValue = requestBytes[2] + (requestBytes[3] << 8);
  int wIndex = requestBytes[4] + (requestBytes[5] << 8);
  int wLength = requestBytes[6] + (requestBytes[7] << 8);
  printf("  bRequest: %i\r\n", bRequest);
  printf("  wValue: 0x%04X\r\n", wValue);
  printf("  wIndex: 0x%04X\r\n", wIndex);
  printf("  wLength: 0x%04X\r\n", wLength);

  if((bmRequestType & BM_REQ_TYPE_MASK) != BM_REQ_TYPE_STD) {
    printf("  *** Non-standard request, unsupported\r\n", length);
    SetEndpoint(0, SET_ENDP_TX, SET_ENDP_STALL);
    return;
  }

  sendingData = (bitRead(bmRequestType, 7) == 1);
  dataToTransferIndex = 0;

  if(sendingData) {
    dataLeftToTransfer = PrepareControlDataToSend(bRequest, wValue);
    if(dataLeftToTransfer == 0) {
      printf("  *** Unsupported IN request\r\n", length);
      SetEndpoint(0, SET_ENDP_TX, SET_ENDP_STALL);
    }
    else {
      dataLeftToTransfer = min(dataLeftToTransfer, wLength);
      byte amountToSendNow = min(dataLeftToTransfer, EP0_PIPE_SIZE);
      WriteDataForEndpoint0(amountToSendNow);
    }
  }
  else {
    SetEndpoint(0, SET_ENDP_TX, 0);
    dataLeftToTransfer = 0;
    bool ok = ActOnOutputRquest(bRequest, wValue);
    if(!ok) {
      printf("  *** Unsupported OUT request: %i\r\n", bRequest);
      SetEndpoint(0, SET_ENDP_TX, SET_ENDP_STALL);
    }
  }

  handlingSetupRequest = (dataLeftToTransfer > 0);
}

void WriteDataForEndpoint0(byte amount)
{
  printf("  Writing %i bytes: ", amount);
  CH_WriteCommand(WR_USB_DATA3__EP0);
  CH_WriteData(amount);
  for(int i=0; i<amount; i++) {
    printf("0x%02X ", dataToTransfer[dataToTransferIndex+i]);
    CH_WriteData(dataToTransfer[dataToTransferIndex+i]);
  }
  printf("\r\n");

  dataToTransferIndex += amount;
  dataLeftToTransfer -= amount;
}

int PrepareControlDataToSend(byte bRequest, int wValue)
{
    switch(bRequest) {
      case USB_REQ_GET_INTERFACE:
        printf("  GET_INTERFACE\r\n");
        dataToTransfer = oneOneByte;
        return 1;
      case USB_REQ_GET_CONFIGURATION:
        printf("  GET_CONFIGURATION\r\n");
        dataToTransfer = configured ? oneOneByte : oneZeroByte;
        return 1;
      case USB_REQ_GET_STATUS:
        printf("  GET_STATUS\r\n");
        dataToTransfer = twoZeroBytes;
        return 2;  
      case USB_REQ_GET_DESCRIPTOR:
        printf("  GET_DESCRIPTOR: ");
        byte descriptorType = highByte(wValue);
        switch(descriptorType)
        {
          case USB_DESC_DEVICE:
            printf("DEVICE\r\n");
            dataToTransfer = deviceDescriptor;
            return sizeof(deviceDescriptor);
          case USB_DESC_CONFIGURATION:
            printf("CONFIGURATION\r\n");
            dataToTransfer = configurationDescriptor;
            return sizeof(configurationDescriptor);
          case USB_DESC_STRING:
            printf("STRING: ");
            byte stringIndex = lowByte(wValue);  
            switch(stringIndex)
            {
              case 0:
                printf("Language\r\n");
                dataToTransfer = languagesDescriptor;
                return sizeof(languagesDescriptor);
              case STRING_DESC_PRODUCT:
                printf("Product\r\n");
                dataToTransfer = productStringDescriptor;
                return sizeof(productStringDescriptor);
              case STRING_DESC_MANUFACTURER:
                printf("Manufacturer\r\n");
                dataToTransfer = manufacturerStringDescriptor;
                return sizeof(manufacturerStringDescriptor);
              default:
                printf("Unknown! (%i)\r\n", stringIndex);
                return 0;    
            }
            default:
                printf("Unknown! (%i)\r\n", descriptorType);
                return 0;    
        }
      default:
        printf("  Unsupported request! (0x%02X)\r\n", bRequest);
        return 0;
    }
}

bool ActOnOutputRquest(byte bRequest, int wValue)
{
  switch(bRequest)
  {
    case USB_REQ_SET_ADDRESS:
      addressToSet = lowByte(wValue);
      printf("  SET_ADDRESS: %i\r\n", addressToSet);
      return true;
    case USB_REQ_SET_CONFIGURATION:
      printf("  SET_CONFIGURATION: 0x%04X\r\n", wValue);
      configured = (wValue != 0);
      return true;
  }

  return false;
}

void HandleControlInToken()
{
  if(addressToSet != 0) {
    printf("  Setting address: %i\r\n", addressToSet);
    CH_WriteCommand(SET_USB_ADDR);
    CH_WriteData(addressToSet);
    addressToSet = 0;
    return;
  }

  if(handlingSetupRequest && sendingData) {
    byte amountToSendNow = min(dataLeftToTransfer, EP0_PIPE_SIZE);
    WriteDataForEndpoint0(amountToSendNow);
    if(dataLeftToTransfer == 0) {
      handlingSetupRequest = false;
    }
  }
}

void SetEndpoint(int endpointNumber, int rxOrTx, int sizeOrStatus)
{
  byte cmd = SET_ENDP2__RX_EP0 + 2 * endpointNumber + rxOrTx;
  CH_WriteCommand(cmd);
  CH_WriteData(sizeOrStatus);
}

void Unlock()
{
  CH_WriteCommand(UNLOCK_USB);
  unlocked = true;
}


/**********************
 * CH376 reset & init *
 **********************/

void SetPins()
{
  	pinMode(CH_RD, OUTPUT);
	  pinMode(CH_WR, OUTPUT);
	  pinMode(CH_PCS, OUTPUT);
	  pinMode(CH_A0, OUTPUT);
	
	  digitalWrite(CH_PCS, HIGH);
	  digitalWrite(CH_RD, HIGH);
	  digitalWrite(CH_WR, HIGH);
}

bool CH376Init()
{
    CH_WriteCommand(RESET_ALL);
    delay(50);

    CH_WriteCommand(CHECK_EXIST);
    CH_WriteData(0x57);
    byte data = CH_ReadData();
    if(data != 0xA8) {
      // For some reason the first check always fails
      CH_WriteData(0x57);
      byte data = CH_ReadData();
      if(data != 0xA8) {
        printf("*** CH372 hardware not found! (0x57 --> 0x%02X)\r\n", data);
        return false;
      }
    }

    CH_WriteCommand(SET_USB_MODE);
    CH_WriteData(CH_USB_MODE_INVALID_DEVICE);
    delay(1);
    if (CH_ReadData() != CMD_RET_SUCCESS) {
      printf("*** CH372 set mode %i failed\r\n", CH_USB_MODE_INVALID_DEVICE);
      return false;
    }

    CH_WriteCommand(SET_USB_MODE);
    CH_WriteData(CH_USB_MODE_DEVICE_EXTERNAL_FIRMWARE);
    delay(1);
    if (CH_ReadData() != CMD_RET_SUCCESS) {
      printf("*** CH372 set mode %i failed\r\n", CH_USB_MODE_DEVICE_EXTERNAL_FIRMWARE);
      return false;
    }

    CH_WriteCommand(CHK_SUSPEND);
    CH_WriteData(0x10);
    CH_WriteData(0x04);

    printf("CH372 initialized!\r\n");
    return true;
}


/*********************************
 * Low-level access to the CH372 *
 *********************************/

byte CH_ReadData()
{
	return CH_ReadPort(CH_A0_DATA);
}

byte CH_ReadStatus()
{
	return CH_ReadPort(CH_A0_COMMAND);
}

byte CH_ReadPort(int address)
{
	byte data = 0;

	digitalWrite(CH_A0, address);

	for (int i = 0; i < 8; i++)
	{
		pinMode(CH_D0 + i, INPUT);
		digitalWrite(CH_D0 + i, LOW);
	}

	digitalWrite(CH_PCS, LOW);
	digitalWrite(CH_RD, LOW);

	for (int i = 0; i < 8; i++)
	{
		data >>= 1;
		data |= (digitalRead(CH_D0 + i) == HIGH) ? 128 : 0;
	}

	digitalWrite(CH_RD, HIGH);
	digitalWrite(CH_PCS, HIGH);

	return data;
}

byte CH_WriteData(byte data)
{
	return CH_WritePort(CH_A0_DATA, data);
}

byte CH_WriteCommand(byte command)
{
	return CH_WritePort(CH_A0_COMMAND, command);
}

byte CH_WritePort(int address, byte data)
{
	digitalWrite(CH_A0, address);

	for (int i = 0; i < 8; i++)
	{
		pinMode(CH_D0 + i, OUTPUT);
	}

	digitalWrite(CH_PCS, LOW);
	digitalWrite(CH_WR, LOW);
	
	for (int i = 0; i < 8; i++)
	{
		digitalWrite(CH_D0 + i, (((data >> i) & 1) == 0) ? LOW : HIGH);
	}

	digitalWrite(CH_WR, HIGH);
	digitalWrite(CH_PCS, HIGH);

	return data;
}


/**********************************
 * Redirect printf to serial port *
 **********************************/

//https://forum.arduino.cc/t/printf-to-the-serial-port/333975/4

int serial_putc( char c, FILE * ) 
{
  Serial.write( c );
  return c;
} 

void printf_begin(void)
{
  fdevopen( &serial_putc, 0 );
}


/*****************
 * Debug helpers *
 *****************/

 void PrintInterruptName( byte interruptCode)
 {
   char* name = NULL;

   switch(interruptCode) {
      case USB_BUS_RESET:
        name = "BUS_RESET";
        break;
      case USB_INT_EP0_SETUP:
        name = "EP0_SETUP";
        break;
      case USB_INT_EP0_OUT:
        name = "EP0_OUT";
        break;
      case USB_INT_EP0_IN:
        name = "EP0_IN";
        break;
      case USB_INT_EP1_OUT:
        name = "EP1_OUT";
        break;
      case USB_INT_EP1_IN:
        name = "EP1_IN";
        break;
      case USB_INT_EP2_OUT:
        name = "EP2_OUT";
        break;
      case USB_INT_EP2_IN:
        name = "EP2_IN";
        break;
      case USB_INT_USB_SUSPEND:
        name = "USB_SUSPEND";
        break;
      case USB_INT_WAKE_UP:
        name = "WAKE_UP";
        break;
   }

   if(name == NULL) {
    printf("Unknown interrupt received: 0x%02X\r\n", interruptCode);
   }
   else {
     printf("Int: %s\r\n", name);
   }
 }