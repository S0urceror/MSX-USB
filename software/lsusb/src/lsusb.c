/*
; lsusb.c - list the USB descriptors
; Copyright (c) 2020 Mario Smit (S0urceror)
; 
; This program is free software: you can redistribute it and/or modify  
; it under the terms of the GNU General Public License as published by  
; the Free Software Foundation, version 3.
;
; This program is distributed in the hope that it will be useful, but 
; WITHOUT ANY WARRANTY; without even the implied warranty of 
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
; General Public License for more details.
;
; You should have received a copy of the GNU General Public License 
; along with this program. If not, see <http://www.gnu.org/licenses/>.
;
*/
#include <msx_fusion.h>
#include <asm.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include "lsusb.h"
#include "msxusb.h"

#define LowerCase(c) ((c) | 32)

// Just in case you want to define a faster print function
// for printing plain strings (without formatting).
#define print(x) printf(x)
typedef unsigned char byte;

typedef struct _USB_DEVICE_DESCRIPTOR {
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

 typedef struct _USB_CONFIG_DESCRIPTOR {
     uint8_t bLength;
     uint8_t bDescriptorType;
     uint16_t wTotalLength;
     uint8_t bNumInterfaces;
     uint8_t bConfigurationvalue;
     uint8_t iConfiguration;
     uint8_t bmAttributes;
     uint8_t bMaxPower;
 } USB_CONFIG_DESCRIPTOR;

typedef struct _USB_HID_DESCRIPTOR {
    uint8_t bLength;
    uint8_t bDescriptorType;
    uint16_t hid_version;
    uint8_t country_code;
    uint8_t num_descriptors;
    uint8_t descriptor_type;
    uint16_t descriptor_length;
} USB_HID_DESCRIPTOR;

 typedef struct _USB_INTERF_DESCRIPTOR {
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

 typedef struct _USB_ENDPOINT_DESCRIPTOR {
     uint8_t bLength;
     uint8_t bDescriptorType;
     uint8_t bEndpointAddress;
     uint8_t bmAttributes;
     uint16_t wMaxPacketSize;
     uint8_t bInterval;
 } USB_ENDPOINT_DESCRIPTOR;

typedef struct _USB_ETHERNET_DESCRIPTOR {
     uint8_t bLength;
     uint8_t bDescriptorType;
     uint8_t bDescriptorSubType;
     uint8_t iMACAddress;
     uint32_t bmEthernetStatistics;
     uint16_t wMaxSegmentSize;
     uint16_t wNumberMCFilters;
     uint8_t bNumberPowerFilters;
 } USB_ETHERNET_DESCRIPTOR;

enum MsxUsbUnapiFunctions {
    USB_INFO = 0,
    USB_CHECK,
    USB_CONNECT,
    USB_GETDESCRIPTORS,
    USB_CONTROL_TRANSFER,
    USB_DATA_IN_TRANSFER,
    USB_DATA_OUT_TRANSFER,
    USB_SYNC_MODE,
    USB_CONTROL_PACKET
};
const char* strPresentation=
    "lsusb - list descriptors of connected USB device (c) Sourceror 2020\r\n"
    "\r\n";

const char* strUsage=
    "Usage: lsusb [-v]\r\n"
    "\r\n"
    "v: Verbose\r\n";

uint specVersion;

int main()
{
    uint8_t slot;
    uint8_t segment;
    uint16_t address;
    unapi_code_block unapi;

    print(strPresentation);
    int i = UnapiGetCount("MSXUSB");
    if(i==0) {
        print("*** No MSX USB UNAPI implementations found");
        return 0;
    }
    UnapiBuildCodeBlock(NULL, i, &unapi);
    UnapiParseCodeBlock (&unapi, &slot, &segment, &address);
    printf ("Found implementation:\r\nSlot: %d, segment: %d, address: 0x%x\r\n",slot,segment,address);
    PrintImplementationName(&unapi);
    PrintDescriptors (&unapi);
    return 0;    
}

/****************************
 ***  FUNCTIONS are here  ***
 ****************************/

void PrintUsageAndEnd()
{
    Z80_registers regs;
    print(strUsage);
    DosCall(0, &regs, REGS_MAIN, REGS_NONE);
}

void PrintImplementationName(unapi_code_block* unapi)
{
    byte readChar;
    byte versionMain;
    byte versionSec;
    uint nameAddress;
    Z80_registers regs;
    
    print("Implementation name: ");
    UnapiCall(unapi, USB_INFO, &regs, REGS_NONE, REGS_MAIN);
    versionMain = regs.Bytes.B;
    versionSec = regs.Bytes.C;
    nameAddress = regs.UWords.HL;
    specVersion = regs.UWords.DE;   //Also, save specification version implemented
    
    while(1) {
        readChar = UnapiRead(unapi, nameAddress);
        if(readChar == 0) {
            break;
        }
        putchar(readChar);
        nameAddress++;
    }
    
    printf(" v%u.%u\r\n\r\n", versionMain, versionSec);
}

int connected_devices (unapi_code_block* unapi)
{
    Z80_registers regs;

    UnapiCall(unapi, USB_CONNECT, &regs, REGS_NONE, REGS_AF);
    //AsmCall(jumptable+FN_CONNECT,&regs, REGS_NONE, REGS_AF);
    int highest_address = regs.Bytes.A;
    if (highest_address==0)
    {
        printf ("USB device not connected\r\n");
        return 0;
    }
    else
        printf ("%d USB device(s) connected\r\n",regs.Bytes.A);
    return regs.Bytes.A;
}

bool check_available (unapi_code_block* unapi)
{
    Z80_registers regs;

    UnapiCall(unapi, USB_CHECK, &regs, REGS_NONE, REGS_AF);
    //AsmCall(jumptable+FN_CHECK,&regs, REGS_NONE, REGS_AF);
    return regs.Flags.C==0;
}
bool get_descriptors (unapi_code_block* unapi, char* buffer, int device)
{
    Z80_registers regs;

    regs.UWords.HL = (uint16_t) buffer;
    regs.Bytes.D = device;
    UnapiCall(unapi, USB_GETDESCRIPTORS, &regs, REGS_MAIN, REGS_AF);
    //AsmCall(jumptable+FN_GETDESCRIPTORS,&regs, REGS_MAIN, REGS_AF);
    return regs.Flags.C==0;
}

void print_descriptors (char* buffer)
{
    char *ptr = buffer;
    const char *interface_class_name = "Unknown";
    const char *interface_subclass_name = "Unknown";
    const char *interface_protocol_name = "Unknown";
    USB_DEVICE_DESCRIPTOR* device=NULL;
    USB_CONFIG_DESCRIPTOR* config=NULL;
    USB_INTERF_DESCRIPTOR* interface;
    USB_ENDPOINT_DESCRIPTOR* endpoint;
    USB_HID_DESCRIPTOR* hid;
    while (config==NULL || ptr < (buffer + device->bLength + config->wTotalLength))
    {
        printf ("Scanning: 0x%x (%d)\r\n",ptr,*ptr);
        switch (*(ptr+1))
        {
            case 1: // DEVICE_DESCRIPTOR
                device = (USB_DEVICE_DESCRIPTOR*) ptr;
                printf ("Device Descriptor:\r\n");
                printf ("  bLength\t\t\t%d\r\n",device->bLength);
                printf ("  bDescriptorType\t\t%d\r\n",device->bDescriptorType);
                printf ("  bcdUSB\t\t\t%d.%d\r\n",(device->bcdUSB & 0xff00)>>8, device->bcdUSB & 0xff);
                printf ("  bDeviceClass\t\t\t%d\r\n",device->bDeviceClass);
                printf ("  bDeviceSubClass\t\t%d\r\n",device->bDeviceSubClass);
                printf ("  bDeviceProtocol\t\t%d\r\n",device->bDeviceProtocol);
                printf ("  bMaxPacketSize0\t\t%d\r\n",device->bMaxPacketSize0);
                printf ("  idVendor\t\t\t0x%x\r\n",device->idVendor);
                printf ("  idProduct\t\t\t0x%x\r\n",device->idProduct);
                printf ("  bcdDevice\t\t\t%d.%d\r\n",(device->bcdDevice & 0xff00)>>8, device->bcdDevice & 0xff);
                printf ("  iManufacturer\t\t\t%d\r\n",device->iManufacturer);
                printf ("  iProduct\t\t\t%d\r\n",device->iProduct);
                printf ("  iSerial\t\t\t%d\r\n",device->iSerial);
                printf ("  bNumConfigurations\t\t%d\r\n",device->bNumConfigurations);
                getchar ();
                ptr += *ptr;
                break;
            case 2: // CONFIG_DESCRIPTOR
                config = (USB_CONFIG_DESCRIPTOR*) ptr;
                printf ("  Configuration Descriptor:\r\n");
                printf ("    bLength\t\t\t%d\r\n",config->bLength);
                printf ("    bDescriptorType\t\t%d\r\n",config->bDescriptorType);
                printf ("    wTotalLength\t\t%d\r\n",config->wTotalLength);
                printf ("    bNumInterfaces\t\t%d\r\n",config->bNumInterfaces);
                printf ("    bConfigurationvalue\t\t%d\r\n",config->bConfigurationvalue);
                printf ("    iConfiguration\t\t%d\r\n",config->iConfiguration);
                printf ("    bmAttributes\t\t%d\r\n",config->bmAttributes);
                printf ("    bMaxPower\t\t\t%d\r\n",config->bMaxPower);
                getchar();
                device->bNumConfigurations--;
                ptr += *ptr;
                break;
            case 0x04: // interface descriptor
                interface = (USB_INTERF_DESCRIPTOR*) ptr;
                printf ("    Interface Descriptor:\r\n");
                printf ("      bLength\t\t\t%d\r\n",interface->bLength);
                printf ("      bDescriptorType\t\t%d\r\n",interface->bDescriptorType);
                printf ("      bInterfaceNumber\t\t%d\r\n",interface->bInterfaceNumber);
                printf ("      bAlternateSetting\t\t%d\r\n",interface->bAlternateSetting);
                printf ("      bNumEndpoints\t\t%d\r\n",interface->bNumEndpoints);
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
                printf ("      bInterfaceClass\t\t%d\t%s\r\n",interface->bInterfaceClass,interface_class_name);
                if (interface->bInterfaceClass==0x03 && interface->bInterfaceSubClass==0x01)
                    interface_subclass_name = "Boot";
                if (interface->bInterfaceClass==0x02 && interface->bInterfaceSubClass==0x06)
                    interface_subclass_name = "Ethernet Networking Control Model";
                if (interface->bInterfaceClass==0x08 && interface->bInterfaceSubClass==0x06)
                    interface_subclass_name = "SCSI command set";

                printf ("      bInterfaceSubClass\t%d\t%s\r\n",interface->bInterfaceSubClass,interface_subclass_name);
                if (interface->bInterfaceClass==0x03 && interface->bInterfaceProtocol==0x01)
                    interface_protocol_name = "Keyboard";
                if (interface->bInterfaceClass==0x03 && interface->bInterfaceProtocol==0x02)
                    interface_protocol_name = "Mouse";
                if (interface->bInterfaceClass==0x09 && interface->bInterfaceProtocol==0x00)
                    interface_protocol_name = "No TT";
                if (interface->bInterfaceClass==0x09 && interface->bInterfaceProtocol==0x01)
                    interface_protocol_name = "Single TT";
                if (interface->bInterfaceClass==0x09 && interface->bInterfaceProtocol==0x02)
                    interface_protocol_name = "Multi TT";

                printf ("      bInterfaceProtocol\t%d\t%s\r\n",interface->bInterfaceProtocol,interface_protocol_name);
                printf ("      iInterface\t\t%d\r\n",interface->iInterface);
                getchar();
                ptr += *ptr;
                break;
            case 0x05: // endpoint descriptor
                endpoint = (USB_ENDPOINT_DESCRIPTOR*) ptr;
                printf ("      Endpoint Descriptor:\r\n");
                printf ("        bLength\t\t\t%d\r\n",endpoint->bLength);
                printf ("        bDescriptorType\t\t%d\r\n",endpoint->bDescriptorType);
                printf ("        bEndpointAddress\t%d\r\n",endpoint->bEndpointAddress);
                printf ("        bmAttributes\t\t%d\r\n",endpoint->bmAttributes);
                printf ("        wMaxPacketSize\t\t%d\r\n",endpoint->wMaxPacketSize);
                printf ("        bInterval\t\t%d\r\n",endpoint->bInterval);
                getchar();
                ptr += *ptr;
                break;
            case 0x21: // HID descriptor
                hid = (USB_HID_DESCRIPTOR*) ptr;
                printf ("      HID Descriptor:\r\n");
                printf ("        bLength\t\t\t%d\r\n",hid->bLength);
                printf ("        bDescriptorType\t\t%d\r\n",hid->bDescriptorType);
                printf ("        bcdHID\t\t\t%d.%d\r\n",(hid->hid_version & 0xff00)>>8, hid->hid_version & 0xff);
                printf ("        bCountryCode\t\t%d\r\n",hid->country_code);
                printf ("        bNumDescriptors\t\t%d\r\n",hid->num_descriptors);
                printf ("        bDescriptorType\t\t%d\r\n",hid->descriptor_type);
                printf ("        wDescriptorLength\t%d\r\n",hid->descriptor_length);
                getchar();
                ptr += *ptr;
                break;
            case 0x24: // CDC ECM / CS_INTERFACE
                printf ("      CDC ECM Descriptor:\r\n");
                getchar();
                ptr += *ptr;
                break;
            default:
                ptr += *ptr;
                break;
        }
    }
}


//uint16_t GetJumpTable (unapi_code_block* unapi)
//{
//    Z80_registers regs;
//    regs.UWords.HL = 0; // ask for size
//    UnapiCall(unapi, USB_JUMPTABLE, &regs, REGS_MAIN, REGS_MAIN);
//    uint size = regs.UWords.HL;
//    uint16_t jumptable = (uint16_t) MMalloc (size);
//    regs.UWords.HL = jumptable;
//    UnapiCall(unapi, USB_JUMPTABLE, &regs, REGS_MAIN, REGS_MAIN);
//    printf (", jumptable of %d bytes at 0x%x\r\n\r\n",size,jumptable);
//    return jumptable;
//}

void PrintDescriptors (unapi_code_block* unapi)
{
    char buffer[512];

    if (!check_available (unapi))
    {
        printf ("CH376s not available\r\n");
        return;
    }

    int highest_address = connected_devices (unapi);
    
    for (int device = 1; device <= highest_address; device++)
    {
        printf ("\r\nReading descriptors of device: %d\r\n----------------------------------------------\r\n",device);
        if (!get_descriptors (unapi,buffer,device))
        {
            printf ("USB descriptors not read\r\n");
            return;
        }
        print_descriptors (buffer);
    }
}
