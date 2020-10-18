;
; main.ASM - USB HID keyboard driver that uses the MSX USB Unapi driver.
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

ARG:		equ	#F847
EXTBIO:		equ	#FFCA
RSLREG:     equ 0138h
ENASLT:     equ 0024h
EXPTBL:	    EQU	0FCC1H		;slot is expanded or not
H.CHGE:     EQU 0FDC2h	

; major and minor version number of MSXUSB UNAPI that we need
UNAPI_P:    equ  0
UNAPI_S:    equ  3

    include "msxusbunapi.asm"

    org 0100h
BEGIN:
START_BASIC:
    ld hl,TXT_WELCOME
    call PRINT_DOS
    ; check if EXTBIO is set (before we try UNAPI and Memory Mapper calls)
    ld a, (0FB20h)
    and 00000001b
    ret z
    ; check if the MSX USB UNAPI is available
    call GET_UNAPI_MSXUSB
    push af
    ld hl,TXT_MSXUSB_NOT_FOUND
    call c, PRINT_DOS
    pop af 
    ret c
    ; check, connect, getdescriptors
    call USB_CHECK_ADAPTER
    ret c
    call USB_CONNECT_DEVICE
    push af
    ld hl,TXT_DEVICE_NOT_CONNECTED
    call z, PRINT_DOS
    pop af 
    ret z
    ; A holds the number of connected devices, try all of them
    ld d, 1 ; start with device number 1
    ld b, a
_AGAIN_:
    push bc, de
    call USB_GET_DESCRIPTORS
    ; check if USB HID is connected
    call USB_CHECK_HID
    pop de, bc
    jr nc, _FOUND_
    inc d
    djnz _AGAIN_
    ld hl, TXT_HID_CHECK_NOK
    call PRINT_DOS
    ret
_FOUND_:
    ld a, d
    ld (DEVICE_ADDRESS),a
    ld hl, TXT_HID_CHECK_OKAY
    call PRINT_DOS
    ; allocate a segment in the mapper
    call ALLOC_SEG
    push af
    ld hl,TXT_SEG_NOT_ALLOCATED
    call c, PRINT_DOS
    pop af 
    ret c
    ; get pointer to scratch_area
    call USB_GET_SCRATCH
    ; copy the TSR part to the new segment
    call COPY_TSR_SEG
    ret c
    ; instruct the keyboard to start sending keystrokes
    call USB_HID_KEYBOARD_START
    ret c
    ; hook the TSR to H.CHGE
    call HOOK_TSR_HCHGE
    ret c
    
    ret 

GET_UNAPI_MSXUSB:
    ; copy our ID to ARG
    ld	hl,UNAPI_ID
	ld	de,ARG
	ld	bc,15
	ldir
    ; get the number of instances of MSXUSB
	xor	a
	ld	b,0
	ld	de,#2222
	call EXTBIO ; Returns B=nr.instances
	ld	a, b
	or	a
	jp	z,ERROR
    ; get our UNAPI_ENTRY
    ld a, b ; use last implementation
    ld  de, #2222
    call EXTBIO ;Returns A=slot, B=segment, HL=entry point
    ld  (IMP_SLOT),a
    ld  (IMP_ENTRY),hl
    ; we do not support MSXUSB on memory mapper
    ld  a,b
    cp  0FFh
    jp  nz,ERROR
    ; we do not support page 3
    ld  a,(IMP_ENTRY+1)
    and  10000000b
    jp  nz,ERROR
    ; okay MSXUSB in ROM, check if it supports our version
    ld a, USB_INFO
    call UNAPI_ENTRY
    ld a, d
    cp UNAPI_P
    jp nz, ERROR
    ld a, e
    cp UNAPI_S
    jp nz, ERROR
    ; all fine
    ld hl, TXT_MSXUSB_FOUND
    call PRINT_DOS
    or a
    ret

USB_CHECK_ADAPTER:
    ld a, USB_CHECK
    call UNAPI_ENTRY
    jp c, ERROR

    ld hl, TXT_ADAPTER_OKAY
    call PRINT_DOS
    or a
    ret 
    
USB_CONNECT_DEVICE:
    ld a, USB_CONNECT
    call UNAPI_ENTRY
    and a
    jp z, ERROR

    push af
    ld hl, TXT_DEVICE_CONNECTED
    call PRINT_DOS
    pop af
    ret 
    
USB_GET_DESCRIPTORS:
    ld hl, DESCRIPTORS
    ld a, USB_GETDESCRIPTORS
    call UNAPI_ENTRY
    jp c, ERROR
    ret

USB_GET_SCRATCH:
    ld bc, 0
    ld a, USB_CONTROL_PACKET
    call UNAPI_ENTRY
    ld (SCRATCH_AREA),hl
    ret

USB_HID_KEYBOARD_START:
    ; found HID keyboard?
    call GET_DESCR_CONFIGURATION ; returns configuration_value in A and Cy to indicate error
    ret c
    ; set configuration 
    push af
    ld a, (KEYBOARD_MAX_PACKET_SIZE)
    ld b, a
    ld a, (DEVICE_ADDRESS)
    ld d, a
    pop af
    call CH_SET_CONFIGURATION
    ret c
    ; set protocol (BOOT_PROTOCOL,keyboard_interface)
    ld a, (DEVICE_ADDRESS)
    ld d, a
    ld a, (KEYBOARD_MAX_PACKET_SIZE)
    ld b, a
    ld a, (KEYBOARD_INTERFACENR)
    ld e, a ; interface number
    ld a, CH_BOOT_PROTOCOL
    call CH_SET_PROTOCOL
    ret c
    ; set idle (0x80)
    ld a, (DEVICE_ADDRESS)
    ld d, a
    ld a, (KEYBOARD_MAX_PACKET_SIZE)
    ld b, a
    ld a, (KEYBOARD_INTERFACENR)
    ld e, a ; interface number
    ld a, 80h ; approximately 500ms
    ld c, 0 ; report id
    call CH_SET_IDLE
    ret c
    ret

; --------------------------------------
; GET_DESCR_CONFIGURATION
;
; Input: (none)
; Output: Cy=0 no error, Cy=1 error
;         A = configuration id
GET_DESCR_CONFIGURATION:
    ld ix, DESCRIPTORS
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

; --------------------------------------
; GET_HID_KEYBOARD_VALUES
;
; Input: (none)
; Output: Cy=0 no error, Cy=1 error
;         A = interface number
;         B = endpoint address
GET_HID_KEYBOARD_VALUES:
    ld ix, DESCRIPTORS
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

USB_CHECK_HID:
    call GET_HID_KEYBOARD_VALUES ; returns Cy when error, A contains interface number, B contains endpoint nr
    jp c, ERROR
    ; save for convenience
    ld (KEYBOARD_INTERFACENR),a
    ld a, b
    ld (KEYBOARD_ENDPOINTNR), a
    ld ix, DESCRIPTORS
    ld a, (ix++DEVICE_DESCRIPTOR.bMaxPacketSize0)
    ld (KEYBOARD_MAX_PACKET_SIZE),a
    ret 
    
ALLOC_SEG:
    ld a, 0 ; reset to 0, should change
    ld d, 4 ; extbio device id
    ld e, 2 ; function nr
    ;Result:A = total number of memory mapper segments
	;		B = slot number of primary mapper
	;		C = number of free segments of primary mapper
	;		DE = reserved
	;		HL = start address of jump table
    call EXTBIO
    and a
    jp z, ERROR ; should be set to total nr of mapper segs
    ld (MAPPER_JUMP_TABLE),hl
    ; copy mapper table
    ld de, _ALL_SEG
    ld bc, 30h
    ldir
    ; allocate
    ld a, 1 ; system segment
    ld b, 00100000b ; try to allocate specified slot and, if it failed, try another slot (if any)
    call _ALL_SEG
    jp c, ERROR
    ; save variable for convenience
    ld (MAPPER_SEGMENT),a
    ld a, b
    ld (MAPPER_SLOT),a

    ld hl, TXT_SEG_ALLOCATED
    call PRINT_DOS
    or a
    ret 

COPY_TSR_SEG:
    ; check old segment in page 1
    call _GET_P2
    push af
    ; map new segment into page 2
    ld a, (MAPPER_SEGMENT)
    call _PUT_P2
    ; copy TSR to new segment
    ld hl, TSR+(TSR_START-TSR_ORG)
    ld bc, TSR_END - TSR_START
    ld de, TSR_START ; start page 2
    ldir
    ; copy SHARED_VARIABLES to new segment
    ld hl, SHARED_VARS_START
    ld bc, TSR_SHARED_VARS_END - TSR_SHARED_VARS_START
    ld de, TSR_SHARED_VARS_START ; start page 2
    ldir
    ; populate jumptable
    ld hl, TSR_JUMP_TABLE_START
    ld a, USB_JUMPTABLE
    call UNAPI_ENTRY
    ; map old segment into page 2
    pop af
    call _PUT_P2

    ld hl, TXT_TSR_COPIED
    call PRINT_DOS
    or a
    ret 

HOOK_TSR_HCHGE:
    ; Get MSX USB scratch area
    ; contains 12 * 8 bytes area
    ; first 9*8 is reserved for USB command descriptors
    ; last 3*8 is reserved and free for use
    ; let's store old H.CHGE in 10th and new in 11th
    ; and put jump to new in H.CHGE
    ; page 3 is safe for hooks because it usually does not get mapped out
    di
    ld hl, (SCRATCH_AREA)
    push hl ; save HL
    ; select 10th
    ld bc, 10*8
    add hl, bc
    ex hl,de
    ; save old one in 10th
    LD	HL,H.CHGE
	LD	BC,5
	LDIR
    ; prepare H.CGE template
    ld ix, HCHGE_TEMPLATE
    ld bc, 0fh ; CALLS routine
    ld hl, (MAPPER_JUMP_TABLE)
    add hl, bc
    ld (ix+1),l
    ld (ix+2),h
    ld a, (MAPPER_SEGMENT)
    ld (ix+3),a
    ld hl, TSR_START
    ld (ix+4), l
    ld (ix+5), h
    ; copy to 11th scratch
    pop hl ; restore HL
    ld bc, 11*8
    add hl, bc
    push hl ; store HL
    ex hl, de
    ld hl, HCHGE_TEMPLATE
    ld bc, 7
    ldir
    ; point new H.CHGE to 11th scratch
    ld hl, H.CHGE
    ld (hl),0C3h ; JP
    pop hl ; restore HL
	LD	(H.CHGE+1),HL
    ei
    ; done
    ld hl, TXT_HCHGE_HOOKED
    call PRINT_DOS
    or a
    ret

HCHGE_TEMPLATE:
    call 0000h ; CALLS routine
    db 0 ; segment number
    dw 0 ; address
    ret

ERROR:
    scf 
    ret

    include "print_dos.asm"
    include "usb_descriptors.asm"
    include "usb.asm"

DESCRIPTORS: DS 512 ; maximum length?
; --- Various texts while initialising driver
TXT_NEWLINE: DB "\r\n$",0
TXT_WELCOME: DB "USB HID Driver starting\r\n$",0
TXT_MSXUSB_FOUND: DB "+ MSXUSB Unapi found\r\n$",0
TXT_MSXUSB_NOT_FOUND: DB "- MSXUSB Unapi NOT found\r\n$",0
TXT_ADAPTER_OKAY: DB "+ USB adapter okay\r\n$",0
TXT_DEVICE_CONNECTED: DB "+ USB device connected\r\n$",0
TXT_DEVICE_NOT_CONNECTED: DB "- USB device NOT connected\r\n$",0
TXT_DESCRIPTORS_OKAY: DB "+ USB descriptors read\r\n$",0
TXT_HID_CHECK_OKAY: DB "+ USB HID Keyboard found\r\n$",0
TXT_HID_CHECK_NOK: DB "- USB HID Keyboard NOT found\r\n$",0
TXT_SEG_ALLOCATED: DB "+ New RAM segment allocated\r\n$",0
TXT_SEG_NOT_ALLOCATED: DB "- RAM segment NOT allocated\r\n$",0
TXT_TSR_COPIED: DB "+ Driver copied\r\n$",0
TXT_HCHGE_HOOKED: DB "+ H.CHGE linked\r\n$",0

UNAPI_ID DB "MSXUSB",0

;--- Mapper support routines
_ALL_SEG:	ds	3
_FRE_SEG:	ds	3
_RD_SEG:	ds	3
_WR_SEG:	ds	3
_CAL_SEG:	ds	3
_CALLS:		ds	3
_PUT_PH:	ds	3
_GET_PH:	ds	3
_PUT_P0:	ds	3
_GET_P0:	ds	3
_PUT_P1:    ds  3
_GET_P1:    ds  3
_PUT_P2:    ds  3
_GET_P2:    ds  3
_PUT_P3:	ds	3
_GET_P3:	ds	3

MAPPER_SEGMENT: DB 0
MAPPER_SLOT: DB 0
MAPPER_JUMP_TABLE: DW 0 

UNAPI_ENTRY:
    rst 30h
IMP_SLOT: db 0 ; to be replaced with current slot id
IMP_ENTRY: dw 0 ; to be replaced with UNAPI_ENTRY
    ret

SHARED_VARS_START:
;
DEVICE_ADDRESS:             DB 0
KEYBOARD_INTERFACENR:       DB 0
KEYBOARD_ENDPOINTNR:        DB 0
KEYBOARD_MAX_PACKET_SIZE:   DB 0
SCRATCH_AREA:               DW 0
JUMP_TABLE_START:
FN_CHECK: DS 8
FN_CONNECT: DS 8
FN_GETDESCRIPTORS: DS 8
FN_CONTROL_TRANSFER: DS 8
FN_DATA_IN_TRANSFER: DS 8
FN_DATA_OUT_TRANSFER: DS 8
FN_SYNC_MODE: DS 8
FN_CONTROL_PACKET: DS 8
SHARED_VARS_END:

TSR: 
    include "tsr.asm"


