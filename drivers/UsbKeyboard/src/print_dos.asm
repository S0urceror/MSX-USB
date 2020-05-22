; ---------------------------------------------------------
; Miscellanous helper functions
;
;
_CONOUT equ 02h
_STROUT equ 09h
BDOS    EQU 5
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