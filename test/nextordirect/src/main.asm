ENASLT:     equ 0024h
EXPTBL:     equ 0FCC1h
CALBNK:	    equ	4042h
FN_CHECK:   equ 4D88h

; BLOAD header
    db 0x0fe
    dw BEGIN, ENDADR, START_BASIC
    org 0c000h
BEGIN:
START_BASIC:
    call TEST
    DB 1
    DB 7
    DW FN_CHECK

TEST:
    exx
    ex af,af'
    ; get all the vars
    ld hl,0
    ex (sp),hl
    ld b, (hl)
    inc hl
    ld c, (hl)
    inc hl
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    ex (sp),hl ; sp points now to RET
    ; ld ix, de
    push de
    pop ix
    ; store current slot for page 1
    call GETSLT1
    push af
    ; select ROM slot
    ld a, b
    ld h, 40h
    push bc
    call ENASLT
    pop bc
    ; call Nextor Function
    ld a, c
    exx
    call CALBNK
    ex af,af'
    exx
    ; and back
    pop af
    call ENASLT
    exx
    ex af,af'
    inc sp
    inc sp
    ret

   ;--- Get slot connected on page 1
    ;    Input:  -
    ;    Output: A = Slot number
    ;    Modifies: AF, HL, E, BC
GETSLT1:
    push bc,de,hl
    ;exx
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
    ;exx
    pop hl,de,bc
    ret

ENDADR: