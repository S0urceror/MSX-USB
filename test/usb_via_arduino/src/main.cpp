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

#define BOOT_PROTOCOL 0
#define HID_CLASS 0x03
#define HID_BOOT 0x01
#define HID_KEYBOARD 0x01
#define HID_MOUSE 0x02

int serial=-1;

#define CH376_CMD_GET_IC_VER 0x01
#define CH375_CMD_SET_USB_SPEED 0x04
#define CH375_CMD_RESET_ALL 0x05
#define CH375_CMD_CHECK_EXIST 0x06
#define CH375_CMD_SET_USB_MODE 0x15
#define CH375_CMD_GET_STATUS 0x22
#define CH375_CMD_SET_USB_ADDR 0x13
#define CH375_CMD_SET_ENDP6 0x1C
#define CH375_CMD_SET_ENDP7 0x1D
#define CH376_CMD_DIRTY_BUFFER 0x25
#define CH375_CMD_RD_USB_DATA 0x27
//#define CH375_CMD_RD_USB_DATA 0x28
//#define CH375_CMD_WR_USB_DATA7 0x2B
#define CH375_CMD_WR_HOST_DATA 0x2C
#define CH376_CMD_SET_FILE_NAME 0x2F
#define CH376_CMD_DISK_CONNECT 0x30
#define CH376_CMD_DISK_MOUNT 0x31
#define CH376_CMD_OPEN_FILE 0x32
#define CH376_CMD_FILE_CLOSE 0x36

#define CH376_CMD_CLR_STALL 0x41
#define CH375_CMD_SET_ADDRESS 0x45
#define CH375_CMD_GET_DESCR 0x46
#define CH375_CMD_SET_CONFIG 0x49
#define CH375_CMD_ISSUE_TOKEN 0x4F
#define CH375_CMD_ISSUE_TKN_X 0x4E
#define CH375_CMD_ABORT_NAK 0x17
#define CH376_CMD_SET_RETRY 0x0B
#define CH376_CMD_SET_SD0_INT 0x0B
#define CH375_CMD_DIRTY_BUFFER 0x25

#define CH375_USB_MODE_HOST 0x06
#define CH375_USB_MODE_HOST_RESET 0x07

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

#define CH375_USB_ERR_OPEN_DIR 0x41

//--- PIDs
#define CH_PID_SETUP 0x0D
#define CH_PID_IN  0x09
#define CH_PID_OUT 0x01

uint8_t device_counter=1;

typedef struct __attribute__((packed)) _USB_DEVICE_DESCRIPTOR {
     uint8_t bLength;
     uint8_t bDescriptorType;
     uint16_t bcdUSB;
     uint8_t bDeviceClass;
     uint8_t bDeviceSubClass;
     uint8_t bDeviceProtocol;
     uint8_t bMaxPacketSize0;
     uint16_t idVendor;
     uint16_t idProduct;
     uint16_t bcdDevice;
     uint8_t iManufacturer;
     uint8_t iProduct;
     uint8_t iSerial;
     uint8_t bNumConfigurations;
} USB_DEVICE_DESCRIPTOR;
USB_DEVICE_DESCRIPTOR device;

 typedef struct __attribute__((packed)) _USB_CONFIG_DESCRIPTOR {
     uint8_t bLength;
     uint8_t bDescriptorType;
     uint16_t wTotalLength;
     uint8_t bNumInterfaces;
     uint8_t bConfigurationvalue;
     uint8_t iConfiguration;
     uint8_t bmAttributes;
     uint8_t bMaxPower;
 } USB_CONFIG_DESCRIPTOR;

typedef struct __attribute__((packed)) _USB_HID_DESCRIPTOR {
    uint8_t bLength;
    uint8_t bDescriptorType;
    uint16_t hid_version;
    uint8_t country_code;
    uint8_t num_descriptors;
    uint8_t descriptor_type;
    uint16_t descriptor_length;
} USB_HID_DESCRIPTOR;

 typedef struct __attribute__((packed)) _USB_INTERF_DESCRIPTOR {
     uint8_t bLength;
     uint8_t bDescriptorType;
     uint8_t bInterfaceNumber;
     uint8_t bAlternateSetting;
     uint8_t bNumEndpoints;
     uint8_t bInterfaceClass;
     uint8_t bInterfaceSubClass;
     uint8_t bInterfaceProtocol;
     uint8_t iInterface;
 } USB_INTERF_DESCRIPTOR;

 typedef struct __attribute__((packed)) _USB_ENDPOINT_DESCRIPTOR {
     uint8_t bLength;
     uint8_t bDescriptorType;
     uint8_t bEndpointAddress;
     uint8_t bmAttributes;
     uint16_t wMaxPacketSize;
     uint8_t bInterval;
 } USB_ENDPOINT_DESCRIPTOR;

typedef struct __attribute__((packed)) _USB_ETHERNET_DESCRIPTOR {
     uint8_t bLength;
     uint8_t bDescriptorType;
     uint8_t bDescriptorSubType;
     uint8_t iMACAddress;
     uint32_t bmEthernetStatistics;
     uint16_t wMaxSegmentSize;
     uint16_t wNumberMCFilters;
     uint8_t bNumberPowerFilters;
 } USB_ETHERNET_DESCRIPTOR;

typedef struct __attribute__((packed)) _USB_ETHERNET_HEADER_DESCRIPTOR {
     uint8_t bLength;
     uint8_t bDescriptorType;
     uint8_t bDescriptorSubType;
     uint16_t bcdCDC;
 } USB_ETHERNET_HEADER_DESCRIPTOR;

typedef struct __attribute__((packed)) _USB_ETHERNET_UNION_DESCRIPTOR {
     uint8_t bLength;
     uint8_t bDescriptorType;
     uint8_t bDescriptorSubType;
     uint8_t bControlInterface;
     uint8_t bSubordinateInterface0;
     uint8_t bSubordinateInterface1;
     uint8_t bSubordinateInterface2;
     uint8_t bSubordinateInterface3;
 } USB_ETHERNET_UNION_DESCRIPTOR;

typedef struct __attribute__((packed)) _USB_HUB_DESCRIPTOR 
{
     uint8_t bLength;
     uint8_t bDescriptorType;
     uint8_t bNrPorts;
     uint16_t wHubCharacteristics;
     uint8_t bPwrOn2PwrGood;
     uint8_t bHubContrCurrent;
     uint8_t DeviceRemovable;
     uint8_t PortPwrCtrlMask;
} USB_HUB_DESCRIPTOR;

struct _hid_info 
{
    uint8_t mouse_endpoint,mouse_millis,mouse_interface=255;
    uint16_t mouse_packetsize;
    uint8_t keyboard_endpoint,keyboard_millis,keyboard_interface=255;
    uint16_t keyboard_packetsize;
    uint8_t configuration_id=0;
    uint8_t device_address;
}* hid_info=NULL;
struct _ethernet_info 
{
    uint8_t ethernet_data_interface=255,ethernet_control_interface=255;
    uint8_t ethernet_interrupt_endpoint,ethernet_bulk_in_endpoint,ethernet_bulk_out_endpoint;
    uint8_t ethernet_interrupt_millis;
    uint16_t ethernet_interrupt_packetsize,ethernet_bulk_in_packetsize,ethernet_bulk_out_packetsize;
    uint8_t configuration_id=0;
    uint8_t ethernet_alternate_setting;
    uint8_t device_address;
}* ethernet_info=NULL;
struct _hub_info
{
    uint8_t hub_interface=255;
    uint8_t configuration_id=0;
    uint8_t hub_interrupt_endpoint;
    uint16_t hub_interrupt_packetsize;
    uint8_t hub_interrupt_millis;
    uint8_t device_address;
}* hub_info=NULL;
struct _storage_info
{
    uint8_t interface_id=255;
    uint8_t configuration_id=0;
    uint8_t bulk_in_endpoint_id=0;
    uint8_t bulk_in_packetsize;
    uint8_t bulk_out_endpoint_id=0;
    uint8_t bulk_out_packetsize;
    uint8_t device_address;
}* storage_info=NULL;
typedef struct __attribute__((packed)) _command_block_wrapper 
{
    uint32_t dCBWSignature = 0x43425355;
    uint32_t dCBWTag = 1;
    uint32_t dCBWDataTransferLength;
    uint8_t bmCBWFlags;
    uint8_t bCBWLUN;
    uint8_t bCBWCBLength;
    uint8_t data [16];
} command_block_wrapper;
typedef struct __attribute__((packed)) _command_status_wrapper 
{
    uint32_t dCBWSignature;
    uint32_t dCBWTag;
    uint32_t dCSWDataResidue;
    uint8_t bCSWStatus;
} command_status_wrapper;
typedef struct __attribute__((packed)) _scsi_inquiry
{
    uint8_t bOperationCode = 0x12;
    uint8_t bLUN=0;
    uint8_t bReserved1=0;
    uint8_t bReserved2=0;
    uint8_t bAllocationLength = 0x24;
    uint8_t bReserved3=0;
    uint8_t pad [6] = {0,0,0,0,0,0};
} scsi_inquiry;
typedef struct __attribute__((packed)) _scsi_read10
{
    uint8_t bOperationCode = 0x28;
    uint8_t bLUN=0;
    uint32_t dLBA=0;
    uint8_t bReserved1=0;
    uint16_t wTransferLength=0;
    uint8_t bReserved2=0;
    uint8_t pad [2]={0,0};
} scsi_read10;
typedef struct __attribute__((packed)) _scsi_request_sense
{
    uint8_t bOperationCode = 0x03;
    uint8_t bLUN=0;
    uint8_t bReserved1=0;
    uint8_t bReserved2=0;
    uint8_t bAllocationLength = 18;
    uint8_t bReserved3=0;
    uint8_t pad [6] = {0,0,0,0,0,0};
} scsi_request_sense;
typedef struct __attribute__((packed)) _scsi_test_unit_ready
{
    uint8_t bOperationCode = 0x00;
    uint8_t bLUN=0;
    uint8_t bReserved1=0;
    uint8_t bReserved2=0;
    uint8_t bReserved3=0;
    uint8_t bReserved4=0;
    uint8_t pad[6] = {0,0,0,0,0,0};
} scsi_test_unit_ready;
typedef struct __attribute__((packed)) _scsi_mode_sense
{
    uint8_t bOperationCode = 0x5a;
    uint8_t bLUN=0;
    uint8_t bPageCode=0;
    uint8_t bSubpageCode=0;
    uint8_t bReserved1=0;
    uint8_t bReserved2=0;
    uint8_t bReserved3=0;
    uint16_t wAllocationLength=0;
    uint8_t pad[3] = {0,0,0};
} scsi_mode_sense;
typedef struct __attribute__((packed)) _scsi_capacity
{
    uint8_t bOperationCode = 0x25;
    uint8_t bLUN=0;
    uint8_t pad[10] = {0,0,0,0,0,0,0,0,0,0};
} scsi_capacity;

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
     
    config.c_cc[VTIME]    = 5;   /* inter-character timer unused */
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
const uint8_t RD_DATA_MULTIPLE = 6;
const uint8_t WR_DATA_MULTIPLE = 7;
const uint8_t END_COMMAND = 8;
const uint8_t DATA_DUMP = 10;

void testspeed ()
{
    uint8_t new_value[512];
    uint8_t cmd = DATA_DUMP;
    int i;
    write (serial, &cmd, 1);

    auto t1 = std::chrono::high_resolution_clock::now();
    for (i=0;i<10*512;i++) {
        int bytes = read (serial,new_value,1);
        if (bytes!=1)
            error ("Serial max speed test did not receive all expected bytes");
    }
    auto t2 = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::microseconds>( t2 - t1 ).count();
    std::cout << "Serial max read speed: " << i / (duration/1000000.0) << " bytes/second" << std::endl;
}

void writeCommand (uint8_t command)
{
    uint8_t cmd[] = {WR_COMMAND,command};
    write (serial,cmd,sizeof(cmd));
}
void endCommand ()
{
    uint8_t cmd[] = {END_COMMAND};
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
    //for (int i=0;i<len;i++)
    //    writeData (buffer[i]);
    //writeData (0);
}
ssize_t readData (uint8_t* new_value)
{
    writeData (0);

    uint8_t cmd[] = {RD_DATA};
    write (serial,cmd,sizeof(cmd));
    return read (serial,new_value,1);
}
ssize_t readDataMultiple (uint8_t* buffer,uint8_t len)
{
    int i;
    uint8_t cmd[] = {RD_DATA_MULTIPLE,len};
    write (serial,cmd,sizeof(cmd));
    uint8_t bytes = read (serial,buffer,len);
    assert (bytes==len);
    return bytes;
    //for (i=0;i<len;i++)
    //{
    //    uint8_t value;
    //    uint8_t bytes = readData (&value);
    //    if (bytes==0)
    //        break;
    //    *(buffer+i)=value;
    //}
    //return i;
}
ssize_t readStatus (uint8_t* new_value)
{
    uint8_t cmd[] = {RD_STATUS};
    write (serial,cmd,sizeof(cmd));
    return read (serial,new_value,1);
}

// CHECK STATUS
///////////////////////////////////////////////////////////////////////////
uint8_t waitStatus ()
{
    uint8_t status,interrupt;
    int i=0;
    ssize_t bytes;
    int counter = 1000;
    while ((bytes=readStatus(&interrupt)) && counter>0)
    {
        if ((interrupt&0x80)==0)
            break;
        usleep (1000);
        counter --;
    }
    if (counter<=0)
        error ("timeout waitStatus");
    //if (counter<=0)
    //    printf ("timeout waitStatus\n");
    writeCommand(CH375_CMD_GET_STATUS);
    bytes = readData (&status);
    endCommand();
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
    endCommand();
    value = value ^ 255;
    if (bytes!=1 || (new_value != value))
        error ("Device does not exist\n");
}

// CH376 built-in commands
///////////////////////////////////////////////////////////////////////////
void abort_nak ()
{
    writeCommand (CH375_CMD_ABORT_NAK);
    endCommand();
}

void reset_all ()
{
    writeCommand (CH375_CMD_RESET_ALL);
    endCommand();
    usleep (100000);

    // interrupt via MISO
    writeCommand (CH376_CMD_SET_SD0_INT);
    writeData (0x16);
    writeData (0x90);
    endCommand ();
}
void set_target_device_address (uint8_t address)
{
    writeCommand (CH375_CMD_SET_USB_ADDR);
    writeData(address);
    endCommand();
    usleep (2000);
}

bool set_usb_host_mode (uint8_t mode)
{
    writeCommand(CH375_CMD_SET_USB_MODE);
    writeData(mode);
    uint8_t value;
    for(int i=0; i!=200; i++ )
    {
        usleep(20);
        readData(&value);
        if ( value == CH375_CMD_RET_SUCCESS ) {
            endCommand();
            return true;
        }
    }
    endCommand();
    return false;
}

//Bits 7 and 6:
//  0x: Don't retry NAKs
//  10: Retry NAKs indefinitely (default)
//  11: Retry NAKs for 3s
//Bits 5-0: Number of retries after device timeout
//Default after reset and SET_USB_MODE is 8Fh
void set_retry (uint8_t mode)
{
    writeCommand (CH376_CMD_SET_RETRY);
    writeData (0x25); // fixed value, required
    writeData (mode);
    endCommand();
}
void set_speed (uint8_t speed)
{
    writeCommand (CH375_CMD_SET_USB_SPEED);
    writeData(speed);
    endCommand();
}
void set_address (uint8_t address)
{
     writeCommand (CH375_CMD_SET_ADDRESS);
     writeData(address);
     endCommand();
     if (waitStatus ()!=CH375_USB_INT_SUCCESS)
         error ("ERROR: address not set\n");
}
void set_configuration (uint8_t configuration)
{
     writeCommand(CH375_CMD_SET_CONFIG);
     writeData(configuration);
     endCommand();
     if (waitStatus ()!=CH375_USB_INT_SUCCESS)
         error ("ERROR: configuration not set\n");
}
bool get_device_descriptor ()
{
    uint8_t value;
    ssize_t bytes;
    
    writeCommand(CH375_CMD_GET_DESCR);
    writeData(CH375_USB_DEVICE_DESCRIPTOR);
    endCommand();
    if (waitStatus ()!=CH375_USB_INT_SUCCESS)
        error ("ERROR: USB device descriptor not read 1\n");
    writeCommand(CH375_CMD_RD_USB_DATA);
    // read length of return package
    value = 0;
    bytes = readData(&value);
    if (bytes==1 && value == sizeof (USB_DEVICE_DESCRIPTOR))
    {
        bytes = readDataMultiple ((uint8_t*)&device,sizeof (USB_DEVICE_DESCRIPTOR));
        if (bytes!=value)
            error ("ERROR: USB device descriptor not read 2\n");
    }
    else
        error ("ERROR: USB device descriptor not read 3\n");
    endCommand();
    return true;
}

// Higher level USB read/write
///////////////////////////////////////////////////////////////////////////
void write_usb_data (uint8_t* message,uint8_t length)
{
    writeCommand (CH375_CMD_WR_HOST_DATA);
    writeData(length);
    for (int i=0;i<length;i++)
        writeData(message[i]);
    endCommand();
}
void issue_token (uint8_t endpoint_number, uint8_t pid, uint8_t in_toggle, uint8_t out_toggle)
{
    writeCommand(CH375_CMD_ISSUE_TKN_X);
    writeData(in_toggle<<7 | out_toggle<<6);
    writeData(((endpoint_number&0x0f) << 4) | pid);
    endCommand();
}
ssize_t read_usb_data (uint8_t* pBuffer)
{
    uint8_t value = 0;
    writeCommand(CH375_CMD_RD_USB_DATA);
    ssize_t bytes = readData(&value);
    if (bytes==0)
        error ("no data available");
    if (value==0) {
        endCommand();
        return 0;
    }
    bytes = readDataMultiple(pBuffer, value);
    endCommand();
    if (bytes<value)
        error("did not receive enough bytes");
    return bytes;
}

// USB data packet input
///////////////////////////////////////////////////////////////////////////
uint16_t get_endpoint_status (uint8_t target_device_address,uint8_t endpoint_id);

int data_in_transfer (uint16_t length, uint8_t target_device_address, uint8_t endpoint_number, uint8_t endpoint_packetsize, uint8_t& endpoint_toggle,uint8_t* &result)
{
    uint16_t remaining_data_length = length;
    result = (uint8_t*) malloc (length);
    bzero(result, length);
    uint8_t* pTemp = result;
    uint8_t status;
    int bytes_read=0;
    
    set_target_device_address(target_device_address);
    
    while (remaining_data_length>0)
    {
        issue_token(endpoint_number, CH_PID_IN, endpoint_toggle, 0);
        endpoint_toggle = endpoint_toggle ^ 1;
        if ((status=waitStatus())!=CH375_USB_INT_SUCCESS)
        {
            if ((status&0x2f)==0b00101010) // 2A
            {
                printf (">> NAK <<\n");
                free (result);
                result = NULL;
                return 0;
            }
            if ((status&0x2f)==0b00101110) // 2E
            {
                printf (">> STALL <<\n");
                free (result);
                result = NULL;
                return 0;
            }
            if ((status&0x23)==0b00100000) // 20
            {
                printf (">> OVER TIME <<\n");
                free (result);
                result = NULL;
                return 0;
            }
            printf (">> UNEXPECTED 0x%x <<\n",status);
            endpoint_toggle = endpoint_toggle ^ 1; // extra toggle, maybe out of sync?
        }; 
        bytes_read = read_usb_data (pTemp);
        remaining_data_length -= bytes_read;
        pTemp += bytes_read;
        
        if (bytes_read<endpoint_packetsize)
            break;
    }
    return length-remaining_data_length;
}

// USB data packet output
///////////////////////////////////////////////////////////////////////////
void data_out_transfer (uint8_t* pBuffer,uint16_t length, uint8_t target_device_address, uint8_t endpoint_number, uint8_t endpoint_packetsize, uint8_t& endpoint_toggle)
{
    uint8_t* pTemp = pBuffer;
    uint16_t remaining_data_length = length;
    set_target_device_address(target_device_address);
    
    while (remaining_data_length>0)
    {
        int amountwritten=endpoint_packetsize<remaining_data_length?endpoint_packetsize:remaining_data_length;
        write_usb_data(pTemp, amountwritten);
        pTemp+=amountwritten;
        remaining_data_length-=amountwritten;
        
        issue_token(endpoint_number, CH_PID_OUT, 0, endpoint_toggle);
        endpoint_toggle = endpoint_toggle ^ 1;

        while ((waitStatus()&0x2f)==0x2a); // absorb NAK
    }
}

#define IN 1
#define OUT 0
// USB command execution via SETUP, DATA, STATUS stages
///////////////////////////////////////////////////////////////////////////
bool execute_control_transfer (uint8_t target_device_address,uint8_t message[8],uint8_t* senddata, uint8_t endpoint_packet_size,uint8_t endpoint,uint8_t* &result)
{
    uint16_t requested_length = (*(message + 6))+((*(message +7))<<8);
    uint8_t data_direction = message[0]&0b10000000?IN:OUT;

    //print_buffer (message,8);
    set_target_device_address(target_device_address);
    
    //Setup stage
    write_usb_data (message,8);
    //uint8_t endpoint = 0;
    issue_token (endpoint, CH_PID_SETUP,0,0);
    uint8_t interrupt = waitStatus();
    if (interrupt != CH375_USB_INT_SUCCESS)
        return false;//error ("execute_control_transfer 0");
    
    //Data stage
    uint8_t endpoint_toggle = 1;
    if (data_direction==IN)
    {
        int bytes_read = data_in_transfer(requested_length, target_device_address, 0, endpoint_packet_size, endpoint_toggle,result);
        if (result==NULL)
            return false;
    }
    else
        data_out_transfer (senddata,requested_length, target_device_address, 0, endpoint_packet_size, endpoint_toggle);
    
    // Status stage
    if (data_direction==OUT || requested_length==0)
    {
        issue_token(endpoint, CH_PID_IN, 1, 0);
        while ((waitStatus()&0x2f)==0x2a); // absorb NAK
        uint8_t tmp[endpoint_packet_size];
        bzero (tmp,endpoint_packet_size);
        ssize_t bytes = read_usb_data((uint8_t*)&tmp);
        //print_buffer (tmp,endpoint_packet_size);
    }
    else
    {
        issue_token(endpoint, CH_PID_OUT, 0, 1);
        uint8_t interrupt;
        while (true)
        {
            interrupt = waitStatus();
            if ((interrupt&0x2f)==0x2a) // absorb NAK
                continue;
            if ((interrupt&0x2f)==0x2e) // absorb STALL
                interrupt = CH375_USB_INT_SUCCESS;
            break;
        };
        if (interrupt!=CH375_USB_INT_SUCCESS)
            return false;//error ("ERROR: execute_control_transfer 2");
    }
    return true;
}

// DESCRIPTOR commands
///////////////////////////////////////////////////////////////////////////
uint8_t max_packet_size;
bool get_device_status (uint8_t target_device_address,uint16_t* buffer)
{
    uint8_t cmd[] = {0x80,0,0,0,0,0,2,0};
    uint8_t* data=NULL;
    max_packet_size = 8;

    bool result = execute_control_transfer(target_device_address,cmd,NULL,max_packet_size,0,data);
    if (result)
    {
        if (data[0]&0x1)
            printf ("Device is self-powered\n");
        if (data[0]&0x2)
            printf ("Device supports remote wake-up\n");
        memcpy (buffer,data,2);
    }
    free(data);
    return result;
}
bool get_device_descriptor2 (uint8_t target_device_address,uint8_t* buffer, int& buffer_length)
{
    uint8_t cmd[] = {0x80,6,0,1,0,0,18,0};
    uint8_t* data=NULL;
    max_packet_size = 8;

    bool result = execute_control_transfer(target_device_address,cmd,NULL,max_packet_size,0,data);
    if (result)
    {
        print_buffer (data,*(data));
        memcpy(buffer, data, *(data));
        memcpy(&device, data, *(data));
        buffer_length=*(data);
        max_packet_size = device.bMaxPacketSize0;
    }
    free(data);
    return result;
}
bool get_configuration_descriptor2 (uint8_t target_device_address,uint8_t config_id,uint8_t* buffer,int &buffer_length)
{
    uint8_t cmd[] = {0x80,6,config_id,2,0,0,sizeof(USB_CONFIG_DESCRIPTOR),0};
    uint8_t* data=NULL;
    bool result2 = false;
    bool result = execute_control_transfer(target_device_address,cmd,NULL,max_packet_size,0,data);
    if (result)
    {
        USB_CONFIG_DESCRIPTOR* config = (USB_CONFIG_DESCRIPTOR*) data;
        uint8_t cmd2[] = {0x80,6,config_id,2,0,0,(uint8_t)config->wTotalLength,0};
        uint8_t* data2=NULL;
        result2 = execute_control_transfer(target_device_address,cmd2,NULL,max_packet_size,0,data2);
        if (result2)
        {
            memcpy (buffer, data2,config->wTotalLength);
            buffer_length += config->wTotalLength;
            print_buffer (data2,config->wTotalLength);
        }
        free (data2);
    }
    free (data);
    return result && result2;
}

std::string utf16_to_utf8(std::u16string const& s)
{
    std::wstring_convert<std::codecvt_utf8_utf16<char16_t, 0x10ffff>, char16_t> cnv;
    std::string utf8 = cnv.to_bytes(s);
    if(cnv.converted() < s.size())
        throw std::runtime_error("incomplete conversion");
    return utf8;
}

const char no_data[] = "{no data}";
std::string get_string2 (uint8_t target_device_address,uint8_t string_id)
{
    if (string_id==0)
        return no_data;
    
    uint8_t cmd[] = {0x80,6,string_id,3,0,0,255,0};
    uint8_t* data=NULL;
    std::string str8;
    bool result = execute_control_transfer(target_device_address,cmd,NULL,max_packet_size,0,data);
    if (result)
    {
        uint8_t len = data[0];
        uint8_t type = data[1];
        std::u16string str = (char16_t*) (data+2);
        str8 = utf16_to_utf8(str);
    }
    free (data);
    return str8;
}

// USB HID COMMANDS
///////////////////////////////////////////////////////////////////////////
bool set_protocol2 (uint8_t target_device_address,uint8_t protocol_id,uint8_t interface)
{
    uint8_t cmd[] = {0x21,0x0B,protocol_id,0,interface,0,0,0};
    uint8_t* data=NULL;
    bool result = execute_control_transfer(target_device_address,cmd,NULL,max_packet_size,0,data);
    free (data);
    return result;
}
bool set_idle2 (uint8_t target_device_address,uint8_t duration,uint8_t report_id, uint8_t interface)
{
    uint8_t cmd[] = {0x21,0x0A,report_id,duration,interface,0,0,0};
    uint8_t* data=NULL;
    bool result = execute_control_transfer(target_device_address,cmd,NULL,max_packet_size,0,data);
    free (data);
    return result;
}

// USB STORAGE COMMANDS
///////////////////////////////////////////////////////////////////////////
uint8_t get_max_luns (uint8_t target_device_address,uint8_t interface)
{
    uint8_t nr_luns = 0;
    uint8_t cmd[] = {0b10100001,0b11111110,0,0,interface,0,1,0};
    uint8_t* data=NULL;
    bool result = execute_control_transfer(target_device_address,cmd,NULL,max_packet_size,0,data);
    if (result)
        nr_luns = *data;
    free (data);
    return nr_luns;
}
bool bulkonly_mass_storage_reset (uint8_t target_device_address,uint8_t interface)
{
    uint8_t cmd[] = {0b00100001,0b11111111,0,0,interface,0,0,0};
    uint8_t* data=NULL;
    bool result = execute_control_transfer(target_device_address,cmd,NULL,max_packet_size,0,data);
    free (data);
    return result;
}

// USB COMMANDS
///////////////////////////////////////////////////////////////////////////
bool set_address2 (uint8_t target_device_address)
{
    uint8_t cmd[] = {0x00,0x05,target_device_address,0,0,0,0,0};
    uint8_t* data=NULL;
    bool result = execute_control_transfer(0,cmd,NULL,max_packet_size,0,data);
    free (data);
    return result;
}
bool set_configuration2 (uint8_t target_device_address,uint8_t configuration_id)
{
    uint8_t cmd[] = {0x00,0x09,configuration_id,0,0,0,0,0};
    uint8_t* data=NULL;
    bool result = execute_control_transfer(target_device_address,cmd,NULL,max_packet_size,0,data);
    free (data);
    return result;
}
bool set_interface2 (uint8_t target_device_address,uint8_t interface_id,uint8_t alternative_setting)
{
    uint8_t cmd[] = {0x01,11,alternative_setting,0,interface_id,0,0,0};
    uint8_t* data=NULL;
    bool result = execute_control_transfer(target_device_address,cmd,NULL,max_packet_size,0,data);
    free (data);
    return result;
}
bool clear_endpoint_feature2 (uint8_t target_device_address,uint8_t endpoint_id)
{
    uint8_t cmd[] = {0b00000010,1,0,0,endpoint_id,0,0,0};
    uint8_t* data=NULL;
    bool result = execute_control_transfer(target_device_address,cmd,NULL,max_packet_size,0,data);
    free (data);
    return result;
}
bool set_endpoint_feature2 (uint8_t target_device_address,uint8_t endpoint_id)
{
    uint8_t cmd[] = {0b00000010,3,0,0,endpoint_id,0,0,0};
    uint8_t* data=NULL;
    bool result = execute_control_transfer(target_device_address,cmd,NULL,max_packet_size,0,data);
    free (data);
    return result;
}
uint16_t get_endpoint_status (uint8_t target_device_address,uint8_t endpoint_id)
{
    uint16_t status = 0;
    uint8_t cmd[] = {0b10000010,0,0,0,endpoint_id,0,2,0};
    uint8_t* data=NULL;
    bool result = execute_control_transfer(target_device_address,cmd,NULL,max_packet_size,0,data);
    if (result)
        status = *data;
    free (data);
    return status;
}
bool set_packet_filter2 (uint8_t target_device_address,uint8_t interface_id,uint8_t packet_filter)
{
    uint8_t cmd[] = {0b00100001,0x43,packet_filter,0,interface_id,0,0,0}; // set ethernet packet filter
    uint8_t* data=NULL;
    bool result = execute_control_transfer(target_device_address,cmd,NULL,max_packet_size,0,data);
    free (data);
    return result;
}

///////////////////////////////////////////////////////////////////////////
// USB HUB commands
bool get_hub_descriptor2 (uint8_t target_device_address,uint8_t* buffer, int& buffer_length)
{
    //bmRequestType, bRequest, wValue, wIndex, wLength
    uint8_t cmd[] = {0b10100000,6,0,0x29,0,0,sizeof(USB_HUB_DESCRIPTOR),0};
    uint8_t* data=NULL;
    bool result = execute_control_transfer(target_device_address,cmd,NULL,max_packet_size,0,data);
    if (result)
    {
        print_buffer (data,*(data));
        memcpy(buffer, data, *(data));
        buffer_length+=*(data);
    }
    free(data);
    return result;
}
uint32_t get_hub_portstatus (uint8_t target_device_address,uint8_t portnr)
{
    //bmRequestType, bRequest, wValue, wIndex, wLength
    uint8_t cmd[] = {0b10100011,0,0,0,portnr,0,4,0};
    uint8_t* data=NULL;
    bool result = execute_control_transfer(target_device_address,cmd,NULL,max_packet_size,0,data);
    uint32_t retval = 0;
    if (result)
    {
        //print_buffer (data,4);
        memcpy (&retval,data,4);

        uint16_t portstatus = 0;
        memcpy (&portstatus,data,2);
        printf ("Port %d status: ",portnr);
        std::string status="";
        if (portstatus & 0b1)
            status += "connected,";
        if (portstatus & 0b10)
            status += "enabled,";
        if (portstatus & 0b100)
            status += "suspended,";
        if (portstatus & 0b1000)
            status += "reset,";
        if (portstatus & 0b100000000)
            status += "powered,";
        if (portstatus & 0b1000000000)
            status += "low-speed,";
        if (portstatus & 0b10000000000)
            status += "high-speed,";
        if (portstatus & 0b1000000000000)
            status += "indicator control";
        printf ("%s\n",status.c_str());

        uint16_t portchange = 0;
        memcpy (&portchange,data+2,2);
        printf ("Port %d change: ",portnr);
        status="";
        if (portchange & 0b1)
            status += "C_PORT_CONNECTION,";
        if (portchange & 0b10)
            status += "C_PORT_ENABLE,";
        if (portchange & 0b100)
            status += "C_PORT_SUSPEND,";
        if (portchange & 0b1000)
            status += "C_PORT_OVER_CURRENT,";
        if (portchange & 0b10000)
            status += "C_PORT_RESET,";
        printf ("%s\n",status.c_str());

    }
    free(data);
    return retval;
}
bool set_hub_port_feature2 (uint8_t target_device_address,uint8_t feature_selector,uint8_t port,uint8_t value)
{
    //bmRequestType, bRequest, wValue, wIndex, wLength
    uint8_t cmd[] = {0b00100011,0x03,feature_selector,0,port,value,0,0};
    uint8_t* data=NULL;
    bool result = execute_control_transfer(target_device_address,cmd,NULL,max_packet_size,0,data);
    free (data);
    return result;
}
bool clear_hub_port_feature2 (uint8_t target_device_address,uint8_t feature_selector,uint8_t port,uint8_t value)
{
    //bmRequestType, bRequest, wValue, wIndex, wLength
    uint8_t cmd[] = {0b00100011,0x01,feature_selector,0,port,value,0,0};
    uint8_t* data=NULL;
    bool result = execute_control_transfer(target_device_address,cmd,NULL,max_packet_size,0,data);
    free (data);
    return result;
}
///////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////
// USB HID BOOT DEVICE INTERRUPT READOUT
bool read_boot_mouse (uint8_t target_device_address,uint8_t mouse_endpoint_id,uint8_t mouse_millis,uint16_t mouse_in_packetsize)
{
    uint8_t endpoint_toggle = 0;
    while (true)
    {
        uint8_t* buffer=NULL;
        int bytes_read = data_in_transfer(mouse_in_packetsize, target_device_address,mouse_endpoint_id, max_packet_size, endpoint_toggle,buffer);
        if (bytes_read==0 || buffer==NULL)
            return false;
        uint8_t buttonstate = buffer[0];
        uint8_t x = buffer[1];
        uint8_t y = buffer[2];
        printf ("left: %d, right: %d, middle: %d - X: %d, Y: %d\n",buttonstate&0x01,buttonstate&0x02,buttonstate&0x04,x,y);
        free (buffer);
        std::this_thread::sleep_for(std::chrono::milliseconds(mouse_millis));
        if (buttonstate&0x02) //right button
            return false;
    }
    return true;
}
bool read_boot_keyboard (uint8_t target_device_address,uint8_t endpoint_id,uint8_t millis,uint16_t in_packetsize)
{
    uint8_t endpoint_toggle = 0;
    int count=5;
    while (count--)
    {
        uint8_t* buffer = NULL;
        int bytes_read = data_in_transfer(in_packetsize, target_device_address,endpoint_id, max_packet_size, endpoint_toggle,buffer);
        if (bytes_read==0 || buffer==NULL)
            return false;
        uint8_t modifier_keys = buffer[0];
        uint8_t reserved = buffer[1];
        uint8_t keycode1 = buffer[2];
        uint8_t keycode2 = buffer[3];
        uint8_t keycode3 = buffer[4];
        uint8_t keycode4 = buffer[5];
        uint8_t keycode5 = buffer[6];
        uint8_t keycode6 = buffer[7];
        printf ("modifier_keys: %02X, keycode1:%02X, keycode2:%02X, keycode3:%02X, keycode4:%02X, keycode5:%02X, keycode6:%02X\n",modifier_keys,keycode1,keycode2,keycode3,keycode4,keycode5,keycode6);
        free (buffer);
        std::this_thread::sleep_for(std::chrono::milliseconds(millis));
        if (keycode1==0x14) // Q for quit
            return false;
    }
    return true;
}
///////////////////////////////////////////////////////////////////////////
// USB ETHERNET DEVICE INTERRUPT READOUT
bool check_network_connection (uint8_t target_device_address,uint8_t endpoint_id,uint8_t millis,uint16_t in_packetsize)
{
    uint8_t endpoint_toggle = 0;
    int count = 500;
    bool result = false;

    struct _ecm_notification_event
    {
        uint8_t bmRequestType;
        uint8_t bNotificationCode;
        uint16_t wValue;
        uint16_t wIndex;
        uint16_t wLength;
    } ecm_notification_event;
    while (--count > 0 && !result)
    {
        uint8_t* buffer = NULL; 
        int bytes_read = data_in_transfer(in_packetsize, target_device_address,endpoint_id, max_packet_size, endpoint_toggle,buffer);
        if (bytes_read==0 || buffer==NULL)
            return false;
        memcpy (&ecm_notification_event,buffer,sizeof (_ecm_notification_event));
        //print_buffer (buffer,in_packetsize);
        if (ecm_notification_event.bmRequestType == 0b10100001) // device to host, class, endpoint communication
        {
            switch (ecm_notification_event.bNotificationCode)
            {
                case 0x00: // NETWORK_CONNECTION
                    //if (ecm_notification_event.wValue==0)
                    //    printf ("network cable DISCONNECTED on interface %d\n",*(buffer+4));
                    if (ecm_notification_event.wValue==1)
                        result = true;
                    //    printf ("network cable CONNECTED on interface %d\n",*(buffer+4));
                    break;
                case 0x01: // RESPONSE_AVAILABLE
                    //printf ("response available on interface %d\n",*(buffer+4));
                    break;
                case 0x2A: // CONNECTION_SPEED_CHANGE
                    //long speed_down = *(buffer+8) + *(buffer+9)*256+ *(buffer+10)*65536 + *(buffer+11)*4294967296;
                    //long speed_up = *(buffer+12) + *(buffer+13)*256+ *(buffer+14)*65536 + *(buffer+15)*4294967296;
                    //printf ("connection speed change on interface %d, %ld Mbps down / %ld Mbps up\n",*(buffer+4),speed_down/(8*1024*1024),speed_up/(8*1024*1024));
                    break;
            }
        }
        free (buffer);
        std::this_thread::sleep_for(std::chrono::milliseconds(millis));
    }
    return result;
}

void dump_in_packets (uint8_t target_device_address,uint8_t endpoint_id,uint16_t in_packetsize)
{
    uint8_t endpoint_toggle = 0;
    int count = 5;
    in_packetsize=1514;

    set_retry (0x0f);    
    while (count)
    {
        uint8_t* buffer = NULL;
        //const clock_t begin_time = clock();
        int bytes_read = data_in_transfer(in_packetsize, target_device_address,endpoint_id, max_packet_size, endpoint_toggle,buffer);
        //std::cout << std::fixed << std::showpoint << float( clock () - begin_time ) /  CLOCKS_PER_SEC << std::endl;
        if (buffer==NULL)
            continue;
        
        printf ("\n%d - dst: %02x:%02x:%02x:%02x:%02x:%02x - src: %02x:%02x:%02x:%02x:%02x:%02x - type: %04x",
            count,
            *(buffer+0),*(buffer+1),*(buffer+2),*(buffer+3),*(buffer+4),*(buffer+5), // dst
            *(buffer+6),*(buffer+7),*(buffer+8),*(buffer+9),*(buffer+10),*(buffer+11), // src
            ((*(buffer+12))<<8)+((*(buffer+13))));// EtherType

        if (!(bytes_read == 0 || buffer==NULL))
        {
            print_buffer (buffer,bytes_read);
            free (buffer);   
        }
        else
            printf ("\n");
        printf ("length: %d\n",bytes_read);
        count --;
    }
    set_retry (0x8f);
}
///////////////////////////////////////////////////////////////////////////
// USB HUB DEVICE INTERRUPT READOUT
uint8_t get_hub_change (uint8_t target_device_address,uint8_t endpoint_id,uint8_t millis,uint16_t in_packetsize)
{
    uint8_t value = 0;
    uint8_t endpoint_toggle = 0;
    uint8_t* buffer = NULL;
    int bytes_read = data_in_transfer(in_packetsize, target_device_address,endpoint_id, max_packet_size, endpoint_toggle,buffer);
    if (bytes_read == 0 || buffer==NULL)
        return 0;
    //print_buffer (buffer,in_packetsize);
    value = buffer[0];
    free (buffer);   
    std::this_thread::sleep_for(std::chrono::milliseconds(millis));
    return value;
}

bool get_descriptors (uint8_t address, uint8_t* buffer, int& buffer_length)
{
    uint8_t* buffer_ptr;

    bool result = get_device_descriptor2(0,buffer, buffer_length);
    if (!result && address==1) // only for first device try low speed
    {
        // 2-set to 1.5 Mhz low-speed mode, 0-set to 12 Mhz high-speed mode (default)
        set_speed(2);
        result = get_device_descriptor2(0,buffer, buffer_length);
    }
    if (!result)
        error("unable to get device descriptor");

    if (!set_address2 (address))
            error ("error setting address");

    for (int i=0;i<device.bNumConfigurations;i++)
    {
        buffer_ptr = buffer+buffer_length;
        result = get_configuration_descriptor2(address,i,buffer_ptr,buffer_length);
        if (!result)
            error("unable to get config descriptor");
    }
    return true;
}
void print_descriptors (uint8_t device_address, uint8_t* buffer, int buffer_length)
{ 
    USB_DEVICE_DESCRIPTOR* device;
    USB_CONFIG_DESCRIPTOR* config;
    USB_INTERF_DESCRIPTOR* interface;
    USB_ENDPOINT_DESCRIPTOR* endpoint;
    USB_HID_DESCRIPTOR* hid;
    USB_ETHERNET_HEADER_DESCRIPTOR* header;
    USB_ETHERNET_UNION_DESCRIPTOR* unione;
    USB_ETHERNET_DESCRIPTOR* ethernet;
    USB_HUB_DESCRIPTOR* hub;

    uint8_t *ptr = buffer;
    while (ptr<buffer+buffer_length)
    {
        std::string endpoint_type;
        std::string endpoint_address_type;
        std::string interface_class_name;
        std::string interface_protocol_name;
        std::string interface_subclass_name;
        std::string device_class_name;
        printf ("\n");
        switch (*(ptr+1))
        {
            case 0x01: // DEVICE_DESCRIPTOR
                device = (USB_DEVICE_DESCRIPTOR*) ptr;
                printf ("Device Descriptor:\n");
                printf ("  bLength\t\t\t%d\n",device->bLength);
                printf ("  bDescriptorType\t\t%d\n",device->bDescriptorType);
                printf ("  bcdUSB\t\t\t%d.%d\n",(device->bcdUSB & 0xff00)>>8, device->bcdUSB & 0xff);
                if (device->bDeviceClass==0xff)
                    device_class_name = "Vendor Specific Class";
                if (device->bDeviceClass==0x02)
                    device_class_name = "Communications";
                if (device->bDeviceClass==0x03)
                    device_class_name = "HID";
                if (device->bDeviceClass==0x09)
                    device_class_name = "Hub";
                if (device->bDeviceClass==0x0A)
                    device_class_name = "CDC Data";
                printf ("  bDeviceClass\t\t\t%d\t%s\n",device->bDeviceClass,device_class_name.c_str());
                printf ("  bDeviceSubClass\t\t%d\n",device->bDeviceSubClass);
                printf ("  bDeviceProtocol\t\t%d\n",device->bDeviceProtocol);
                printf ("  bMaxPacketSize0\t\t%d\n",device->bMaxPacketSize0);
                printf ("  idVendor\t\t\t0x%04x\n",device->idVendor);
                printf ("  idProduct\t\t\t0x%04x\n",device->idProduct);
                printf ("  bcdDevice\t\t\t%d.%d\n",(device->bcdDevice & 0xff00)>>8, device->bcdDevice & 0xff);
                printf ("  iManufacturer\t\t\t%d\n",device->iManufacturer);
                printf ("  iProduct\t\t\t%d\t%s\n",device->iProduct,get_string2 (device_address,device->iProduct).c_str());
                printf ("  iSerial\t\t\t%d\t%s\n",device->iSerial,get_string2 (device_address,device->iSerial).c_str());
                printf ("  bNumConfigurations\t\t%d\n",device->bNumConfigurations);
                ptr += *ptr;
                break;
            case 0x02: // CONFIG_DESCRIPTOR
                config = (USB_CONFIG_DESCRIPTOR*) ptr;
                printf ("  Configuration Descriptor:\n");
                printf ("    bLength\t\t\t%d\n",config->bLength);
                printf ("    bDescriptorType\t\t%d\n",config->bDescriptorType);
                printf ("    wTotalLength\t\t%d\n",config->wTotalLength);
                printf ("    bNumInterfaces\t\t%d\n",config->bNumInterfaces);
                printf ("    bConfigurationvalue\t\t%d\n",config->bConfigurationvalue);
                printf ("    iConfiguration\t\t%d\t%s\n",config->iConfiguration,get_string2 (device_address,config->iConfiguration).c_str());
                printf ("    bmAttributes\t\t%d\n",config->bmAttributes);
                printf ("    bMaxPower\t\t\t%d\n",config->bMaxPower);
                device->bNumConfigurations--;
                ptr += *ptr;
                break;
            case 0x04: // interface descriptor
                interface = (USB_INTERF_DESCRIPTOR*) ptr;
                printf ("    Interface Descriptor:\n");
                printf ("      bLength\t\t\t%d\n",interface->bLength);
                printf ("      bDescriptorType\t\t%d\n",interface->bDescriptorType);
                printf ("      bInterfaceNumber\t\t%d\n",interface->bInterfaceNumber);
                printf ("      bAlternateSetting\t\t%d\n",interface->bAlternateSetting);
                printf ("      bNumEndpoints\t\t%d\n",interface->bNumEndpoints);
                if (interface->bInterfaceClass==0xff)
                    interface_class_name = "Vendor Specific Class";
                if (interface->bInterfaceClass==0x02)
                    interface_class_name = "Communications";
                if (interface->bInterfaceClass==0x03)
                    interface_class_name = "HID";
                if (interface->bInterfaceClass==0x08)
                    interface_class_name = "Storage";
                if (interface->bInterfaceClass==0x09)
                    interface_class_name = "Hub";
                if (interface->bInterfaceClass==0x0A)
                    interface_class_name = "CDC Data";
                printf ("      bInterfaceClass\t\t%d\t%s\n",interface->bInterfaceClass,interface_class_name.c_str());
                if (interface->bInterfaceClass==0x03 && interface->bInterfaceSubClass==0x01)
                    interface_subclass_name = "Boot";
                if (interface->bInterfaceClass==0x02 && interface->bInterfaceSubClass==0x06)
                {
                    interface_subclass_name = "Ethernet Networking Control Model";
                    ethernet_info = new _ethernet_info();
                    ethernet_info->ethernet_control_interface = interface->bInterfaceNumber;
                }
                if (interface->bInterfaceClass==0x08 && interface->bInterfaceSubClass==0x06)
                    interface_subclass_name = "SCSI command set";
                if (interface->bInterfaceClass==0x0A && interface->bInterfaceSubClass==0x00)
                {
                    ethernet_info->ethernet_data_interface = interface->bInterfaceNumber;
                    if (interface->bAlternateSetting!=0)
                        ethernet_info->ethernet_alternate_setting = interface->bAlternateSetting;
                }
                printf ("      bInterfaceSubClass\t%d\t%s\n",interface->bInterfaceSubClass,interface_subclass_name.c_str());
                if (interface->bInterfaceClass==0x03 && interface->bInterfaceProtocol==0x01)
                {
                    interface_protocol_name = "Keyboard";
                    if (!hid_info) hid_info = new _hid_info();
                    hid_info->keyboard_interface = interface->bInterfaceNumber;
                }
                if (interface->bInterfaceClass==0x03 && interface->bInterfaceProtocol==0x02)
                {
                    interface_protocol_name = "Mouse";
                    if (!hid_info) hid_info = new _hid_info();
                    hid_info->mouse_interface = interface->bInterfaceNumber;
                }
                if (interface->bInterfaceClass==0x09 && interface->bInterfaceProtocol==0x00)
                {
                    interface_protocol_name = "No TT";
                    if (!hub_info) hub_info = new _hub_info();
                    hub_info->hub_interface = interface->bInterfaceNumber;
                }
                if (interface->bInterfaceClass==0x09 && interface->bInterfaceProtocol==0x01)
                {
                    interface_protocol_name = "Single TT";
                    if (!hub_info) hub_info = new _hub_info();
                    hub_info->hub_interface = interface->bInterfaceNumber;
                }
                if (interface->bInterfaceClass==0x09 && interface->bInterfaceProtocol==0x02)
                {
                    interface_protocol_name = "Multi TT";
                    if (!hub_info) hub_info = new _hub_info();
                    hub_info->hub_interface = interface->bInterfaceNumber;
                }
                if (interface->bInterfaceClass==0x08 && interface->bInterfaceSubClass==0x06 && interface->bInterfaceProtocol==0x50)
                {
                    interface_protocol_name = "BBB";
                    storage_info = new _storage_info();
                    storage_info->interface_id = interface->bInterfaceNumber;
                    storage_info->configuration_id = config->bConfigurationvalue;
                }
                printf ("      bInterfaceProtocol\t%d\t%s\n",interface->bInterfaceProtocol,interface_protocol_name.c_str());
                printf ("      iInterface\t\t%d\t%s\n",interface->iInterface,get_string2 (device_address,interface->iInterface).c_str());
                ptr += *ptr;
                break;
            case 0x05: // endpoint descriptor
                endpoint = (USB_ENDPOINT_DESCRIPTOR*) ptr;
                printf ("    Endpoint Descriptor:\n");
                printf ("      bLength\t\t\t%d\n",endpoint->bLength);
                printf ("      bDescriptorType\t\t%d\n",endpoint->bDescriptorType);
                endpoint_address_type = endpoint->bEndpointAddress&0b10000000 ? "IN" : "OUT";
                printf ("      bEndpointAddress\t\t%d\t%s\n",endpoint->bEndpointAddress&0b01111111,endpoint_address_type.c_str());
                if ((endpoint->bmAttributes&0b00000011) == 0b00)
                    endpoint_type = "Control";
                if ((endpoint->bmAttributes&0b00000011) == 0b01)
                    endpoint_type = "Isochronous";
                if ((endpoint->bmAttributes&0b00000011) == 0b10)
                    endpoint_type = "Bulk";
                if ((endpoint->bmAttributes&0b00000011) == 0b11)
                    endpoint_type = "Interrupt";
                printf ("      bmAttributes\t\t%d\t%s\n",endpoint->bmAttributes,endpoint_type.c_str());
                printf ("      wMaxPacketSize\t\t%d\n",endpoint->wMaxPacketSize);
                printf ("      bInterval\t\t\t%d\n",endpoint->bInterval);
                if (interface->bInterfaceClass==0x03 && interface->bInterfaceProtocol==0x01) // keyboard
                {
                    hid_info->keyboard_endpoint = endpoint->bEndpointAddress&0b01111111;
                    hid_info->keyboard_packetsize = endpoint->wMaxPacketSize;
                    hid_info->keyboard_millis = endpoint->bInterval;
                    hid_info->configuration_id = config->bConfigurationvalue;
                }
                if (interface->bInterfaceClass==0x03 && interface->bInterfaceProtocol==0x02) // mouse
                {
                    hid_info->mouse_endpoint = endpoint->bEndpointAddress&0b01111111;
                    hid_info->mouse_packetsize = endpoint->wMaxPacketSize;
                    hid_info->mouse_millis = endpoint->bInterval;
                    hid_info->configuration_id = config->bConfigurationvalue;
                }
                if (interface->bInterfaceClass==0x02 && interface->bInterfaceSubClass==0x06) // ethernet control
                {
                    if ((endpoint->bmAttributes&0b00000011) == 0b11) // interrupt
                    {
                        ethernet_info->ethernet_interrupt_endpoint = endpoint->bEndpointAddress&0b01111111;
                        ethernet_info->ethernet_interrupt_millis = endpoint->bInterval;
                        ethernet_info->ethernet_interrupt_packetsize = endpoint->wMaxPacketSize;
                    }
                    ethernet_info->configuration_id = config->bConfigurationvalue;
                }
                if (interface->bInterfaceClass==0x0a && interface->bInterfaceSubClass==0x00) // ethernet data
                {
                    if ((endpoint->bmAttributes&0b00000011) == 0b10 && endpoint->bEndpointAddress&0b10000000) // bulk IN
                    {
                        ethernet_info->ethernet_bulk_in_endpoint = endpoint->bEndpointAddress&0b01111111;
                        ethernet_info->ethernet_bulk_in_packetsize = endpoint->wMaxPacketSize;
                    }      
                    if ((endpoint->bmAttributes&0b00000011) == 0b10 && !(endpoint->bEndpointAddress&0b10000000)) // bulk OUT
                    {
                        ethernet_info->ethernet_bulk_out_endpoint = endpoint->bEndpointAddress&0b01111111;
                        ethernet_info->ethernet_bulk_out_packetsize = endpoint->wMaxPacketSize;
                    }                     
                }
                if (interface->bInterfaceClass==0x09 && (endpoint->bmAttributes&0b00000011) == 0b11) // interrupt
                {
                    hub_info->hub_interrupt_endpoint = endpoint->bEndpointAddress&0b01111111;
                    hub_info->hub_interrupt_packetsize = endpoint->wMaxPacketSize;
                    hub_info->hub_interrupt_millis = endpoint->bInterval;
                    hub_info->configuration_id = config->bConfigurationvalue;
                }
                if (interface->bInterfaceClass==0x08 && interface->bInterfaceSubClass==0x06 && interface->bInterfaceProtocol==0x50)
                {
                    if ((endpoint->bmAttributes&0b00000011) == 0b10 && endpoint->bEndpointAddress&0b10000000) // bulk IN
                    {
                        storage_info->bulk_in_endpoint_id = endpoint->bEndpointAddress&0b01111111;
                        storage_info->bulk_in_packetsize = endpoint->wMaxPacketSize;
                    }      
                    if ((endpoint->bmAttributes&0b00000011) == 0b10 && !(endpoint->bEndpointAddress&0b10000000)) // bulk OUT
                    {
                        storage_info->bulk_out_endpoint_id = endpoint->bEndpointAddress&0b01111111;
                        storage_info->bulk_out_packetsize = endpoint->wMaxPacketSize;
                    }                     
                }
                ptr += *ptr;
                break;
            case 0x21: // HID descriptor
                hid = (USB_HID_DESCRIPTOR*) ptr;
                printf ("      HID Descriptor:\n");
                printf ("        bLength\t\t\t%d\n",hid->bLength);
                printf ("        bDescriptorType\t\t%d\n",hid->bDescriptorType);
                printf ("        bcdHID\t\t\t%d.%d\n",(hid->hid_version & 0xff00)>>8, hid->hid_version & 0xff);
                printf ("        bCountryCode\t\t%d\n",hid->country_code);
                printf ("        bNumDescriptors\t\t%d\n",hid->num_descriptors);
                printf ("        bDescriptorType\t\t%d\n",hid->descriptor_type);
                printf ("        wDescriptorLength\t%d\n",hid->descriptor_length);
                ptr += *ptr;
                break;
            case 0x24: // CDC ECM / CS_INTERFACE
                printf ("    CDC ECM ");
                switch (*(ptr+2)) // subtype
                {
                    case 0x00: // header
                        printf ("header\n");
                        header = (USB_ETHERNET_HEADER_DESCRIPTOR*) ptr;
                        printf ("      bcdCDC\t\t\t%d.%d\n",(header->bcdCDC & 0xff00)>>8, header->bcdCDC & 0xff);
                        break;
                    case 0x06: // union
                        printf ("union\n");
                        unione = (USB_ETHERNET_UNION_DESCRIPTOR*) ptr;
                        printf ("      bControlInterface\t\t%d\n",unione->bControlInterface);
                        printf ("      bSubordinateInterface0\t%d\n",unione->bSubordinateInterface0);
                        break;
                    case 0x0f: // ethernet
                        printf ("ethernet\n");
                        ethernet = (USB_ETHERNET_DESCRIPTOR*) ptr;
                        printf ("      MAC\t\t\t%s\n",get_string2(device_address, ethernet->iMACAddress).c_str());
                        printf ("      wMaxSegmentSize\t\t%d\n",ethernet->wMaxSegmentSize);
                        break;
                    default:
                        printf ("unknown %02x\n",*(ptr+2));
                }
                ptr += *(ptr);
                break;
            case 0x29: // HUB
                hub = (USB_HUB_DESCRIPTOR*) ptr;
                printf ("  Hub Descriptor:\n");
                printf ("    bLength\t\t\t%d\n",hub->bLength);
                printf ("    bDescriptorType\t\t%x\n",hub->bDescriptorType);
                printf ("    bNrPorts\t\t\t%d\n",hub->bNrPorts);
                printf ("    wHubCharacteristics\t\t%x\n",hub->wHubCharacteristics);
                printf ("    bPwrOn2PwrGood\t\t%d\n",hub->bPwrOn2PwrGood);
                printf ("    bHubContrCurrent\t\t%d\n",hub->bHubContrCurrent);
                ptr += *(ptr);
                break;
            default:
                printf ("Unknown type: %02x\n",*(ptr+1));
                ptr += *ptr;
                break;
        }
    }
}
void do_hid (_hid_info&);
void do_ethernet (_ethernet_info&);
void do_hub (_hub_info&);
void do_storage (_storage_info&);

void connect_disk ()
{
    writeCommand (CH376_CMD_DISK_CONNECT);
    endCommand();
    if (waitStatus ()!=CH375_USB_INT_SUCCESS)
        error ("disk not connected");
    
}
void mount_disk ()
{
    int status;
    writeCommand (CH376_CMD_DISK_MOUNT);
    endCommand();
    status = waitStatus ();
    if ((status!=CH375_USB_INT_SUCCESS))
        error ("disk not mounted");
}
void open_file (char* name)
{
    int status;
    writeCommand (CH376_CMD_SET_FILE_NAME);
    writeDataMultiple ((uint8_t*) name,strlen(name));
    endCommand();
    writeCommand (CH376_CMD_OPEN_FILE);
    endCommand();
    if ((status=waitStatus ())!=CH375_USB_INT_SUCCESS)
        error ("file not opened");
    
}
#define CH376_CMD_BYTE_READ 0x3a
#define CH376_CMD_BYTE_RD_GO 0x3b
#define CH375_USB_INT_DISK_READ 0x1d
void read_file ()
{
    int status;
    while (true)
    {
        writeCommand (CH376_CMD_BYTE_READ);
        writeData (64);
        writeData (0);
        endCommand();
        status=waitStatus ();
        if (status==CH375_USB_INT_SUCCESS)
            return; // done
        if (status==CH375_USB_INT_DISK_READ)
        {
            uint8_t buffer[64];
            ssize_t len = read_usb_data(buffer);
            print_buffer (buffer,len);
            char line[65];
            strncpy (line,(char*) buffer,len);
            printf ("%s\n",line);
            writeCommand (CH376_CMD_BYTE_RD_GO);
            endCommand();
            if ((status=waitStatus ())!=CH375_USB_INT_SUCCESS)
                error ("read file error");
        }
    }
}
void close_file ()
{
    int status;
    writeCommand (CH376_CMD_FILE_CLOSE);
    writeData (0);
    endCommand();
    if ((status=waitStatus ())!=CH375_USB_INT_SUCCESS)
        error ("file not closed");
}
void open_dir (char* name)
{
    int status;
    writeCommand (CH376_CMD_SET_FILE_NAME);
    writeDataMultiple ((uint8_t*) name,strlen(name));
    endCommand();
    writeCommand (CH376_CMD_OPEN_FILE);
    endCommand();
    if ((status=waitStatus ())!=CH375_USB_ERR_OPEN_DIR)
        error ("directory not opened");
}
void wait_for_insert ()
{
    uint8_t status,bytes;
    while (1)
    {
        writeCommand(CH375_CMD_GET_STATUS);
        bytes = readData (&status);
        endCommand();
        if (bytes)
        {
            if(status==CH375_USB_INT_CONNECT)
            {
                printf ("USB device inserted\n");
                break;
            }
            else
            {
                printf ("Please insert an USB device\n");
                sleep (1);
            }
        }
    }
}
void usb_host_bus_reset ()
{
    bool result;
    result=set_usb_host_mode(CH375_USB_MODE_HOST);
    // wait for insert
    wait_for_insert ();
    result = set_usb_host_mode(CH375_USB_MODE_HOST_RESET);
    sleep (1);
    if (!(result=set_usb_host_mode(CH375_USB_MODE_HOST)))
        error ("host mode not succeeded\n");
    usleep (500000);

    uint8_t version;
    writeCommand (CH376_CMD_GET_IC_VER);
    readData (&version);
    endCommand();
    if (version&0b00100000 == 0)
        error ("Not a right version\n");
    version = version&0b00011111;
    printf ("CH376 IC version: %d\n",version);
    if (version == 3) 
    {
        // un-stall endpoint 0
        writeCommand (CH376_CMD_CLR_STALL);
        writeData (0x80);
        endCommand();
    }
}

std::vector <_hid_info> hids;
std::vector <_hub_info> hubs;
std::vector <_storage_info> storages;
std::vector <_ethernet_info> ethernets;

void init_device (uint8_t device_address)
{
    uint8_t buffer[1024];
    int buffer_length;
    hid_info=NULL;
    hub_info=NULL;
    ethernet_info=NULL;

    memset (buffer, 0, 1024);
    bool result = get_descriptors (device_address,buffer, buffer_length);
    if (!result)
        error("unable to get descriptors");

    print_descriptors (device_address, buffer, buffer_length);
    
    if (hid_info)
    {
        hid_info->device_address = device_address;
        if (!set_configuration2(hid_info->device_address,hid_info->configuration_id))
                error ("error setting Hid configuration");
        hids.push_back (*hid_info);
        hid_info=NULL;
    }
    if (ethernet_info)
    {
        ethernet_info->device_address = device_address;
        if (!set_configuration2(ethernet_info->device_address,ethernet_info->configuration_id))
                error ("error setting Ethernet configuration");
        ethernets.push_back (*ethernet_info);
        ethernet_info=NULL;
    }
    if (hub_info)
    {
        hub_info->device_address = device_address;
        if (!set_configuration2(hub_info->device_address,hub_info->configuration_id))
            error ("error setting Hub configuration");
        hubs.push_back (*hub_info);
        do_hub (*hub_info);
        hub_info=NULL;
    }
    if (storage_info)
    {
        storage_info->device_address = device_address;
        if (!set_configuration2(storage_info->device_address,storage_info->configuration_id))
                error ("error setting Storage configuration");
        storages.push_back (*storage_info);
        storage_info=NULL;
    }
}

uint32_t tag = 1;
uint8_t storage_out_toggle=0;
uint8_t storage_in_toggle=0;

bool do_scsi_command (_storage_info& storage_info,uint8_t lun,bool read,uint8_t* command,uint8_t command_len,uint8_t *&buffer,uint32_t buffer_len)
{
    command_block_wrapper cbw;
    command_status_wrapper csw;
    int bytes_read;

    // CHECK CAPACITY
    memset (&cbw,0,sizeof (command_block_wrapper));
    cbw.dCBWSignature = 0x43425355;
    cbw.dCBWTag = tag++;
    cbw.bCBWLUN = lun;
    cbw.dCBWDataTransferLength = buffer_len;
    if (cbw.dCBWDataTransferLength>0 && read)
        cbw.bmCBWFlags = 0b10000000; // Data-In;
    else
        cbw.bmCBWFlags = 0b00000000; // Data-Out;
    cbw.bCBWCBLength = command_len;
    memcpy (cbw.data,command,command_len);
    print_buffer ((uint8_t*) &cbw,sizeof (command_block_wrapper));
    data_out_transfer ((uint8_t*) &cbw,sizeof(command_block_wrapper),storage_info.device_address,storage_info.bulk_out_endpoint_id,storage_info.bulk_out_packetsize,storage_out_toggle);
    if (cbw.dCBWDataTransferLength>0)
    {
        if (read)
        {
            // get command results
            bytes_read = data_in_transfer (buffer_len,storage_info.device_address,storage_info.bulk_in_endpoint_id,storage_info.bulk_in_packetsize,storage_in_toggle,buffer);
            if (bytes_read==0 || buffer==NULL)
                return false;
            print_buffer (buffer,buffer_len);
        }
        else
        {
            /* code */
        }
    }
    // get CSW
    uint8_t* csw_result;
    bytes_read = data_in_transfer (sizeof (command_status_wrapper),storage_info.device_address,storage_info.bulk_in_endpoint_id,storage_info.bulk_in_packetsize,storage_in_toggle,csw_result);
    if (bytes_read==0 || csw_result==NULL)
        return false;
    memcpy (&csw,csw_result,sizeof(command_status_wrapper));
    free (csw_result);

    //print_buffer (csw_result,sizeof (command_status_wrapper));
    if (csw.dCBWSignature!= 0x53425355 || csw.dCBWTag!=cbw.dCBWTag || csw.bCSWStatus!=0)
    {
        printf ("\tSignature: %x\n",csw.dCBWSignature);
        printf ("\tTag: %x (%s)\n",csw.dCBWTag,csw.dCBWTag==cbw.dCBWTag?"okay":"nok");
        printf ("\tResidue: %x\n",csw.dCSWDataResidue);
        printf ("\tStatus: %x (%s)\n",csw.bCSWStatus,csw.bCSWStatus==0?"Success":"Failed");
        return false;
    }

    return true;
}

bool scsi_read_block (_storage_info& storage_info, uint32_t blocknr, uint16_t blocksize,uint8_t *&buffer)
{
    scsi_read10 read;
    uint32_t swapped =  ((blocknr>>24)&0xff) | // move byte 3 to byte 0
                        ((blocknr<<8)&0xff0000) | // move byte 1 to byte 2
                        ((blocknr>>8)&0xff00) | // move byte 2 to byte 1
                        ((blocknr<<24)&0xff000000); // byte 0 to byte 3
    read.dLBA = swapped;
    read.wTransferLength = 1; // blocks requested
    read.wTransferLength = (read.wTransferLength>>8) | (read.wTransferLength<<8); // convert endianness
    return do_scsi_command (storage_info,0,true,(uint8_t*) &read,sizeof(read),buffer,blocksize);
}

void do_storage (_storage_info& storage_info)
{
    // USB HID?
    if (storage_info.configuration_id>0)
    {
        uint8_t* buffer=NULL;
        int max_luns;
        
        //bulkonly_mass_storage_reset (storage_info.device_address,storage_info.interface_id);
        max_luns = get_max_luns (storage_info.device_address,storage_info.interface_id);
        printf ("\tMax LUNs: %d\n",max_luns);

        // INQUIRY
        scsi_inquiry inquiry;
        if (do_scsi_command (storage_info,0,true,(uint8_t*) &inquiry,sizeof(inquiry),buffer,0x24))
        {
            printf ("\tPDT: %d\n",buffer[0]);
            printf ("\tRemovable: %s\n",0b10000000 & buffer[1]?"yes":"no");
            printf ("\tAdditional length: %d\n",buffer[4]);
            char vendor[9];
            strncpy (vendor,(const char*) &buffer[8],8);
            vendor[8] = 0;
            printf ("\tVendor: %s\n",vendor);
            char product[17];
            strncpy (product,(const char*) &buffer[16],16);
            product[16]=0;
            printf ("\tProduct: %s\n",product);
            char rev[5];
            strncpy (rev,(const char*) &buffer[32],4);
            rev[4]=0;
            printf ("\tRevision: %s\n",rev);

            if (buffer[0]!=0)
            {
                printf ("\tNo Direct-access block device\n");
                free (buffer);
                return;
            }
            free (buffer);
        }
        
        // TEST UNIT READY
        scsi_test_unit_ready ready;
        bool device_ready=false;
        while (device_ready==false)
        {
            if (do_scsi_command (storage_info,0,false,(uint8_t*) &ready,sizeof(scsi_test_unit_ready),buffer,0))
            {
                device_ready = true;
            }
            else
            {
                // REQUEST SENSE
                scsi_request_sense sense;
                if (do_scsi_command(storage_info,0,true,(uint8_t*) &sense,sizeof (scsi_request_sense),buffer,sense.bAllocationLength))
                {
                    std::string sense_key;
                    switch (buffer[2])
                    {
                        case 1 : sense_key = "Soft error"; break;
                        case 2 : sense_key = "Not ready"; break;
                        case 3 : sense_key = "Medium error"; break;
                        case 4 : sense_key = "Hardware error"; break;
                        case 5 : sense_key = "Illegal request"; break;
                        case 6 : sense_key = "Unit attention"; break;
                        case 7 : sense_key = "Data protect"; break;
                    }
                    printf ("\tSense Key: %d (%s)\n",buffer[2],sense_key.c_str());
                    printf ("\tAdditional sense code: %d\n",buffer[12]);
                    printf ("\tAdditional sense code qualifier: %d\n",buffer[13]);
                    free (buffer);
                }
            }
        }
        
        // CHECK CAPACITY
        scsi_capacity capacity;
        uint32_t lba,len;
        if (do_scsi_command (storage_info,0,true,(uint8_t*) &capacity,sizeof(capacity),buffer,0x8))
        {
            lba = buffer[0]*16777216+buffer[1]*65536+buffer[2]*256+buffer[3];
            len = buffer[4]*16777216+buffer[5]*65536+buffer[6]*256+buffer[7];
            printf ("\tMax LBA: %ld\n",lba);
            printf ("\tBlock length in bytes: %ld\n",len);
            free (buffer);
        }

        /*
        // MODE SENSE
        scsi_mode_sense mode;
        mode.bPageCode = 0x3f; // all mode pages
        //mode.bPageCode = 0x04; // Flexible Disk
        mode.bSubpageCode = 0x00;
        mode.wAllocationLength = 192;
        if (do_scsi_command (storage_info.device_address,0,true,(uint8_t*) &mode,sizeof(mode),buffer,192))
        {
            free (buffer);
        }
        */

        // READ MBR
        if (scsi_read_block (storage_info,0,len,buffer))
        {
            if (buffer[0x1fe]==0x55 && buffer[0x1ff]==0xaa) // Boot signature present?
            {
                if (buffer[0]==0 && buffer[1]==0) // MBR
                {
                    uint8_t type = buffer[0x1be + 4];
                    uint32_t first_partition = 0;
                    if (type == 0x01 || type == 0x04 || type == 0x06 || type == 0x0b || type == 0x0c || type == 0x0e)
                    {
                        uint8_t* ptr = (buffer + 0x1be + 8);
                        first_partition = *((uint32_t*) ptr);
                        printf ("\tMBR, first partition at block: 0x%x\n",first_partition);
                    }
                    free (buffer);
                    // READ BOOTSECTOR
                    uint8_t cluster_map = 2;
                    if (scsi_read_block (storage_info,first_partition,len,buffer))
                    {
                        if (buffer[0x1fe]==0x55 && buffer[0x1ff]==0xaa) // Boot signature present
                        {
                            char OEM[9];
                            uint16_t bytes_per_sector = *((uint16_t*)(buffer+0x0b));
                            uint8_t sectors_per_cluster = buffer[0x0d];
                            uint32_t total_sectors = *((uint16_t*)(buffer+0x13));
                            if (total_sectors==0)
                                total_sectors = *((uint32_t*)(buffer+0x24));
                            uint32_t total_clusters = total_sectors / sectors_per_cluster;
                            uint32_t partition_size = total_sectors * bytes_per_sector;
                            strncpy (OEM,(char*) buffer+3,8);
                            OEM[8]=0;
                            printf ("\tBoot, OEM name: %s\n",OEM);
                            char FAT[9];
                            strncpy (FAT,(char*) buffer+0x36,8);
                            FAT[8]=0;
                            printf ("\tFilesystem label: %s\n",FAT);
                            strncpy (FAT,(char*) buffer+0x52,8);
                            FAT[8]=0;
                            printf ("\tFilesystem label: %s\n",FAT);
                            cluster_map = buffer[0x2c];
                            free (buffer);
                        }
                    }
                }
                else 
                {
                    char OEM[9];
                    strncpy (OEM,(char*) buffer+3,8);
                    OEM[8]=0;
                    printf ("\tBoot, OEM name: %s\n",OEM);
                    free (buffer);
                }
            }
        }

        // speed test
        VERBOSE=0;
        auto t1 = std::chrono::high_resolution_clock::now();
        int i=0;
        while (scsi_read_block (storage_info,i++,len,buffer)) {

            free (buffer);
            if (i==10)
                break;
            std::cout << "block " << i << " read" << std::endl;
        }
        auto t2 = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::microseconds>( t2 - t1 ).count();
        std::cout << "Read speed: " << i*len / (duration/1000000.0) << " bytes/second" << std::endl;
        VERBOSE=1;

        /*
        // try some high-level stuff
        // set reset bus and set host mode
        usb_host_bus_reset ();
        connect_disk ();
        mount_disk ();
        open_dir ("\\\0");
        open_file ("AUTOEXEC.DSK\0");
        read_file ();
        close_file ();
        open_dir ("\\\0");
        open_file ("128MB.DSK\0");
        //read_file();
        close_file ();
        */
    }
}
void do_hid (_hid_info& hid_info)
{
    // USB HID?
    if (hid_info.configuration_id>0)
    {
        printf ("\nWe found an USB HID device, lets start using it.\n");
        if (hid_info.mouse_interface!=255 && hid_info.keyboard_interface!=255)
        {
            // enable device configuration
            //(hid_info.device_address,hid_info.hid_configuration_id))
            //    error ("error setting HID configuration");
            // set boot protocol for mouse and read it
            //if (!set_protocol2 (hid_info.device_address,BOOT_PROTOCOL,hid_info->mouse_interface)) // select boot protocol for our device
            //    error ("error setting boot protocol for mouse");
            //set_idle2(hid_info.device_address, 0x0, 0,mouse_interface); // wait on change
            // set boot protocol for keyboard and read it
            if (!set_protocol2 (hid_info.device_address,BOOT_PROTOCOL,hid_info.keyboard_interface)) // select boot protocol for our device
                error ("error setting boot protocol for keyboard");
            set_idle2(hid_info.device_address, 0x80, 0,hid_info.keyboard_interface); // scan every ~500ms
            
            read_boot_keyboard (hid_info.device_address,hid_info.keyboard_endpoint,hid_info.keyboard_millis,hid_info.keyboard_packetsize); 
            //read_boot_mouse (device_address,mouse_endpoint,mouse_millis,mouse_packetsize);
        }
    }
}
void do_ethernet (_ethernet_info& ethernet_info)
{
    if (ethernet_info.configuration_id>0)
    {
        printf ("\nWe found an USB CDC ECM device, lets start using it.\n");
        if (ethernet_info.ethernet_control_interface==255 || ethernet_info.ethernet_data_interface==255)
            return; 
        // enable device configuration
        //if (!set_configuration2(ethernet_info.device_address,ethernet_info.ethernet_configuration_id))
        //    error ("error setting Ethernet configuration");
        // set alternate interface
        if (!set_interface2 (ethernet_info.device_address,ethernet_info.ethernet_data_interface,ethernet_info.ethernet_alternate_setting))
            error ("error setting alternate interface");

        // check if the network cable is connected
        bool result = check_network_connection (ethernet_info.device_address,ethernet_info.ethernet_interrupt_endpoint,ethernet_info.ethernet_interrupt_millis,ethernet_info.ethernet_interrupt_packetsize);
        if (!result)
            error ("please connect a network cable");
        else
        {
            printf ("network cable connected\n");
            const uint8_t PACKET_TYPE_MULTICAST =       0b00010000;
            const uint8_t PACKET_TYPE_BROADCAST =       0b00001000;
            const uint8_t PACKET_TYPE_DIRECTED =        0b00000100;
            const uint8_t PACKET_TYPE_ALL_MULTICAST =   0b00000010;
            const uint8_t PACKET_TYPE_PROMISCUOUS =     0b00000001;
            if (!set_packet_filter2 (ethernet_info.device_address,ethernet_info.ethernet_control_interface,PACKET_TYPE_BROADCAST|PACKET_TYPE_DIRECTED))
                error ("error setting packet filter");
            dump_in_packets (ethernet_info.device_address,ethernet_info.ethernet_bulk_in_endpoint,ethernet_info.ethernet_bulk_in_packetsize);
        }
    }
}

void do_hub (_hub_info& hub_info)
{
    if (hub_info.configuration_id>0)
    {
        if (hub_info.hub_interface==255)
            return;

        int length;
        USB_HUB_DESCRIPTOR* hub = new USB_HUB_DESCRIPTOR();
        bool result = get_hub_descriptor2(hub_info.device_address,(uint8_t*) hub,length);
        if (!result)
            error("unable to get hub descriptor");
        printf ("  Hub Descriptor:\n");
        printf ("    bLength\t\t\t%d\n",hub->bLength);
        printf ("    bDescriptorType\t\t%x\n",hub->bDescriptorType);
        printf ("    bNrPorts\t\t\t%d\n",hub->bNrPorts);
        printf ("    wHubCharacteristics\t\t%x\n",hub->wHubCharacteristics);
        printf ("    bPwrOn2PwrGood\t\t%d\n",hub->bPwrOn2PwrGood);
        printf ("    bHubContrCurrent\t\t%d\n",hub->bHubContrCurrent);
        printf ("    DeviceRemovable\t\t%x\n",hub->DeviceRemovable);
        printf ("    PortPwrCtrlMask\t\t%x\n",hub->PortPwrCtrlMask);

        uint32_t status;
        const int PORT_POWER = 8;
        const int PORT_RESET = 4;
        const int PORT_LOW_SPEED = 9;
        const int C_PORT_RESET = 0x14;
        const int C_PORT_CONNECTION = 0x10;
        const int HUB_PORT_NUMBER = 1;
        const uint8_t HUB_PORT_BITMASK = (1 << (HUB_PORT_NUMBER));
        for (int i=1;i<=hub->bNrPorts;i++)
        {
            if (!set_hub_port_feature2 (hub_info.device_address,PORT_POWER,i,0)) // power all ports
                error ("error powering Hub port");
        }   
        //if (!set_hub_port_feature2 (device_address,PORT_POWER,HUB_PORT_NUMBER,0)) // power all ports
        //        error ("error powering Hub port");

        // wait something happens on any of the powered ports
        //while (!(get_hub_change (device_address,hub_info->hub_interrupt_endpoint,hub_info->hub_interrupt_millis,hub_info->hub_interrupt_packetsize)&HUB_PORT_BITMASK));
        //if (!clear_hub_port_feature2 (device_address,C_PORT_CONNECTION,HUB_PORT_NUMBER,0))// clear C_PORT_CONNECTION feature
        //    error ("error clearing feature Hub port");
        //usleep (100000); // wait 100msec

        for (int i=1;i<=hub->bNrPorts;i++)
        {
            status = get_hub_portstatus (hub_info.device_address,i)&0xffff;
            if (status & 0x0001)
            {
                if (!set_hub_port_feature2 (hub_info.device_address,PORT_RESET,i,0)) // reset port 1
                    error ("error resetting Hub port");
                usleep (250000);
                // endpoint 0 should now be equal to the resetted device
                init_device (device_counter++);
            }
        } 
        delete hub;
        // check if low speed
        //status = get_hub_portstatus (device_address,HUB_PORT_NUMBER)&0xffff;
        //if (status&0x0200) // low speed
        //{
            // no idea to handle this...
        //}

        //if (!set_hub_port_feature2 (device_address,PORT_RESET,HUB_PORT_NUMBER,0)) // reset port 1
        //    error ("error resetting Hub port 1");
        // wait for change of port 1 => bit 2
        //while (!(get_hub_change (device_address,hub_info->hub_interrupt_endpoint,hub_info->hub_interrupt_millis,hub_info->hub_interrupt_packetsize)&HUB_PORT_BITMASK));
        //status = get_hub_portstatus (device_address,HUB_PORT_NUMBER);
        //if (!clear_hub_port_feature2 (device_address,C_PORT_RESET,HUB_PORT_NUMBER,0))// clear C_PORT_RESET feature
        //    error ("error clearing feature Hub port");
        
        // endpoint 0 should now be equal to the resetted device
        //init_device (device_address+1);
    }
}

int main(int argc, const char * argv[]) 
{
    init_serial();
    testspeed();

    check_exists();
    reset_all();

    // set reset bus and set host mode
    usb_host_bus_reset ();

    // do the low-level things
    init_device (device_counter++);

    for (int i=0;i<hids.size();i++)
        do_hid (hids[i]);
    for (int i=0;i<storages.size();i++)
        do_storage (storages[i]);
    for (int i=0;i<ethernets.size();i++)
        do_ethernet (ethernets[i]);
    
    return 0;
}
