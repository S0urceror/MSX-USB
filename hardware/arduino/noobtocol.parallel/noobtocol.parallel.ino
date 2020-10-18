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

//CH376 pins to Arduino digital connections mapping

const int CH_INT = 0;
const int CH_WR = 1;
const int CH_RD = 2;
const int CH_A0 = 3;
const int CH_PCS = 4;

const int CH_D0 = 14;
//CH_Dx = CH_D0 + x

const int CH_A0_DATA = LOW;
const int CH_A0_COMMAND = HIGH;

const int CH375_CMD_CHECK_EXIST = 0x06;

void setup() {
  pinMode(CH_RD, OUTPUT);
  pinMode(CH_WR, OUTPUT);
  pinMode(CH_PCS, OUTPUT);
  pinMode(CH_A0, OUTPUT);
  
  digitalWrite(CH_PCS, HIGH);
  digitalWrite(CH_RD, HIGH);
  digitalWrite(CH_WR, HIGH);

  Serial.begin(0); // baudrate is always maximum usb bus speed 12Mbit/sec
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
    CH_WriteCommand(data);
    break;
  case 2: //Read status
    data = CH_ReadStatus();
    WriteByteToSerial(data);
    break;
  case 3: //Write data
    data = ReadByteFromSerial();
    CH_WriteData(data);
    break;
  case 4: //Read data
    data = CH_ReadData();
    WriteByteToSerial(data);
    break;
  case 5: //Read HW Int port
    data = CH_ReadInt();
    WriteByteToSerial(data);
    break;
  case 6: //Read multiple data
    length = ReadByteFromSerial();
    inbytes = (byte*) malloc (length);
    for (i = 0; i < length; i++)
    {
      inbytes[i] = CH_ReadData();
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
      CH_WriteData(outbytes[i]);
    }
    free (outbytes);
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

byte CH_ReadPort(int address)
{
  byte data = 0;

  digitalWrite(CH_A0, address);

  for (int i = 0; i < 8; i++)
  {
    pinMode(CH_D0 + i, INPUT);
  }

  digitalWrite(CH_PCS, LOW);
  digitalWrite(CH_RD, LOW);

  for (int i = 0; i < 8; i++)
  {
    data |= (digitalRead (CH_D0+i) << i);
  }

  digitalWrite(CH_RD, HIGH);
  digitalWrite(CH_PCS, HIGH);

  return data;
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
    digitalWrite(CH_D0 + i, (data >> i) & 0x01);
  }

  digitalWrite(CH_WR, HIGH);
  digitalWrite(CH_PCS, HIGH);

  return data;
}

byte CH_ReadData()
{
  return CH_ReadPort(CH_A0_DATA);
}

byte CH_ReadStatus()
{
  return CH_ReadPort(CH_A0_COMMAND);
}

byte CH_ReadInt()
{
  byte value=0;
  //check int state
  int interrupt = digitalRead (CH_INT);
  value = ((interrupt==LOW) ? (value|=0x80) : value);
  return value;
}

byte CH_WriteData(byte data)
{
  return CH_WritePort(CH_A0_DATA, data);
}

byte CH_WriteCommand(byte command)
{
  return CH_WritePort(CH_A0_COMMAND, command);
}
