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
Updated by Mario Smit to use Teensy 2.0 and serial interface
*/

const unsigned long SERIAL_BAUDS = 115200;

//CH376 pins to Arduino digital connections mapping

#define USB Serial1
const int CH_BZY = 2;
const int CH_INT = 3;

void setup() {
  pinMode (CH_BZY, INPUT);
  pinMode (CH_INT, INPUT);
  
  Serial.begin(SERIAL_BAUDS);
  USB.begin(9600);
}

void loop() {
	byte data;
	int length;
	int i;

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
	case 6: //Read multiple data
		length = ReadByteFromSerial();
		if (length == 0) length = 256;
		for (i = 0; i < length; i++)
		{
			data = CH_ReadData();
			WriteByteToSerial(data);
		}
		break;
	case 7: //Write multiple data
		length = ReadByteFromSerial();
		if (length == 0) length = 256;
		for (i = 0; i < length; i++)
		{
			data = ReadByteFromSerial();
			CH_WriteData(data);
		}
		break;
	default:
		while (Serial.available() >= 0) Serial.read();
	}

	//while (Serial.available() >= 0) Serial.read();
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
  while (USB.available() == 0);
  return USB.read();
}

byte CH_ReadStatus()
{
  //check busy state
  int busy_state = digitalRead (CH_BZY);
  //check int state
  int interrupt = digitalRead (CH_INT);
  char value=0;
  //value = (busy_state==HIGH ? value|=0x10 : value);
  value = (interrupt==LOW ? value|=0x80 : value);
  return value;
}

byte CH_WriteData(byte data)
{
	while (USB.availableForWrite() == 0);
  USB.write(data);
}

byte CH_WriteCommand(byte command)
{
  // flush all old data not read
  while (USB.available())
    USB.read ();
  // write command
  CH_WriteData (0x57);
  CH_WriteData (0xAB);
  CH_WriteData (command);
}
