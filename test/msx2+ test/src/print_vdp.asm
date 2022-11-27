; ---------------------------------------------------------
; Miscellanous helper functions
;
;


;       Subroutine      Print a buffer of data in HEX
;       Inputs          HL - buffer to be printed
;                       BC - number of bytes
;       Outputs         ________________________
PRINTHEX_BUFFER:
    ld d,8
_PRINTHEX_LOOP:
    ld a, (hl)
    call PRINT_HEX
    ld a, 020h
    call PRINT_CHAR
    inc hl
    dec bc
    ; decrement d and check if zero
    dec d
    ld a, d
    and a
    jr nz, _PRINTHEX_NEXT
    ;push hl
    ;ld a, 13
    ;call PRINT_CHAR
    ;ld a, 10
    ;call PRINT_CHAR
    ld d,8
    ;pop hl

_PRINTHEX_NEXT:
    ld a,b
    or c
    jp nz, _PRINTHEX_LOOP
    ret

;       Subroutine      Print a buffer of data in chars
;       Inputs          HL - buffer to be printed
;                       BC - number of bytes
;       Outputs         ________________________
PRINT_BUFFER:
    ld a, (hl)
    call PRINT_CHAR
    inc hl
    dec bc
    ld a,b
    or c
    jp nz, PRINT_BUFFER
    ret

;       Subroutine      Print 8-bit hexidecimal number
;       Inputs          A - number to be printed - 0ABh
;       Outputs         ________________________
PRINT_HEX:
    push af
    push bc
    push de
    call __NUMTOHEX
    ld a, d
    call PRINT_CHAR
    ld a, e
    call PRINT_CHAR
    pop de
    pop bc
    pop af
    ret
;       Subroutine      Convert 8-bit hexidecimal number to ASCII reprentation
;       Inputs          A - number to be printed - 0ABh
;       Outputs         DE - two byte ASCII values - D=65 / 'A' and E=66 / 'B'
__NUMTOHEX:
    ld c, a   ; a = number to convert
    call _NTH1
    ld d, a
    ld a, c
    call _NTH2
    ld e, a
    ret  ; return with hex number in de
_NTH1:
    rra
    rra
    rra
    rra
_NTH2:
    or 0F0h
    daa
    add a, 0A0h
    adc a, 040h ; Ascii hex at this point (0 to F)   
    ret


;       Subroutine      Print nul-terminated text to VRAM
;       Inputs          HL - pointer to text to print
;       Outputs         -------------------------------
PRINT:
    push af
_PRINT_MORE:
    ld a,(hl)
    and a
    jr z, _PRINT_DONE
    call PRINT_CHAR
    inc hl
    jr _PRINT_MORE
_PRINT_DONE:
    pop af
    ret

PRINT_CHAR:
    ; print to VDP (auto increments)
    out (#98),a
    ret

PRINT_INIT:
    ; set pointer to 0,0
    xor a
    ld hl,0
    call SetVdp_Write
    ; cls
    di
    ld bc, 160
.again:
    ld a, ' '
    out (#98),a
    dec bc
    ld a,b
    or c
    jr nz, .again
    ei
    ; set pointer to 0,0
    xor a
    ld hl,0
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