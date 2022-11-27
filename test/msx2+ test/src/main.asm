OPTENT	EQU	0x7A00			; optrom entrypoint
RDRES EQU 0x017A ; check F4 register
WRRES EQU 0x017D ; set F4 register
EXTROM EQU 0x015F ; 
RDSLT EQU 0x000c
CALSLT EQU 0x1c
CHGMOD EQU 0x5f
WAIT_ONE_SECOND EQU 50

    org 0C000h
; BLOAD header
    db 0x0fe
    dw BEGIN, ENDADR, START_BASIC
BEGIN:
START_BASIC:
    ld hl, WELCOME_MSG
    call PRINT

    ld b, 8
    ld hl,0
    call GET_BYTES_SUBROM

    ld hl, BUFFER
    ld bc, 8
    call PRINTHEX_BUFFER

    ld hl, TXT_NEWLINE
    call PRINT

    ld b, 8
    ld hl,OPTENT
    call GET_BYTES_SUBROM

    ld hl, BUFFER
    ld bc, 8
    call PRINTHEX_BUFFER

    call RDRES
    call PRINT_HEX

    xor a
    call WRRES

    call RDRES
    call PRINT_HEX

    ld bc, WAIT_ONE_SECOND*5
    call WAIT

    call SHOW_BOOT_LOGO

    ld bc, WAIT_ONE_SECOND*5
    call WAIT

    xor a
    call CHGMOD

    call 0
    
    ret


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

GET_BYTES_SUBROM:
    ld ix, BUFFER
AGAIN:
    push bc
    ld a, 0b10000011 ; slot 3-0 expanded
    call RDSLT
    ld (ix),a
    inc ix
    inc hl
    pop bc
    djnz AGAIN
    ei
    ret

SHOW_BOOT_LOGO:
    ; show boot logo
    ld iyh, 0b10000011 ; slot 3-0 expanded
    ld ix, OPTENT
    call CALSLT
    ret

    include "print_bios.asm"

WELCOME_MSG: DB "Checking SubRom routines\r\n",0
MSG_COLD_BOOT: DB "COLD BOOT",0
MSG_WARM_BOOT: DB "WARM BOOT",0
TXT_NEWLINE: DB "\r\n",0
BUFFER: DS 9,0
ENDADR:
