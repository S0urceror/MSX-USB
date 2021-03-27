/*
The "Noobtocol": A very simple protocol for communication with a CH376
connected to the Arduino using SPI interface.

The protocol is as follows:

- To write to the command port:
  Host sends 1, then the command byte.

- To read the status port:
  Host sends 2, then reads the status byte.

- To write to the data port:
  Host sends 3, then the data byte.

- To read from the data port:
  Host sends 4, then reads the data byte.

- To read a block of bytes from the data port:
  Host sends 6, then reads block size (0 means 256),
  then reads that many bytes.

- To write a block of bytes to the data port:
  Host sends 7, then the block size (0 means 256),
  then that many bytes.
*/

/*
By Konamiman, extending original code by Xavirompe
Updated by Sourceror to use Teensy 2.0 and parallel interface
*/

#include <SPI.h>

const byte CH376_CMD_CHECK_EXIST = 0x06;
const byte CH376_CMD_RESET_ALL = 0x05;
const byte CH376_CMD_SET_SD0_INT = 0x0b;
const byte CH376_CMD_GET_STATUS = 0x22;

const uint8_t TESTVAL = 0b10001000;
SPISettings _spisettings (1000UL * 125, MSBFIRST, SPI_MODE0);

void setup() {
  pinMode(SS, OUTPUT);
  digitalWrite(SS, HIGH);
  SPI.begin ();
  Serial.begin(0); // baudrate is always maximum usb bus speed 12Mbit/sec

  beginTransfer ();
  CH_WriteCommand (CH376_CMD_RESET_ALL);
  endTransfer ();
  delay(2000);// wait after reset command
  
/*
  beginTransfer ();
  CH_WriteCommand (CH376_CMD_SET_SD0_INT);
  CH_WriteData (0x16);
  CH_WriteData (0x90);
  endTransfer ();
*/
  
  beginTransfer ();
  CH_WriteCommand (CH376_CMD_CHECK_EXIST);
  CH_WriteData (TESTVAL);
  uint8_t result = CH_ReadData ();
  endTransfer ();
/*
  Serial.println (result,HEX);
  Serial.println (TESTVAL^0xff,HEX);
  if (result!=(TESTVAL^0xff))
    Serial.println ("CH376s not recognized");
  else
    Serial.println ("CH376s recognized");
*/
}

void beginTransfer ()
{
  delayMicroseconds(2);
  //SPI.beginTransaction(_spisettings);
  digitalWrite(SS, LOW);
}

void endTransfer ()
{
  digitalWrite(SS, HIGH);
  //SPI.endTransaction();
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
    beginTransfer();
    data = ReadByteFromSerial();
    CH_WriteCommand(data);
    endTransfer();
    break;
  case 2: //Read status
    beginTransfer();
    data = CH_ReadStatus();
    WriteByteToSerial(data);
    endTransfer();
    break;
  case 3: //Write data
    beginTransfer();
    data = ReadByteFromSerial();
    CH_WriteData(data);
    endTransfer();
    break;
  case 4: //Read data
    beginTransfer();
    data = CH_ReadData();
    WriteByteToSerial(data);
    endTransfer();
    break;
  case 5: //Read HW Int port
    beginTransfer();
    data = CH_ReadInt();
    WriteByteToSerial(data);
    endTransfer();
    break;
  case 6: //Read multiple data
    beginTransfer();
    length = ReadByteFromSerial();
    inbytes = (byte*) malloc (length);
    for (i = 0; i < length; i++)
    {
      inbytes[i] = CH_ReadData();
    }
    Serial.write (inbytes,length);
    Serial.send_now();
    free (inbytes);
    endTransfer();
    break;
  case 7: //Write multiple data
    beginTransfer();
    length = ReadByteFromSerial();
    outbytes = (byte*) malloc (length);
    for (i = 0; i < length; i++)
    {
      outbytes[i] = ReadByteFromSerial();
      CH_WriteData(outbytes[i]);
    }
    free (outbytes);
    endTransfer();
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

byte CH_ReadData()
{
  delayMicroseconds(2);//datasheet TSC min 1.5uSec
  return SPI.transfer (0x00);
}

byte CH_ReadStatus()
{
  return CH_ReadInt ();
}

byte CH_ReadInt()
{
  uint8_t _tmpReturn = 0;
  beginTransfer();
  CH_WriteCommand(CH376_CMD_GET_STATUS);
  _tmpReturn = CH_ReadData();
  endTransfer();
  return _tmpReturn;
}

uint8_t CH_WriteData(uint8_t data)
{
  delayMicroseconds(2);//datasheet TSC min 1.5uSec
  SPI.transfer (data);
}


void CH_WriteCommand(uint8_t command)
{
  delayMicroseconds(2);//datasheet TSC min 1.5uSec
  SPI.transfer (command);
}
