#ifndef __USB_H
#define __USB_H

#define MAX_NUMBER_OF_STORAGE_DEVICES 4
#define MAX_CONFIG_SIZE 140

//USB error codes
typedef enum {
  USB_ERR_OK                          = 0,
  USB_ERR_NAK                         = 1,
  USB_ERR_STALL                       = 2,
  USB_ERR_TIMEOUT                     = 3,
  USB_ERR_DATA_ERROR                  = 4,
  USB_ERR_NO_DEVICE                   = 5,
  USB_ERR_PANIC_BUTTON_PRESSED        = 6,
  USB_TOKEN_OUT_OF_SYNC               = 7,
  USB_ERR_UNEXPECTED_STATUS_FROM_HOST = 8,
  USB_ERR_CODE_EXCEPTION              = 9,
  USB_ERR_MEDIA_CHANGED               = 10,
  USB_ERR_MEDIA_NOT_PRESENT           = 11,
  USB_ERR_CH376_BLOCKED               = 12,
  USB_ERR_CH376_TIMEOUT               = 13,
  USB_ERR_FAIL                        = 14,
  USB_ERR_MAX                         = 14,
  USB_ERR_OTHER                       = 15,
  USB_ERR_DISK_READ                   = 0x1D,
  USB_ERR_DISK_WRITE                  = 0x1E,
  USB_FILERR_MIN                      = 0x41,
 // USB_ERR_OPEN_DIR                    = 0x41,
 // USB_ERR_MISS_FILE                   = 0x42,
  USB_FILERR_MAX                      = 0xB4
} usb_error;

typedef enum { USB_IS_FLOPPY = 1, USB_IS_MASS_STORAGE = 2, USB_IS_HUB = 128 } usb_device_type;

typedef struct {
  uint8_t next_storage_device_index;
  uint8_t next_device_address;
} enumeration_state;

typedef struct {
  uint8_t max_packet_size;
  uint8_t value;
  uint8_t interface_number;
  uint8_t tag;
  uint8_t address;
} device_config;

typedef struct {
  uint8_t toggle : 1;
  uint8_t number : 4;
  uint8_t max_packet_size;
} endpoint_param;

typedef struct {
  usb_device_type type; // floppy or mass storage
  device_config   config;
  endpoint_param  endpoints[3]; // bulk in/out and interrupt
} storage_device_config;

typedef struct __usb_state {
  storage_device_config storage_device[MAX_NUMBER_OF_STORAGE_DEVICES];
  device_config         hub_config;
  endpoint_param        hub_endpoint;
} _usb_state;

typedef struct _device_descriptor {
  uint8_t  bLength;
  uint8_t  bDescriptorType;
  uint16_t bcdUSB;
  uint8_t  bDeviceClass;
  uint8_t  bDeviceSubClass;
  uint8_t  bDeviceProtocol;
  uint8_t  bMaxPacketSize0;
  uint16_t idVendor;
  uint16_t idProduct;
  uint16_t bcdDevice;
  uint8_t  iManufacturer;
  uint8_t  iProduct;
  uint8_t  iSerialNumber;
  uint8_t  bNumConfigurations;
} device_descriptor;

typedef struct _work_area {
  uint8_t    read_count;           // COUNT OF SECTORS TO BE READ
  uint16_t   index;                // sector number to be read
  uint8_t *  dest;                 // destination write address
  uint8_t    read_count_requested; // number of sectors requested
  uint8_t    present;              // BIT FIELD FOR DETECTED DEVICES (BIT 0 -> COMPACTFLASH/IDE, BIT 1-> MSX-MUSIC NOR FLASH)
  _usb_state ch376;
} work_area;

typedef struct _config_descriptor {
  uint8_t  bLength;
  uint8_t  bDescriptorType;
  uint16_t wTotalLength;
  uint8_t  bNumInterfaces;
  uint8_t  bConfigurationvalue;
  uint8_t  iConfiguration;
  uint8_t  bmAttributes;
  uint8_t  bMaxPower;
} config_descriptor;

typedef struct __working {
  enumeration_state *state;

  usb_device_type   usb_device;
  device_descriptor desc;
  uint8_t           config_index;
  uint8_t           interface_count;
  uint8_t           endpoint_count;

  const uint8_t *ptr;

  union {
    uint8_t           buffer[MAX_CONFIG_SIZE];
    config_descriptor desc;
  } config;
} _working;


void usb_init ();
usb_error enumerate_all_devices();
usb_error read_all_configs(enumeration_state *const state);
_usb_state *get_usb_work_area();
usb_error hw_get_description(device_descriptor *const buffer);
//usb_error op_get_config_descriptor(_working *const working);
usb_error hw_get_config_descriptor(config_descriptor *const buffer,
                                          const uint8_t            config_index,
                                          const uint8_t            buffer_size,
                                          const uint8_t            device_address);


#endif // __USB_H