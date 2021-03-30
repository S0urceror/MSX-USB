


#include <SPI.h>

SPISettings _spisettings (1000UL * 125, MSBFIRST, SPI_MODE0);

byte lasttransfer;

void setup() {
  pinMode(SS, OUTPUT);
  digitalWrite(SS, HIGH);
  SPI.begin ();
  Serial.begin(0); // baudrate is always maximum usb bus speed 12Mbit/sec
}

byte last_received;

void beginTransfer ()
{
  digitalWrite(SS, LOW);  
  delayMicroseconds(1);
}

void endTransfer ()
{
  delayMicroseconds(2);
  digitalWrite(SS, HIGH);
}

void writeCommand (byte cmd)
{
  beginTransfer();
  SPI.transfer (cmd);
}
void endCommand ()
{
  endTransfer();
}
void writeData (byte data)
{
  last_received = SPI.transfer (data);
}
byte readData ()
{
  return last_received;
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
    //data = digitalRead (4)<<7; // INT
    data = digitalRead (3)<<7; // MISO
    data += 1; // simulated READY bit
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
    {
      writeData (0);
      inbytes[i] = readData();
      //Serial.write (readData());
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
    for (i=0;i<512*10;i++) 
    {
      Serial.write (0x41);
    }
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
