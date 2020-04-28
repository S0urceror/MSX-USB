ENASLT:     equ 0024h
EXPTBL:     equ 0FCC1h
EXTBIO:     equ 0FFCAh

; BLOAD header
    db 0x0fe
    dw BEGIN, ENDADR, START_BASIC
    org 0c000h
BEGIN:
START_BASIC:
    call TEST
    ret

TEST:
    call CALLRAM
    DB 0b00000000
    DB 7

; CALLRAM:
; =======================
; CALL <routine address>
; DB 0bMMAAAAAA
; DB <segment number>
;    MM = Slot as the index of the entry in the mapper table.
;    AAAAAA = Routine address index:
;    0=4000h, 1=4003h, ..., 63=40BDh

CALLRAM:
    exx
    ex af,af'
    ; get all the vars
    ex (sp),hl
    ld b, (hl)
    inc hl
    ld a, (hl)
    ld iyh, a
    ex (sp),hl
    ; store current slot for page 1
    call GETSLT1
    push af
    push iy
    push bc
    ; get mapper slot
    ld a, b
    and 0b11000000
    rlca
    rlca ; back to lower 2 bits
    call GETMAPPER_SLOT
    ; select mapper slot
    ld h, 40h
    call ENASLT
    ; get jumpaddress
    pop bc
    ld a, b
    and 0b00111111
    ld b, a
    add a,a ; times 2
    add b   ; times 3
    ld ixl, a
    ld ixh, 0x40
    pop iy
    ; all set, let's now call the routine
    ld hl, _RETURN
    push hl
    call GETMAPPER_CALSEG
    push hl ; push CAL_SEG
    ex af, af'
    exx
    ret ; trigger call to CAL_SEG
_RETURN:
    ex af,af'
    exx
    ; and back
    pop af
    ld h, 40h
    call ENASLT
    ;
    exx
    ex af,af'
    inc sp ; back to routine before calling us
    inc sp
    ret

; Input: A - which mapper to use?
; Output: A - slot id of selected mapper
GETMAPPER_SLOT:
    push af
    ld a, 0 ; reset to 0, should change
    ld d, 4 ; extbio device id
    ld e, 1 ; function nr
    ;Result:A = total number of memory mapper segments
	;		B = slot number of primary mapper
	;		C = number of free segments of primary mapper
	;		DE = reserved
	;		HL = start address of jump table
    call EXTBIO
    and a
    ret z
    ;
    ld de, 8
    pop bc
_GETMAPPER_SLOT_AGAIN:
    ld a, b
    and a
    jr z, _GETMAPPER_SLOT_FOUND
    dec b
    add hl, de
    jr _GETMAPPER_SLOT_AGAIN
_GETMAPPER_SLOT_FOUND:
    ld a, (hl)
    ret

GETMAPPER_JUMPTABLE:
    ld a, 0 ; reset to 0, should change
    ld d, 4 ; extbio device id
    ld e, 2 ; function nr
    ;Result:A = total number of memory mapper segments
	;		B = slot number of primary mapper
	;		C = number of free segments of primary mapper
	;		DE = reserved
	;		HL = start address of jump table
    call EXTBIO
    and a
    ret

GETMAPPER_CALSEG
    push ix, iy
    call GETMAPPER_JUMPTABLE
    pop iy, ix
    ret z
    ld bc, 0x0c
    add hl, bc
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