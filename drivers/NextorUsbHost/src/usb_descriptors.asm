;
; usb_descriptors.ASM - UNAPI compliant MSX USB driver
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

    STRUCT HUB_DESCRIPTOR
bLength: DB
bDescriptorType: DB
bNrPorts: DB
wHubCharacteristics: DW
bPwrOn2PwrGood: DB
bHubContrCurrent: DB
bDeviceRemovable: DB
bPortPwrCtrlMask: DB
    ENDS