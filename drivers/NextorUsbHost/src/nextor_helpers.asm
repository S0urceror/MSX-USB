_GDRVR EQU 78h
_DOSVER EQU 6Fh
SLTWRK EQU 0FD09h

;       Subroutine      Returns contents of SLTWRK belonging to slot in register A
;       Inputs          A - slot ID
;       Outputs         HL - contents of SLTWRK
;                       Cy - 1 is error, 0 is okay
GET_SLTWRK_FOR_SLOT:
    ; formula: SLTWRK address = FD09H + 32*primary slot + 8*expansion slot + 2*page
    ld b, a
    and 00000011b; select primary slot
    ld hl,0
    ld l,a
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl; multiply by 32

    ld a, b
    and 00001100b; select extended slot
    sla a; times 2
    ld de, 0
    ld e, a
    add hl, de

    ld de, SLTWRK
    add hl, de

    ld a, (hl)
    ld e, a
    inc hl
    ld a, (hl)
    ld d, a
    
    ld hl, de
    or a ; clear Cy
    ret

;       Subroutine      Returns the slot for a NEXTOR driver
;       Inputs          A - driver number
;       Outputs         A - slot ID
;                       Cy - 1 is error, 0 is okay
DRIVER_SLOT:
    ld c, _GDRVR
    ld hl, BUFFER
    call BDOS

    or a ; check error
    jr nz, _ERR_DRIVER_SLOT

    ld a, (hl); driver slot number
    ret
_ERR_DRIVER_SLOT
    scf
    ret

;       Subroutine      Check if we're running NEXTOR
;       Inputs          -
;       Outputs         Cy - 1 is error, 0 is okay
NEXTOR_CHECK:
    ld b, 5Ah
    ld hl, 1234h
    ld de, 0ABCDh
    ld ix, 0
    ld c, _DOSVER
    call BDOS

    or a
    jr nz, _NOT_NEXTOR ; or DOS
    ld a, ixh
    or a
    jr z, _NOT_NEXTOR
    or a ; clear Cy
    ret

_NOT_NEXTOR
    ld hl, TXT_NOT_NEXTOR
    call PRINT
    scf 
    ret

TXT_NOT_NEXTOR DB "Not running on compatible version of Nextor\r\n",0,"$"
BUFFER DS 64