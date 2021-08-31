// USB-HID - application that discovers attached USB devices to CH376s
// Copyright 2019 - Sourceror (Mario Smit)

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

#include <stdio.h>
#include <fcntl.h>
#include <termios.h>
#include <strings.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <vector>
#include <string>
#include <locale>
#include <codecvt>
#include <thread>
#include <chrono>
#include <ctime>
#include <iostream>
#include <stdio.h>
#include <algorithm>
#include <sys/time.h>

//#define   B115200 0010002
//#define   B230400 0010003
#define   B460800 0010004
#define   B500000 0010005
#define   B576000 0010006
#define   B921600 0010007
#define  B1000000 0010010
#define  B1152000 0010011
#define  B1500000 0010012
#define  B2000000 0010013
#define  B2500000 0010014
#define  B3000000 0010015
#define  B3500000 0010016
#define  B4000000 0010017
#define BAUDRATE B115200
int serial=-1;

#define CH376_CMD_GET_IC_VER 0x01
#define CH_CMD_ENTER_SLEEP 0x03
#define CH375_CMD_SET_USB_SPEED 0x04
#define CH375_CMD_RESET_ALL 0x05
#define CH375_CMD_CHECK_EXIST 0x06
#define CH375_CMD_SET_USB_MODE 0x15
#define CH375_CMD_GET_STATUS 0x22
#define CH375_CMD_SET_USB_ADDR 0x13
#define CH375_CMD_SET_ENDP6 0x1C
#define CH375_CMD_SET_ENDP7 0x1D
#define	CH375_CMD_UNLOCK_USB 0x23
#define CH375_CMD_RD_USB_DATA 0x27
#define CH375_CMD_RD_USB_DATA_UNLOCK 0x28
//#define CH375_CMD_WR_USB_DATA7 0x2B
#define CH_CMD_WR_EP0 0x29 // DATA3
#define CH_CMD_WR_EP1 0x2A // DATA5
#define CH_CMD_WR_EP2 0x2B // DATA7
#define CH375_CMD_WR_HOST_DATA 0x2C
#define CH376_CMD_SET_FILE_NAME 0x2F
#define CH376_CMD_DISK_CONNECT 0x30
#define CH376_CMD_DISK_MOUNT 0x31
#define CH376_CMD_OPEN_FILE 0x32
#define CH376_CMD_FILE_CLOSE 0x36
#define CH376_CMD_DIR_INFO_READ 0x37

#define CH376_CMD_BYTE_READ 0x3a
#define CH376_CMD_BYTE_RD_GO 0x3b
#define CH375_USB_INT_DISK_READ 0x1d

#define CH376_CMD_CLR_STALL 0x41
#define CH375_CMD_SET_ADDRESS 0x45
#define CH375_CMD_GET_DESCR 0x46
#define CH375_CMD_SET_CONFIG 0x49
#define CH375_CMD_ISSUE_TOKEN 0x4F
#define CH375_CMD_ISSUE_TKN_X 0x4E
#define CH375_CMD_ABORT_NAK 0x17
#define CH376_CMD_GET_REGISTER 0x0A
#define CH376_CMD_SET_REGISTER 0x0B

#define CH375_USB_MODE_DEVICE_INVALID 0x00
#define CH375_USB_MODE_DEVICE_OUTER_FW 0x01
#define CH375_USB_MODE_DEVICE_INNER_FW 0x02
#define CH375_USB_MODE_HOST 0x06
#define CH375_USB_MODE_HOST_RESET 0x07

#define CH375_USB_ERR_OPEN_DIR 0x41

#define CH375_USB_INT_SUCCESS 0x14
#define CH375_USB_INT_CONNECT 0x15
#define CH375_USB_INT_DISCONNECT 0x16
#define CH375_USB_INT_BUF_OVER 0x17
#define CH375_USB_INT_USB_READY 0x18

#define CH375_CMD_RET_SUCCESS 0x51
#define CH375_CMD_RET_ABORT 0x52

#define CH375_USB_DEVICE_DESCRIPTOR 0x01
#define CH375_USB_CONFIGURATION_DESCRIPTOR 0x02
#define CH375_USB_INTERFACE_DESCRIPTOR 0x04
#define CH375_USB_ENDPOINT_DESCRIPTOR 0x05

//--- PIDs
#define CH_PID_SETUP 0x0D
#define CH_PID_IN  0x09
#define CH_PID_OUT 0x01

bool VERBOSE=1;
void print_buffer (uint8_t* data, uint16_t length)
{
    if (VERBOSE==0)
        return;

    for (int i=0;i<length;i++)
    {
        if ((i%16)==0)
            printf ("\n");
        if ((i%4)==0)
            printf (" ");
        printf ("%02x ",*(data+i));
    }
    printf ("\n");
}

void error (char const * msg)
{
    printf ("ERROR: %s\n",msg);
    exit(0);
}

void init_serial ()
{
    const char device[] = "/dev/tty.usbmodem123451";
    serial = open(device, O_RDWR | O_NOCTTY | O_NONBLOCK);
    if(serial == -1)
      error( "failed to open port" );
    if(!isatty(serial))
      error( "not serial" );
    fcntl(serial, F_SETFL, 0);
    
    struct termios  config;
    bzero(&config, sizeof(config));
    config.c_cflag |= CS8 | CLOCAL | CREAD;
    config.c_iflag |= IGNPAR;
    cfsetispeed (&config, B230400);
    cfsetospeed (&config, B230400);
     
    config.c_cc[VTIME]    = 1;   /* wait 0.1 * VTIME on new characters to arrive when blocking */
    config.c_cc[VMIN]     = 1;   /* blocking read until 1 chars received */
    
    tcflush(serial, TCIFLUSH);
    tcsetattr(serial, TCSANOW, &config); 
}

// LOW_LEVEL serial communication to CH376
///////////////////////////////////////////////////////////////////////////
const uint8_t WR_COMMAND = 1;
const uint8_t RD_STATUS = 2;
const uint8_t WR_DATA = 3;
const uint8_t RD_DATA = 4;
const uint8_t RD_INT = 5;
const uint8_t RD_DATA_MULTIPLE = 6;
const uint8_t WR_DATA_MULTIPLE = 7;
const uint8_t DATA_DUMP = 10;
const uint8_t ROUNDTRIP = 11;
const uint8_t WAITSTATUS = 12;

struct timeval prevtime, curtime,wsprevtime, wscurtime,acprevtime, accurtime;
void roundtrip ()
{
    gettimeofday(&curtime, NULL);
    uint8_t cmd[] = {ROUNDTRIP,0x41};
    write (serial,cmd,sizeof(cmd));
    uint8_t new_value;
    read (serial,&new_value,1);
    unsigned long nsecs = (curtime.tv_sec - prevtime.tv_sec) * 1000000 + (curtime.tv_usec - prevtime.tv_usec);
    prevtime = curtime;
    printf("Roundtrip: %ld nsecs\r\n", nsecs);
}
uint8_t waitStatus2 (bool indefiniteTries=false)
{
    gettimeofday(&wsprevtime, NULL);

    uint8_t cmd[] = {WAITSTATUS};
    write (serial,cmd,sizeof(cmd));
    uint8_t status;
    read (serial,&status,1);

    gettimeofday(&wscurtime, NULL);
    unsigned long nsecs = (wscurtime.tv_sec - wsprevtime.tv_sec) * 1000000 + (wscurtime.tv_usec - wsprevtime.tv_usec);
    printf("waitStatus2: %ld nsecs\r\n", nsecs);

    return status;
}
void writeCommand (uint8_t command)
{
    uint8_t cmd[] = {WR_COMMAND,command};
    write (serial,cmd,sizeof(cmd));
}
void writeData (uint8_t data)
{
    uint8_t cmd[] = {WR_DATA,data};
    write (serial,cmd,sizeof(cmd));
}
void writeDataMultiple (uint8_t* buffer,uint8_t len)
{
    uint8_t cmd[] = {WR_DATA_MULTIPLE,len};
    write (serial,cmd,sizeof(cmd));
    write (serial,buffer,len);
}
ssize_t readData (uint8_t* new_value)
{
    uint8_t cmd[] = {RD_DATA};
    write (serial,cmd,sizeof(cmd));
    return read (serial,new_value,1);
}
ssize_t readDataMultiple (uint8_t* buffer,uint8_t len)
{
    int i;
    uint8_t cmd[] = {RD_DATA_MULTIPLE,len};
    write (serial,cmd,sizeof(cmd));
    uint8_t bytes_read = 0;
    while (bytes_read<len)
    {
        uint8_t bytes = read (serial,buffer,len);
        if (bytes==0) 
            error ("did not receive data");
        bytes_read += bytes;
        buffer += bytes;
    }
    assert (bytes_read==len);
    return bytes_read;
}
ssize_t readStatus (uint8_t* new_value)
{
    uint8_t cmd[] = {RD_STATUS};
    write (serial,cmd,sizeof(cmd));
    return read (serial,new_value,1);
}

// CHECK STATUS
///////////////////////////////////////////////////////////////////////////
uint8_t waitStatus (bool indefiniteTries=false)
{
    uint8_t status,interrupt;
    int i=0;
    ssize_t bytes;
    int counter = 1000;
    while ((bytes=readStatus(&interrupt)) && counter>0)
    {
        if ((interrupt&0x80)==0)
            break;
        //usleep (1000);
        if (indefiniteTries==false)
            counter --;
    }
    if (counter<=0)
        error ("timeout waitStatus");
    writeCommand(CH375_CMD_GET_STATUS);
    bytes = readData (&status);
    if (bytes)
        return status;
    return 0;
}
void check_exists ()
{
    uint8_t value = 190;
    uint8_t new_value;
    //char cmd[] = {0x57,0xAB,CH375_CMD_CHECK_EXIST,value};
    writeCommand (CH375_CMD_CHECK_EXIST);
    writeData(value);
    ssize_t bytes = readData (&new_value);
    value = value ^ 255;
    if (bytes!=1 || (new_value != value))
        error ("Device does not exist\n");
}

// CH376 built-in commands
///////////////////////////////////////////////////////////////////////////
void reset_all ()
{
    writeCommand (CH375_CMD_RESET_ALL);
    usleep (100000);
}
void set_target_device_address (uint8_t address)
{
    writeCommand (CH375_CMD_SET_USB_ADDR);
    writeData(address);
    usleep (2000);
}

bool set_usb_host_mode (uint8_t mode)
{
    writeCommand(CH375_CMD_SET_USB_MODE);
    writeData(mode);
    
    uint8_t value;
    for(int i=0; i!=200; i++ )
    {
        readData(&value);
        if ( value == CH375_CMD_RET_SUCCESS )
            return true;
        usleep(1000);
    }
    return false;
}

// Higher level USB read/write
///////////////////////////////////////////////////////////////////////////
void write_usb_data (uint8_t* message,uint8_t length)
{
    writeCommand (CH375_CMD_WR_HOST_DATA);
    writeData(length);
    for (int i=0;i<length;i++)
        writeData(message[i]);
}
ssize_t read_usb_data (uint8_t* pBuffer)
{
    uint8_t value = 0;
    writeCommand(CH375_CMD_RD_USB_DATA_UNLOCK);
    ssize_t bytes = readData(&value);
    if (bytes==0)
        error ("no data available");
    if (value==0)
        return 0;
    bytes = readDataMultiple(pBuffer, value);
    if (bytes<value)
        error("did not receive enough bytes");
    return bytes;
}

void usb_device_bus_reset ()
{
    bool result;
    //result = set_usb_host_mode(CH375_USB_MODE_DEVICE_INVALID);
    //usleep (500000);
    if (!(result=set_usb_host_mode(CH375_USB_MODE_DEVICE_OUTER_FW)))
        error ("device mode not succeeded\n");

    // enable SUSPEND/WAKEUP
    //writeCommand (CH376_CMD_SET_REGISTER);
    //writeData (0x10);
    //writeData (0x04);
}

//; / * The following status code 0XH is used for USB device mode * /
//; / * Only need to process in the built-in firmware mode: USB_INT_EP1_OUT, USB_INT_EP1_IN, USB_INT_EP2_OUT, USB_INT_EP2_IN * /
//; / * Bit 7-Bit 4 is 0000 * /
//; / * Bit 3-bit 2 indicates the current transaction, 00 = OUT, 10 = IN, 11 = SETUP * /
//; / * Bit 1 to Bit 0 indicate the current endpoint, 00 = Endpoint 0, 01 = Endpoint 1, 10 = Endpoint 2, 11 = USB Bus Reset * /
#define USB_INT_EP0_SETUP 		0x00C			 //; / * SETUP of USB endpoint 0 * /
#define USB_INT_EP0_OUT 		0x000			 //; / * OUT of USB endpoint 0 * /
#define USB_INT_EP0_IN 			0x008			 //; / * IN of USB endpoint 0 * /
#define USB_INT_EP1_OUT 		0x001			 //; / * OUT of USB endpoint 1 * /
#define USB_INT_EP1_IN 			0x009			 //; / * IN of USB endpoint 1 * /
#define USB_INT_EP2_OUT 		0x002			 //; / * OUT of USB endpoint 2 * /
#define USB_INT_EP2_IN 			0x00A			 //; / * IN of USB endpoint 2 * /
//; / * USB_INT_BUS_RESET EQU 00000XX11B * /; / * USB bus reset * /
#define USB_BUS_RESET_MASK      0b00000011
#define USB_INT_BUS_RESET 		0x003
#define USB_INT_BUS_RESET1 		0x003			 //; / * USB bus reset * /
#define USB_INT_BUS_RESET2 		0x007			 //; / * USB bus reset * /
#define USB_INT_BUS_RESET3 		0x00B			 //; / * USB bus reset * /
#define USB_INT_BUS_RESET4 		0x00F			 //; / * USB bus reset * /
#define USB_INT_USB_SUSPEND     0x05
#define USB_INT_WAKE_UP         0x06

// USB requests
////////////////////////////////////////////
// IN
#define USB_REQ_GET_STATUS              0x00
#define USB_REQ_GET_DESCRIPTOR          0x06
#define USB_REQ_GET_CONFIGURATION       0x08
#define USB_REQ_GET_INTERFACE           0x0a
#define USB_REQ_SYNC_FRAME              0x0c

//OUT
#define USB_REQ_CLEAR_FEATURE           0x01
#define USB_REQ_SET_FEATURE             0x03
#define USB_REQ_SET_ADDRESS             0x05
#define USB_REQ_SET_DESCR               0x07
#define USB_REQ_SET_CONFIGURATION       0x09
#define USB_REQ_SET_INTERFACE           0x0b

#define EP0_PIPE_SIZE               8
#define BULK_OUT_ENDP_MAX_SIZE      0x40

// USB descriptor codes
#define USB_DESC_DEVICE             1
#define USB_DESC_CONFIGURATION      2
#define USB_DESC_STRING             3
#define USB_DESC_INTERFACE          4
#define USB_DESC_ENDPOINT           5

// USB string descriptor ids
#define STRING_DESC_MANUFACTURER    1
#define STRING_DESC_PRODUCT         2
#define STRING_DESC_SERIAL          3

//0000-ready ACK, 1110-busy NAK, 1111-error STALL
#define SET_ENDP_ACK        0b0000
#define SET_ENDP_NAK        0b1110
#define SET_ENDP_STALL      0b1111

#define SET_ENDP_RX         0b0000
#define SET_ENDP_TX         0b0001

#define SET_ENDP2__RX_EP0   0x18
#define SET_ENDP3__TX_EP0   0x19
#define SET_ENDP4__RX_EP1   0x1A
#define SET_ENDP5__TX_EP1   0x1B
#define SET_ENDP6__RX_EP2   0x1C
#define SET_ENDP7__TX_EP2   0x1D

#define SET_LINE_CODING         0x20    //Configures baud rate, stop-bits, parity, and number- of-character bits.
#define GET_LINE_CODING         0x21    //Requests current DTE rate, stop-bits, parity, and number-of-character bits.
#define SET_CONTROL_LINE_STATE  0x22    //RS232 signal used to tell the DCE device the DTE device is now present.
#define SEND_BREAK              0x23    // Sends special carrier modulation used to specify RS-232 style break

#define USB_CONFIGURATION_ID    1

/*******************
 * Descriptor data *
 *******************/
/* Various descriptors of the device */
/* Include device descriptors, configuration descriptors, interface descriptors, endpoint descriptors, string descriptors, and CDC type function descriptors */



/* Device descriptor */
uint8_t DevDes[] = {
    0X12, // bLength 1 the number of bytes of the device descriptor
    0X01, // bDecriptorType. 1 for the device type description 0x01

    0X10, // bcdUSB 2 This device is compatible with the description table of the USB device description version number BCD code, currently 1.1
    0X01,

    0X02, // bDeviceClass 1 device class code CDC Class
    0X00, // bDeviceSubClass 1 subclass code
    0X00, // bDevicePortocol 1 protocol code

    EP0_PIPE_SIZE, // bMaxPacketSize0 1 The maximum packet size of endpoint 0, only 8, 16, 32, 64 are legal values; the current maximum is 8
    // idVendor 2 manufacturer logo (valued by USB standard)
    0xC0, // VendorID-L
    0x16, // VendorId-H
    // idProduct 2 product logo (paid by the manufacturer)
    0x83, // ProductId-L
    0x04, // ProductId-H

    0X00, // bcdDevice 2 device release number BCD code
    0X01,

    0X01, // iManufacturer 1 Index: Index description string of vendor information
    0X02, // iProduct 1 Index: The index of the string describing the product information
    0X03, // iSerialNumber 1 Index: the index of the string describing the device serial number information

    0X01 // bNumConfigurations 1 the number of possible settings
};

/* Configuration descriptor */
uint8_t ConDes[9 + 9 + 5 + 4 + 5 + 5 + 7 + 9 + 7 + 7] = {
    /* Configuration descriptor */
    0X09,                  // bLength 1 The number of bytes in the configuration descriptor
    0X02,                  // bDescriptorType 1 configuration description table type 0X02
    sizeof(ConDes) & 0xFF, // wTotalLength 2 The total length of this configuration information, including the configuration interface endpoint and device class and the description table defined by the manufacturer
    (sizeof(ConDes) >> 8) & 0xFF,
    // 0x43,
    // 0x00,

    0X02, // bNumInterfaces 1 The number of interfaces supported by this configuration
    USB_CONFIGURATION_ID, // bCongfigurationValue SetConfiguration. 1 as a parameter in () request to the selected configuration
    0X00, // iConfiguration 1 Index: the index of the string description table describing this configuration
    0Xc0, // bmAttributes 1 configuration characteristics
    0X19, // MaxPower 1 Bus power consumption in this configuration takes 2mA as a unit, 50mA

    /* Control interface descriptor */
    0X09, // bLength 1 The number of bytes of interface 0 descriptor
    0X04, // bDescriptorType 1 interface description table class 0x04
    0X00, // bInterfaceNumber 1 The index of the interface array supported by the current configuration of the interface number (starting from zero)
    0X00, // bAlternateSetting 1 optional setting index value
    0X01, // number of endpoints bNumEndpoints 1 using this interface, if it indicates that the interface is zero only default control pipe
    0X02, // bInterfaceClass 1 class value, CDC class
    0X02, // bInterfaceSubClass 1
    0X01, // bInterfaceProtocol 1 protocol code, which means CDC type
    0X00, // iInterface 1 The index value of the string description table describing this interface

    /* Class-Specific Functional Descriptors */
    0X05, // bFunctionLength
    0X24, // bDescriptorType CS_INTERFACE
    0X00, // bDescriptorSubtype Header
    0X10, // bcdCDC
    0X01,

    0X04, // bFunctionLength
    0X24, // bDescriptorType CS_INTERFACE
    0X02, // bDescriptorSubtype Abstract Control Management
    0X02, // bmCapabilities
    // D7..D4: RESERVED (Reset to zero)
    // D3: 1-Device supports the notification Network_Connection.
    // D2: 1-Device supports the request Send_Break
    // D1: 1-Device supports the request combination of
    // Set_Line_Coding,Set_Control_Line_State,Get_Line_Coding, and the notification Serial_State.
    // D0: 1-Device supports the request combination of
    // Set_Comm_Feature,
    // Clear_Comm_Feature, and
    // Get_Comm_Feature.

    0X05, // bFunctionLength
    0x24, // bDescriptorType CS_INTERFACE
    0X06, // bDescriptorSubtype of Union Functional descriptor
    0X00, // bMasterInterface
    0X01, // bSlaveInterface0

    0X05, // bFunctionLength
    0X24, // bDescriptorType CS_INTERFACE
    0X01, // bDescriptorSubtype Call Management Functional Descriptor
    0X03, // bmCapabilities
    // D7..D2: RESERVED (Reset to zero)
    // D1: 0-Device sends/receives call management information only over the Communication Class interface.
    // 1-Device can send/receive call management information over a Data Class interface.
    // D0: 0-Device does not handle call management itself.
    // 1-Device handles call management itself.
    0X01, // bDataInterface Interface Number The interface of the Data Class OPTIONALLY Used for Call Management.

    /* The endpoint descriptor corresponding to the control interface */
    0X07, // bLength 1 The number of bytes in the endpoint description table
    0X05, // bDescriptorType 1 endpoint description table class 0x05
    0X81, // bEndpointAddress 1 The address of the endpoint described in this description table
    0X03, // bmAttributes 1 This endpoint is interrupt transmission
    0X08, // wMaxPacketSize 2 The size of the largest data packet that this endpoint can receive or send under the current configuration
    0X00,
    0X14, // bInterval 1 The time interval for polling data transmission endpoints is 20ms

    /* Data interface descriptor */
    0X09, // bLength 1 The number of bytes of interface 0 descriptor
    0X04, // bDescriptorType 1 interface description table class 0x04
    0X01, // bInterfaceNumber 1 The index of the interface array supported by the current configuration of the interface number (starting from zero)
    0X00, // bAlternateSetting 1 optional setting index value
    0X02, // bNumEndpoints 1 The number of endpoints used by this interface, if it is zero, it means that this interface only uses the default control pipe
    0X0A, // bInterfaceClass 1 class value, CDC class
    0X00, // bInterfaceSubClass 1 subclass code
    0X00, // bInterfaceProtocol 1 protocol code, which means CDC type
    0X00,

    /* The endpoint descriptor corresponding to the data interface-batch input endpoint 2 descriptor */
    0X07,                   // bLength 1 The number of bytes in the endpoint description table
    0X05,                   // bDescriptorType 1 endpoint description table class 0x05
    0X02,                   // bEndpointAddress 1 The address of the endpoint described in this description table
    0X02,                   // bmAttributes 1 This endpoint is interrupt transmission
    BULK_OUT_ENDP_MAX_SIZE, // wMaxPacketSize 2 The size of the largest data packet that this endpoint can receive or send under the current configuration
    0X00,
    0X00, // bInterval 1 The time interval of round-robin data transmission endpoint, invalid for bulk endpoint
    /* The endpoint descriptor corresponding to the data interface-batch input endpoint 2 descriptor */
    0X07,                   // bLength 1 The number of bytes in the endpoint description table
    0X05,                   // bDescriptorType 1 endpoint description table class 0x05
    0X82,                   // bEndpointAddress 1 The address of the endpoint described in this description table
    0X02,                   // bmAttributes 1 This endpoint is interrupt transmission
    BULK_OUT_ENDP_MAX_SIZE, // wMaxPacketSize 2 The size of the largest data packet that this endpoint can receive or send under the current configuration
    0X00,
    0X00, // bInterval 1 The time interval of round-robin data transmission endpoint, invalid for bulk endpoint
};

/* Language descriptor */
uint8_t LangDes[] = {
    0X04, // bLength
    0X03, // bDescriptorType
    0X09,
    0X04};

/* Vendor string descriptor */
uint8_t MANUFACTURER_Des[] = {
    0X2C,  // bLength
    0X03,  // bDescriptorType
    'w', // "www.temcocontrols.com"
    0X00,
    'w',
    0X00,
    'w',
    0X00,
    '.',
    0X00,
    't',
    0X00,
    'e',
    0X00,
    'm',
    0X00,
    'c',
    0X00,
    'o',
    0X00,
    'c',
    0X00,
    'o',
    0X00,
    'n',
    0X00,
    't',
    0X00,
    'r',
    0X00,
    'o',
    0X00,
    'l',
    0X00,
    's',
    0X00,
    '.',
    0X00,
    'c',
    0X00,
    'o',
    0X00,
    'm',
    0X00
};

/* Product string descriptor */
uint8_t PRODUCER_Des[] = {
    0X26,  // bLength
    0X03,  // bDescriptorType
    'N', // "Network Controller"
    0X00,
    'e',
    0X00,
    't',
    0X00,
    'w',
    0X00,
    'o',
    0X00,
    'r',
    0X00,
    'k',
    0X00,
    ' ',
    0X00,
    'C',
    0X00,
    'o',
    0X00,
    'n',
    0X00,
    't',
    0X00,
    'r',
    0X00,
    'o',
    0X00,
    'l',
    0X00,
    'l',
    0X00,
    'e',
    0X00,
    'r',
    0X00
};

/* Product serial number string descriptor */
uint8_t PRODUCER_SN_Des[] = {
    0X16,        // bLength
    0X03,        // bDescriptorType
    '2', 0x00, // "2012-04-27"
    '0', 0x00,
    '1', 0x00,
    '2', 0x00,
    '-', 0x00,
    '0', 0x00,
    '5', 0x00,
    '-', 0x00,
    '1', 0x00,
    '1', 0x00
};

uint8_t oneOneByte[1] = {1};
uint8_t oneZeroByte[1] = {0};
uint8_t twoZeroBytes[2] = {0,0};

typedef	union __attribute__((packed)) _REQUEST_PACK{
	unsigned char  buffer[64];
	struct{
		uint8_t	    bmRequestType;  
		uint8_t	    bRequest;	
		uint16_t    wValue;		
		uint16_t    wIndx;		
		uint16_t    wLength;	
	}r;
} REQUEST_PACKET;

typedef union __attribute__((packed)) _UART_PARA
{
    uint8_t uart_para_buf[ 7 ];
    struct
    {
        uint8_t bBaudRate1; // Serial port baud rate (lowest bit)
        uint8_t bBaudRate2; // (second low)
        uint8_t bBaudRate3; // (second highest)
        uint8_t bBaudRate4; // (highest bit)
        uint8_t bStopBit; // Stop bit
        uint8_t bParityBit; // Parity bit
        uint8_t bDataBits; // Number of data bits
    } uart;
} UART_PARA;
UART_PARA uart_parameters;

void printInterruptName( uint8_t interruptCode)
{
    const char* name = NULL;

    switch(interruptCode) 
    {
        case USB_INT_BUS_RESET:
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

   gettimeofday(&curtime, NULL);
   if(name == NULL) 
   {
        printf("Unknown interrupt received: 0x%02X\r\n", interruptCode);
   }
   else 
   {
       unsigned long msecs = (curtime.tv_sec - prevtime.tv_sec) * 1000 + (curtime.tv_usec - prevtime.tv_usec)/1000;
       unsigned long acmsecs = (curtime.tv_sec - accurtime.tv_sec) * 1000 + (curtime.tv_usec - accurtime.tv_usec)/1000;
       prevtime = curtime;

       printf("Int: %s (%ld msecs, %ld msecs)\r\n", name,msecs,acmsecs);
   }
 }

#define USB_DIR_MASK    0x80
#define USB_DIR_IN      0x80
#define USB_DIR_OUT     0x00
#define USB_TYPE_MASK			(0x03 << 5)
#define USB_TYPE_STANDARD		(0x00 << 5)
#define USB_TYPE_CLASS			(0x01 << 5)
#define USB_TYPE_VENDOR			(0x02 << 5)
#define USB_TYPE_RESERVED		(0x03 << 5)

uint8_t* dataToTransfer;
int     dataLength;
uint8_t usb_device_address;
uint8_t usb_configuration_id;

void reset ()
{
    dataLength = 0;
    dataToTransfer = NULL;
    usb_device_address = 0;
    usb_configuration_id = 0;
}

void sendEP0ACK ()
{
    writeCommand (SET_ENDP3__TX_EP0);
    writeData (SET_ENDP_ACK);
}
void sendEP0STALL ()
{
    writeCommand (SET_ENDP3__TX_EP0);
    writeData (SET_ENDP_STALL);
}
void writeDataForEndpoint0()
{
    int amount = std::min (EP0_PIPE_SIZE,dataLength);

    // this is a data stage
    printf("  Writing %d bytes of %d: ", amount,dataLength);    
    writeCommand(CH_CMD_WR_EP0);
    writeData(amount);
    for(int i=0; i<amount; i++) 
    {
        printf("0x%02X ", dataToTransfer[i]);
        writeData(dataToTransfer[i]);
    }
    printf("\r\n");

    dataToTransfer += amount;
    dataLength -= amount;
}

REQUEST_PACKET request;
int length;
char characterBuffer[255];
enum state_transaction 
{
    SETUP=0,
    DATA,
    STATUS
} transaction_state = STATUS;

char * strupr (char *str) 
{
  char *ret = str;

  while (*str)
    {
      *str = toupper (*str);
      ++str;
    }

  return ret;
}

int main(int argc, const char * argv[]) 
{
    uint8_t interruptType;
    uint8_t length;

    // reset our own internal vars
    reset ();

    init_serial();
    for (int i=0;i<10;i++) roundtrip ();

    check_exists();
    reset_all();

    // set reset bus and set device mode
    usb_device_bus_reset ();
    printf ("Listening to USB events\r\n");

    gettimeofday(&curtime, NULL);

    while (true)
    {
        interruptType = waitStatus(true);

        if((interruptType & USB_BUS_RESET_MASK) == USB_INT_BUS_RESET)
            interruptType = USB_INT_BUS_RESET;

        printInterruptName(interruptType);

        switch(interruptType)
        {
            case USB_INT_USB_SUSPEND:
                writeCommand(CH_CMD_ENTER_SLEEP);
                writeCommand(CH375_CMD_UNLOCK_USB);
                break;
            case USB_INT_BUS_RESET:
                //writeCommand (CH375_CMD_RESET_ALL);
                reset ();
                writeCommand(CH375_CMD_UNLOCK_USB);
                break;
            // control endpoint setup package
            case USB_INT_EP0_SETUP:
            {
                if (transaction_state!=STATUS)
                    printf ("SETUP: >> previous transaction not completed <<\r\n");
                transaction_state = SETUP;
                printf ("SETUP\r\n");

                // read setup package
                length = read_usb_data (request.buffer);
                printf("  bmRequestType: 0x%02X\r\n", request.r.bmRequestType);
                printf("  bRequest: %i\r\n", request.r.bRequest);
                printf("  wValue: 0x%04X\r\n", request.r.wValue);
                printf("  wIndex: 0x%04X\r\n", request.r.wIndx);
                printf("  wLength: %03d\r\n", request.r.wLength);
                
                // initialize dataLength with length of setup package
                dataLength = request.r.wLength;

                if ((request.r.bmRequestType & USB_TYPE_MASK)==USB_TYPE_VENDOR)
                {
                    printf("SETUP VENDOR request\r\n");
                }
                if ((request.r.bmRequestType & USB_TYPE_MASK)==USB_TYPE_CLASS)
                {
                    printf("SETUP CLASS request\r\n");
                    switch (request.r.bRequest)              // Analyze the class request code and process it
                    {
                        case SET_LINE_CODING: // SET_LINE_CODING
                            printf ("  SET_LINE_CODING\n");
                            break;
                        case GET_LINE_CODING: // GET_LINE_CODING
                            printf ("  GET_LINE_CODING\n");
                            dataToTransfer = (uint8_t*) &uart_parameters;
                            dataLength = std::min ((uint16_t) sizeof(UART_PARA),request.r.wLength);;
                            break;
                        case SET_CONTROL_LINE_STATE: // SET_CONTROL_LINE_STATE
                            printf ("  SET_CONTROL_LINE_STATE\n");
                            sendEP0ACK ();
                            break;
                        default:
                            printf ("  Unsupported class command code\n");
                            //sendEP0STALL ();
                            break;
                    }                    
                }
                if ((request.r.bmRequestType & USB_TYPE_MASK)==USB_TYPE_STANDARD)
                {
                    printf("SETUP STANDARD request");
                    if ((request.r.bmRequestType & USB_DIR_MASK) == USB_DIR_IN) // IN
                    {
                        printf(" IN\r\n");
                        switch(request.r.bRequest)
                        {
                            case USB_REQ_GET_DESCRIPTOR:
                            {
                                printf("USB_REQ_GET_DESCRIPTOR: ");
                                switch (request.r.wValue>>8)
                                {
                                    case USB_DESC_DEVICE: 
                                    {
                                        printf("DEVICE\r\n");
                                        dataToTransfer = DevDes;
                                        dataLength = std::min ((uint16_t) sizeof(DevDes),request.r.wLength);
                                        break;
                                    }
                                    case USB_DESC_CONFIGURATION: 
                                    {
                                        printf("CONFIGURATION\r\n");
                                        dataToTransfer = ConDes;
                                        dataLength = std::min ((uint16_t) sizeof(ConDes),request.r.wLength);
                                        break;
                                    }
                                    case USB_DESC_STRING: 
                                    {
                                        printf("STRING: ");
                                        uint8_t stringIndex = request.r.wValue&0xff;  
                                        switch(stringIndex)
                                        {
                                            case 0: 
                                            {
                                                printf("Language\r\n");
                                                dataToTransfer = LangDes;
                                                dataLength = std::min ((uint16_t) sizeof(LangDes),request.r.wLength);
                                                break;
                                            }
                                            case STRING_DESC_PRODUCT: 
                                            {
                                                printf("Product\r\n");
                                                dataToTransfer = PRODUCER_Des;
                                                dataLength = std::min ((uint16_t) sizeof(PRODUCER_Des),request.r.wLength);
                                                break;
                                            }
                                            case STRING_DESC_MANUFACTURER: 
                                            {
                                                printf("Manufacturer\r\n");
                                                dataToTransfer = MANUFACTURER_Des;
                                                dataLength = std::min ((uint16_t) sizeof(MANUFACTURER_Des),request.r.wLength);
                                                break;
                                            }
                                            case STRING_DESC_SERIAL:
                                            {
                                                printf("Serial\r\n");
                                                dataToTransfer = PRODUCER_SN_Des;
                                                dataLength = std::min ((uint16_t) sizeof(PRODUCER_SN_Des),request.r.wLength);
                                                break;
                                            }
                                            default: 
                                            {
                                                printf("Unknown! (%i)\r\n", stringIndex);
                                                break;
                                            }
                                        }
                                        break;
                                    }
                                }
                                writeDataForEndpoint0();
                                break;                   
                            } 
                            case USB_REQ_GET_CONFIGURATION:
                                printf("USB_REQ_GET_CONFIGURATION\r\n");    
                                dataToTransfer = &usb_configuration_id;
                                dataLength = 1;
                                break;
                            case USB_REQ_GET_INTERFACE:
                                printf("USB_REQ_GET_INTERFACE\r\n");    
                                break;
                            case USB_REQ_GET_STATUS:
                                printf("USB_REQ_GET_STATUS\r\n");    
                                break;
                            default:
                                printf("UNKNOWN IN REQUEST 0x%x\r\n", request.r.bRequest);    
                                break;
                        }
                    }
                    else // OUT
                    {
                        printf(" OUT\r\n");
                        switch(request.r.bRequest)
                        {
                            case USB_REQ_SET_ADDRESS:
                            {  
                                usb_device_address = request.r.wValue;
                                printf("  SET_ADDRESS: %i\r\n", usb_device_address);
                                gettimeofday(&accurtime, NULL);
                                sendEP0ACK ();
                                break;
                            }
                            case USB_REQ_SET_CONFIGURATION:
                            {
                                printf("  USB_REQ_SET_CONFIGURATION %d\r\n",request.r.wValue);  
                                if (request.r.wValue==USB_CONFIGURATION_ID) 
                                    usb_configuration_id = request.r.wValue;
                                sendEP0ACK ();
                                break; 
                            }
                            case USB_REQ_SET_INTERFACE:
                            {
                                printf("  USB_REQ_SET_INTERFACE\r\n");  
                                break; 
                            }
                            case USB_REQ_CLEAR_FEATURE:
                            {
                                printf("  USB_REQ_CLEAR_FEATURE\r\n");  
                                break; 
                            }
                            default:
                                printf("  UNKNOWN OUT REQUEST 0x%x\r\n", request.r.bRequest);    
                                break;
                        }
                    }
                }
                break;
            }
            // control endpoint, handles follow-up on setup packets
            case USB_INT_EP0_IN:
            {
                if (transaction_state!=SETUP && transaction_state!=DATA) {
                    printf ("IN: >> unexpected IN after STATUS <<\r\n");
                    writeCommand (CH375_CMD_UNLOCK_USB);
                    break;
                }
                if (dataLength==0) {
                    transaction_state = STATUS;
                    printf ("IN:STATUS\r\n");
                }
                else {
                    transaction_state = DATA;
                    printf ("IN:DATA\r\n");
                }
            
                switch(request.r.bRequest)
                {
                    case USB_REQ_SET_ADDRESS:
                    {
                        printf("  Setting device address to: %d\r\n",usb_device_address);  
                        // it's time to set the new address
                        set_target_device_address (usb_device_address);
                        break;
                    }
                }
                // write remaining data, or a zero packet to indicate end of transfer
                writeDataForEndpoint0 ();
                writeCommand (CH375_CMD_UNLOCK_USB);
                break;
            }
            case USB_INT_EP0_OUT:
            {
                if (transaction_state!=SETUP && transaction_state!=DATA) {
                    printf ("OUT: >> unexpected OUT after status<<\r\n");
                    sendEP0STALL();
                    writeCommand (CH375_CMD_UNLOCK_USB);
                    break;
                }
                if (dataLength==0) {
                    transaction_state = STATUS;
                    printf ("OUT:STATUS\r\n");
                }
                else {
                    transaction_state = DATA;
                    printf ("OUT:DATA\r\n");
                }

                // save previous request before it's overwritten in the next step
                uint8_t current_request = request.r.bRequest;

                // read data send to us
                length = read_usb_data (request.buffer);

                printf("  Read %i bytes: ", length);
                for(int i=0; i<length; i++) 
                {
                    printf("0x%02X ", request.buffer[i]);
                }
                printf("\r\n");

                // handle data
                dataLength = 0;
                switch(current_request)
                {
                    case SET_LINE_CODING:
                    {
                        printf ("  Copy line encoding parameters \r\n");
                        //memcpy (&uart_parameters,request.buffer,length);
                        sendEP0ACK ();
                        break;
                    }
                    default:
                    {
                        // absorb mode
                        break;
                    }
                }
                break;  
            }
            // interrupt endpoint
            case USB_INT_EP1_IN:
                printf ("EP1 IN");
                writeCommand (CH375_CMD_UNLOCK_USB);
                break;
            case USB_INT_EP1_OUT:
                printf ("EP1 OUT");
                // read data send to us
                length = read_usb_data (request.buffer);
                printf("  Read %i bytes: ", length);
                for(int i=0; i<length; i++) 
                {
                    printf("0x%02X ", request.buffer[i]);
                }
                printf("\r\n");
                break;
            // bulk endpoint
            case USB_INT_EP2_IN:
                // interrupt send after writing to EP2 buffer 
                // when we do nothing data does get send
                writeCommand (CH375_CMD_UNLOCK_USB);
                break;
            case USB_INT_EP2_OUT:
                length = read_usb_data ((uint8_t*)characterBuffer);
                characterBuffer[length]='\0';
                printf("  Read %i bytes: ", length);
                for(int i=0; i<length; i++) 
                {
                    printf("0x%02X ", characterBuffer[i]);
                }
                printf("\r\n");

                // write back (echo)
                strupr (characterBuffer);
                // write characterbuffer to EP2
                length = strlen (characterBuffer);
                writeCommand (CH_CMD_WR_EP2);
                writeData (length);
                for (int i=0; i<length; i++)
                {
                    writeData (characterBuffer[i]);
                }
                break;
            default:
                writeCommand (CH375_CMD_UNLOCK_USB);
                break;
        }
    }

    return 0;
}