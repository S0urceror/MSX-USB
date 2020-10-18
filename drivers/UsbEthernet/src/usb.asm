;
; usb.ASM - USB Ethernet driver that uses the MSX USB Unapi driver.
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

; CH376 result codes
CH_USB_INT_SUCCESS:  equ 14h
CH_USB_INT_CONNECT:  equ 15h
CH_USB_INT_DISCONNECT: equ 16h
CH_USB_INT_BUF_OVER: equ 17h
CH_USB_INT_DISK_READ: equ 1dh
CH_USB_INT_DISK_WRITE: equ 1eh
CH_USB_ERR_OPEN_DIR: equ 41h
CH_USB_ERR_MISS_FILE: equ 42h
CH_USB_ERR_FOUND_NAME: equ 43h
CH_USB_ERR_FILE_CLOSE: equ 0b4h

; HID constants
HID_CLASS   equ 0x03
HID_BOOT    equ 0x01
HID_KEYBOARD equ 0x01
HID_MOUSE   equ 0x02

CH_BOOT_PROTOCOL: equ 0

; Generic USB command variables
target_device_address EQU 0
configuration_id EQU 0
string_id EQU 0
config_descriptor_size EQU 9
report_id EQU 0
duration EQU 0x80
interface_id EQU 0
alternate_setting EQU 0

; --------------------------------------
; CH_SET_CONFIGURATION
;
; Input: A=configuration id
;        B=packetsize
;        D=device address 
; Output: Cy=0 no error, Cy=1 error
CH_SET_CONFIGURATION:
    push ix,hl
    push af
    push bc
    ld bc, 2*8
    call FN_CONTROL_PACKET
    pop bc
    pop af
    ;ld hl, CMD_SET_CONFIGURATION ; Address of the command: 0x00,0x09,configuration_id,0,0,0,0,0
    ld ix, hl
    ld (ix+2),a
    ld c, d ; device address
    call FN_CONTROL_TRANSFER
    pop hl,ix
    cp CH_USB_INT_SUCCESS
    ret z ; no error
    scf ; error
    ret

; --------------------------------------
; CH_SET_INTERFACE
;
; Input: A=alternate_setting
;        B=packetsize
;        D=device address 
;        E=interface id
; Output: Cy=0 no error, Cy=1 error
CH_SET_INTERFACE:
    push ix,hl
    push af
    push bc
    ld bc, 5*8
    call FN_CONTROL_PACKET
    pop bc
    pop af
    ;ld hl, CMD_SET_INTERFACE ; Address of the command: 0x01,11,alternative_setting,0,interface_id,0,0,0
    ld ix, hl
    ld (ix+2),a
    ld (ix+4),e
    ld c, d ; device address
    call FN_CONTROL_TRANSFER
    pop hl,ix
    cp CH_USB_INT_SUCCESS
    ret z ; no error
    scf ; error
    ret

; --------------------------------------
; CH_GET_STRING
;
; Input: A=string-id
;        B=packetsize
;        D=device address
;        HL=buffer to receive string
; Output: Cy=0 no error, Cy=1 error
CH_GET_STRING:
    push ix,hl
    push hl
    push af
    push bc
    ld bc, 3*8
    call FN_CONTROL_PACKET
    pop bc
    pop af
    ;ld hl, CMD_GET_STRING ; Address of the command: 0x80,6,string_id,3,0,0,255,0
    ld ix, hl
    ld (ix+2),a
    ld c, d ; device address
    pop de ; buffer to receiver string
    call FN_CONTROL_TRANSFER
    pop hl,ix
    cp CH_USB_INT_SUCCESS
    ret z ; no error
    scf ; error
    ret