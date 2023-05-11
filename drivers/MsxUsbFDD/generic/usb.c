#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "../include/usb.h"
#include "../include/ch376s.h"
#include "../include/hal.h"

void usb_init ()
{
    printf ("MSXUSB-FDD Firmware v1.0 (c)The Retro Hacker\r\n");
    ch376_reset_all();
    if (!ch376_plugged_in())
    {
        error ("-CH376 NOT detected");
    }
    else 
    {
        const uint8_t ver = ch376_get_ic_version();
        printf ("\n+CH376 detected (version %d)\r\n",ver);
    }

    ch376_set_usb_host_mode(USB_MODE_HOST);

    //now we need to enumerate the USB devices connected and report
    printf ("+Scanning USB devices...\r\n");

    enumerate_all_devices();

    while (true)
    {
        char c = getchar ();
    }

    //if (!ch376_connect_disk ())
    //   error ("-Connect USB device");
    //else
    //    printf ("+USB device connected\r\n");
    //if (!ch376_mount_disk ())
    //    error ("-Not a valid disk");
    //printf ("+USB disk mounted\r\n");
}


// return the pointer to the allocated workarea
work_area* get_work_area() __z88dk_fastcall __naked
{
    __asm
    GWORK .equ 0x4045
    CALBNK .equ 0x4042
    push ix
    xor a
    ex af,af' ;'
    xor a
    LD	ix,#GWORK
	call CALBNK
    ld l,0(ix)
    ld h,1(ix)
    pop ix
    ret
    __endasm;
} 

_usb_state *get_usb_work_area() {
  work_area *const p = get_work_area();
  return &p->ch376;
}

usb_error hw_get_description(device_descriptor *const buffer)
{
    ch376_set_usb_address(0);

    usb_error result;

    result = ch376_control_transfer_request_descriptor(1);

    read_data_multiple((uint8_t *)buffer, 18);
    

    return USB_ERR_OK;
}

usb_error enumerate_all_devices()
{
    enumeration_state state;
    state.next_storage_device_index = (uint8_t)-1;
    state.next_device_address       = 20;

    return read_all_configs(&state);
    
}


void logDevice(const device_descriptor *const p) {
    printf("dev len=%d,", p->bLength);
    printf("typ=%d,", p->bDescriptorType);
    printf("USB=%02X,", p->bcdUSB);
    printf("cls=%02x,", p->bDeviceClass);
    printf("sub=%02x,", p->bDeviceSubClass);
    printf("pro=%02x,", p->bDeviceProtocol);
    printf("siz=%d,", p->bMaxPacketSize0);
    printf("ven=%04X,", p->idVendor);
    printf("prd=%04X,", p->idProduct);
    printf("dev=%d,", p->bcdDevice);
    printf("man=%d,", p->iManufacturer);
    printf("ipd=%d,", p->iProduct);
    printf("ser=%d,", p->iSerialNumber);
    printf("num=%d\r\n", p->bNumConfigurations);
}

usb_error get_config_descriptor(const uint8_t config_index, const uint8_t device_address, uint8_t *const buffer) {
  usb_error result;

  printf("Config %d, %d: ", config_index, device_address);
  //CHECK(hw_get_config_descriptor((config_descriptor *)buffer, config_index, sizeof(config_descriptor), device_address),
  //     x_printf("a %02x\r\n", result));
  // logConfig((config_descriptor *)buffer);

  //CHECK(hw_get_config_descriptor(
  //          (config_descriptor *)buffer, config_index, ((config_descriptor *)buffer)->wTotalLength, device_address),
   //     x_printf("b %02x\r\n", result));
  // printf("len: %d\r\n", ((config_descriptor *)buffer)->wTotalLength);

  // logConfig((config_descriptor *)buffer);

  return USB_ERR_OK;
}

usb_error op_get_config_descriptor(_working *const working)
{
  usb_error result;

  memset(working->config.buffer, 0, MAX_CONFIG_SIZE);

  result = get_config_descriptor(working->config_index, working->state->next_device_address, working->config.buffer);
  
  working->ptr             = (working->config.buffer + sizeof(config_descriptor));
  working->interface_count = working->config.desc.bNumInterfaces;

  //return op_identify_class_driver(working);
}


usb_error read_all_configs(enumeration_state *const state)
{
    uint8_t           result;
    _usb_state *const work_area = get_usb_work_area();

    _working working;
    memset(&working, 0, sizeof(_working));
    working.state = state;

    result = hw_get_description(&working.desc);
    logDevice(&working.desc);

    uint8_t dev_address = state->next_device_address;

    //printf("Device Address: %d,", dev_address);
    //printf("Num. Configs: %d\n", working.desc.bNumConfigurations);
    result = ch376_control_transfer_set_address(dev_address);

    for (uint8_t config_index = 0; config_index < working.desc.bNumConfigurations; config_index++) {
        working.config_index = config_index;

        result = op_get_config_descriptor(&working);
    }

    return USB_ERR_OK;
}

