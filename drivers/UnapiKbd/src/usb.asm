; HID constants
HID_CLASS   equ 0x03
HID_BOOT    equ 0x01
HID_KEYBOARD equ 0x01
HID_MOUSE   equ 0x02

USB_DEVICE_ADDRESS EQU 1 ; TODO: ask the UNAPI USB implementation the ID given to this device
CH_BOOT_PROTOCOL: equ 0

; Generic USB command variables
target_device_address EQU 0
configuration_id EQU 0
string_id EQU 0
config_descriptor_size EQU 9

; Generic USB commands
CMD_GET_DEVICE_DESCRIPTOR: DB 0x80,6,0,1,0,0,18,0
CMD_SET_ADDRESS: DB 0x00,0x05,target_device_address,0,0,0,0,0
CMD_SET_CONFIGURATION: DB 0x00,0x09,configuration_id,0,0,0,0,0
CMD_GET_STRING: DB 0x80,6,string_id,3,0,0,255,0
CMD_GET_CONFIG_DESCRIPTOR: DB 0x80,6,configuration_id,2,0,0,config_descriptor_size,0

; USB HID command variables
report_id EQU 0
duration EQU 0x80
interface_id EQU 0
protocol_id EQU 0
; USB HID commands
CMD_SET_IDLE: DB 0x21,0x0A,report_id,duration,interface_id,0,0,0
CMD_SET_PROTOCOL: DB 0x21,0x0B,protocol_id,0,interface_id,0,0,0

; --------------------------------------
; CH_SET_CONFIGURATION
;
; Input: A=configuration id
;        B=packetsize
;        D=device address 
; Output: Cy=0 no error, Cy=1 error
CH_SET_CONFIGURATION:
    push ix,hl
    ld hl, CMD_SET_CONFIGURATION ; Address of the command: 0x00,0x09,configuration_id,0,0,0,0,0
    ld ix, hl
    ld (ix+2),a
    ld a, d ; device address
    call JUMP_TABLE+18h ; HW_CONTROL_TRANSFER
    pop hl,ix
    cp CH_USB_INT_SUCCESS
    ret z ; no error
    scf ; error
    ret

; --------------------------------------
; CH_SET_PROTOCOL
;
; Input: A=protocol id (0=BOOT)
;        B=packetsize
;        D=device address 
;        E=interface id
; Output: Cy=0 no error, Cy=1 error
CH_SET_PROTOCOL:
    push ix,hl
    ld hl, CMD_SET_PROTOCOL ; Address of the command: 0x21,0x0B,protocol_id,0,interface_id,0,0,0
    ld ix, hl
    ld (ix+2),a
    ld (ix+4),e
    ld a, d ; device address
    call JUMP_TABLE+18h ; HW_CONTROL_TRANSFER
    pop hl,ix
    cp CH_USB_INT_SUCCESS
    ret z ; no error
    scf ; error
    ret

; --------------------------------------
; CH_SET_IDLE
;
; Input: A=idle value
;        B=packetsize
;        C=report id
;        D=device address 
;        E=interface id
; Output: Cy=0 no error, Cy=1 error
CH_SET_IDLE:
    push ix,hl
    ld hl, CMD_SET_IDLE ; Address of the command: 0x21,0x0A,report_id,duration,interface_id,0,0,0
    ld ix, hl
    ld (ix+2),c
    ld (ix+3),a
    ld (ix+4),e
    ld a, d ; device address
    call JUMP_TABLE+18h ; HW_CONTROL_TRANSFER
    pop hl,ix
    cp CH_USB_INT_SUCCESS
    ret z ; no error
    scf ; error
    ret