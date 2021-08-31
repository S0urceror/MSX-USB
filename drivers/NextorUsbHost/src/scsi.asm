;
; scsi.ASM - scsi command set for low level usb storage
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

    include "scsi_helpers.asm"

; Input:  A = USB storage device id
;         B = LUN number
;         C = CMD buffer length
;         DE = send/recv buffer length
;		  HL = points to CMD to send
;		  IX = points to buffer to send/receive
;         Cy=0 to read, 1 to write
; Output: Cy when error
DO_SCSI_CMD:
    push ix, af, de, bc, hl ; +++++
    ld bc, WRKAREA.SCSI_DEVICE_INFO.BUFFER
    call WRKAREAPTR
    ld iy,ix
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; SEND CBW
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; prepare CBW
    ; copy template
    ld de, iy
    ld bc, _SCSI_COMMAND_BLOCK_WRAPPER
    ld hl, SCSI_COMMAND_BLOCK_WRAPPER
    ldir 
    ; copy CMD
    pop hl, bc ; +++
    push bc ; ++++
    ld b, 0
    ldir
    pop bc ; +++
    pop de ; ++
    ; set transfer length
    ld ix, iy ; ix points now to SCSI_COMMAND_BLOCK
    ld (ix+_SCSI_COMMAND_BLOCK_WRAPPER.CBWLUN),b
    ld (ix+_SCSI_COMMAND_BLOCK_WRAPPER.CBWCBLENGTH),c
    ld (ix+_SCSI_COMMAND_BLOCK_WRAPPER.CBWDATATRANSFERLENGTH),e
    ld (ix+_SCSI_COMMAND_BLOCK_WRAPPER.CBWDATATRANSFERLENGTH+1),d
    ; set tag
    ld bc, WRKAREA.BASE - WRKAREA.SCSI_DEVICE_INFO.BUFFER
    add iy, bc ; iy points now to WRKAREA
    ld a, (iy+WRKAREA.SCSI_DEVICE_INFO.TAG)
    ld (ix+_SCSI_COMMAND_BLOCK_WRAPPER.CBWTAG),a
    inc a
    ld (iy+WRKAREA.SCSI_DEVICE_INFO.TAG),a
    pop af ; usb_storage_device_id +
    push af ; usb_storage_device_id ++
    ; CBWFLAGS is zero by default, indicates write
    jr c, _DO_SCSI_CMD_WRITE
_DO_SCSI_CMD_READ:    
    ; CBWFLAGS indicates read
    set 7,(ix+_SCSI_COMMAND_BLOCK_WRAPPER.CBWFLAGS)
_DO_SCSI_CMD_WRITE:
    ld hl, ix
    ld a, (iy+WRKAREA.STORAGE_DEVICE_INFO.MAX_PACKET_SIZE)
    ld d, a
    ld a, (iy+WRKAREA.STORAGE_DEVICE_INFO.DATA_BULK_OUT_ENDPOINT_ID)
    ld e, a
    ld a, (iy+WRKAREA.STORAGE_DEVICE_INFO.DATA_BULK_OUT_ENDPOINT_TOGGLE)
    rla ; move bit 7 to Cy
    pop bc ; usb_storage_device_id +
    push bc ; usb_storage_device_id ++
    ld a, b
    ld bc, _SCSI_COMMAND_BLOCK_WRAPPER+16 ; 16 byte commands + wrapper
    push iy ; +++
    call HW_DATA_OUT_TRANSFER
    pop iy ; ++
    push af ; 0 or error_code +++
    ld a, 0
    rra ; move Cy to bit 7
    ld (iy+WRKAREA.STORAGE_DEVICE_INFO.DATA_BULK_OUT_ENDPOINT_TOGGLE),a
    pop af ; 0 or error_code ++
    and a
    jr z, _DO_SCSI_CMD_PAYLOAD
    pop af ; usb_storage_device_id +
    pop ix ; 
    scf
    ret ; error
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; SEND or RECEIVE PAYLOAD
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_DO_SCSI_CMD_PAYLOAD:
    ld e,(ix+_SCSI_COMMAND_BLOCK_WRAPPER.CBWDATATRANSFERLENGTH)
    ld d,(ix+_SCSI_COMMAND_BLOCK_WRAPPER.CBWDATATRANSFERLENGTH+1)
    ld a, e
    or d
    jr z, _DO_SCSI_CMD_RCV_COMMAND_STATUS_WRAPPER ; no use to read or write zero bytes, skip
    ; do read or write?
    ld a,(ix+_SCSI_COMMAND_BLOCK_WRAPPER.CBWFLAGS)
    bit 7,a
    jr z, _DO_SCSI_CMD_WRITE3
    ; READ response from USB SCSI device to IX
    ld a, (iy+WRKAREA.STORAGE_DEVICE_INFO.MAX_PACKET_SIZE)
    ld d, a
    ld a, (iy+WRKAREA.STORAGE_DEVICE_INFO.DATA_BULK_IN_ENDPOINT_ID)
    ld e, a
    ld a, (iy+WRKAREA.STORAGE_DEVICE_INFO.DATA_BULK_IN_ENDPOINT_TOGGLE)
    rla ; move bit 7 to Cy
    pop bc ; usb_storage_device_id +
    pop hl ; was ix passed to DO_SCSI_CMD = read/write buffer 
    push hl ; +
    push bc ; usb_storage_device_id ++
    ld a, b
    ld c,(ix+_SCSI_COMMAND_BLOCK_WRAPPER.CBWDATATRANSFERLENGTH)
    ld b,(ix+_SCSI_COMMAND_BLOCK_WRAPPER.CBWDATATRANSFERLENGTH+1)
    push iy ; ++
    call HW_DATA_IN_TRANSFER
    pop iy ; +
    ld a, 0
    rra ; move Cy to bit 7
    ld (iy+WRKAREA.STORAGE_DEVICE_INFO.DATA_BULK_IN_ENDPOINT_TOGGLE),a
    jr _DO_SCSI_CMD_RCV_COMMAND_STATUS_WRAPPER
_DO_SCSI_CMD_WRITE3:
    ; WRITE contents IX to USB SCSI device
    ld a, (iy+WRKAREA.STORAGE_DEVICE_INFO.MAX_PACKET_SIZE)
    ld d, a
    ld a, (iy+WRKAREA.STORAGE_DEVICE_INFO.DATA_BULK_OUT_ENDPOINT_ID)
    ld e, a
    ld a, (iy+WRKAREA.STORAGE_DEVICE_INFO.DATA_BULK_OUT_ENDPOINT_TOGGLE)
    rla ; move bit 7 to Cy
    pop bc ; usb_storage_device_id +
    pop hl ; was ix passed to DO_SCSI_CMD = read/write buffer 
    push hl ; +
    push bc ; usb_storage_device_id ++
    ld a, b
    ld c,(ix+_SCSI_COMMAND_BLOCK_WRAPPER.CBWDATATRANSFERLENGTH)
    ld b,(ix+_SCSI_COMMAND_BLOCK_WRAPPER.CBWDATATRANSFERLENGTH+1)
    push iy ; ++
    call HW_DATA_OUT_TRANSFER
    pop iy ; +
    ld a, 0
    rra ; move Cy to bit 7
    ld (iy+WRKAREA.STORAGE_DEVICE_INFO.DATA_BULK_OUT_ENDPOINT_TOGGLE),a
_DO_SCSI_CMD_RCV_COMMAND_STATUS_WRAPPER:
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; RECEIVE CSW
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; read back CSW
    ; data_in_transfer
    ; check if all went right, set Cy accordingly
    ld hl, iy
    ld bc, WRKAREA.SCSI_DEVICE_INFO.CSW
    add hl,bc
    ld ix, hl
    ld a, (iy+WRKAREA.STORAGE_DEVICE_INFO.MAX_PACKET_SIZE)
    ld d, a
    ld a, (iy+WRKAREA.STORAGE_DEVICE_INFO.DATA_BULK_IN_ENDPOINT_ID)
    ld e, a
    ld a, (iy+WRKAREA.STORAGE_DEVICE_INFO.DATA_BULK_IN_ENDPOINT_TOGGLE)
    rla ; move bit 7 to Cy
    pop bc ; usb_storage_device_id +
    ld a, b
    pop bc ;  was ix passed to DO_SCSI_CMD = read/write buffer
    ld bc,_SCSI_COMMAND_STATUS_WRAPPER
    push ix,iy ; ++
    call HW_DATA_IN_TRANSFER
    pop iy,ix ; 
    ld a, 0
    rra ; move Cy to bit 7
    ld (iy+WRKAREA.STORAGE_DEVICE_INFO.DATA_BULK_IN_ENDPOINT_TOGGLE),a

    ld a, (ix+_SCSI_COMMAND_STATUS_WRAPPER.CBWSTATUS)
    and a
    jr nz, DO_SCSCI_CMD_CBW_ERROR ; set Cy when CBWSTATUS!=0
    or a ; clear Cy
	ret

DO_SCSCI_CMD_CBW_ERROR:
    call PRINT_ERROR_CODE_VDP
    scf
    ret

; --------------------------------------
; SCSI_INQUIRY
;
; Input: IX points to SLTWRK
; Output: Cy=0 no error, Cy=1 error
SCSI_INQUIRY:
    push ix ; ix points to SLTWRK

    ld a, (ix+WRKAREA.STORAGE_DEVICE_INFO.DEVICE_ADDRESS)
    ld bc, WRKAREA.SCSI_DEVICE_INFO.BUFFER
    add ix, bc
    ld iy, ix
    
    ld b, 0
    ld c, _SCSI_PACKET_INQUIRY
    ld de, 0x24
    ld hl, SCSI_PACKET_INQUIRY
    push iy
    call DO_SCSI_CMD
    pop iy
    pop ix
    ret c

    push ix
    ld hl, iy
    ld bc, 8
    add hl,bc
    ld bc, WRKAREA.SCSI_DEVICE_INFO.VENDORID
	call WRKAREAPTR
    ld de, ix
    ld bc, 8
    ldir

    ld hl, iy
    ld bc, 16
    add hl,bc
    ld bc, WRKAREA.SCSI_DEVICE_INFO.PRODUCTID
	call WRKAREAPTR
    ld de, ix
    ld bc, 16
    ldir

    ld hl, iy
    ld bc, 32
    add hl,bc
    ld bc, WRKAREA.SCSI_DEVICE_INFO.PRODUCTREV
	call WRKAREAPTR
    ld de, ix
    ld bc, 4
    ldir
    pop ix

    or a ; reset Cy
    ret

; --------------------------------------
; SCSI_TEST
;
; Input: IX points to SLTWRK
; Output: Cy=0 no error, Cy=1 error
SCSI_TEST:
    push ix
    ld a,(ix+WRKAREA.STORAGE_DEVICE_INFO.DEVICE_ADDRESS)
    ld bc, WRKAREA.SCSI_DEVICE_INFO.BUFFER
    add ix,bc
    ld b, 0
    ld c, _SCSI_PACKET_TEST
    ld de, 0 ; no result data, only status in CBWSTATUS
    ld hl, SCSI_PACKET_TEST

    call DO_SCSI_CMD
    pop ix
    ret c

    or a ; reset Cy
    ret 

; --------------------------------------
; SCSI_REQUEST_SENSE
;
; Input: IX points to SLTWRK
; Output: Cy=0 no error, Cy=1 error
SCSI_REQUEST_SENSE:
    push ix
    ld a,(ix+WRKAREA.STORAGE_DEVICE_INFO.DEVICE_ADDRESS)
    ld bc, WRKAREA.SCSI_DEVICE_INFO.BUFFER
    add ix,bc
    ld b, 0
    ld c, _SCSI_PACKET_REQUEST_SENSE
    ld de, 18
    ld hl, SCSI_PACKET_REQUEST_SENSE

    call DO_SCSI_CMD
    pop ix
    ret c

    or a ; reset Cy
    ret 

; --------------------------------------
; SCSI_READ
;
; Input: B  nr sectors
;        HL points to buffer to receive bytes
;        DE address of 4 byte sector number
; Output: Cy=0 no error, Cy=1 error
SCSI_READ:
    push hl, de, bc
    ; copy SCSI_PACKET_READ to receive buffer
    ld de, hl
    ld hl, SCSI_PACKET_READ
    ld bc, _SCSI_PACKET_READ
    ldir
    pop bc, de, hl
    ; reverse sector number to high-endian
    push hl
    ld ix, hl
    ld (ix+_SCSI_PACKET_READ.TRANSFER_LEN+1),b ; high-endian
    ld a, (de)
    ld (ix+_SCSI_PACKET_READ.LBA+3),a
    inc de
    ld a, (de)
    ld (ix+_SCSI_PACKET_READ.LBA+2),a
    inc de
    ld a, (de)
    ld (ix+_SCSI_PACKET_READ.LBA+1),a
    inc de
    ld a, (de)
    ld (ix+_SCSI_PACKET_READ.LBA),a
    ; do read
    call MY_GWORK
    ld a,(ix+WRKAREA.STORAGE_DEVICE_INFO.DEVICE_ADDRESS)
    ld de, 512
    ld hl, 0
_TOTAL_BYTES_RD
    add hl, de
    djnz _TOTAL_BYTES_RD
    ld de, hl
    ld b, 0
    ld c, _SCSI_PACKET_READ
    pop hl
    ld ix, hl ; receive buffer is also holding modified scsi read command
    or a ; clear Cy = read bytes from scsi
    call DO_SCSI_CMD
    ret 

; --------------------------------------
; SCSI_WRITE
;
; Input: B  nr sectors
;        HL points to buffer to send bytes
;        DE address of 4 byte sector number
; Output: Cy=0 no error, Cy=1 error
SCSI_WRITE:
    push hl, de, bc ; +++
    ; copy SCSI_PACKET_WRITE to receive buffer
    ld bc, WRKAREA.SCSI_DEVICE_INFO.BUFFER+_SCSI_COMMAND_BLOCK_WRAPPER
    call WRKAREAPTR
    ld de, ix
    ld hl, SCSI_PACKET_WRITE
    ld bc, _SCSI_PACKET_WRITE
    ldir
    pop bc, de, hl ;
    ; reverse sector number to high-endian
    push ix ; CMD buffer +
    push hl ; sector buffer ++
    ;ld ix, hl
    ld (ix+_SCSI_PACKET_WRITE.TRANSFER_LEN+1),b ; high-endian
    ld a, (de)
    ld (ix+_SCSI_PACKET_WRITE.LBA+3),a
    inc de
    ld a, (de)
    ld (ix+_SCSI_PACKET_WRITE.LBA+2),a
    inc de
    ld a, (de)
    ld (ix+_SCSI_PACKET_WRITE.LBA+1),a
    inc de
    ld a, (de)
    ld (ix+_SCSI_PACKET_WRITE.LBA),a
    ; do read
    call MY_GWORK
    ld a,(ix+WRKAREA.STORAGE_DEVICE_INFO.DEVICE_ADDRESS)
    ld de, 512
    ld hl, 0
_TOTAL_BYTES_WR
    add hl, de
    djnz _TOTAL_BYTES_WR
    ld de, hl
    ld b, 0
    ld c, _SCSI_PACKET_WRITE
    pop ix ; sector buffer +
    pop hl ; CMD buffer
    scf ; set Cy = write bytes to scsi
    call DO_SCSI_CMD
    ret

; --------------------------------------
; SCSI_MAX_LUNS
;
; Input:  Input: IX=pointer to WRKAREA
; Output: Cy=0 no error, Cy=1 error
SCSI_MAX_LUNS:
    push iy,ix,hl,de,bc

    push ix
    ld bc, WRKAREA.SCSI_DEVICE_INFO.MAX_LUNS
	call WRKAREAPTR
	ld iy, ix
    pop ix
	ld d,(ix+WRKAREA.STORAGE_DEVICE_INFO.DEVICE_ADDRESS)
	ld b,(ix+WRKAREA.STORAGE_DEVICE_INFO.MAX_PACKET_SIZE)
	ld a,(ix+WRKAREA.STORAGE_DEVICE_INFO.INTERFACE_ID)

    ; get SLTWRK in HL for this ROM page
    push bc
    ld bc, CMD_GET_MAX_LUNS-CMD_GET_DEVICE_DESCRIPTOR ; Address of the command: {0b10100001,0b11111110,0,0,interface,0,1,0};
    call GET_CONTROL_PACKET
    pop bc
    
    ld ix, hl
    ld (ix+4), a
    ld a, d ; device address
    ld de, iy ; Address of the input or output data buffer
    call HW_CONTROL_TRANSFER
    pop bc,de,hl,ix,iy
    cp CH_USB_INT_SUCCESS
    ret z ; no error
    scf ; error
    ret

; --------------------------------------
; SCSI_INIT
;
; Input: IX=pointer to WRKAREA
;
SCSI_INIT:
    ld a, 1
	ld (ix+WRKAREA.SCSI_DEVICE_INFO.TAG),a
	xor a
	ld (ix+WRKAREA.STORAGE_DEVICE_INFO.DATA_BULK_OUT_ENDPOINT_TOGGLE),a
	ld (ix+WRKAREA.STORAGE_DEVICE_INFO.DATA_BULK_IN_ENDPOINT_TOGGLE),a
    ret

PRINT_ERROR_CODE_VDP:
    push af
    call PRINT_INIT_SCREEN0
    ld a, 'E'
    call PRINT_CHAR_VDP
    pop af
    call PRINT_HEX_VDP
    ret

PRINT_CHAR_VDP:
    ; print to VDP (auto increments)
    out (#98),a
    ret

PRINT_INIT_SCREEN0:
    ; set pointer to 77,0 for screen 0
    xor a
    ld hl,77
    call SetVdp_Write
    ret
PRINT_INIT_SCREEN1:
    ; set pointer to 0,0 for screen 1
    xor a
    ld hl,#1800
    call SetVdp_Write
    ret
;
; Set VDP address counter to write from address AHL (17-bit)
; Enables the interrupts
;
SetVdp_Write:
    rlc h
    rla
    rlc h
    rla
    srl h
    srl h
    di
    out (#99),a
    ld a,14 + 128
    out (#99),a
    ld a,l
    nop
    out (#99),a
    ld a,h
    or 64
    ei
    out (#99),a
    ret


;       Subroutine      Print 8-bit hexidecimal number
;       Inputs          A - number to be printed - 0ABh
;       Outputs         ________________________
PRINT_HEX_VDP:
    push af
    push bc
    push de
    call .NUMTOHEX
    ld a, d
    call PRINT_CHAR_VDP
    ld a, e
    call PRINT_CHAR_VDP
    pop de
    pop bc
    pop af
    ret
;       Subroutine      Convert 8-bit hexidecimal number to ASCII reprentation
;       Inputs          A - number to be printed - 0ABh
;       Outputs         DE - two byte ASCII values - D=65 / 'A' and E=66 / 'B'
.NUMTOHEX:
    ld c, a   ; a = number to convert
    call .NTH1
    ld d, a
    ld a, c
    call .NTH2
    ld e, a
    ret  ; return with hex number in de
.NTH1:
    rra
    rra
    rra
    rra
.NTH2:
    or 0F0h
    daa
    add a, 0A0h
    adc a, 040h ; Ascii hex at this point (0 to F)   
    ret


SCSI_PACKET_INQUIRY         _SCSI_PACKET_INQUIRY
SCSI_PACKET_TEST            _SCSI_PACKET_TEST
SCSI_COMMAND_BLOCK_WRAPPER  _SCSI_COMMAND_BLOCK_WRAPPER
SCSI_PACKET_REQUEST_SENSE   _SCSI_PACKET_REQUEST_SENSE
SCSI_PACKET_READ            _SCSI_PACKET_READ
SCSI_PACKET_WRITE           _SCSI_PACKET_WRITE