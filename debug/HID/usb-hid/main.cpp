// USB-HID - application that discovers attached USB devices to CH376s
// Copyright 2019 - Mario Smit

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

#define BAUDRATE B115200
int serial=-1;

#define CH375_CMD_SET_USB_SPEED 0x04
#define CH375_CMD_RESET_ALL 0x05
#define CH375_CMD_CHECK_EXIST 0x06
#define CH375_CMD_SET_USB_MODE 0x15
#define CH375_CMD_GET_STATUS 0x22
#define CH375_CMD_SET_USB_ADDR 0x13
#define CH375_CMD_SET_ENDP6 0x1C
#define CH375_CMD_SET_ENDP7 0x1D
#define CH375_CMD_RD_USB_DATA0 0x27
#define CH375_CMD_RD_USB_DATA 0x28
#define CH375_CMD_WR_USB_DATA7 0x2B
#define CH375_CMD_WR_HOST_DATA 0x2C
#define CH375_CMD_SET_ADDRESS 0x45
#define CH375_CMD_GET_DESCR 0x46
#define CH375_CMD_SET_CONFIG 0x49
#define CH375_CMD_ISSUE_TOKEN 0x4F
#define CH375_CMD_ISSUE_TKN_X 0x4E
#define CH375_CMD_ABORT_NAK 0x17

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

//--- PIDs
#define CH_PID_SETUP 0x0D
#define CH_PID_IN  0x09
#define CH_PID_OUT 0x01

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
     uint8_t iSerialNumber;
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
std::vector <USB_CONFIG_DESCRIPTOR> configs;

typedef struct __attribute__((packed)) _USB_HID_DESCRIPTOR {
    uint8_t bLength;
    uint8_t bDescriptorType;
    uint16_t hid_version;
    uint8_t country_code;
    uint8_t num_descriptors;
    uint8_t descriptor_type;
    uint16_t descriptor_length;
} USB_HID_DESCRIPTOR;
std::vector <USB_HID_DESCRIPTOR> hids;

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
std::vector <USB_INTERF_DESCRIPTOR> interfaces;

 typedef struct __attribute__((packed)) _USB_ENDPOINT_DESCRIPTOR {
     uint8_t bLength;
     uint8_t bDescriptorType;
     uint8_t bEndpointAddress;
     uint8_t bmAttributes;
     uint16_t wMaxPacketSize;
     uint8_t bInterval;
 } USB_ENDPOINT_DESCRIPTOR;
std::vector <USB_ENDPOINT_DESCRIPTOR> endpoints;

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
    if(tcgetattr(serial, &config) < 0)
      error("cannot get serial attributes");
    
    bzero(&config, sizeof(config));
    config.c_cflag = BAUDRATE | CRTSCTS | CS8 | CLOCAL | CREAD;
    config.c_iflag = IGNPAR;
    config.c_oflag = 0;
    
    /* set input mode (non-canonical, no echo,...) */
    config.c_lflag = 0;
     
    config.c_cc[VTIME]    = 5;
    config.c_cc[VMIN]     = 0;
    
    tcflush(serial, TCIFLUSH);
    tcsetattr(serial, TCSANOW, &config);
}
const uint8_t WR_COMMAND = 1;
const uint8_t RD_STATUS = 2;
const uint8_t WR_DATA = 3;
const uint8_t RD_DATA = 4;
const uint8_t RD_INT = 5;
const uint8_t RD_DATA_MULTIPLE = 6;
const uint8_t WR_DATA_MULTIPLE = 7;

// LOW_LEVEL serial communication to CH376
///////////////////////////////////////////////////////////////////////////
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
    for (i=0;i<len;i++)
    {
        uint8_t value;
        uint8_t bytes = read (serial,&value,1);
        if (bytes==0)
            break;
        *(buffer+i)=value;
    }
    return i;
}
ssize_t readStatus (uint8_t* new_value)
{
    uint8_t cmd[] = {RD_STATUS};
    write (serial,cmd,sizeof(cmd));
    return read (serial,new_value,1);
}
ssize_t readInterrupt (uint8_t* new_value)
{
    uint8_t cmd[] = {RD_INT};
    write (serial,cmd,sizeof(cmd));
    return read (serial,new_value,1);
}

// CHECK STATUS
///////////////////////////////////////////////////////////////////////////
uint8_t waitInterrupt ()
{
    uint8_t status,interrupt;
    int i=0;
    ssize_t bytes;
    while ((bytes=readInterrupt(&interrupt)))
    {
        if (interrupt&0x80)
            break;
    }
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
        error ("ERROR: device does not exist\n");
}
// CH376 built-in commands
///////////////////////////////////////////////////////////////////////////
void reset_all ()
{
    writeCommand (CH375_CMD_RESET_ALL);
    sleep (1);
}
void set_target_device_address (uint8_t address)
{
    writeCommand (CH375_CMD_SET_USB_ADDR);
    writeData(address);
    sleep (0.2);
}

bool set_usb_host_mode (uint8_t mode)
{
    writeCommand(CH375_CMD_SET_USB_MODE);
    writeData(mode);
    
    uint8_t value;
    for(int i=0; i!=50; i++ )
    {
        readData(&value);
        if ( value == CH375_CMD_RET_SUCCESS )
            return true;
        usleep(1000);
    }
    return false;
}
void set_speed (uint8_t speed)
{
    writeCommand (CH375_CMD_SET_USB_SPEED);
    writeData(speed);
}

void set_address (uint8_t address)
{
     writeCommand (CH375_CMD_SET_ADDRESS);
     writeData(address);
     if (waitInterrupt ()!=CH375_USB_INT_SUCCESS)
         error ("ERROR: address not set\n");
}
void set_configuration (uint8_t configuration)
{
     writeCommand(CH375_CMD_SET_CONFIG);
     writeData(configuration);
     if (waitInterrupt ()!=CH375_USB_INT_SUCCESS)
         error ("ERROR: configuration not set\n");
}
bool get_device_descriptor ()
{
    uint8_t value;
    ssize_t bytes;
    
    writeCommand(CH375_CMD_GET_DESCR);
    writeData(CH375_USB_DEVICE_DESCRIPTOR);
    if (waitInterrupt ()!=CH375_USB_INT_SUCCESS)
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
    return true;
}

void get_configuration_descriptor ()
{
    uint8_t value;
    ssize_t bytes;
    
    writeCommand(CH375_CMD_GET_DESCR);
    writeData(CH375_USB_CONFIGURATION_DESCRIPTOR);
    uint8_t interrupt = waitInterrupt();
    if (interrupt==CH375_USB_INT_BUF_OVER)
        error ("ERROR: USB config descriptor is too large [1]\n");
    if (interrupt!=CH375_USB_INT_SUCCESS)
        error ("ERROR: USB config descriptor not read [1]\n");
    writeCommand(CH375_CMD_RD_USB_DATA);
    // read length of return package
    value = 0;
    bytes = readData(&value);
    USB_CONFIG_DESCRIPTOR config;
    if (bytes==1 && value >= sizeof (USB_CONFIG_DESCRIPTOR))
    {
        bytes = readDataMultiple ((uint8_t*)&config,sizeof (USB_CONFIG_DESCRIPTOR));
        if (bytes!=sizeof (USB_CONFIG_DESCRIPTOR))
            error ("ERROR: USB config descriptor not read [2]\n");
        configs.push_back(config);
    }
    else
        error ("ERROR: USB config descriptor not read [3]\n");
    for (int i=0;i<config.bNumInterfaces;i++)
    {
        USB_INTERF_DESCRIPTOR interface;
        bytes = readDataMultiple ((uint8_t*)&interface,sizeof (USB_INTERF_DESCRIPTOR));
        if (bytes!=sizeof(USB_INTERF_DESCRIPTOR))
            error ("ERROR: USB interface descriptor not read");
        interfaces.push_back(interface);
        
        if (interface.bInterfaceClass==0x03) // HID
        {
            USB_HID_DESCRIPTOR hid;
            bytes = readDataMultiple ((uint8_t*)&hid,sizeof (USB_HID_DESCRIPTOR));
            if (bytes!=sizeof(USB_HID_DESCRIPTOR))
                error ("ERROR: USB HID descriptor not read");
            hids.push_back(hid);
        }
        for (int j=0;j<interface.bNumEndpoints;j++)
        {
            USB_ENDPOINT_DESCRIPTOR endpoint;
            bytes = readDataMultiple ((uint8_t*)&endpoint,sizeof (USB_ENDPOINT_DESCRIPTOR));
            if (bytes!=sizeof(USB_ENDPOINT_DESCRIPTOR))
                error ("ERROR: USB endpoint descriptor not read");
            endpoints.push_back(endpoint);
        }
    }
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
void issue_token (uint8_t endpoint, uint8_t pid, uint8_t in_toggle, uint8_t out_toggle)
{
    writeCommand(CH375_CMD_ISSUE_TKN_X);
    writeData(in_toggle<<7 | out_toggle<<6);
    writeData(endpoint << 4 | pid);
}
ssize_t read_usb_data (uint8_t* pBuffer)
{
    uint8_t value = 0;
    writeCommand(CH375_CMD_RD_USB_DATA0);
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
// USB data packet input
///////////////////////////////////////////////////////////////////////////
uint8_t* data_in_transfer (uint16_t length, uint8_t target_device_address, uint8_t endpoint_number, uint8_t endpoint_packetsize, uint8_t& direction)
{
    uint16_t remaining_data_length = length;
    uint8_t* pBuffer = (uint8_t*) malloc (length);
    bzero(pBuffer, length);
    uint8_t* pTemp = pBuffer;
    uint8_t status;
    
    set_target_device_address(target_device_address);
    
    while (remaining_data_length>0)
    {
        issue_token(endpoint_number, CH_PID_IN, direction, 0);
        direction = direction ^ 1;
        if ((status=waitInterrupt())!=CH375_USB_INT_SUCCESS)
            break;
        ssize_t bytes = read_usb_data (pTemp);
        remaining_data_length -= bytes;
        pTemp += bytes;
        
        if (bytes<endpoint_packetsize)
            break;
    }
    return pBuffer;
}
// USB data packet output
///////////////////////////////////////////////////////////////////////////
uint8_t* data_out_transfer (uint8_t* pBuffer,uint16_t length, uint8_t target_device_address, uint8_t endpoint_number, uint8_t endpoint_packetsize, uint8_t direction)
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
        direction = direction ^ 1;
        
        issue_token(endpoint_number, CH_PID_OUT, 0, direction);
        while ((waitInterrupt()&0x2f)==0x2a); // absorb NAK
    }
    return NULL;
}

#define IN 1
#define OUT 0
// USB command execution via SETUP, DATA, STATUS stages
///////////////////////////////////////////////////////////////////////////
uint8_t* execute_control_transfer (uint8_t target_device_address,uint8_t message[8],uint8_t* senddata, uint8_t endpoint_packet_size)
{
    uint8_t* result;
    uint16_t requested_length = (*(message + 6))+((*(message +7))<<8);
    uint8_t data_direction = message[0]&0b10000000?IN:OUT;
    set_target_device_address(target_device_address);
    
    //Setup stage
    write_usb_data (message,8);
    uint8_t endpoint = 0;
    issue_token (endpoint, CH_PID_SETUP,0,0);
    uint8_t interrupt = waitInterrupt();
    if (interrupt != CH375_USB_INT_SUCCESS)
        return NULL;//error ("execute_control_transfer 0");
    
    //Data stage
    uint8_t direction = 1;
    if (data_direction==IN)
        result = data_in_transfer(requested_length, target_device_address, 0, endpoint_packet_size, direction);
    else
        result = data_out_transfer (senddata,requested_length, target_device_address, 0, endpoint_packet_size, direction);
    
    // Status stage
    if (data_direction==OUT || requested_length==0)
    {
        issue_token(endpoint, CH_PID_IN, 1, 0);
        while ((waitInterrupt()&0x2f)==0x2a); // absorb NAK
        uint8_t tmp[endpoint_packet_size];
        ssize_t bytes = read_usb_data((uint8_t*)&tmp);
    }
    else
    {
        issue_token(endpoint, CH_PID_OUT, 0, 1);
        uint8_t interrupt;
        while (true)
        {
            interrupt = waitInterrupt();
            if ((interrupt&0x2f)==0x2a) // absorb NAK
                continue;
            break;
        };
        if (interrupt!=CH375_USB_INT_SUCCESS)
            return NULL;//error ("ERROR: execute_control_transfer 2");
    }
    return result;
}
// DESCRIPTOR commands
///////////////////////////////////////////////////////////////////////////
uint8_t max_packet_size = 8;
bool get_device_descriptor2 ()
{
    uint8_t cmd[] = {0x80,6,0,1,0,0,18,0};
    uint8_t* data = execute_control_transfer(0,cmd,NULL,max_packet_size);
    if (data==NULL)
        return false;
    memcpy(&device, data, 18);
    free(data);
    max_packet_size = device.bMaxPacketSize0;
    return true;
}
bool get_configuration_descriptor2 (uint8_t target_device_address,uint8_t config_id)
{
    uint8_t cmd[] = {0x80,6,config_id,2,0,0,sizeof(USB_CONFIG_DESCRIPTOR),0};
    uint8_t* data = execute_control_transfer(target_device_address,cmd,NULL,max_packet_size);
    if (data==NULL)
        return false;
    USB_CONFIG_DESCRIPTOR config;
    memcpy(&config, data, sizeof(USB_CONFIG_DESCRIPTOR));
    configs.push_back(config);
    free (data);
    
    uint8_t cmd2[] = {0x80,6,config_id,2,0,0,(uint8_t)config.wTotalLength,0};
    uint8_t* data2 = execute_control_transfer(target_device_address,cmd2,NULL,max_packet_size);
    if (data2==NULL)
        return false;
    uint8_t* pointer = data2+sizeof(USB_CONFIG_DESCRIPTOR);
    for (int i=0;i<config.bNumInterfaces;i++)
    {
        USB_INTERF_DESCRIPTOR interface;
        memcpy (&interface,pointer,sizeof(USB_INTERF_DESCRIPTOR));
        if (interface.bLength!=sizeof(USB_INTERF_DESCRIPTOR))
            error ("ERROR: USB interface descriptor not read");
        interfaces.push_back(interface);
        pointer+=sizeof(USB_INTERF_DESCRIPTOR);
        
        if (interface.bInterfaceClass==0x03) // HID
        {
            USB_HID_DESCRIPTOR hid;
            memcpy (&hid,pointer,sizeof(USB_INTERF_DESCRIPTOR));
            if (hid.bLength!=sizeof(USB_HID_DESCRIPTOR))
                error ("ERROR: USB HID descriptor not read");
            hids.push_back(hid);
            pointer+=sizeof(USB_HID_DESCRIPTOR);
        }
        for (int j=0;j<interface.bNumEndpoints;j++)
        {
            USB_ENDPOINT_DESCRIPTOR endpoint;
            memcpy (&endpoint,pointer,sizeof(USB_INTERF_DESCRIPTOR));
            if (endpoint.bLength!=sizeof(USB_ENDPOINT_DESCRIPTOR))
                error ("ERROR: USB endpoint descriptor not read");
            endpoints.push_back(endpoint);
            pointer+=sizeof(USB_ENDPOINT_DESCRIPTOR);
        }
    }
    free (data2);
    return true;
}

std::string utf16_to_utf8(std::u16string const& s)
{
    std::wstring_convert<std::codecvt_utf8_utf16<char16_t, 0x10ffff,
        std::codecvt_mode::little_endian>, char16_t> cnv;
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
    uint8_t* data = execute_control_transfer(target_device_address,cmd,NULL,max_packet_size);
    if (data==NULL)
           return no_data;
    uint8_t len = data[0];
    uint8_t type = data[1];
    std::u16string str = (char16_t*) (data+2);
    std::string str8 = utf16_to_utf8(str);
    return str8;
}
// USB HID COMMANDS
///////////////////////////////////////////////////////////////////////////
bool set_protocol2 (uint8_t target_device_address,uint8_t protocol_id,uint8_t interface)
{
    uint8_t cmd[] = {0x21,0x0B,protocol_id,0,interface,0,0,0};
    uint8_t* data = execute_control_transfer(target_device_address,cmd,NULL,max_packet_size);
    if (data==NULL)
        return false;
    return true;
}
bool set_idle2 (uint8_t target_device_address,uint8_t duration,uint8_t report_id, uint8_t interface)
{
    uint8_t cmd[] = {0x21,0x0A,report_id,duration,interface,0,0,0};
    uint8_t* data = execute_control_transfer(target_device_address,cmd,NULL,max_packet_size);
    if (data==NULL)
        return false;
    return true;
}
// USB COMMANDS
///////////////////////////////////////////////////////////////////////////
bool set_address2 (uint8_t target_device_address)
{
    uint8_t cmd[] = {0x00,0x05,target_device_address,0,0,0,0,0};
    uint8_t* data = execute_control_transfer(0,cmd,NULL,max_packet_size);
    if (data==NULL)
        return false;
    return true;
}
bool set_configuration2 (uint8_t target_device_address,uint8_t configuration_id)
{
    uint8_t cmd[] = {0x00,0x09,configuration_id,0,0,0,0,0};
    uint8_t* data = execute_control_transfer(target_device_address,cmd,NULL,max_packet_size);
    if (data==NULL)
        return false;
    return true;
}
// USB HID BOOT DEVICE INTERRUPT READOUT
///////////////////////////////////////////////////////////////////////////
bool read_boot_mouse (uint8_t target_device_address,uint8_t mouse_endpoint_id,uint8_t mouse_millis,uint16_t mouse_in_packetsize)
{
    uint8_t direction = 0;
    while (true)
    {
        uint8_t* buffer = data_in_transfer(mouse_in_packetsize, target_device_address,mouse_endpoint_id, max_packet_size, direction);
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
    uint8_t direction = 0;
    while (true)
    {
        uint8_t* buffer = data_in_transfer(in_packetsize, target_device_address,endpoint_id, max_packet_size, direction);
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

#define DEV_ADDRESS 1
#define BOOT_PROTOCOL 0
#define HID_CLASS 0x03
#define HID_BOOT 0x01
#define HID_KEYBOARD 0x01
#define HID_MOUSE 0x02
int main(int argc, const char * argv[]) {
    init_serial();
    reset_all();
    check_exists();
    
    //if (!set_usb_host_mode(CH375_USB_MODE_HOST))
    //    error ("ERROR: host mode not succeeded\n");
    set_usb_host_mode(CH375_USB_MODE_HOST_RESET);
    if (!set_usb_host_mode(CH375_USB_MODE_HOST))
        error ("ERROR: host mode not succeeded\n");
    
    bool result = get_device_descriptor2();
    if (!result)
    {
        // 2-set to 1.5 Mhz low-speed mode, 0-set to 12 Mhz high-speed mode (default)
        set_speed(2);
        result = get_device_descriptor2();
    }
    if (!result)
        error("unable to get device descriptor");
    set_address2 (DEV_ADDRESS);
    for (int i=0;i<device.bNumConfigurations;i++)
        get_configuration_descriptor2(DEV_ADDRESS,i);
    
    printf ("Manufacturer ID: %s\n",get_string2 (DEV_ADDRESS,device.iManufacturer).c_str());
    printf ("Product ID: %s\n",get_string2 (DEV_ADDRESS,device.iProduct).c_str());
    printf ("VID:PID: %04X:%04X\n",device.idVendor,device.idProduct);
    printf ("Serial: %s\n",get_string2 (DEV_ADDRESS,device.iSerialNumber).c_str());
    printf ("Device Class: %02X\n",device.bDeviceClass);
    printf ("Device SubClass: %02X\n",device.bDeviceSubClass);
    printf ("Device Protocol: %02X\n",device.bDeviceProtocol);
    int interface_nr = 0;
    int hid_nr = 0;
    int endpoint_nr = 0;
    uint8_t mouse_endpoint,mouse_millis,mouse_interface;
    uint16_t mouse_packetsize;
    uint8_t keyboard_endpoint,keyboard_millis,keyboard_interface;
    uint16_t keyboard_packetsize;
    for (int j=0;j<configs.size();j++)
    {
        printf ("\nCONFIGURATION: %d\n",j);
        printf ("Serial: %s\n",get_string2 (DEV_ADDRESS,configs[j].iConfiguration).c_str());
        printf ("Configuration ID: %d\n",configs[j].bConfigurationvalue);
        for (int i=0;i<configs[j].bNumInterfaces;i++)
        {
            printf ("\n\tINTERFACE: %d\n",interfaces[interface_nr].bInterfaceNumber);
            printf ("\tName: %s\n",get_string2(DEV_ADDRESS, interfaces[interface_nr].iInterface).c_str());
            printf ("\tInterface Class: %02X\n",interfaces[interface_nr].bInterfaceClass);
            printf ("\tInterface SubClass: %02X\n",interfaces[interface_nr].bInterfaceSubClass);
            printf ("\tInterface Protocol: %02X\n",interfaces[interface_nr].bInterfaceProtocol);
            
            if (interfaces[interface_nr].bInterfaceClass==HID_CLASS) // HID
            {
                const char* boot = interfaces[interface_nr].bInterfaceSubClass==HID_BOOT?"BOOT":"";
                if (interfaces[interface_nr].bInterfaceProtocol==HID_KEYBOARD)
                    printf ("\tHID Keyboard %s\n",boot);
                if (interfaces[interface_nr].bInterfaceProtocol==HID_MOUSE)
                    printf ("\tHID Mouse %s\n",boot);
                printf ("\tHID: %d\n",hid_nr);
                printf ("\tHID descriptor type: %0x\n",hids[hid_nr].descriptor_type);
                printf ("\tHID descriptor length: %d\n",hids[hid_nr++].descriptor_length);
            }
            for (int i=0;i<interfaces[interface_nr].bNumEndpoints;i++)
            {
                const char* direction = endpoints[endpoint_nr].bEndpointAddress&0b10000000?"IN":"OUT";
                printf ("\tENDPOINT: %d %s\n",endpoint_nr,direction);
                printf ("\tEndpoint address: %02X\n",endpoints[endpoint_nr].bEndpointAddress);
                
                if (interfaces[interface_nr].bInterfaceSubClass==HID_BOOT &&
                    interfaces[interface_nr].bInterfaceProtocol==HID_MOUSE) {
                    mouse_endpoint = endpoints[endpoint_nr].bEndpointAddress&0x0f;
                    mouse_millis = endpoints[endpoint_nr].bInterval;
                    mouse_packetsize = endpoints[endpoint_nr].wMaxPacketSize;
                    mouse_interface = interfaces[interface_nr].bInterfaceNumber;
                }
                if (interfaces[interface_nr].bInterfaceSubClass==HID_BOOT &&
                    interfaces[interface_nr].bInterfaceProtocol==HID_KEYBOARD) {
                    keyboard_endpoint = endpoints[endpoint_nr].bEndpointAddress&0x0f;
                    keyboard_millis = endpoints[endpoint_nr].bInterval;
                    keyboard_packetsize = endpoints[endpoint_nr].wMaxPacketSize;
                    keyboard_interface = interfaces[interface_nr].bInterfaceNumber;
                }
                endpoint_nr++;
            }
            
            interface_nr++;
        }
    }
    // enable device configuration
    set_configuration2(DEV_ADDRESS,configs[0].bConfigurationvalue);
    // set boot protocol for mouse and read it
    set_protocol2 (DEV_ADDRESS,BOOT_PROTOCOL,mouse_interface); // select boot protocol for our device
    //set_idle2(DEV_ADDRESS, 0x0, 0,mouse_interface); // wait on change
    // set boot protocol for keyboard and read it
    set_protocol2 (DEV_ADDRESS,BOOT_PROTOCOL,keyboard_interface); // select boot protocol for our device
    set_idle2(DEV_ADDRESS, 0x80, 0,keyboard_interface); // scan every ~500ms
    
    read_boot_keyboard (DEV_ADDRESS,keyboard_endpoint,keyboard_millis,keyboard_packetsize); // assume endpoint 2
    //read_boot_mouse (DEV_ADDRESS,mouse_endpoint,mouse_millis,mouse_packetsize); // assume endpoint 2
    return 0;
}
