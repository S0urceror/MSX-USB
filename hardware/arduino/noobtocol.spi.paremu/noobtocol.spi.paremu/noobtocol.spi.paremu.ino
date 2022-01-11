#include <SPI.h>

#define CH376_CMD_GET_IC_VER      0x01
#define CH_CMD_ENTER_SLEEP        0x03
#define CH375_CMD_RESET_ALL       0x05
#define CH375_CMD_CHECK_EXIST     0x06
#define CH375_CMD_SET_USB_ADDR    0x13
#define CH375_CMD_SET_USB_MODE    0x15
#define CH_CMD_SET_EP0_RX         0x18
#define CH_CMD_SET_EP0_TX         0x19
#define CH_CMD_SET_EP1_RX         0x1a
#define CH_CMD_SET_EP1_TX         0x1b
#define CH_CMD_SET_EP2_RX         0x1c
#define CH_CMD_SET_EP2_TX         0x1d
#define CH375_CMD_GET_STATUS      0x22
#define CH375_CMD_UNLOCK_USB      0x23
#define CH375_CMD_RD_USB_DATA     0x27
#define CH375_CMD_RD_USB_DATA_UNLOCK     0x28
#define CH_CMD_WR_EP0             0x29 // DATA3
#define CH_CMD_WR_EP1             0x2A // DATA5
#define CH_CMD_WR_EP2             0x2B // DATA7
#define CH375_CMD_WR_HOST_DATA    0x2C
#define CH376_CMD_CLR_STALL       0x41
#define CH375_CMD_ISSUE_TKN_X     0x4E
#define CH_CMD_SET_REGISTER       0x0b
#define CH_CMD_GET_REGISTER       0x0a
#define CH_CMD_DELAY_100US        0x0f
#define CH375_CMD_GET_DESCR       0x46
#define CH_CMD_TEST_CONNECT       0x16
#define CH_CMD_SET_FILE_NAME      0x2f
#define CH_CMD_DISK_CONNECT       0x30
#define CH_CMD_DISK_MOUNT         0x31
#define CH_CMD_FILE_OPEN          0x32
#define CH_CMD_FILE_CLOSE         0x36
#define CH_CMD_FILE_ENUM_GO       0x33
#define CH_CMD_BYTE_READ          0x3a
#define CH_CMD_BYTE_RD_GO         0x3b
#define CH_CMD_BYTE_WRITE         0x3c
#define CH_CMD_BYTE_WR_GO         0x3d
#define CH_CMD_DIR_CREATE         0x40
#define CH_CMD_FILE_CREATE        0x34
#define CH_CMD_WR_REQ_DATA        0x2d
#define CH_CMD_DIR_INFO_READ      0x37
#define CH_CMD_BYTE_LOCATE        0x39
#define CH_CMD_FILE_ERASE         0x35

// return codes
#define CH_ST_RET_SUCCESS         0x51
#define CH_ST_RET_ABORT           0x5F

int ledPin = 11;
int intPin = 5;
int misoPin = 3;

int bytes_following;
bool extended_command;
bool zero_ended_command;
bool wait_for_operation_status;
//bool cmd_get_status;
//uint8_t lastStatus;

void setup() {
  // initialize SPI pins
  pinMode(SS, OUTPUT);
  digitalWrite(SS, HIGH);
  SPI.begin ();
  
  // initialize Teensy USB serial
  Serial.begin(0); // baudrate is always maximum usb bus speed 12Mbit/sec

  // initialize LED
  pinMode (ledPin,OUTPUT);
  digitalWrite (ledPin, LOW);

  //lastStatus = 0xff;
}


void beginCmd (byte cmd)
{
  extended_command = false;
  zero_ended_command = false;
  wait_for_operation_status = false;
  //cmd_get_status = false;
  
  switch (cmd) 
  {
    case CH_CMD_ENTER_SLEEP:        bytes_following = 1;
                                    break;   
    case CH375_CMD_CHECK_EXIST:     bytes_following = 3;
                                    break;
    case CH375_CMD_SET_USB_MODE:    wait_for_operation_status = true;
                                    break;
    case CH375_CMD_SET_USB_ADDR:    bytes_following = 2;
                                    break;
    case CH375_CMD_WR_HOST_DATA:    bytes_following = 2;
                                    extended_command = true;
                                    break; 
    case CH_CMD_SET_EP0_RX:         bytes_following = 2;
                                    break;
    case CH_CMD_SET_EP0_TX:         bytes_following = 2;
                                    break;
    case CH_CMD_SET_EP1_RX:         bytes_following = 2;
                                    break;
    case CH_CMD_SET_EP1_TX:         bytes_following = 2;
                                    break;
    case CH_CMD_SET_EP2_RX:         bytes_following = 2;
                                    break;
    case CH_CMD_SET_EP2_TX:         bytes_following = 2;
                                    break;
    case CH_CMD_WR_EP0:             bytes_following = 2;
                                    extended_command = true;
                                    break;  
    case CH_CMD_WR_EP1:             bytes_following = 2;
                                    extended_command = true;
                                    break;  
    case CH_CMD_WR_EP2:             bytes_following = 2;
                                    extended_command = true;
                                    break;                                                                                            
    case CH375_CMD_GET_STATUS:      bytes_following = 2;
                                    //cmd_get_status = true;
                                    break; 
    case CH375_CMD_ISSUE_TKN_X:     bytes_following = 3;
                                    break;           
    case CH376_CMD_GET_IC_VER:      bytes_following = 2;
                                    break;
    case CH376_CMD_CLR_STALL:       bytes_following = 2;
                                    break;
    case CH375_CMD_RD_USB_DATA:     bytes_following = 2;
                                    extended_command = true;
                                    break;
    case CH375_CMD_RD_USB_DATA_UNLOCK:     
                                    bytes_following = 2;
                                    extended_command = true;
                                    break;
    case CH_CMD_SET_REGISTER:       bytes_following = 3;
                                    break;
    case CH_CMD_GET_REGISTER:       bytes_following = 3;
                                    break;        
    case CH_CMD_DELAY_100US:        bytes_following = 2;
                                    break;
    case CH375_CMD_GET_DESCR:       bytes_following = 2;
                                    break;         
    case CH_CMD_TEST_CONNECT:       bytes_following = 2;
                                    break;   
    case CH_CMD_DISK_CONNECT:       bytes_following = 1;
                                    break;   
    case CH_CMD_DISK_MOUNT:         bytes_following = 1;
                                    break;    
    case CH_CMD_FILE_OPEN:          bytes_following = 1;  
                                    break;          
    case CH_CMD_FILE_CLOSE:         bytes_following = 2;  
                                    break;          
    case CH_CMD_FILE_ENUM_GO:       bytes_following = 1;  
                                    break;    
    case CH_CMD_FILE_ERASE:         bytes_following = 1;  
                                    break;                                                                   
    case CH_CMD_SET_FILE_NAME:      bytes_following = 15;
                                    zero_ended_command = true;
                                    break;         
    case CH_CMD_BYTE_READ:          bytes_following = 3;
                                    break;      
    case CH_CMD_BYTE_RD_GO:         bytes_following = 1;
                                    break;  
    case CH_CMD_BYTE_WRITE:         bytes_following = 3;
                                    break;
    case CH_CMD_BYTE_WR_GO:         bytes_following = 1;
                                    break;       
    case CH_CMD_DIR_CREATE:         bytes_following = 1;
                                    break;  
    case CH_CMD_FILE_CREATE:        bytes_following = 1;
                                    break;            
    case CH_CMD_WR_REQ_DATA:        bytes_following = 2;
                                    extended_command = true;
                                    break;         
    case CH_CMD_DIR_INFO_READ:      bytes_following = 2;
                                    break;         
    case CH_CMD_BYTE_LOCATE:        bytes_following = 5;
                                    break;                
    case CH375_CMD_UNLOCK_USB:      bytes_following = 1;
                                    break;                                                                                                                                                                                                                       
    default:                        bytes_following = 1;  
                                    break;
  }
  digitalWrite(SS, LOW);  
  digitalWrite (ledPin, HIGH);
}
void checkEndCmd (byte value)
{
  if (zero_ended_command && value==0)
  {
    bytes_following=0;
    digitalWrite(SS, HIGH);
    digitalWrite (ledPin, LOW);
    return; 
  }
  if (wait_for_operation_status && (value==CH_ST_RET_SUCCESS || value==CH_ST_RET_ABORT))
  {
    bytes_following=0;
    digitalWrite(SS, HIGH);
    digitalWrite (ledPin, LOW);
    return;
  }
  if (--bytes_following==0) 
  {
      if (extended_command)
      {
        extended_command = false;
        bytes_following = value;
        if (bytes_following>0)
          return;
      }
      digitalWrite(SS, HIGH);
      digitalWrite (ledPin, LOW);
      return;
  }
}

void writeCommand (byte cmd)
{
  beginCmd (cmd);
  SPI.transfer (cmd);
  checkEndCmd (-1);
}

void writeData (byte data)
{
  SPI.transfer (data);
  checkEndCmd (data);
}

byte readData ()
{
  byte data = SPI.transfer (0);
  checkEndCmd (data);
/*
  if (cmd_get_status && lastStatus!=0xff)
  {
    data = lastStatus;
    lastStatus = 0xff;
  }
*/
  return data;
}

byte readStatus () 
{
  byte data;
  data = digitalRead (intPin)<<7; // INT
  //data = digitalRead (misoPin)<<7; // MISO
  data += 1; // simulated READY bit
/*
  if ((data & 0x80) == 0) // interrupt pulls down to zero
  {
    digitalWrite(SS, LOW);
    SPI.transfer (CH375_CMD_GET_STATUS);
    delayMicroseconds (1);
    lastStatus = SPI.transfer (0);
    digitalWrite(SS, HIGH);
  }
  else
    lastStatus = 0xff;
*/    
  return data;
}

void loop() 
{
  byte data;
  int length;
  int i;
  byte *inbytes,*outbytes;

  // loop when no serial request received
  if (Serial.available() == 0) 
    return;

  // process serial request
  data = ReadByteFromSerial();
  switch (data)
  {
  case 1: //Write command
    data = ReadByteFromSerial();
    writeCommand(data);
    break;
  case 2: //Read status
    data = readStatus ();
    WriteByteToSerial(data);
    break;
  case 3: //Write data
    data = ReadByteFromSerial();
    writeData(data);
    break;
  case 4: //Read data
    data = readData();
    WriteByteToSerial(data);
    break;
  case 6: //Read multiple data
    length = ReadByteFromSerial();
    inbytes = (byte*) malloc (length);
    for (i = 0; i < length; i++)
      inbytes[i] = readData();
    Serial.write (inbytes,length);
    Serial.send_now();
    free (inbytes);
    break;
  case 7: //Write multiple data
    length = ReadByteFromSerial();
    outbytes = (byte*) malloc (length);
    for (i = 0; i < length; i++)
    {
      outbytes[i] = ReadByteFromSerial();
      writeData(outbytes[i]);
    }
    free (outbytes);
    break;    
  case 10: // block benchmark
    for (i=0;i<512*10;i++) 
    {
      Serial.write (0xAA);
    }
    break;
  case 11: // roundtrip benchmark
    Serial.write (Serial.read ());
    break;
  default:
    while (Serial.available() >= 0) Serial.read();
  }
}

byte ReadByteFromSerial()
{
   while (Serial.available() == 0);
   return Serial.read();
}

void WriteByteToSerial(byte data)
{
  while (Serial.availableForWrite() == 0);
  Serial.write(data);
}
