;
; USB-HID keyboard driver
; Copyright (c) 2019 Mario Smit (S0urceror)
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

MYADDRESS EQU 1

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

    STRUCT BOOT_KEYBOARD_INPUT_REPORT
bModifierKeys: DB 0
bReserved: DB 0
Keycode1: DB 0
Keycode2: DB 0
Keycode3: DB 0
Keycode4: DB 0
Keycode5: DB 0
Keycode6: DB 0
    ENDS

; Input: IX=pointer to work area
INIT_USBHID_KEYBOARD:
    ; check_exists
    call CH_HW_TEST
    ret c
    IF DEBUG==1
        ld hl,TXT_CHECK_EXISTS
        call PRINT
    ENDIF
    ; set_usb_mode (MODE_HOST_RESET)
    ld a, CH_MODE_HOST_RESET
    call CH_SET_USB_MODE
    ret c
    ; set_usb_mode (MODE_HOST)
    ld a, CH_MODE_HOST
    call CH_SET_USB_MODE
    ret c
    IF DEBUG==1
        ld hl, TXT_USB_MODE_SET
        call PRINT
    ENDIF
    ; get device descriptor
    ld hl, ix ;DEVICE_DESCRIPTOR
    call CH_GET_DEVICE_DESCRIPTOR
    jr nc, _INIT_USBHID_NEXT
    ; if not OK, set_speed (2), get device descriptor
    ld a, CH_SPEED_LOW
    call CH_SET_SPEED
    ret c
    IF DEBUG==1
        ld hl, TXT_SET_SPEED
        call PRINT
    ENDIF
    ld hl, ix ;DEVICE_DESCRIPTOR
    call CH_GET_DEVICE_DESCRIPTOR
    ret c
_INIT_USBHID_NEXT:
    IF DEBUG==1
        ld hl, TXT_DEVICE_DESCRIPTOR
        call PRINT
        ld hl, ix
        ld bc, 18
        call PRINTHEX_BUFFER
    ENDIF
    ; set address (1)
    ld a, MYADDRESS ; address to assign to attached USB device
    ld b, (ix+DEVICE_DESCRIPTOR.bMaxPacketSize0)
    call CH_SET_ADDRESS
    ret c
    IF DEBUG==1
        ld hl, TXT_SET_ADDRESS
        call PRINT
    ENDIF
    ; from now on the device only listens to address given
    ; get config descriptor
    ld bc, DEVICE_DESCRIPTOR ; sizeof
    ld hl, ix
    add hl, bc ; config lies after device descriptor
    ld a, 0 ; first configuration
    ld b, (ix+DEVICE_DESCRIPTOR.bMaxPacketSize0)
    ld c, CONFIG_DESCRIPTOR ; sizeof
    ld d, MYADDRESS ; assigned address
    call CH_GET_CONFIG_DESCRIPTOR ; call first with max packet size to discover real size
    ret c
    ld a, 0 ; first configuration
    ld ix, hl
    ld c, (ix+CONFIG_DESCRIPTOR.wTotalLength) ; lower 8 bits
    call CH_GET_CONFIG_DESCRIPTOR ; call again with real size
    ret c
    IF DEBUG==1
        push hl
        ld hl, TXT_CONFIG_DESCRIPTOR
        call PRINT
        pop hl
        ld ix, hl
        ld bc, (ix+CONFIG_DESCRIPTOR.wTotalLength)
        call PRINTHEX_BUFFER
    ENDIF
    ; found HID keyboard?
    call GET_DESCR_CONFIGURATION ; returns configuration_value in A and Cy to indicate error
    ret c
    ; set configuration 
    ld ix, WRKAREA
    ld b, (ix+DEVICE_DESCRIPTOR.bMaxPacketSize0)
    ld d, MYADDRESS
    call CH_SET_CONFIGURATION
    ret c

    call GET_HID_KEYBOARD_VALUES ; returns Cy when error, A contains interface number, B contains endpoint nr
    ret c
    ; save for convenience
    ld (KEYBOARD_INTERFACENR),a
    ld a, b
    ld (KEYBOARD_ENDPOINTNR), a
    IF DEBUG==1
        ld hl, TXT_KEYBOARD_FOUND
        call PRINT
    ENDIF
    ; set protocol (BOOT_PROTOCOL,keyboard_interface)
    ld ix, WRKAREA
    ld d, MYADDRESS ; assigned address
    ld b, (ix+DEVICE_DESCRIPTOR.bMaxPacketSize0)
    ld a, (KEYBOARD_INTERFACENR)
    ld e, a ; interface number
    ld a, CH_BOOT_PROTOCOL
    call CH_SET_PROTOCOL
    ret c
    IF DEBUG==1
        ld hl, TXT_KEYBOARD_BOOT_PROTOCOL
        call PRINT
    ENDIF
    ; set idle (0x80)
    ld ix, WRKAREA
    ld d, MYADDRESS ; assigned address
    ld b, (ix+DEVICE_DESCRIPTOR.bMaxPacketSize0)
    ld a, (KEYBOARD_INTERFACENR)
    ld e, a ; interface number
    ld a, 80h ; approximately 500ms
    ld c, 0 ; report id
    call CH_SET_IDLE
    ret c
    IF DEBUG==1
        ld hl, TXT_KEYBOARD_IDLE_SET
        call PRINT
    ENDIF
    ; we're now ready to receive keystrokes from the keyboard interface
    or a ; clear Cy
    ret

; --------------------------------------
; GET_DESCR_CONFIGURATION
;
; Input: (none)
; Output: Cy=0 no error, Cy=1 error
;         A = configuration id
GET_DESCR_CONFIGURATION:
    ld ix, WRKAREA
    ld a, (ix+DEVICE_DESCRIPTOR.bNumConfigurations)
    cp 1
    jr nz,_ERR_GET_DESCR_CONFIGURATION ; only 1 configuration allowed
    ld bc, DEVICE_DESCRIPTOR
    add ix, bc
    ; ix now pointing to first (and only) configuration descriptor
    ld a, (ix+CONFIG_DESCRIPTOR.bConfigurationvalue)
    or a ; reset Cy
    ret
_ERR_GET_DESCR_CONFIGURATION:
    scf
    ret

HID_CLASS equ 0x03
HID_BOOT equ 0x01
HID_KEYBOARD equ 0x01
HID_MOUSE equ 0x02
; --------------------------------------
; GET_HID_KEYBOARD_VALUES
;
; Input: (none)
; Output: Cy=0 no error, Cy=1 error
;         A = interface number
;         B = endpoint address
GET_HID_KEYBOARD_VALUES:
    ld ix, WRKAREA
    ld a, (ix+DEVICE_DESCRIPTOR.bNumConfigurations)
    cp 1
    jr nz,_ERR_GET_HID_KEYBOARD_VALUES ; only 1 configuration allowed
    ld bc, DEVICE_DESCRIPTOR
    add ix, bc
    ; ix now pointing to first (and only) configuration descriptor
    ld c, CONFIG_DESCRIPTOR
    ld b, 0
    ld d, (ix+CONFIG_DESCRIPTOR.bNumInterfaces)
    add ix, bc
    ; ix now pointing to interface descriptor
_NEXT_INTERFACE:
    ld a, (ix+INTERFACE_DESCRIPTOR.bNumEndpoints)
    cp 1
    jr nz, _ERR_GET_HID_KEYBOARD_VALUES; not supported more then 1 endpoint per interface
    ; HID interface class?
    ld a, (ix+INTERFACE_DESCRIPTOR.bInterfaceClass)
    ld c, INTERFACE_DESCRIPTOR+ENDPOINT_DESCRIPTOR ; next interface, no HID block
    cp HID_CLASS
    jr nz, _NEXT_GET_HID_KEYBOARD
    ; HID BOOT interface subclass?
    ld c, INTERFACE_DESCRIPTOR+HID_DESCRIPTOR+ENDPOINT_DESCRIPTOR ; next interface, plus HID block
    ld a, (ix+INTERFACE_DESCRIPTOR.bInterfaceSubClass)
    cp HID_BOOT
    jr nz, _NEXT_GET_HID_KEYBOARD
    ; HID KEYBOARD interface protocol?
    ld a, (ix+INTERFACE_DESCRIPTOR.bInterfaceProtocol)
    cp HID_KEYBOARD
    jr nz, _NEXT_GET_HID_KEYBOARD
    ; found it
    ld a, (ix+INTERFACE_DESCRIPTOR+HID_DESCRIPTOR+ENDPOINT_DESCRIPTOR.bEndpointAddress)
    and 0x0f
    ld b,a
    ld a, (ix+INTERFACE_DESCRIPTOR.bInterfaceNumber)
    or a ; clear Cy
    ret
_NEXT_GET_HID_KEYBOARD:
    add ix, bc
    dec d ; more interfaces to scan?
    jr nz, _NEXT_INTERFACE
_ERR_GET_HID_KEYBOARD_VALUES:
    scf
    ret

    IF DEBUG==1
TXT_CHECK_EXISTS: DB "+CH376s plugged in\r\n",0
TXT_USB_MODE_SET: DB "+USB Reset and Mode set\r\n",0
TXT_SET_SPEED: DB "+Lowered speed of USB bus\r\n",0
TXT_DEVICE_DESCRIPTOR: DB "+USB device descriptor:\r\n",0
TXT_SET_ADDRESS: DB "+USB address set\r\n",0
TXT_CONFIG_DESCRIPTOR: DB "+USB configuration descriptor:\r\n",0
TXT_KEYBOARD_FOUND: DB "+USB HID keyboard detected\r\n",0
TXT_KEYBOARD_BOOT_PROTOCOL: DB "+USB HID keyboard boot protocol set\r\n",0
TXT_KEYBOARD_IDLE_SET: DB "+USB HID keyboard idle repeat set to 250ms\r\n",0
    ENDIF

KEYBOARD_INTERFACENR: DB 0
KEYBOARD_ENDPOINTNR: DB 0