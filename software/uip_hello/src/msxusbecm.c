#include "msxusbecm.h"
#include "stdint.h"
#include "msxusb.h"
#include <asm.h>
#include "stdio.h"
#include <string.h>
#include "uip.h"

#define USB_DEBUG 0

__at (0xe000) uint8_t msxusb_jumptable;
__at (0xd000) uint8_t descriptor;

unapi_code_block unapi;
Z80_registers regs;

#define PACKET_TYPE_MULTICAST       0b00010000
#define PACKET_TYPE_BROADCAST       0b00001000
#define PACKET_TYPE_DIRECTED        0b00000100
#define PACKET_TYPE_ALL_MULTICAST   0b00000010
#define PACKET_TYPE_PROMISCUOUS     0b00000001

enum MsxUsbUnapiFunctions {
    USB_INFO = 0,
    USB_CHECK,
    USB_CONNECT,
    USB_GETDESCRIPTORS,
    USB_CONTROL_TRANSFER,
    USB_DATA_IN_TRANSFER,
    USB_DATA_OUT_TRANSFER,
    USB_SYNC_MODE,
    USB_CONTROL_PACKET,
    USB_JUMP_TABLE
};

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

typedef struct _USB_ETHERNET_HEADER_DESCRIPTOR {
     uint8_t bLength;
     uint8_t bDescriptorType;
     uint8_t bDescriptorSubType;
     uint16_t bcdCDC;
 } USB_ETHERNET_HEADER_DESCRIPTOR;

typedef struct _USB_ETHERNET_UNION_DESCRIPTOR {
     uint8_t bLength;
     uint8_t bDescriptorType;
     uint8_t bDescriptorSubType;
     uint8_t bControlInterface;
     uint8_t bSubordinateInterface0;
     uint8_t bSubordinateInterface1;
     uint8_t bSubordinateInterface2;
     uint8_t bSubordinateInterface3;
 } USB_ETHERNET_UNION_DESCRIPTOR;

typedef struct _USB_HUB_DESCRIPTOR 
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

struct _ethernet_info 
{
    uint8_t ethernet_data_interface,ethernet_control_interface;
    uint8_t ethernet_interrupt_endpoint,ethernet_bulk_in_endpoint,ethernet_bulk_out_endpoint;
    uint8_t ethernet_interrupt_millis;
    uint16_t ethernet_interrupt_packetsize,ethernet_bulk_in_packetsize,ethernet_bulk_out_packetsize;
    uint8_t configuration_id;
    uint8_t ethernet_alternate_setting;
    uint8_t device_address;
    uint16_t ethernet_max_segment_size;
    uint8_t ethernet_mac_address_string_id;
    uint8_t max_packet_size;
} ethernet_info;

bool isCDCECM (uint8_t *buffer)
{
    USB_DEVICE_DESCRIPTOR* device;
    USB_CONFIG_DESCRIPTOR* config=NULL;
    USB_INTERF_DESCRIPTOR* interface;
    USB_ENDPOINT_DESCRIPTOR* endpoint;
    USB_ETHERNET_DESCRIPTOR* ethernet;
    
    ethernet_info.ethernet_control_interface = 255;
    uint8_t num_configs = 255;
    uint16_t descriptorsize = sizeof (USB_DEVICE_DESCRIPTOR);

    uint8_t *ptr = buffer;
    while ((ptr-buffer)<descriptorsize || num_configs>0)
    {
        switch (*(ptr+1))
        {
            case 0x01: // DEVICE_DESCRIPTOR
                device = (USB_DEVICE_DESCRIPTOR*) ptr;
                ethernet_info.max_packet_size = device->bMaxPacketSize0;
                num_configs = device->bNumConfigurations;
                ptr += *ptr;
                break;
            case 0x02: // CONFIG_DESCRIPTOR
                config = (USB_CONFIG_DESCRIPTOR*) ptr;
                descriptorsize = descriptorsize + config->wTotalLength;
                num_configs--;
                ptr += *ptr;
                break;
            case 0x04: // interface descriptor
                interface = (USB_INTERF_DESCRIPTOR*) ptr;
                if (interface->bInterfaceClass==0x02 && interface->bInterfaceSubClass==0x06)
                    ethernet_info.ethernet_control_interface = interface->bInterfaceNumber;
                if (interface->bInterfaceClass==0x0A && interface->bInterfaceSubClass==0x00)
                {
                    ethernet_info.ethernet_data_interface = interface->bInterfaceNumber;
                    if (interface->bAlternateSetting!=0)
                        ethernet_info.ethernet_alternate_setting = interface->bAlternateSetting;
                }
                ptr += *ptr;
                break;
            case 0x05: // endpoint descriptor
                endpoint = (USB_ENDPOINT_DESCRIPTOR*) ptr;
                if (interface->bInterfaceClass==0x02 && interface->bInterfaceSubClass==0x06) // ethernet control
                {
                    if ((endpoint->bmAttributes&0b00000011) == 0b11) // interrupt
                    {
                        ethernet_info.ethernet_interrupt_endpoint = endpoint->bEndpointAddress&0b01111111;
                        ethernet_info.ethernet_interrupt_millis = endpoint->bInterval;
                        ethernet_info.ethernet_interrupt_packetsize = endpoint->wMaxPacketSize;
                    }
                    ethernet_info.configuration_id = config->bConfigurationvalue;
                }
                if (interface->bInterfaceClass==0x0a && interface->bInterfaceSubClass==0x00) // ethernet data
                {
                    if ((endpoint->bmAttributes&0b00000011) == 0b10 && endpoint->bEndpointAddress&0b10000000) // bulk IN
                    {
                        ethernet_info.ethernet_bulk_in_endpoint = endpoint->bEndpointAddress&0b01111111;
                        ethernet_info.ethernet_bulk_in_packetsize = endpoint->wMaxPacketSize;
                    }      
                    if ((endpoint->bmAttributes&0b00000011) == 0b10 && !(endpoint->bEndpointAddress&0b10000000)) // bulk OUT
                    {
                        ethernet_info.ethernet_bulk_out_endpoint = endpoint->bEndpointAddress&0b01111111;
                        ethernet_info.ethernet_bulk_out_packetsize = endpoint->wMaxPacketSize;
                    }                     
                }
                ptr += *ptr;
                break;
            case 0x24: // CDC ECM / CS_INTERFACE
                switch (*(ptr+2)) // subtype
                {
                    case 0x0f: // ethernet
                        ethernet = (USB_ETHERNET_DESCRIPTOR*) ptr;
                        ethernet_info.ethernet_max_segment_size = ethernet->wMaxSegmentSize;
                        ethernet_info.ethernet_mac_address_string_id = ethernet->iMACAddress;
                        break;
                }
                ptr += *(ptr);
                break;
            default:
                ptr += *ptr;
                break;
        }
    }

    if (ethernet_info.ethernet_control_interface!=255)
        return true;

    return false;
}

bool set_ethernet_config ()
{
    regs.Words.BC = 2*8; // CMD_SET_CONFIGURATION;
    AsmCall(((uint16_t)&msxusb_jumptable)+FN_CONTROL_PACKET,&regs, REGS_MAIN, REGS_MAIN);
    uint8_t* control_packet = (uint8_t*) regs.Words.HL;
    *(control_packet+2) = ethernet_info.configuration_id;
    regs.Bytes.B = ethernet_info.max_packet_size;
    regs.Bytes.C = ethernet_info.device_address;
    regs.Words.DE = 0;
    AsmCall(((uint16_t)&msxusb_jumptable)+FN_CONTROL_TRANSFER,&regs, REGS_MAIN, REGS_AF);

    return regs.Bytes.A==0x14;
}
bool set_alternate_interface ()
{
    regs.Words.BC = 5*8; // CMD_SET_INTERFACE;
    AsmCall(((uint16_t)&msxusb_jumptable)+FN_CONTROL_PACKET,&regs, REGS_MAIN, REGS_MAIN);
    uint8_t* control_packet = (uint8_t*) regs.Words.HL;
    *(control_packet+2) = ethernet_info.ethernet_alternate_setting;
    *(control_packet+4) = ethernet_info.ethernet_data_interface;
    regs.Bytes.B = ethernet_info.max_packet_size;
    regs.Bytes.C = ethernet_info.device_address;
    regs.Words.DE = 0;
    AsmCall(((uint16_t)&msxusb_jumptable)+FN_CONTROL_TRANSFER,&regs, REGS_MAIN, REGS_AF);

    return regs.Bytes.A==0x14;
}
bool get_mac (char* buffer)
{
    regs.Words.BC = 3*8; // CMD_GET_STRING;
    AsmCall(((uint16_t)&msxusb_jumptable)+FN_CONTROL_PACKET,&regs, REGS_MAIN, REGS_MAIN);
    uint8_t* control_packet = (uint8_t*) regs.Words.HL;
    *(control_packet+2) = ethernet_info.ethernet_mac_address_string_id;
    regs.Bytes.B = ethernet_info.max_packet_size;
    regs.Bytes.C = ethernet_info.device_address;
    regs.Words.DE = (uint16_t) buffer;
    AsmCall(((uint16_t)&msxusb_jumptable)+FN_CONTROL_TRANSFER,&regs, REGS_MAIN, REGS_AF);

    return regs.Bytes.A==0x14;
}
bool set_packet_filter (uint8_t filter) 
{
    regs.Words.BC = 6*8; // CMD_SET_PACKET_FILTER;
    AsmCall(((uint16_t)&msxusb_jumptable)+FN_CONTROL_PACKET,&regs, REGS_MAIN, REGS_MAIN);
    uint8_t* control_packet = (uint8_t*) regs.Words.HL;
    *(control_packet+2) = filter;
    *(control_packet+4) = ethernet_info.ethernet_control_interface;
    regs.Bytes.B = ethernet_info.max_packet_size;
    regs.Bytes.C = ethernet_info.device_address;
    regs.Words.DE = 0;
    AsmCall(((uint16_t)&msxusb_jumptable)+FN_CONTROL_TRANSFER,&regs, REGS_MAIN, REGS_AF);

    return regs.Bytes.A==0x14;
}
void set_retry (uint8_t syncmode)
{
    regs.Bytes.B = syncmode;
    AsmCall(((uint16_t)&msxusb_jumptable)+FN_SYNC_MODE,&regs, REGS_MAIN, REGS_NONE);
    return;
}

uint8_t two_hexascii_to_byte (uint8_t a1,uint8_t a2)
{
    uint8_t hn = a1 - '0';
    if (hn>9)
        hn -= ('A'-'9'-1);
    uint8_t ln = a2 - '0';
    if (ln>9)
        ln -= ('A'-'9'-1);
    return hn*16+ln;
}

bool msxusbecm_init (struct uip_eth_addr* mac)
{
    int i = UnapiGetCount("MSXUSB");
    if(i==0) {
        printf("- No MSX USB UNAPI implementations found\r\n");
        return false;
    }
    printf ("+MSXUSB UNAPI found\r\n");

    UnapiBuildCodeBlock(NULL, i, &unapi);
    regs.Words.HL = (uint16_t) &msxusb_jumptable;
    UnapiCall(&unapi,USB_JUMP_TABLE, &regs, REGS_MAIN, REGS_NONE);
    AsmCall(((uint16_t)&msxusb_jumptable)+FN_CONNECT,&regs, REGS_NONE, REGS_AF);
    int highest_address = regs.Bytes.A;
    if (highest_address==0)
    {
        printf ("-USB device not connected\r\n");
        return false;
    }
    else
        printf ("+%d USB device(s) connected\r\n",highest_address);

    for (int d=1;d<=highest_address;d++) {
        regs.UWords.HL = (uint16_t) &descriptor;
        regs.Bytes.D = d;
        AsmCall(((uint16_t)&msxusb_jumptable)+FN_GETDESCRIPTORS,&regs, REGS_MAIN, REGS_AF);
        if (regs.Flags.C!=0)
            return false; // error
        if (isCDCECM(&descriptor)) {
            printf ("+USB CDC ECM adapter found [%d]\r\n",d);
            ethernet_info.device_address = d;
        
            char buffer[255];
            if (get_mac ((char*) &buffer)) {
                char* buf = buffer+2;
                mac->addr[0] = two_hexascii_to_byte (*buf,*(buf+2));
                mac->addr[1] = two_hexascii_to_byte (*(buf+4),*(buf+6));
                mac->addr[2] = two_hexascii_to_byte (*(buf+8),*(buf+10));
                mac->addr[3] = two_hexascii_to_byte (*(buf+12),*(buf+14));
                mac->addr[4] = two_hexascii_to_byte (*(buf+16),*(buf+18));
                mac->addr[5] = two_hexascii_to_byte (*(buf+20),*(buf+22));
                printf ("+MAC address: %x:%x:%x:%x:%x:%x\r\n",mac->addr[0],mac->addr[1],mac->addr[2],mac->addr[3],mac->addr[4],mac->addr[5]);
            }
            // set ethernet config
            if (!set_ethernet_config ())
                return false;
            // set alternate interface
            if (!set_alternate_interface ())
                return false;
            // set filter to DIRECT+BROADCAST
            if (!set_packet_filter (PACKET_TYPE_DIRECTED+PACKET_TYPE_BROADCAST))
            //if (!set_packet_filter (PACKET_TYPE_PROMISCUOUS))
                return false;
            // set retries to NO retries
            // set NAK retries to return immediately
            // this way we can poll status and keep things snappy
            // Bits 7 and 6:
            //   0x: Don't retry NAKs
            //   10: Retry NAKs indefinitely (default)
            //   11: Retry NAKs for 3s
            // Bits 5-0: Number of retries after device timeout
            // Default after reset and SET_USB_MODE is 8Fh
            set_retry (0b00001111);

            // start communicating
            return true;
        }
    }
    printf ("-USB CDC ECM adapter NOT found\r\n");
    return false;
}

uint8_t endpoint_read_toggle = 0;
unsigned int  msxusbecm_read ()
{
    regs.Words.HL = (uint16_t) &uip_buf;
    regs.Words.BC = ethernet_info.ethernet_max_segment_size;
    regs.Bytes.D = ethernet_info.max_packet_size;
    regs.Bytes.E = ethernet_info.ethernet_bulk_in_endpoint+(ethernet_info.device_address<<4);
    regs.Flags.C = endpoint_read_toggle!=0;
    AsmCall(((uint16_t)&msxusb_jumptable)+FN_DATA_IN_TRANSFER,&regs, REGS_MAIN, REGS_AF);
    if (regs.Bytes.A!=0x14) {
        //printf ("Error reading packet\r\n");
        regs.Words.BC = 0;
    }
    else {
        //printf ("Read %d bytes\r\n",regs.Words.BC);
        #if USB_DEBUG
        printf ("<< dst: %x:%x:%x:%x:%x:%x - src: %x:%x:%x:%x:%x:%x - type: %x\r\n",
            *(uip_buf+0),*(uip_buf+1),*(uip_buf+2),*(uip_buf+3),*(uip_buf+4),*(uip_buf+5), // dst
            *(uip_buf+6),*(uip_buf+7),*(uip_buf+8),*(uip_buf+9),*(uip_buf+10),*(uip_buf+11), // src
            ((*(uip_buf+12))<<8)+((*(uip_buf+13))));// EtherType
        #endif 
    }
    endpoint_read_toggle = regs.Flags.C;
    return regs.Words.BC;
}

uint8_t endpoint_write_toggle = 0;
void msxusbecm_send ()
{
    #if USB_DEBUG
    printf (">> dst: %x:%x:%x:%x:%x:%x - src: %x:%x:%x:%x:%x:%x - type: %x\r\n",
            *(uip_buf+0),*(uip_buf+1),*(uip_buf+2),*(uip_buf+3),*(uip_buf+4),*(uip_buf+5), // dst
            *(uip_buf+6),*(uip_buf+7),*(uip_buf+8),*(uip_buf+9),*(uip_buf+10),*(uip_buf+11), // src
            ((*(uip_buf+12))<<8)+((*(uip_buf+13))));// EtherType
    #endif
    regs.Words.HL = (uint16_t) &uip_buf;
    regs.Words.BC = uip_len;
    regs.Bytes.D = ethernet_info.max_packet_size;
    regs.Bytes.E = ethernet_info.ethernet_bulk_out_endpoint+(ethernet_info.device_address<<4);
    regs.Flags.C = endpoint_write_toggle!=0;
    AsmCall(((uint16_t)&msxusb_jumptable)+FN_DATA_OUT_TRANSFER,&regs, REGS_MAIN, REGS_AF);
    if (regs.Bytes.A) {
        printf ("Error writing packet %d [%d]\r\n",regs.Bytes.A);
        regs.Words.BC=0;
    }
    endpoint_write_toggle = regs.Flags.C;
}