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
/*
    Compilation command line:
   
   sdcc --code-loc 0x170 --data-loc 0 -mz80 --disable-warning 196
        --no-std-crt0 crt0_msxdos_advanced.rel msxchar.rel asm.lib lsusb.c
   hex2bin -e com eth.ihx
   
   ASM.LIB, MSXCHAR.REL and crt0msx_msxdos_advanced.rel
   are available at www.konamiman.com
   
   (You don't need MSXCHAR.LIB if you manage to put proper PUTCHAR.REL,
   GETCHAR.REL and PRINTF.REL in the standard Z80.LIB... I couldn't manage to
   do it, I get a "Library not created with SDCCLIB" error)
   
   Comments are welcome: sourceror@neximus.com
*/

#include "lsusb.h"
#include <stdio.h>
#include <arch/msx.h>

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

enum EthUnapiFunctions {
    USB_INFO = 0,
    USB_JUMPTABLE,
    USB_CHECK,
    USB_CONNECT,
    USB_GETDESCRIPTORS,
    USB_EXECUTE_CONTROL_TRANSFER,
    USB_DATA_IN_TRANSFER,
    USB_DATA_OUT_TRANSFER
};

const char* strPresentation=
    "lsusb - list descriptors of connected USB device\r\n"
    "(c) Sourceror 2020\r\n"
    "\r\n";

const char* strUsage=
    "Usage: lsusb [-v]\r\n"
    "\r\n"
    "v: Verbose\r\n";

Z80_registers regs;
uint specVersion;
unapi_code_block codeBlock;
char jumptable[6*8];
    
int main(char** argv, int argc)
{
    char paramLetter;
    uint8_t slot;
    uint8_t segment;
    uint16_t address;

    print(strPresentation);
    int i = UnapiGetCount("MSXUSB");
    if(i==0) {
        print("*** No MSX USB UNAPI implementations found");
        return 0;
    }
    UnapiBuildCodeBlock(NULL, i, &codeBlock);
    UnapiParseCodeBlock (&codeBlock, &slot, &segment, &address);
    printf ("Found implementation in slot: %d, segment: %d, address: %x\n",slot,segment,address);
    GetJumpTable ();
    PrintImplementationName();
    PrintDescriptors ();
    return 0;    
}

/****************************
 ***  FUNCTIONS are here  ***
 ****************************/

void PrintUsageAndEnd()
{
    print(strUsage);
    DosCall(0, &regs, REGS_MAIN, REGS_NONE);
}


void PrintImplementationName()
{
    byte readChar;
    byte versionMain;
    byte versionSec;
    uint nameAddress;
    
    print("Implementation name: ");
    UnapiCall(&codeBlock, USB_INFO, &regs, REGS_NONE, REGS_MAIN);
    versionMain = regs.Bytes.B;
    versionSec = regs.Bytes.C;
    nameAddress = regs.UWords.HL;
    specVersion = regs.UWords.DE;   //Also, save specification version implemented
    
    while(1) {
        readChar = UnapiRead(&codeBlock, nameAddress);
        if(readChar == 0) {
            break;
        }
        putchar(readChar);
        nameAddress++;
    }
    
    printf(" v%u.%u\r\n\r\n", versionMain, versionSec);
}

void PrintDescriptors ()
{
    char buffer[512];

    //AsmCall(jumptable,&regs, REGS_NONE, REGS_MAIN);
    UnapiCall(&codeBlock, USB_CHECK, &regs, REGS_NONE, REGS_MAIN);
    if (regs.Flags.C)
    {
        printf ("CH376s not available\n");
        return;
    }
    //AsmCall(jumptable+8,&regs, REGS_NONE, REGS_MAIN);
    UnapiCall(&codeBlock, USB_CONNECT, &regs, REGS_NONE, REGS_MAIN);
    if (regs.Flags.C)
    {
        printf ("USB device not connected\n");
        return;
    }
    regs.UWords.HL = buffer;
    //AsmCall(jumptable+16,&regs, REGS_MAIN, REGS_MAIN);
    UnapiCall(&codeBlock, USB_GETDESCRIPTORS, &regs, REGS_MAIN, REGS_MAIN);
    if (regs.Flags.C)
    {
        printf ("USB descriptors not read\n");
        return;
    }
    char *ptr = buffer;
    USB_DEVICE_DESCRIPTOR* device=NULL;
    USB_CONFIG_DESCRIPTOR* config=NULL;
    USB_INTERF_DESCRIPTOR* interface;
    USB_ENDPOINT_DESCRIPTOR* endpoint;
    USB_HID_DESCRIPTOR* hid;
    while (config==NULL || ptr < (buffer + device->bLength + config->wTotalLength))
    {
        printf ("Scanning: 0x%04x (%d)\n",ptr,*ptr);
        switch (*(ptr+1))
        {
            case 1: // DEVICE_DESCRIPTOR
                device = (USB_DEVICE_DESCRIPTOR*) ptr;
                printf ("Device Descriptor:\n");
                printf ("  bLength\t\t\t%d\n",device->bLength);
                printf ("  bDescriptorType\t\t%d\n",device->bDescriptorType);
                printf ("  bcdUSB\t\t\t%d.%d\n",(device->bcdUSB & 0xff00)>>8, device->bcdUSB & 0xff);
                printf ("  bDeviceClass\t\t\t%d\n",device->bDeviceClass);
                printf ("  bDeviceSubClass\t\t%d\n",device->bDeviceSubClass);
                printf ("  bDeviceProtocol\t\t%d\n",device->bDeviceProtocol);
                printf ("  idVendor\t\t\t0x%04x\n",device->idVendor);
                printf ("  idProduct\t\t\t0x%04x\n",device->idProduct);
                printf ("  bcdDevice\t\t\t%d.%d\n",(device->bcdDevice & 0xff00)>>8, device->bcdDevice & 0xff);
                printf ("  iManufacturer\t\t\t%d\n",device->iManufacturer);
                printf ("  iProduct\t\t\t%d\n",device->iProduct);
                printf ("  iSerial\t\t\t%d\n",device->iSerial);
                printf ("  bNumConfigurations\t\t%d\n",device->bNumConfigurations);
                ptr += *ptr;
                break;
            case 2: // CONFIG_DESCRIPTOR
                config = (USB_CONFIG_DESCRIPTOR*) ptr;
                printf ("  Configuration Descriptor:\n");
                printf ("    bLength\t\t\t%d\n",config->bLength);
                printf ("    bDescriptorType\t\t%d\n",config->bDescriptorType);
                printf ("    wTotalLength\t\t%d\n",config->wTotalLength);
                printf ("    bNumInterfaces\t\t%d\n",config->bNumInterfaces);
                printf ("    bConfigurationvalue\t\t%d\n",config->bConfigurationvalue);
                printf ("    iConfiguration\t\t%d\n",config->iConfiguration);
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
                printf ("      bInterfaceClass\t\t%d\n",interface->bInterfaceClass);
                printf ("      bInterfaceSubClass\t%d\n",interface->bInterfaceSubClass);
                printf ("      bInterfaceProtocol\t%d\n",interface->bInterfaceProtocol);
                printf ("      iInterface\t\t%d\n",interface->iInterface);
                ptr += *ptr;
                break;
            case 0x05: // endpoint descriptor
                endpoint = (USB_ENDPOINT_DESCRIPTOR*) ptr;
                printf ("      Endpoint Descriptor:\n");
                printf ("        bLength\t\t\t%d\n",endpoint->bLength);
                printf ("        bDescriptorType\t\t%d\n",endpoint->bDescriptorType);
                printf ("        bEndpointAddress\t%d\n",endpoint->bEndpointAddress);
                printf ("        bmAttributes\t\t%d\n",endpoint->bmAttributes);
                printf ("        wMaxPacketSize\t\t%d\n",endpoint->wMaxPacketSize);
                printf ("        bInterval\t\t%d\n",endpoint->bInterval);
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
                printf ("      CDC ECM Descriptor:\n");
                ptr += *ptr;
                break;
            default:
                ptr += *ptr;
                break;
        }
    }
}

void GetJumpTable ()
{
    regs.UWords.HL = jumptable;
    UnapiCall(&codeBlock, USB_JUMPTABLE, &regs, REGS_MAIN, REGS_MAIN);
    /*
    char *ptr = jumptable;
    for (int i=0;i<6;i++)
    {
        printf ("%04x: %02x %02x %02x %02x %02x %02x %02x %02x\n",ptr,*(ptr+0)&0xff,*(ptr+1)&0xff,*(ptr+2)&0xff,*(ptr+3)&0xff,*(ptr+4)&0xff,*(ptr+5)&0xff,*(ptr+6)&0xff,*(ptr+7)&0xff);
        ptr=ptr+8;
    }
    */
}