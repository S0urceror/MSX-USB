


#include <SPI.h>

SPISettings _spisettings (1000UL * 125, MSBFIRST, SPI_MODE0);

byte lasttransfer;

void setup() {
  pinMode(SS, OUTPUT);
  digitalWrite(SS, HIGH);
  SPI.begin ();
  Serial.begin(0); // baudrate is always maximum usb bus speed 12Mbit/sec
  /*
  byte data;
  Serial.println ("Check CH376s communication");
  
  // reset
  Serial.println ("Reset:");
  writeCommand (5);
  delay(1000);
    
  // check CH376s
  Serial.println ("Check:");
  writeCommand (6);
  Serial.print (" Value: 0x");
  data = 'A';
  Serial.println (data,HEX);
  writeData (data);
  Serial.print (" Result: 0x");
  data = readData ();
  Serial.println (data,HEX);
  if ((data ^ 255) == 'A')
    Serial.println ("CH376s detected");
  else {
    Serial.println ("CH376s not found");
    return;
  }

  // set usb mode
  Serial.println ("Set USB mode:");
  writeCommand (0x15);
  Serial.println (" mode reset:");
  writeData (0x07);
  Serial.print (" result: 0x");
  data = readData ();
  Serial.println (data,HEX);
  if (data == 0x51)
    Serial.println ("CH375_CMD_RET_SUCCESS");
  else if (data == 0x5f) {
    Serial.println ("CH375_CMD_RET_ABORT");
    return;
  } 
  else
    return;
  Serial.println ("Set USB mode:");
  writeCommand (0x15);
  Serial.println (" mode reset:");
  writeData (0x06);
  Serial.print (" result: 0x");
  data = readData ();
  Serial.println (data,HEX);
  if (data == 0x51)
    Serial.println ("CH375_CMD_RET_SUCCESS");
  else if (data == 0x5f) {
    Serial.println ("CH375_CMD_RET_ABORT");
    return;
  } 
  else
    return;

  // set target device address
  Serial.println ("Set target address: 0x");
  writeCommand (0x13);
  Serial.println (" address: 1");
  writeData (1);
  */
}

void beginTransfer ()
{
  //SPI.beginTransaction (_spisettings);
  digitalWrite(SS, LOW);  
  delayMicroseconds(1);
}

void endTransfer ()
{
  delayMicroseconds(2);
  digitalWrite(SS, HIGH);
  //SPI.endTransaction();
}

void writeCommand (byte cmd)
{
  endTransfer();
  beginTransfer();
  SPI.transfer (cmd);
  //endTransfer();
}
void endCommand ()
{
  endTransfer();
}
void writeData (byte data)
{
  //beginTransfer();
  SPI.transfer (data);
  //endTransfer();
}
byte readData ()
{
  //beginTransfer();
  return SPI.transfer (0);
  //endTransfer();
}

void loop() {
  byte data;
  int length;
  int i;
  byte *inbytes,*outbytes;

  if (Serial.available() == 0) return;

  data = ReadByteFromSerial();
  switch (data)
  {
  case 1: //Write command
    data = ReadByteFromSerial();
    writeCommand(data);
    break;
  case 2: //Read status
    data = digitalRead (3)<<7; // MISO
    data += 1; // simulated READY bit
    //data = digitalRead (4)<<7; // INT
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
  case 5: //Read HW Int port
    data = readData();
    WriteByteToSerial(data);
    break;
  case 6: //Read multiple data
    length = ReadByteFromSerial();
    inbytes = (byte*) malloc (length);
    for (i = 0; i < length; i++)
    {
      inbytes[i] = readData();
    }
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
  case 8:
    endCommand ();
    break;
  case 10:
    for (i=0;i<512*50;i++) 
    {
      Serial.write (0xff);
    }
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
