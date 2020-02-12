; major and minor version number of MSXUSB UNAPI
UNAPI_P:  equ  0
UNAPI_S:  equ  1
; S0urceror's CH376s driver, major and minor version
IMPLEMENTATION_P:  equ  0
IMPLEMENTATION_S:  equ  1

USB_DEVICE_ADDRESS EQU 1
SCRATCH_SPACE EQU 0100h

HIMEM equ 0FC4Ah
BOTTOM equ 0FC48h
MEMSIZ equ 0F672h
USRTAB equ 0F39Ah
RAMAD3 equ 0F344h

    org  4000h
    db  "AB"
    dw  INIT
    ds  12

INIT:
    ; HOOK EXTBIO
    call HOOK_EXTBIO
    ; INIT finished
    ld hl, TXT_INIT
    call PRINT
    ; create a scratch space by moving HIMEM down
    call ALLOC_SCRATCH
	ret	; Back to slots scanning

ALLOC_SCRATCH:
    push af, bc, de, hl

    ; get SLTWRK in HL for this ROM page
    call GETSLT
    call GETWRK
    ; calculate new HIMEM
    ld de,(HIMEM)
    ex hl, de
    ld bc, SCRATCH_SPACE
    or a
    sbc hl, bc
    ex hl, de
    ; store updated HIMEM in SLT WRK
    ld (hl),e
    inc hl
    ld (hl),d
    ex hl, de
    ; OPTION 2, make HIMEM lower => works
    ld a,l
    ld (HIMEM),a
    ld a,h
    ld (HIMEM+1),a

    ; copy USB commands to scratch area
    ex de,hl
    ld hl, CMD_GET_DEVICE_DESCRIPTOR
    ld bc, CMD_GET_CONFIG_DESCRIPTOR - CMD_GET_DEVICE_DESCRIPTOR + 8
    ldir

    pop hl,de,bc,af
    ret 

    include "print_bios.asm"

;***********************************
;***  FUNCTIONS ADDRESSES TABLE  ***
;***********************************

;--- Standard routines addresses table
FN_TABLE:
FN_0:  dw  FN_INFO
FN_1:  dw  FN_CHECK
FN_2:  dw  FN_CONNECT
FN_3:  dw  FN_GETDESCRIPTORS
FN_4:  dw  FN_EXECUTE_CONTROL_TRANSFER
FN_5:  dw  FN_DATA_IN_TRANSFER
FN_6:  dw  FN_DATA_OUT_TRANSFER
MAX_FN equ 6

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

; Check if CH376s is connected and functional
; Input: (none)
; Output: Cy = 0, everything okay, Cy = 1, not connected
FN_CHECK:
    ; check_exists
    call CH_HW_TEST
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
    ; set address (1)
    ld a, USB_DEVICE_ADDRESS ; address to assign to attached USB device
    ld b, (ix+DEVICE_DESCRIPTOR.bMaxPacketSize0)
    call CH_SET_ADDRESS
    ret c
    ; from now on the device only listens to address given
    ; get config descriptor
    ld bc, DEVICE_DESCRIPTOR ; sizeof
    ld hl, ix
    add hl, bc ; config lies after device descriptor
    ld a, 0 ; first configuration
    ld b, (ix+DEVICE_DESCRIPTOR.bMaxPacketSize0)
    ld c, CONFIG_DESCRIPTOR ; sizeof
    ld d, USB_DEVICE_ADDRESS ; assigned address
    call CH_GET_CONFIG_DESCRIPTOR ; call first with max packet size to discover real size
    ret c
    ld a, 0 ; first configuration
    ld ix, hl
    ld c, (ix+CONFIG_DESCRIPTOR.wTotalLength) ; lower 8 bits
    call CH_GET_CONFIG_DESCRIPTOR ; call again with real size
    ret
FN_LSUSB:
    ret
FN_EXECUTE_CONTROL_TRANSFER:
    ret
FN_DATA_IN_TRANSFER:
    ret
FN_DATA_OUT_TRANSFER:
    ret

    include "usb_descriptors.asm"
	include "ch376s.asm"
    include "unapi.asm"

TXT_INIT DB "\r\nUNAPI USB Driver started\r\n\r\n",0
TXT_NEWLINE DB "\r\n",0
UNAPI_ID DB "MSXUSB",0
UNAPI_INFO: db "MSXUSB driver by Sourceror",0

    DS 0C000h-$,0