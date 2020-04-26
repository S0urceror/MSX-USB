;
; usbhost.ASM - UNAPI compliant MSX USB driver
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

; major and minor version number of MSXUSB UNAPI
UNAPI_P:  equ  0
UNAPI_S:  equ  2
; S0urceror's CH376s driver, major and minor version
IMPLEMENTATION_P:  equ  0
IMPLEMENTATION_S:  equ  5

USB_DEVICE_ADDRESS EQU 1
NXT_DIRECT EQU 0x0000

;***********************************
;***  FUNCTIONS ADDRESSES TABLE  ***
;***********************************

;--- Standard routines addresses table
FN_TABLE:
FN_0:  dw  FN_INFO
FN_1:  dw  FN_JUMP_TABLE
MAX_FN equ 1

JUMP_TABLE_START:
JN_0:
    call NXT_DIRECT         ; 3 bytes - call to switching code
    DB 1                    ; 1 byte  - ROM slot number
    DB 7                    ; 1 byte  - ROM segment
    DW FN_CHECK             ; 2 bytes - address to call
    ret                     ; 1 byte
JN_1:
    call NXT_DIRECT         ; 3 bytes - call to switching code
    DB 1                    ; 1 byte  - ROM slot number
    DB 7                    ; 1 byte  - ROM segment
    DW FN_CONNECT           ; 2 bytes - address to call
    ret                     ; 1 byte
JN_2:
    call NXT_DIRECT         ; 3 bytes - call to switching code
    DB 1                    ; 1 byte  - ROM slot number
    DB 7                    ; 1 byte  - ROM segment
    DW FN_GETDESCRIPTORS    ; 2 bytes - address to call
    ret                     ; 1 byte
JN_3:
    call NXT_DIRECT         ; 3 bytes - call to switching code
    DB 1                    ; 1 byte  - ROM slot number
    DB 7                    ; 1 byte  - ROM segment
    DW FN_CONTROL_TRANSFER  ; 2 bytes - address to call
    ret                     ; 1 byte
JN_4:
    call NXT_DIRECT         ; 3 bytes - call to switching code
    DB 1                    ; 1 byte  - ROM slot number
    DB 7                    ; 1 byte  - ROM segment
    DW FN_DATA_IN_TRANSFER  ; 2 bytes - address to call
    ret                     ; 1 byte
JN_5:
    call NXT_DIRECT         ; 3 bytes - call to switching code
    DB 1                    ; 1 byte  - ROM slot number
    DB 7                    ; 1 byte  - ROM segment
    DW FN_DATA_OUT_TRANSFER ; 2 bytes - address to call
    ret                     ; 1 byte
JN_6:
    call NXT_DIRECT         ; 3 bytes - call to switching code
    DB 1                    ; 1 byte  - ROM slot number
    DB 7                    ; 1 byte  - ROM segment
    DW FN_SYNC_MODE         ; 2 bytes - address to call
    ret                     ; 1 byte
JN_7:
    call NXT_DIRECT         ; 3 bytes - call to switching code
    DB 1                    ; 1 byte  - ROM slot number
    DB 7                    ; 1 byte  - ROM segment
    DW FN_GET_USB_DESCRIPTOR; 2 bytes - address to call
    ret                     ; 1 byte
JUMP_TABLE_END: DB 0
NR_JUMP_ENTRIES EQU 8

;************************
;***  FUNCTIONS CODE  ***
;************************

;--- Mandatory routine 0: return API information
;    Input:  A  = 0
;    Output: HL = Descriptive string for this implementation, on this slot, zero terminated
;            DE = API version supported, D.E
;            BC = This implementation version, B.C.
;            A  = 0 and Cy = 0
FN_INFO:
    ld  bc,256*IMPLEMENTATION_P+IMPLEMENTATION_S
    ld  de,256*UNAPI_P+UNAPI_S
    ld  hl,UNAPI_INFO
    xor  a
    ret
; Connect attached USB device and reset it
; Input: (none)
; Output: Cy = 0, everything okay, Cy = 1, something went wrong
FN_CONNECT:
    ; set_usb_mode (MODE_HOST_RESET)
    ld a, CH_MODE_HOST_RESET
    call CH_SET_USB_MODE
    ret c
    ; set_usb_mode (MODE_HOST)
    ld a, CH_MODE_HOST
    call CH_SET_USB_MODE
    ret

FN_CHECK:
    jp CH_HW_TEST
FN_CONTROL_TRANSFER:
    ld a, c ; device address in C
    jp HW_CONTROL_TRANSFER
FN_DATA_IN_TRANSFER:
    call _UNPACK_E
    jp HW_DATA_IN_TRANSFER
FN_DATA_OUT_TRANSFER:
    call _UNPACK_E
    jp HW_DATA_OUT_TRANSFER
FN_GET_USB_DESCRIPTOR:
    jp GET_USB_DESCRIPTOR
FN_SYNC_MODE:
    ld a, b
    jp HW_CONFIGURE_NAK_RETRY_2

; E contains DDDDEEEE (D=device address, E=endpoint id) unpack it and preserve Cy
; Output: A = device address
;         E = endpoint id
; Modifies: IXl  
_UNPACK_E:
    push af
    ld ixl, e
    ld a, e ; trick device address in high nibble, endpoint id in low nibble.
    and 0x0f
    ld e, a
    ld a, ixl
    sra a
    sra a
    sra a
    sra a
    and 0x0f
    ld ixl, a
    pop af
    ld a,ixl
    ret
    
; Get both the DEVICE and full CONFIG descriptors and return it
; Input: HL = pointer to buffer
; Output: Cy = 0, everything okay, Cy = 1, not connected
FN_GETDESCRIPTORS:
    ld ix, hl
    ; get device descriptor
    call CH_GET_DEVICE_DESCRIPTOR
    jr nc, _INIT_USBHID_NEXT
    ; if not OK, set_speed (2), get device descriptor
    ld a, CH_SPEED_LOW
    call CH_SET_SPEED
    ret c
    ld hl, ix ;DEVICE_DESCRIPTOR
    call CH_GET_DEVICE_DESCRIPTOR
    ret c
_INIT_USBHID_NEXT:
    ; store number of configurations
    ld a, (ix+DEVICE_DESCRIPTOR.bNumConfigurations)
    ld iyh, a
    ; set address (1)
    ld a, USB_DEVICE_ADDRESS ; address to assign to attached USB device
    ld b, (ix+DEVICE_DESCRIPTOR.bMaxPacketSize0)
    call CH_SET_ADDRESS
    ret c
    ; from now on the device only listens to address given
    ; get config descriptor
    ld iy, ix
    ld bc, DEVICE_DESCRIPTOR ; sizeof
    add iy, bc ; config lies after device descriptor
    ld e, 0 ; first configuration
_INIT_USBHID_AGAIN:
    ld a, e
    ld b, (ix+DEVICE_DESCRIPTOR.bMaxPacketSize0)
    ld c, CONFIG_DESCRIPTOR ; sizeof
    ld d, USB_DEVICE_ADDRESS ; assigned address
    ld hl, iy 
    call CH_GET_CONFIG_DESCRIPTOR ; call first with max packet size to discover real size
    ret c
    ld a, e
    ld c, (iy+CONFIG_DESCRIPTOR.wTotalLength) ; lower 8 bits
    call CH_GET_CONFIG_DESCRIPTOR ; call again with real size
    ld b, 0
    add iy, bc
    inc e
    ld a, (ix+DEVICE_DESCRIPTOR.bNumConfigurations)
    cp e
    jr nz, _INIT_USBHID_AGAIN
    ret

; TODO: do not copy anymore, just return HL in WRKAREA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; FN_JUMP_TABLE: return the configured jumptable in WRKAREA
; Input: (none)
; Output: HL
;
; Example jumptable
; call NXT_DIRECT ; 3 bytes - call to switching code
; DB 1            ; 1 byte  - ROM slot number
; DB 7            ; 1 byte  - ROM segment
; DW FN_CHECK     ; 2 bytes - address to call
; ret             ; 1 byte
;                 ; =============
;                 ; 8 bytes total per entry
FN_JUMP_TABLE:
    push ix, de, bc, af
    ; get pointer to NXT_DIRECT
    ld bc, WRKAREA.NXT_DIRECT
	call WRKAREAPTR
    ld hl, ix
    ; get pointer to JUMP_TABLE
    ld bc, WRKAREA.JUMP_TABLE
	call WRKAREAPTR
    push ix ; to be returned later
    ; get current bank
    ld a, (CUR_BANK)
    ld b, a
    ; get current slot-id
    call GETSLT1
    ; increment
    ld c, NR_JUMP_ENTRIES
    ld de, 8
_FN_JUMP_TABLE_NEXT_ENTRY:
    ld (ix+JN_0-JUMP_TABLE_START+1),hl
    ld (ix+JN_0-JUMP_TABLE_START+3),a
    ld (ix+JN_0-JUMP_TABLE_START+4),b
    add ix, de
    dec c
    jr nz, _FN_JUMP_TABLE_NEXT_ENTRY
    ;
    pop hl
    pop af, bc, de, ix
    ret 

;--- Get slot connected on page 1
;    Input:  -
;    Output: A = Slot number
;    Modifies: AF
GETSLT1:
    push bc,de,hl
    in  a,(0A8h)
    ld  e,a
    and  00001100b
    sra  a
    sra  a
    ld  c,a  ;C = Slot
    ld  b,0
    ld  hl,EXPTBL
    add  hl,bc
    bit  7,(hl)
    jr  z,NOEXP1
EXP1:  
    inc  hl
    inc  hl
    inc  hl
    inc  hl
    ld  a,(hl)
    and  00001100b
    or  c
    or  80h
    ld  c,a
NOEXP1:  
    ld  a,c
    pop hl,de,bc
    ret

USBHOST_INIT:
    push ix
    ; copy USB descriptors to WRKAREA
    ld bc, WRKAREA.USB_DESCRIPTORS
    call WRKAREAPTR
    ld hl, USB_DESCRIPTORS_START
    ld de, ix
    ld bc, USB_DESCRIPTORS_END - USB_DESCRIPTORS_START
    ldir
    ; copy JUMPTABLE to WRKAREA
    ld bc, WRKAREA.JUMP_TABLE
    call WRKAREAPTR
    ld hl, JUMP_TABLE_START
    ld de, ix
    ld bc, JUMP_TABLE_END - JUMP_TABLE_START ; currently 8 jump entries with 8 bytes each
    ldir
    ; INIT finished
    ld hl, TXT_UNAPI_INIT
    call PRINT
    pop ix
	ret

; GET_USB_DESCRIPTOR
; return USB descriptors stored in RAM to enable modification
; Input: BC - offset within descriptor table
; Output: HL - location of USB descriptors in RAM
GET_USB_DESCRIPTOR:
    push ix, bc
    ld bc, WRKAREA.USB_DESCRIPTORS
    call WRKAREAPTR
    pop bc
    ld hl, ix
    add hl, bc
    pop ix
    ret 

; --------------------------------------
; CH_GET_DEVICE_DESCRIPTOR
;
; Input: HL=pointer to memory to receive device descriptor
; Output: Cy=0 no error, Cy=1 error
;         A  = USB error code
;         BC = Amount of data actually transferred (if IN transfer and no error)
CH_GET_DEVICE_DESCRIPTOR:
    push ix,hl,de,bc
    ld de, hl ; Address of the input or output data buffer

    ; return USB descriptor stored in scratch-area pointed to by SLTWRK+5 in HL for this ROM page
    ld bc, CMD_GET_DEVICE_DESCRIPTOR-CMD_GET_DEVICE_DESCRIPTOR ; Address of the command: 0x80,6,0,1,0,0,18,0
    call GET_USB_DESCRIPTOR

    ld a, 0 ; device address
    ld b, 8 ; length in bytes
    call HW_CONTROL_TRANSFER
    pop bc,de,hl,ix
    cp CH_USB_INT_SUCCESS
    ret z ; no error
    scf ; error
    ret

; --------------------------------------
; CH_GET_CONFIG_DESCRIPTOR
;
; Input: HL=pointer to memory to receive config descriptor
;        A=configuration index starting with 0 to DEVICE_DESCRIPTOR.bNumConfigurations
;        B=max_packetsize
;        C=config_descriptor_size
;        D=device address 
; Output: Cy=0 no error, Cy=1 error
CH_GET_CONFIG_DESCRIPTOR:
    push iy,ix,hl,de,bc
    ld iy, hl ; Address of the input or output data buffer

    ; get SLTWRK in HL for this ROM page
    push bc
    ld bc, CMD_GET_CONFIG_DESCRIPTOR-CMD_GET_DEVICE_DESCRIPTOR ; Address of the command: 0x80,6,configuration_id,2,0,0,config_descriptor_size,0
    call GET_USB_DESCRIPTOR
    pop bc
    
    ld ix, hl
    ld (ix+2), a
    ld (ix+6), c
    ld a, d ; device address
    ld de, iy ; Address of the input or output data buffer
    call HW_CONTROL_TRANSFER
    pop bc,de,hl,ix,iy
    cp CH_USB_INT_SUCCESS
    ret z ; no error
    scf ; error
    ret

; --------------------------------------
; CH_SET_CONFIGURATION
;
; Input: A=configuration id
;        B=packetsize
;        D=device address 
; Output: Cy=0 no error, Cy=1 error
CH_SET_CONFIGURATION:
    push ix,hl
    
    ; get SLTWRK in HL for this ROM page
    push bc
    ld bc, CMD_SET_CONFIGURATION-CMD_GET_DEVICE_DESCRIPTOR ; Address of the command: 0x00,0x09,configuration_id,0,0,0,0,0
    call GET_USB_DESCRIPTOR
    pop bc

    ld ix, hl
    ld (ix+2),a
    ld a, d ; device address
    call HW_CONTROL_TRANSFER
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
    
    ; get SLTWRK in HL for this ROM page
    push bc
    ld bc, CMD_SET_PROTOCOL-CMD_GET_DEVICE_DESCRIPTOR ; Address of the command: 0x21,0x0B,protocol_id,0,interface_id,0,0,0
    call GET_USB_DESCRIPTOR
    pop bc

    ld ix, hl
    ld (ix+2),a
    ld (ix+4),e
    ld a, d ; device address
    call HW_CONTROL_TRANSFER
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
    
    ; get SLTWRK in HL for this ROM page
    push bc
    ld bc, CMD_SET_IDLE-CMD_GET_DEVICE_DESCRIPTOR ; Address of the command: 0x21,0x0A,report_id,duration,interface_id,0,0,0
    call GET_USB_DESCRIPTOR
    pop bc

    ld ix, hl
    ld (ix+2),c
    ld (ix+3),a
    ld (ix+4),e
    ld a, d ; device address
    call HW_CONTROL_TRANSFER
    pop hl,ix
    cp CH_USB_INT_SUCCESS
    ret z ; no error
    scf ; error
    ret

; --------------------------------------
; CH_SET_ADDRESS
;
; Input: A=address to assign to connected USB device
;        B=packetsize
; Output: Cy=0 no error, Cy=1 error
CH_SET_ADDRESS:
    push ix,hl,de
    ld de, hl ; Address of the input or output data buffer

    ; get SLTWRK in HL for this ROM page
    push bc
    ld bc, CMD_SET_ADDRESS-CMD_GET_DEVICE_DESCRIPTOR ; Address of the command: 0x00,0x05,target_device_address,0,0,0,0,0
    call GET_USB_DESCRIPTOR
    pop bc
    
    ld ix, hl
    ld (ix+2),a
    ld a, 0 ; device address
    call HW_CONTROL_TRANSFER
    pop de,hl,ix
    cp CH_USB_INT_SUCCESS
    ret z ; no error
    scf ; error
    ret

    include "usb_descriptors.asm"
	include "unapi.asm"

TXT_UNAPI_INIT DB "+UNAPI MSXUSB initialised\r\n",0
UNAPI_ID DB "MSXUSB",0
;UNAPI_INFO: db "MSXUSB driver by Sourceror",0
;Moved to start of unused space in Nextor kernel
UNAPI_INFO: equ 7BD0h