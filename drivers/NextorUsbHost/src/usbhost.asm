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
UNAPI_S:  equ  3
; S0urceror's CH376s driver, major and minor version
IMPLEMENTATION_P:  equ  0
IMPLEMENTATION_S:  equ  6

NXT_DIRECT EQU 0x0000

;***********************************
;***  FUNCTIONS ADDRESSES TABLE  ***
;***********************************

;--- Standard routines addresses table
FN_TABLE:
    dw  FN_INFO
    dw  FN_CHECK
    dw  FN_CONNECT
    dw  FN_GETDESCRIPTORS
    dw  FN_CONTROL_TRANSFER
    dw  FN_DATA_IN_TRANSFER
    dw  FN_DATA_OUT_TRANSFER
    dw  FN_SYNC_MODE
    dw  FN_CONTROL_PACKET
    dw  FN_JUMP_TABLE
MAX_FN equ 9

JUMP_TABLE_START:
JN_0:
    call NXT_DIRECT         ; 3 bytes - call to switching code
    DB 1                    ; 1 byte  - ROM slot number
    DB 7                    ; 1 byte  - ROM segment
    DW FN_CHECK             ; 2 bytes - address to call
    NOP                     ; 1 byte
JN_1:
    call NXT_DIRECT         ; 3 bytes - call to switching code
    DB 1                    ; 1 byte  - ROM slot number
    DB 7                    ; 1 byte  - ROM segment
    DW FN_CONNECT           ; 2 bytes - address to call
    NOP                     ; 1 byte
JN_2:
    call NXT_DIRECT         ; 3 bytes - call to switching code
    DB 1                    ; 1 byte  - ROM slot number
    DB 7                    ; 1 byte  - ROM segment
    DW FN_GETDESCRIPTORS    ; 2 bytes - address to call
    NOP                     ; 1 byte
JN_3:
    call NXT_DIRECT         ; 3 bytes - call to switching code
    DB 1                    ; 1 byte  - ROM slot number
    DB 7                    ; 1 byte  - ROM segment
    DW FN_CONTROL_TRANSFER  ; 2 bytes - address to call
    NOP                     ; 1 byte
JN_4:
    call NXT_DIRECT         ; 3 bytes - call to switching code
    DB 1                    ; 1 byte  - ROM slot number
    DB 7                    ; 1 byte  - ROM segment
    DW FN_DATA_IN_TRANSFER  ; 2 bytes - address to call
    NOP                     ; 1 byte
JN_5:
    call NXT_DIRECT         ; 3 bytes - call to switching code
    DB 1                    ; 1 byte  - ROM slot number
    DB 7                    ; 1 byte  - ROM segment
    DW FN_DATA_OUT_TRANSFER ; 2 bytes - address to call
    NOP                     ; 1 byte
JN_6:
    call NXT_DIRECT         ; 3 bytes - call to switching code
    DB 1                    ; 1 byte  - ROM slot number
    DB 7                    ; 1 byte  - ROM segment
    DW FN_SYNC_MODE         ; 2 bytes - address to call
    NOP                     ; 1 byte
JN_7:
    call NXT_DIRECT         ; 3 bytes - call to switching code
    DB 1                    ; 1 byte  - ROM slot number
    DB 7                    ; 1 byte  - ROM segment
    DW FN_CONTROL_PACKET    ; 2 bytes - address to call
    NOP                     ; 1 byte
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
; Output: A = nr of connected USB devices, zero if none or error
FN_CONNECT:
    ; check of we already did a scan before
    call GET_USB_DEVICE_ADDRESS
    and a
    ret nz ; yes, return the old value
    ; start scanning from address 1
    ld a, 1
    call SET_USB_DEVICE_ADDRESS
FN_CONNECT2: ; skip bus reset (for hubs)
    ld bc, WRKAREA.USB_DESCRIPTOR
    call WRKAREAPTR
    push ix, ix ; ++
    ; Hub connected?
	pop hl ; +-
    ld d, 0 ; from reset device
	call HW_GET_DESCRIPTORS
	jr nc, _CONTINUE_DESCRIPTORS
    ; descriptors not read, return zero to indicate error
    pop ix ; --
    call GET_USB_DEVICE_ADDRESS
    cp 1
    jr nz, _CONNECT_DONE
    xor a
    call SET_USB_DEVICE_ADDRESS
    jr _CONNECT_DONE ; could not get descriptor now, maybe later, skip rest of checks
_CONTINUE_DESCRIPTORS:
	; USB HUB?
    pop hl ; -- throw away
    call CHECK_DESCRIPTOR_MASS_STORAGE
    jr nc, _CONTINUE_STORAGE
    call CHECK_DESCRIPTOR_CDC_ECM
    jr nc, _CONTINUE_CDC_ECM
	call CHECK_DESCRIPTOR_HUB
	jr nc, _CONTINUE_HUB
    jr _CONNECT_DONE:
_CONTINUE_CDC_ECM:
    call INIT_CDC_ECM
    jr _CONNECT_DONE
_CONTINUE_STORAGE:
    call INIT_STORAGE
    jr _CONNECT_DONE
_CONTINUE_HUB:
	; yes, scan hub devices6
	call INIT_HUB
_CONNECT_DONE:
    call GET_USB_DEVICE_ADDRESS
    ret

FN_CHECK:
    jp CH_HW_TEST
FN_GETDESCRIPTORS:
    jp HW_GET_DESCRIPTORS
FN_CONTROL_TRANSFER:
    ld a, c ; device address in C
    jp HW_CONTROL_TRANSFER
FN_DATA_IN_TRANSFER:
    call _UNPACK_E
    jp HW_DATA_IN_TRANSFER
FN_DATA_OUT_TRANSFER:
    call _UNPACK_E
    jp HW_DATA_OUT_TRANSFER
FN_CONTROL_PACKET:
    jp GET_CONTROL_PACKET
FN_SYNC_MODE:
    ld a, b
    jp HW_CONFIGURE_NAK_RETRY_2

GET_USB_DEVICE_ADDRESS:
    push ix
    call MY_GWORK
    ld a, (ix+WRKAREA.MAX_DEVICE_ADDRESS)
    pop ix
    ret
SET_USB_DEVICE_ADDRESS:
    push ix
    call MY_GWORK
    ld (ix+WRKAREA.MAX_DEVICE_ADDRESS),a
    pop ix
    ret

wait_for_insert:
    ; CAPS ON
	in a, 0xaa
	res 6,a
	out 0xaa,a
	;
    ld bc, WAIT_ONE_SECOND/4
    call WAIT
	; CAPS OFF
	in a, 0xaa
	set 6,a
	out 0xaa,a
	;
    ld bc, WAIT_ONE_SECOND/4
    call WAIT

    call CH_GET_STATUS
    cp CH_USB_INT_CONNECT
    jr nz,wait_for_insert
    ret

USB_HOST_BUS_RESET:
    ; reset DEVICE
    ld a, CH_MODE_HOST
    call CH_SET_USB_MODE
    ; wait ~20ms
	ld bc, WAIT_ONE_SECOND/4
	call WAIT

    ; reset BUS
   	ld a, CH_MODE_HOST_RESET
    call CH_SET_USB_MODE
	; wait a bit longer
	ld bc, WAIT_ONE_SECOND/2
	call WAIT
	
    ; reset DEVICE
    ld a, CH_MODE_HOST
    call CH_SET_USB_MODE
    ret c
	; wait ~20ms
	ld bc, WAIT_ONE_SECOND/4
	call WAIT

    ; configure indefinite retries
    or a
    call HW_CONFIGURE_NAK_RETRY

    or a ; clear Cy
	ret

WAIT_ONE_SECOND	equ 60 ; max 60Hz

;-----------------------------------------------------------------------------
;
; Wait a determined number of interrupts
; Input: BC = number of 1/framerate interrupts to wait
; Output: (none)
WAIT:
	halt
	dec bc
	ld a,b
	or c
	jr nz, WAIT
	ret

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
; Input: D = device address
;        HL = pointer to buffer
; Output: Cy = 0, everything okay, Cy = 1, not connected
HW_GET_DESCRIPTORS:
    ld ix, hl

    ; get device descriptor
    call CH_GET_DEVICE_DESCRIPTOR
    jr nc, _INIT_USBHID_NEXT

    call GET_USB_DEVICE_ADDRESS
    cp 1
    ret nz
    ; try again on low speed, only for first device on bus
    ld a, CH_SPEED_LOW
    call CH_SET_SPEED
    ret c
    call CH_GET_DEVICE_DESCRIPTOR
    jr nc, _INIT_USBHID_NEXT
    ret
_INIT_USBHID_NEXT:
    ; set address
    ld a, d
    and a
    jr nz, _SKIP_SET_ADDRESS ; we're asking descriptors of an already identified device
    call GET_USB_DEVICE_ADDRESS
    ld b, (ix+DEVICE_DESCRIPTOR.bMaxPacketSize0)
    call CH_SET_ADDRESS
    ret c
    ; from now on the device only listens to address given
_SKIP_SET_ADDRESS:
    ; get config descriptor
    ld iy, ix
    ld bc, DEVICE_DESCRIPTOR ; sizeof
    add iy, bc ; config lies after device descriptor
    ld e, 0 ; first configuration
_INIT_USBHID_AGAIN:
    ld a, d
    and a
    jr nz, _SKIP_GET_ADDRESS
    call GET_USB_DEVICE_ADDRESS
    ld d, a
_SKIP_GET_ADDRESS:
    ld a, e
    ld b, (ix+DEVICE_DESCRIPTOR.bMaxPacketSize0)
    ld c, CONFIG_DESCRIPTOR ; sizeof
    ld hl, iy 
    call CH_GET_CONFIG_DESCRIPTOR ; call first with max packet size to discover real size
    ret c
    ld c, (iy+CONFIG_DESCRIPTOR.wTotalLength) ; lower 8 bits
    ld a, e
    call CH_GET_CONFIG_DESCRIPTOR ; call again with real size
    ld b, 0
    add iy, bc
    inc e
    ld a, (ix+DEVICE_DESCRIPTOR.bNumConfigurations)
    cp e
    jr nz, _INIT_USBHID_AGAIN
    ret

; FN_JUMP_TABLE: return the configured jumptable in WRKAREA
; Input: HL - location where we want to have the jumptable
; Output: (none)
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
    push hl ; pointer to jumptable
    ex hl,de
    ld hl, JUMP_TABLE_START
    ld bc, JUMP_TABLE_END-JUMP_TABLE_START
    ldir
    ; get pointer to NXT_DIRECT
    ld bc, WRKAREA.NXT_DIRECT
	call WRKAREAPTR
    ld hl, ix
    pop ix ; pointer to jumptable
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
    ; INIT finished
    ld hl, TXT_UNAPI_INIT
    call PRINT
    pop ix
	ret

; GET_CONTROL_PACKET
; return USB descriptors stored in page 3 RAM to enable modification
; Input: BC - offset within descriptor table
; Output: HL - location of USB descriptors in RAM
GET_CONTROL_PACKET:
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
;        D =device address
; Output: Cy=0 no error, Cy=1 error
;         A  = USB error code
;         BC = Amount of data actually transferred (if IN transfer and no error)
CH_GET_DEVICE_DESCRIPTOR:
    push ix,hl,de,bc
    ld a, d ; device address
    push af
    ld de, hl ; Address of the input or output data buffer
    
    ; return USB descriptor stored in WRKAREA
    ld bc, CMD_GET_DEVICE_DESCRIPTOR-CMD_GET_DEVICE_DESCRIPTOR ; Address of the command: 0x80,6,0,1,0,0,18,0
    call GET_CONTROL_PACKET

    pop af
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
    call GET_CONTROL_PACKET
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
    call GET_CONTROL_PACKET
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
    call GET_CONTROL_PACKET
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
    call GET_CONTROL_PACKET
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
    call GET_CONTROL_PACKET
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

; --------------------------------------
; CH_GET_HUB_DESCRIPTOR
;
; Input: HL=pointer to memory to receive device descriptor
;        B=packetsize
;        D=device address
; Output: Cy=0 no error, Cy=1 error
;         A  = USB error code
;         BC = Amount of data actually transferred (if IN transfer and no error)
CH_GET_HUB_DESCRIPTOR:
    push iy,ix,hl,de
    push hl
    ; return USB descriptor stored in WRKAREA
    push bc
    ld bc, CMD_GET_HUB_DESCRIPTOR-CMD_GET_DEVICE_DESCRIPTOR ; Address of the command: {0b10100000,6,0,0x29,0,0,sizeof(USB_HUB_DESCRIPTOR),0}
    call GET_CONTROL_PACKET
    pop bc
    ;
    ld ix, hl
    ld (ix+6),b
    ld a, d ; device address
    pop de ; was HL = memory to receive descriptor
    call HW_CONTROL_TRANSFER

    pop de,hl,ix,iy
    cp CH_USB_INT_SUCCESS
    ret z ; no error
    scf ; error
    ret

; GET_HUB_PORT_STATUS:
; Input: A = port number to check
;        B=packetsize
;        D = device address
;        HL= pointer to 4-bytes memory to receive port status
GET_HUB_PORT_STATUS:
    push iy,ix,hl,de,bc
    push hl
    push bc
    ld bc, CMD_GET_HUB_PORT_STATUS-CMD_GET_DEVICE_DESCRIPTOR ; Address of the command: {0b10100011,0,0,0,portnr,0,4,0};
    call GET_CONTROL_PACKET
    pop bc
    ;
    ld ix, hl
    ld (ix+4),a
    ;
    ld a, d ; device address
    pop de ; was HL = memory to receive port status
    call HW_CONTROL_TRANSFER
    ;
    pop bc,de,hl,ix,iy
    cp CH_USB_INT_SUCCESS
    ret z ; no error
    scf ; error
    ret

; SET_HUB_PORT_FEATURE
; A = port number
; C = feature to set
; D = device address
SET_HUB_PORT_FEATURE:
    push iy,ix,hl,de,bc
    push bc
    ld bc, CMD_SET_HUB_PORT_FEATURE-CMD_GET_DEVICE_DESCRIPTOR ; Address of the command: {0b00100011,0x03,feature_selector,0,port,value,0,0};
    call GET_CONTROL_PACKET
    pop bc
    ;
    ld ix, hl
    ld (ix+2),c
    ld (ix+4),a
    ;
    ld a, d ; device address
    call HW_CONTROL_TRANSFER
    pop bc,de,hl,ix,iy
    cp CH_USB_INT_SUCCESS
    ret z ; no error
    scf ; error
    ret

CHECK_DEVICE_DESCRIPTOR:
    push af
    ld a, (ix+DEVICE_DESCRIPTOR.bNumConfigurations)
    ld (iy+WRKAREA.SEARCH_DEVICE_INFO.NUM_CONFIGS),a
    ld a, (ix+DEVICE_DESCRIPTOR.bMaxPacketSize0)
    ld (iy+WRKAREA.USB_DEVICE_INFO.MAX_PACKET_SIZE),a
    pop af
    ret

CHECK_CONFIG_DESCRIPTOR:
    push af
    ld a, (ix+CONFIG_DESCRIPTOR.bNumInterfaces)
    ld (iy+WRKAREA.SEARCH_DEVICE_INFO.NUM_INTERFACES),a
    ld a, (ix+CONFIG_DESCRIPTOR.bConfigurationvalue)
    ld (iy+WRKAREA.USB_DEVICE_INFO.CONFIG_ID),a
_CHECK_CONFIG_NEXT:
    dec (iy+WRKAREA.SEARCH_DEVICE_INFO.NUM_CONFIGS)
    pop af
    ret
    
CHECK_INTERFACE_DESCRIPTOR:
    push af,bc
    ld a, (ix+INTERFACE_DESCRIPTOR.bNumEndpoints)
    ld (iy+WRKAREA.SEARCH_DEVICE_INFO.NUM_ENDPOINTS),a
    ld b, (ix+INTERFACE_DESCRIPTOR.bInterfaceClass)
    ld a, (iy+WRKAREA.SEARCH_DEVICE_INFO.WANTED_CLASS)
    cp b
    jr nz, _INTERFACE_NOT_INTERESTING
    ld b, (ix+INTERFACE_DESCRIPTOR.bInterfaceSubClass)
    ld a, (iy+WRKAREA.SEARCH_DEVICE_INFO.WANTED_SUB_CLASS)
    cp 0ffh ; wildcard
    jr z, _NEXT_CHECK2
    cp b
    jr nz, _INTERFACE_NOT_INTERESTING
_NEXT_CHECK2:
    ld b, (ix+INTERFACE_DESCRIPTOR.bInterfaceProtocol)
    ld a, (iy+WRKAREA.SEARCH_DEVICE_INFO.WANTED_PROTOCOL)
    cp 0ffh ; wildcard
    jr z, _NEXT_CHECK3
    cp b
    jr nz, _INTERFACE_NOT_INTERESTING
_NEXT_CHECK3:
    ; found the right interface
    ld a, (ix+INTERFACE_DESCRIPTOR.bInterfaceNumber)
    ld (iy+WRKAREA.USB_DEVICE_INFO.INTERFACE_ID),a
_INTERFACE_NOT_INTERESTING:
    dec (iy+WRKAREA.SEARCH_DEVICE_INFO.NUM_INTERFACES)
    pop bc,af
    ret

CHECK_ENDPOINT_DESCRIPTOR:
    push af

    ; data interface
    ld a, (ix+ENDPOINT_DESCRIPTOR.bmAttributes)
    and 0b00000011
    cp 0b00000010
    jr nz,_CHECK_ENDPOINT_DESCRIPTOR_END ; not Bulk endpoint

    ld a, (ix+ENDPOINT_DESCRIPTOR.bEndpointAddress)
    bit 7,a
    jr z, _CHECK_BULK_OUTPUT
    and 0b01111111
    ld (iy+WRKAREA.USB_DEVICE_INFO.DATA_BULK_IN_ENDPOINT_ID), a
    jr _CHECK_ENDPOINT_DESCRIPTOR_END
_CHECK_BULK_OUTPUT:
    and 0b01111111
    ld (iy+WRKAREA.USB_DEVICE_INFO.DATA_BULK_OUT_ENDPOINT_ID), a
_CHECK_ENDPOINT_DESCRIPTOR_END:

    dec (iy+WRKAREA.SEARCH_DEVICE_INFO.NUM_ENDPOINTS)
    pop af
    ret

PARSE_USB_DESCRIPTORS:
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
    ; check if we're done checking
    ld a, (iy+WRKAREA.SEARCH_DEVICE_INFO.NUM_CONFIGS)
    and a
    jr nz, _DO_AGAIN
    ld a, (iy+WRKAREA.SEARCH_DEVICE_INFO.NUM_INTERFACES)
    and a
    jr nz, _DO_AGAIN
    ld a, (iy+WRKAREA.SEARCH_DEVICE_INFO.NUM_ENDPOINTS)
    and a
    jr nz, _DO_AGAIN
    ; no more endpoints, interfaces and configs to scan
    jr _DONE
_DO_AGAIN:
    add ix,bc
    jr _USB_CHECK_NEXT
_DONE:
    ret

; Parse the descriptor to see if a mass storage device 
; is connected
;
; Input: HL points to buffer with descriptor
; Output: Cy = 0 (found), Cy = 1 (not found)
CHECK_DESCRIPTOR_MASS_STORAGE:
    call MY_GWORK
    ld iy, ix ; iy pointing to start of WRKAREA
    ld bc, WRKAREA.USB_DESCRIPTOR
    add ix, bc ; ix pointing to buffer
    ; init value
    ld a, 0ffh
    ld (iy+WRKAREA.USB_DEVICE_INFO.INTERFACE_ID),a
    ld (iy+WRKAREA.USB_DEVICE_INFO.CONFIG_ID),a
    ; start searching
    ld a, 8 ; mass storage
    ld (iy+WRKAREA.SEARCH_DEVICE_INFO.WANTED_CLASS),a
    ld a, 6 ; SCSI command set
    ld (iy+WRKAREA.SEARCH_DEVICE_INFO.WANTED_SUB_CLASS),a
    ld a, 050h
    ld (iy+WRKAREA.SEARCH_DEVICE_INFO.WANTED_PROTOCOL),a
    call PARSE_USB_DESCRIPTORS
    ld a, (iy+WRKAREA.USB_DEVICE_INFO.INTERFACE_ID)
    cp 0ffh
    jr nz, _FOUND_MASS_STORAGE
    scf ; set Cy
    ret
_FOUND_MASS_STORAGE:
    or a ; reset Cy
    ret

; Parse the descriptor to see if an ECM ethernet device
; is connected
;
; Input: HL points to buffer with descriptor
; Output: Cy = 0 (found), Cy = 1 (not found)
CHECK_DESCRIPTOR_CDC_ECM:
    call MY_GWORK
    ld iy, ix ; iy pointing to start of WRKAREA
    ld bc, WRKAREA.USB_DESCRIPTOR
    add ix, bc ; ix pointing to buffer
    ; init value
    ld a, 0ffh
    ld (iy+WRKAREA.USB_DEVICE_INFO.INTERFACE_ID),a
    ld (iy+WRKAREA.USB_DEVICE_INFO.CONFIG_ID),a
    ; start searching
    ld a, 2 ; CDC
    ld (iy+WRKAREA.SEARCH_DEVICE_INFO.WANTED_CLASS),a
    ld a, 6 ; ECM
    ld (iy+WRKAREA.SEARCH_DEVICE_INFO.WANTED_SUB_CLASS),a
    ld a, 0ffh ; don't care
    ld (iy+WRKAREA.SEARCH_DEVICE_INFO.WANTED_PROTOCOL),a
    call PARSE_USB_DESCRIPTORS
    ld a, (iy+WRKAREA.USB_DEVICE_INFO.INTERFACE_ID)
    cp 0ffh
    jr nz, _FOUND_CDC_ECM
    scf ; set Cy
    ret
_FOUND_CDC_ECM:
    or a ; reset Cy
    ret

; Parse the descriptor to see if a USB hub 
; is connected
;
; Input: (none), assumed that descriptor is loaded in WRKAREA.USB_DESCRIPTOR
; Output: Cy = 0 (found), Cy = 1 (not found)
CHECK_DESCRIPTOR_HUB:
    call MY_GWORK
    ld iy, ix ; iy pointing to start of WRKAREA
    ld bc, WRKAREA.USB_DESCRIPTOR
    add ix, bc ; ix pointing to buffer
    ; init value
    ld a, 0ffh
    ld (iy+WRKAREA.USB_DEVICE_INFO.INTERFACE_ID),a
    ld (iy+WRKAREA.USB_DEVICE_INFO.CONFIG_ID),a
    ; start searching
    ld a, 9 ; USB Hub device
    ld (iy+WRKAREA.SEARCH_DEVICE_INFO.WANTED_CLASS),a
    ld a, 0 ; always zero
    ld (iy+WRKAREA.SEARCH_DEVICE_INFO.WANTED_SUB_CLASS),a
    ld a, 0ffh ; don't care
    ld (iy+WRKAREA.SEARCH_DEVICE_INFO.WANTED_PROTOCOL),a
    call PARSE_USB_DESCRIPTORS
    ld a, (iy+WRKAREA.USB_DEVICE_INFO.INTERFACE_ID)
    cp 0ffh
    jr nz, _FOUND_HUB
    scf ; set Cy
    ret
_FOUND_HUB:
    or a ; reset Cy
    ret 

INIT_CDC_ECM:
    call MY_GWORK
    ld iy, ix ; iy pointing to start of WRKAREA
    ld bc, WRKAREA.USB_DESCRIPTOR
    add ix, bc ; ix pointing to buffer
    ; activate CDC_ECM
    ld a, (iy+WRKAREA.USB_DEVICE_INFO.MAX_PACKET_SIZE) 
    ld b,a
    call GET_USB_DEVICE_ADDRESS
    ld d, a
    ld a, (iy+WRKAREA.USB_DEVICE_INFO.CONFIG_ID)
    push bc,de
    call CH_SET_CONFIGURATION
    pop de,bc
    ret

INIT_STORAGE:
    call MY_GWORK
    ld a, (ix+WRKAREA.MAX_DEVICE_ADDRESS) ; current address
	ld (ix+WRKAREA.USB_DEVICE_INFO.DEVICE_ADDRESS),a
	; copy USB_DEVICE_INFO to STORAGE_DEVICE_INFO
	push ix
	ld bc, WRKAREA.STORAGE_DEVICE_INFO.BASE
	call WRKAREAPTR
	ld de, ix
	ld bc, WRKAREA.USB_DEVICE_INFO.BASE
	call WRKAREAPTR
	ld hl, ix
	ld bc, _USB_DEVICE_INFO
	ldir
	pop ix
	; SET CONFIGURATION
	ld d, (ix+WRKAREA.STORAGE_DEVICE_INFO.DEVICE_ADDRESS)
	ld b, (ix+WRKAREA.STORAGE_DEVICE_INFO.MAX_PACKET_SIZE)
	ld a, (ix+WRKAREA.STORAGE_DEVICE_INFO.CONFIG_ID)
	call CH_SET_CONFIGURATION
    ret

; Initialise HUB device
INIT_HUB:
    call MY_GWORK
    ld iy, ix ; iy pointing to start of WRKAREA
    ld bc, WRKAREA.USB_DESCRIPTOR
    add ix, bc ; ix pointing to buffer
    ; activate HUB
    ld a, (iy+WRKAREA.USB_DEVICE_INFO.MAX_PACKET_SIZE) 
    ld b,a
    call GET_USB_DEVICE_ADDRESS
    ld d, a
    ld a, (iy+WRKAREA.USB_DEVICE_INFO.CONFIG_ID)
    push bc,de
    call CH_SET_CONFIGURATION
    pop de,bc
    ret c
    ; get HUB descriptor
    ld hl, ix ; WRKAREA.USB_DESCRIPTOR
    call CH_GET_HUB_DESCRIPTOR
    ret c
    ld a, (ix+HUB_DESCRIPTOR.bNrPorts)
    ld (iy+WRKAREA.HUB_DEVICE_INFO.HUB_PORTS),a
    ; power up all ports
    ld b, a ; counter
    ld e, 1
    ld c, 8 ; PORT_POWER
_POWER_UP_AGAIN:
    ld a, e
    call SET_HUB_PORT_FEATURE
    ret c
    inc e
    djnz _POWER_UP_AGAIN
    ; check which ones have something connected
    ld a, (iy+WRKAREA.HUB_DEVICE_INFO.HUB_PORTS)
    ld b, a ; counter
    ld e, 1 ; start index 1
_HUB_STATUS_AGAIN:
    push bc
    ld hl, iy
    ld bc, WRKAREA.HUB_DEVICE_INFO.HUB_PORT_STATUS
    add hl, bc
    ld a, (iy+WRKAREA.USB_DEVICE_INFO.MAX_PACKET_SIZE) 
    ld b,a
    ld a, e
    call GET_HUB_PORT_STATUS
    pop bc
    ret c
    ld a, (hl)
    bit 0,a ; connected
    call nz, INIT_HUB_DEVICE
    ;bit 1,a ; enabled
    ;bit 2,a ; suspended
    ;bit 3,a ; reset
    ;inc hl
    ;ld a, (hl)
    ;bit 0,a ; powered
    ;bit 1,a ; lowspeed
    ;bit 2,a ; highspeed
    ;bit 4,a ; indicator control
    inc e
    djnz _HUB_STATUS_AGAIN
    ret

; Input - E = portnumber on hub to initialise
;         D = USB device address
INIT_HUB_DEVICE:
    push bc, de
    ; reset usb bus on port(s)
    ld a, e ; e contains port number
    ld c, 4 ; RESET
    call SET_HUB_PORT_FEATURE
    ret c
    ; wait 250ms
    push bc
    ld bc, WAIT_ONE_SECOND/4
    call WAIT
    pop bc
    ; recursively initialise device
    call GET_USB_DEVICE_ADDRESS
    inc a
    call SET_USB_DEVICE_ADDRESS
    call FN_CONNECT2
    ;
    pop de, bc
    ret

    include "usb_descriptors.asm"
	include "unapi.asm"

TXT_UNAPI_INIT DB "+UNAPI initialised\r\n",0
UNAPI_ID DB "MSXUSB",0
;UNAPI_INFO: db "MSXUSB driver by Sourceror",0
;Moved to start of unused space in Nextor kernel
UNAPI_INFO: equ 7BD0h