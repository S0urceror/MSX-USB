;
; main.ASM - USB Ethernet driver that uses the MSX USB Unapi driver.
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

RSLREG:     equ 0138h
ENASLT:     equ 0024h
H.CHGE:     EQU 0FDC2h	
BDOS        EQU 5

; major and minor version number of MSXUSB UNAPI that we need
MSXUSB_UNAPI_P:    equ  0
MSXUSB_UNAPI_S:    equ  3

    include "msxusbunapi.asm"

JP_CHECK                EQU 0*8
JP_CONNECT              EQU 1*8
JP_GET_DESCRIPTORS      EQU 2*8
JP_CONTROL_TRANSFER     EQU 3*8
JP_DATA_IN_TRANSFER     EQU 4*8
JP_DATA_OUT_TRANSFER    EQU 5*8
JP_SYNC_MODE            EQU 6*8
JP_CONTROL_PACKET       EQU 7*8

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
    ; check if the Ram Helper is available
    call GET_RAM_HELPER
    push af
    ld hl,TXT_RAM_HELPER_NOT_FOUND
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
    ; get descriptors 
    push bc, de
    call USB_GET_DESCRIPTORS
    ; check if CDC ECM is connected
    call USB_CHECK_CDC_ECM
    pop de, bc
    jr nc, _FOUND_
    inc d
    djnz _AGAIN_
    ld hl, TXT_CDC_ECM_CHECK_NOK
    call PRINT_DOS
    ret
_FOUND_:
    ld a, d
    ld (DEVICE_ADDRESS),a
    ld hl, TXT_CDC_ECM_CHECK_OKAY
    call PRINT_DOS
    ; initialise ethernet device
    call USB_CDC_ECM_START
    push af
    ld hl,TXT_CDC_ECM_NOT_STARTED
    call c, PRINT_DOS
    pop af 
    ret c
    ; allocate a segment in the mapper
    call ALLOC_SEG
    push af
    ld hl,TXT_SEG_NOT_ALLOCATED
    call c, PRINT_DOS
    pop af 
    ret c
    ; hook the TSR to UNAPI
    call HOOK_TSR_UNAPI
    ret c
    ; copy the TSR part to the new segment
    call COPY_TSR_SEG
    ret c
    
    ret 


GET_UNAPI_MSXUSB:
    ; copy our ID to ARG
    ld	hl,MSXUSB_UNAPI_ID
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
    cp MSXUSB_UNAPI_P
    jp nz, ERROR
    ld a, e
    cp MSXUSB_UNAPI_S
    jp nz, ERROR
    ; get JUMPTABLE
    ld a, USB_JUMPTABLE
    ld hl, JUMP_TABLE_START
    call UNAPI_ENTRY
    ; all fine
    ld hl, TXT_MSXUSB_FOUND
    call PRINT_DOS
    or a
    ret

GET_RAM_HELPER:
    ld de, #2222
    ld hl, 0
    ld a, #ff
    call EXTBIO
    ld a, h
    or l
    scf 
    ; not present
    ret z
    ld (RH_JUMPTABLE), hl
    ld a, b
    or c
    jr nz, _REDUCED_MAPPER_TABLE
    ; get the mapper table from the MSX2 DOS mapper routines
    ld a, 0 ; reset to 0, should change
    ld d, 4 ; extbio device id
    ld e, 1 ; function nr
    ;Result:A = Slot number of primary mapper - if zero, mapper support routines are not available
	;		DE = reserved
	;		HL = Start address of mapper variable table
    call EXTBIO
    or a
    scf
    ret z ; if A is zero and no reduced mapper table present, we need to stop
    jr _NORMAL_MAPPER_TABLE
_REDUCED_MAPPER_TABLE:
    ld hl, bc
_NORMAL_MAPPER_TABLE:
    ld (RH_MAPTAB_ADD),hl
    ; all okay
    ld hl, TXT_RAM_HELPER_FOUND
    call PRINT_DOS
    or a ; clear Cy
    ret

USB_CHECK_ADAPTER:
    call FN_CHECK
    jp c, ERROR

    ld hl, TXT_ADAPTER_OKAY
    call PRINT_DOS
    or a
    ret 
    
USB_CONNECT_DEVICE:
    call FN_CONNECT
    and a
    jp z, ERROR ; nr devices connected is 0
    
    push af
    ld hl, TXT_DEVICE_CONNECTED
    call PRINT_DOS
    pop af
    ret 
    
USB_GET_DESCRIPTORS:
    ld hl, DESCRIPTORS
    call FN_GET_DESCRIPTORS
    jp c, ERROR
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

CHECK_DEVICE_DESCRIPTOR:
    push af
    ld a, (ix+DEVICE_DESCRIPTOR.bNumConfigurations)
    ld (NUM_CONFIGS),a
    ld a, (ix+DEVICE_DESCRIPTOR.bMaxPacketSize0)
    ld (ETHERNET_MAX_PACKET_SIZE),a
    pop af
    ret

CHECK_CONFIG_DESCRIPTOR:
    push af
    ld a, (ix+CONFIG_DESCRIPTOR.bNumInterfaces)
    ld (NUM_INTERFACES),a
    ; overwrite configuration value only when control endpoint has not yet been found
    ld a, (CONTROL_ENDPOINT_ID)
    and a
    jr nz, _CHECK_CONFIG_NEXT
    ; okay to set, will point to the found CDC ECM configuration
    ld a, (ix+CONFIG_DESCRIPTOR.bConfigurationvalue)
    ld (ETHERNET_CONFIG_ID),a
_CHECK_CONFIG_NEXT:
    ld hl, NUM_CONFIGS
    dec (hl)
    pop af
    ret

CHECK_INTERFACE_DESCRIPTOR:
    push af
    ; we don't know yet what kind of interface this is
    ld hl, CUR_INTERFACE_TYPE
    ld (hl),0
    ; let's find out
    ld a, (ix+INTERFACE_DESCRIPTOR.bNumEndpoints)
    ld (NUM_ENDPOINTS),a
    ld a, (ix+INTERFACE_DESCRIPTOR.bInterfaceClass)
    cp 0x02
    jr nz, _INTERFACE_NOT_INTERESTING1
    ld a, (ix+INTERFACE_DESCRIPTOR.bInterfaceSubClass)
    cp 0x06
    jr nz, _INTERFACE_NOT_INTERESTING2
    ld a, (ix+INTERFACE_DESCRIPTOR.bInterfaceProtocol)
    and a ; // check for zero
    jr nz, _INTERFACE_NOT_INTERESTING2
    ; found CDC ECM control interface
    ld a, (ix+INTERFACE_DESCRIPTOR.bInterfaceNumber)
    ld (CONTROL_INTERFACE_ID),a
    ld hl, CUR_INTERFACE_TYPE
    ld (hl),1; treat subsequent endpoints as belonging to control interface
    jr _INTERFACE_NOT_INTERESTING2
_INTERFACE_NOT_INTERESTING1:
    cp 0x0a
    jr nz, _INTERFACE_NOT_INTERESTING2
    ld a, (ix+INTERFACE_DESCRIPTOR.bInterfaceSubClass)
    and a ; // check for zero
    jr nz, _INTERFACE_NOT_INTERESTING2
    ld a, (ix+INTERFACE_DESCRIPTOR.bInterfaceProtocol)
    and a ; // check for zero
    jr nz, _INTERFACE_NOT_INTERESTING2
    ld a, (ix+INTERFACE_DESCRIPTOR.bAlternateSetting)
    and a ; // check for non-zero
    jr z, _INTERFACE_NOT_INTERESTING3
    ; found CDC ECM data interface
    ld (DATA_INTERFACE_ALTERNATE),a
    ld a, (ix+INTERFACE_DESCRIPTOR.bInterfaceNumber)
    ld (DATA_INTERFACE_ID),a
    ld hl, CUR_INTERFACE_TYPE
    ld (hl),2; treat subsequent endpoints as belonging to data interface
_INTERFACE_NOT_INTERESTING2:
    ld hl, NUM_INTERFACES
    dec (hl)
_INTERFACE_NOT_INTERESTING3:
    pop af
    ret

CHECK_ENDPOINT_DESCRIPTOR:
    push af
    ld a, (CUR_INTERFACE_TYPE)
    and a ; check zero, not interested
    jr z,_CHECK_ENDPOINT_DESCRIPTOR_END
    dec a
    jr nz, _CHECK_ENDPOINT_DATA
    ; control interface
    ld a, (ix+ENDPOINT_DESCRIPTOR.bmAttributes)
    and 0b00000011
    cp 0b00000011
    jr nz, _CHECK_ENDPOINT_DESCRIPTOR_END ; not Interrupt endpoint
    ld a, (ix+ENDPOINT_DESCRIPTOR.bEndpointAddress)
    bit 7,a
    jr z,_CHECK_ENDPOINT_DESCRIPTOR_END ; not INPUT
    and 0b01111111
    ld (CONTROL_ENDPOINT_ID), a
    jr _CHECK_ENDPOINT_DESCRIPTOR_END
_CHECK_ENDPOINT_DATA:
    ; data interface
    ld a, (ix+ENDPOINT_DESCRIPTOR.bmAttributes)
    and 0b00000011
    cp 0b00000010
    jr nz,_CHECK_ENDPOINT_DESCRIPTOR_END ; not Bulk endpoint
    ld a, (ix+ENDPOINT_DESCRIPTOR.bEndpointAddress)
    bit 7,a
    jr z, _CHECK_BULK_OUTPUT
    and 0b01111111
    ld (DATA_BULK_IN_ENDPOINT_ID), a
    jr _CHECK_ENDPOINT_DESCRIPTOR_END
_CHECK_BULK_OUTPUT:
    and 0b01111111
    ld (DATA_BULK_OUT_ENDPOINT_ID), a
_CHECK_ENDPOINT_DESCRIPTOR_END:
    ld hl, NUM_ENDPOINTS
    dec (hl)
    pop af
    ret 

CHECK_CDC_ECM_DESCRIPTOR:
    push af
    ld a, (ix+2) ; subtype
    cp 0x0f ; ethernet
    jr nz, _CHECK_CDC_ECM_DESCRIPTOR_END
    ; ethernet descriptor
    ld a, (ix+ETHERNET_DESCRIPTOR.iMACAddress)
    ld (MAC_ADDRESS_ID),a
    ld a, (ix+ETHERNET_DESCRIPTOR.wMaxSegmentSize)
    ld (ETHERNET_MAX_SEGMENT_SIZE),a
    ld a, (ix+ETHERNET_DESCRIPTOR.wMaxSegmentSize+1)
    ld (ETHERNET_MAX_SEGMENT_SIZE+1),a
_CHECK_CDC_ECM_DESCRIPTOR_END:
    pop af
    ret

USB_CHECK_CDC_ECM:
    ld ix, DESCRIPTORS
_USB_CHECK_NEXT:
    ld c, (ix+0) ; length
    ld b, 0
    ld a, (ix+1) ; type
    cp 0x01 ; DEVICE_DESCRIPTOR
    call z, CHECK_DEVICE_DESCRIPTOR
    cp 0x02 ; CONFIG_DESCRIPTOR
    call z, CHECK_CONFIG_DESCRIPTOR
    cp 0x04 ; INTERFACE_DESCRIPTOR
    call z, CHECK_INTERFACE_DESCRIPTOR
    cp 0x05 ; ENDPOINT_DESCRIPTOR
    call z, CHECK_ENDPOINT_DESCRIPTOR
    cp 0x24 ; CDC ECM DESCRIPTOR
    call z, CHECK_CDC_ECM_DESCRIPTOR
    ; check if we're done checking
    ld a, (NUM_CONFIGS)
    and a
    jr nz, _DO_AGAIN
    ld a, (NUM_INTERFACES)
    and a
    jr nz, _DO_AGAIN
    ld a, (NUM_ENDPOINTS)
    and a
    jr nz, _DO_AGAIN
    ; no more endpoints, interfaces and configs to scan
    jr _DONE
_DO_AGAIN:
    add ix,bc
    jr _USB_CHECK_NEXT
_DONE:
    ; check if we now have everything
    ld a, (CONTROL_ENDPOINT_ID)
    and a
    jr z, _NO_CDC_ECM
    ld a, (DATA_INTERFACE_ALTERNATE)
    and a
    jr z, _NO_CDC_ECM
    ld a, (DATA_BULK_IN_ENDPOINT_ID)
    and a
    jr z, _NO_CDC_ECM
    ld a, (DATA_BULK_OUT_ENDPOINT_ID)
    and a
    jr z, _NO_CDC_ECM
    or a ; clear Cy
    ret 
_NO_CDC_ECM:
    scf 
    ret

USB_CDC_ECM_START:
    ; set configuration 
    ld a, (ETHERNET_MAX_PACKET_SIZE)
    ld b, a
    ld a, (DEVICE_ADDRESS)
    ld d, a
    ld a, (ETHERNET_CONFIG_ID)
    call CH_SET_CONFIGURATION
    ret c
    ; set alternate setting for interface
    ld a, (ETHERNET_MAX_PACKET_SIZE)
    ld b, a
    ld a, (DEVICE_ADDRESS)
    ld d, a
    ld a, (DATA_INTERFACE_ID)
    ld e, a
    ld a, (DATA_INTERFACE_ALTERNATE)
    call CH_SET_INTERFACE
    ret c
    ; get MAC address string
    ld a, (ETHERNET_MAX_PACKET_SIZE)
    ld b, a
    ld a, (DEVICE_ADDRESS)
    ld d, a
    ld a, (MAC_ADDRESS_ID)
    ld hl, MAC_ADDRESS_S
    call CH_GET_STRING
    ret c
    ; convert utf16-hex-string to bytes
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ld hl, MAC_ADDRESS_S
    ld de, MAC_ADDRESS
    ld b,12
    ld c,1 ; flag that tells if high nibble to multiply by 16
    inc hl ; len
    inc hl ; type
_NEXT_MAC_NR:
    ld a, (hl) ; 0-9, A-F falls within normal ASCII followed with a zero
    sub "0"
    cp 10 ; bigger than 9, then A-F
    jr c, _NO_AtoF
    sub 7
_NO_AtoF:
    ; A now contains the numeric presentation of the char
    ld (MAC_NIBBLE), a ; store in (DE)
    ld a, c
    xor 1 ; toggle high nibble bit
    ld c, a
    ld a, (MAC_NIBBLE)
    jr nz, _NO_x16
    sla a; times 2 
    sla a; times 4
    sla a; times 8
    sla a; times 16
    ld (MAC_HIGH_NIBBLE), a
    inc hl
    inc hl
    djnz _NEXT_MAC_NR
_NO_x16
    ld iyl,a
    ld a, (MAC_HIGH_NIBBLE)
    add a, iyl
    ld (de),a
    inc de
    inc hl
    inc hl
    djnz _NEXT_MAC_NR

    
    ld hl,TXT_CDC_ECM_STARTED
    call PRINT_DOS
    ld hl,TXT_MAC_ADDRESS
    call PRINT_DOS
    ld hl,MAC_ADDRESS_S
    call PRINT_DOS
    or a
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
    call _GET_P1
    push af
    ; map new segment into page 1
    ld a, (MAPPER_SEGMENT)
    call _PUT_P1
    ; copy TSR to new segment
    ld hl, TSR+(TSR_START-TSR_ORG)
    ld bc, TSR_END - TSR_START
    ld de, TSR_START ; start page 1
    ldir
    ; copy SHARED_VARIABLES to new segment
    ld hl, SHARED_VARS_START
    ld bc, TSR_SHARED_VARS_END - TSR_SHARED_VARS_START
    ld de, TSR_SHARED_VARS_START ; start page 1
    ldir
    ; get new jumptable for the new addresses
    ; get JUMPTABLE
    ld a, USB_JUMPTABLE
    ld hl, TSR_JUMP_TABLE_START
    call UNAPI_ENTRY
    ;
    ; map old segment into page 1
    pop af
    call _PUT_P1

    ld hl, TXT_TSR_COPIED
    call PRINT_DOS
    or a
    ret 

HOOK_TSR_UNAPI:
    call HOOK_EXTBIO
    ld hl, TXT_UNAPI_READY
    call PRINT_DOS
    or a
    ret

ERROR:
    scf 
    ret

_CONOUT equ 02h
_STROUT equ 09h
;       Subroutine      Print a buffer of characters
;       Inputs          HL - start address
;                       BC - number of chars
;       Outputs         -------------------------------
PRINT_BUFFER:
    push af
_AGAIN_PRINT:
    ld a, (hl)
    call PRINT_CHAR
    inc hl
    dec bc
    jr nz, _AGAIN_PRINT
    ret
;       Subroutine      Print char with the DOS routine
;       Inputs          A - char to print
;       Outputs         -------------------------------
PRINT_CHAR:
    push bc,de,hl
    ld e, a
    ld c, _CONOUT
    call BDOS
    pop hl,de,bc
    ret
;       Subroutine      Print text with the DOS routine
;       Inputs          HL - pointer to text to print
;       Outputs         -------------------------------
PRINT_DOS:
    push hl,de,bc
    ex de,hl
    ld c, _STROUT
    call BDOS
    pop bc,de,hl
    ret

    include "usb_descriptors.asm"
    include "usb.asm"
    include "unapi_init.asm"

DESCRIPTORS: DS 512 ; maximum length?
; --- Various texts while initialising driver
TXT_NEWLINE: DB "\r\n$",0
TXT_WELCOME: DB "USB Ethernet Driver starting\r\n$",0
TXT_MSXUSB_FOUND: DB "+ MSXUSB Unapi found\r\n$",0
TXT_MSXUSB_NOT_FOUND: DB "- MSXUSB Unapi NOT found\r\n$",0
TXT_ADAPTER_OKAY: DB "+ USB adapter okay\r\n$",0
TXT_DEVICE_CONNECTED: DB "+ USB device connected\r\n$",0
TXT_DEVICE_NOT_CONNECTED: DB "+ USB device NOT connected\r\n$",0
TXT_DESCRIPTORS_OKAY: DB "+ USB descriptors read\r\n$",0
TXT_DESCRIPTORS_NOK: DB "- USB descriptors NOT read\r\n$",0
TXT_CDC_ECM_CHECK_OKAY: DB "+ USB CDC ECM device found\r\n$",0
TXT_CDC_ECM_CHECK_NOK: DB "- USB CDC ECM device NOT found\r\n$",0
TXT_SEG_ALLOCATED: DB "+ New RAM segment allocated\r\n$",0
TXT_SEG_NOT_ALLOCATED: DB "- New RAM segment NOT allocated\r\n$",0
TXT_TSR_COPIED: DB "+ Driver copied\r\n$",0
TXT_UNAPI_HOOKED: DB "+ Usb Ethernet Unapi linked\r\n$",0
TXT_CDC_ECM_STARTED: DB "+ USB CDC ECM device initialized\r\n$",0
TXT_MAC_ADDRESS: DB "+ MAC Address: $",0
TXT_CDC_ECM_NOT_STARTED: DB "- USB CDC ECM device NOT initialized\r\n$",0
TXT_UNAPI_READY: DB "+ Ethernet Unapi ready\r\n$",0
TXT_RAM_HELPER_FOUND: DB "+ Ram Helper Unapi found\r\n$",0
TXT_RAM_HELPER_NOT_FOUND: DB "- Ram Helper Unapi NOT found\r\n$",0

MSXUSB_UNAPI_ID DB "MSXUSB",0
; UNAPI_ENTRY
UNAPI_ENTRY:
    rst 30h
IMP_SLOT: db 0 ; to be replaced with current slot id
IMP_ENTRY: dw 0 ; to be replaced with UNAPI_ENTRY
    ret

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

; RAM HELPER
MAPPER_JUMP_TABLE: DW 0 

; enumeration variables
NUM_CONFIGS:        DB 0
NUM_INTERFACES:     DB 0
NUM_ENDPOINTS:      DB 0
CUR_INTERFACE_TYPE: DB 0 ; 1 = CONTROL, 2 = DATA
MAC_ADDRESS_ID:     DB 0
MAC_ADDRESS_S       DS 64 ; len + type + 12*utf-16 chars + nul-char (503EAA7B601A)
_MAC_ADDRESS_SE     DB "\r\n$"
MAC_HIGH_NIBBLE     DB 0
MAC_NIBBLE          DB 0

; ram helper variables
RH_JUMPTABLE:           DW 0
RH_MAPTAB_ADD:          dw 0    ;Address of the mappers table supplied by either DOS 2 or the RAM helper
RH_MAPTAB_ENTRY_SIZE:   db 8    ;Size of an entry in the mappers table:
                                ;- 8 in DOS 2 (mappers table provided by standard mapper support routines),
                                ;- 2 in DOS 1 (mappers table provided by the RAM helper)

SHARED_VARS_START:
;
DEVICE_ADDRESS              DB 0
; CDC ECM identifiers
CONTROL_INTERFACE_ID:       DB 0
CONTROL_ENDPOINT_ID:        DB 0
DATA_INTERFACE_ID:          DB 0
DATA_INTERFACE_ALTERNATE:   DB 0
DATA_BULK_IN_ENDPOINT_ID:   DB 0
DATA_BULK_OUT_ENDPOINT_ID:  DB 0
ETHERNET_MAX_PACKET_SIZE:   DB 0
ETHERNET_CONFIG_ID:         DB 0
ETHERNET_MAX_SEGMENT_SIZE:  DW 0
MAC_ADDRESS                 DW 0,0,0
; EXTBIO variables
OLD_EXTBIO:                 DS 5
MAPPER_SEGMENT:             DB 0
MAPPER_SLOT:                DB 0
JUMP_TABLE_START:
FN_CHECK: DS 8
FN_CONNECT: DS 8
FN_GET_DESCRIPTORS: DS 8
FN_CONTROL_TRANSFER: DS 8
FN_DATA_IN_TRANSFER: DS 8
FN_DATA_OUT_TRANSFER: DS 8
FN_SYNC_MODE: DS 8
FN_CONTROL_PACKET: DS 8
SHARED_VARS_END:

TSR: 
    include "tsr.asm"