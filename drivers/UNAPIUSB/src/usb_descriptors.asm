
    STRUCT DEVICE_DESCRIPTOR
BASE:
bLength: db
bDescriptorType: db
bcdUSB: dw
bDeviceClass: db
bDeviceSubClass: db
bDeviceProtocol: db
bMaxPacketSize0: db
idVendor: dw
idProduct: dw
bcdDevice: dw
iManufacturer: db
iProduct: db
iSerialNumber: db
bNumConfigurations: db
    ENDS

    STRUCT CONFIG_DESCRIPTOR
BASE:
bLength: DB
bDescriptorType: DB
wTotalLength: DW
bNumInterfaces: DB
bConfigurationvalue: DB
iConfiguration: DB
bmAttributes: DB
bMaxPower: DB
    ENDS

    STRUCT INTERFACE_DESCRIPTOR
bLength: DB
bDescriptorType: DB
bInterfaceNumber: DB
bAlternateSetting: DB
bNumEndpoints: DB
bInterfaceClass: DB
bInterfaceSubClass: DB
bInterfaceProtocol: DB
iInterface: DB
    ENDS

   STRUCT HID_DESCRIPTOR
bLength: DB
bDescriptorType: DB
hid_version: DW
country_code: DB
num_descriptors: DB
descriptor_type: DB
descriptor_length: DW
    ENDS

    STRUCT ENDPOINT_DESCRIPTOR
bLength: DB
bDescriptorType: DB
bEndpointAddress: DB
bmAttributes: DB
wMaxPacketSize: DW
bInterval: DB
    ENDS