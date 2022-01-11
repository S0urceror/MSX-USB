/*
  The "Noobtocol": A very simple protocol for communication with a CH376
  connected to the Arduino using parallel interface.

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

//CH376 pins to Arduino digital connections mapping
const int CH_WR = 0;
const int CH_RD = 1;
const int CH_PCS = 2;
const int CH_A0 = 3;
const int CH_INT = 4;
const int CH_D0 = 14;
//CH_Dx = CH_D0 + x

const int CH_A0_DATA = LOW;
const int CH_A0_COMMAND = HIGH;

const int CH375_CMD_CHECK_EXIST = 0x06;

//const int ledPin = 13;
const int SPI_SLAVE_SELECT_PIN = 10;

const uint8_t WR_COMMAND = 1;
const uint8_t RD_STATUS = 2;
const uint8_t WR_DATA = 3;
const uint8_t RD_DATA = 4;
const uint8_t RD_INT = 5;
const uint8_t RD_DATA_MULTIPLE = 6;
const uint8_t WR_DATA_MULTIPLE = 7;
const uint8_t DATA_DUMP = 10;

const uint8_t SPI_WRITE_MULTIPLE = 11;
SPISettings spi_settings(2000000, MSBFIRST, SPI_MODE0); 

void setup() {
  pinMode(CH_RD, OUTPUT);
  pinMode(CH_WR, OUTPUT);
  pinMode(CH_PCS, OUTPUT);
  pinMode(CH_A0, OUTPUT);

  digitalWrite(CH_PCS, LOW);
  digitalWrite(CH_RD, HIGH);
  digitalWrite(CH_WR, HIGH);
  digitalWrite(CH_A0, LOW);

  Serial.begin(0); // baudrate is always maximum usb bus speed 12Mbit/sec

  // SPI
  SPI.begin ();
  pinMode (SPI_SLAVE_SELECT_PIN, OUTPUT);
  digitalWrite (SPI_SLAVE_SELECT_PIN, HIGH);
  

  // initialize LED
  //pinMode (ledPin, OUTPUT);
  //digitalWrite (ledPin, LOW);

}

void loop() {
  byte data;
  byte length;
  int i;
  byte *inbytes;

  if (Serial.available() == 0) return;

  data = ReadByteFromSerial();
  switch (data)
  {
    case WR_COMMAND: //Write command
      data = ReadByteFromSerial();
      CH_WriteCommand(data);
      //digitalWrite (ledPin, HIGH);
      break;
    case RD_STATUS: //Read status
      data = CH_ReadStatus();
      WriteByteToSerial(data);
      //digitalWrite (ledPin, LOW);
      break;
    case WR_DATA: //Write data
      data = ReadByteFromSerial();
      CH_WriteData(data);
      //digitalWrite (ledPin, LOW);
      break;
    case RD_DATA: //Read data
      data = CH_ReadData();
      WriteByteToSerial(data);
      //digitalWrite (ledPin, LOW);
      break;
    //case RD_INT: //Read HW Int port
    //  data = CH_ReadInt();
    //  WriteByteToSerial(data);
    //  break;
    case RD_DATA_MULTIPLE: //Read multiple data
      length = ReadByteFromSerial();
      inbytes = (byte*) malloc (length);
      for (i = 0; i < length; i++)
        inbytes[i] = CH_ReadData();
      Serial.write (inbytes, length);
      //Serial.send_now();
      free (inbytes);
      //digitalWrite (ledPin, LOW);
      break;
    case WR_DATA_MULTIPLE: //Write multiple data
      length = ReadByteFromSerial();
      for (i = 0; i < length; i++)
        CH_WriteData(ReadByteFromSerial());
      //digitalWrite (ledPin, LOW);
      break;
    case DATA_DUMP:
      //digitalWrite (ledPin, HIGH);
      for (i = 0; i < 512 * 10; i++)
        Serial.write (0xaa);
      //digitalWrite (ledPin, LOW);
      break;
    case SPI_WRITE_MULTIPLE: // test SPI
      length = ReadByteFromSerial();
      inbytes = (byte*) malloc (length);
      SPI.beginTransaction (spi_settings);
      digitalWrite (SPI_SLAVE_SELECT_PIN,LOW);
      for (i = 0; i < length; i++)
        inbytes[i] = SPI.transfer (ReadByteFromSerial());
      digitalWrite (SPI_SLAVE_SELECT_PIN,HIGH);
      SPI.endTransaction();
      for (i = 0; i < length; i++)
        WriteByteToSerial (inbytes[i]);
       free (inbytes);
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

byte CH_ReadPort(int address)
{
  byte data = 0;

  digitalWrite(CH_A0, address);

  for (int i = 0; i < 8; i++)
  {
    pinMode(CH_D0 + i, INPUT);
  }

  //digitalWrite(CH_PCS, LOW);
  digitalWrite(CH_RD, LOW);

  for (int i = 0; i < 8; i++)
  {
    data |= (digitalRead (CH_D0 + i) << i);
  }

  digitalWrite(CH_RD, HIGH);
  //digitalWrite(CH_PCS, HIGH);

  return data;
}

byte CH_WritePort(int address, byte data)
{
  digitalWrite(CH_A0, address);

  for (int i = 0; i < 8; i++)
  {
    pinMode(CH_D0 + i, OUTPUT);
  }

  //digitalWrite(CH_PCS, LOW);
  digitalWrite(CH_WR, LOW);

  for (int i = 0; i < 8; i++)
  {
    digitalWrite(CH_D0 + i, (data >> i) & 0x01);
  }

  digitalWrite(CH_WR, HIGH);
  //digitalWrite(CH_PCS, HIGH);

  return data;
}

byte CH_ReadData()
{
  return CH_ReadPort(CH_A0_DATA);
}

byte CH_ReadStatus()
{
  // NOTE: INT seems to be too fast for KINGSTON USB stick
  //byte data;
  //data = digitalRead (CH_INT)<<7; // INT
  //data += 1; // simulated READY bit
  //return data;
  return CH_ReadPort(CH_A0_COMMAND);
}

byte CH_WriteData(byte data)
{
  return CH_WritePort(CH_A0_DATA, data);
}

byte CH_WriteCommand(byte command)
{
  return CH_WritePort(CH_A0_COMMAND, command);
}
