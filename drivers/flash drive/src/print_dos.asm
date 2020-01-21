BDOS	equ	0F37Dh   ; Set the address 0005h into label BDOS.
		                ; We can call several routines under MSX-DOS at address 0005h.
;_ZSTROUT equ 72h
_CONOUT equ 02h
_STROUT equ 09h

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
    
;       Subroutine      Print text with the DOS routine
;       Inputs          HL - pointer to text to print
;       Outputs         -------------------------------
PRINT:
    push bc,de,hl
    ld c, _STROUT
    ld de, hl
    call BDOS
    pop hl,de,bc
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