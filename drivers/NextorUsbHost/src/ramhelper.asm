;
; ramhelper.ASM - embedded short CALLRAM routine
;                 compatible with Konamiman's CALL_MAPI call
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

RAMHELPER_WRKAREA:
    push ix

    ; copy RAMHELPER to WRKAREA
    ld bc, WRKAREA.RAMHELPER
	call WRKAREAPTR
    push ix
    pop de
    ld hl, RAMHELPER_START
    ld bc, RAMHELPER_END - RAMHELPER_START
    ldir

    ; copy MAPPER TABLE to WRKAREA
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
    jr z, _RAMHELPER_WRKAREA_END ; should not happen!
    ld bc, WRKAREA.RAMMAPPERS
	call WRKAREAPTR
    push ix
    push ix
    pop de
    ld bc, 2*8 ; assume max of 2 mappers, a primary and secondary
    ldir
    pop hl ; points to start of RAMMAPPERS
    ld bc, WRKAREA.RAMHELPER + (GETMAPPER_SLOT+1) - RAMHELPER_START
    call WRKAREAPTR
    ld (ix+0),l
    ld (ix+1),h

    ; copy MAPPER ROUTINES to WKRAREA
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
    jr z, _RAMHELPER_WRKAREA_END ; should not happen!
    ld bc, WRKAREA.RAMCALLS
	call WRKAREAPTR
    push ix
    push ix
    pop de
    ld bc, 030h
    ldir
    pop hl ; points to start of RAMCALLS
    ld bc, WRKAREA.RAMHELPER + (GETMAPPER_CALSEG+1) - RAMHELPER_START
    call WRKAREAPTR
    ld (ix+0),l
    ld (ix+1),h

    ; link _RETURN
    ld bc, WRKAREA.RAMHELPER + _RETURN - RAMHELPER_START
    call WRKAREAPTR
    push ix
    pop hl
    ld bc, WRKAREA.RAMHELPER + (_GETMAPPER_RETURN+1) - RAMHELPER_START
    call WRKAREAPTR
    ld (ix+0),l
    ld (ix+1),h

    ;
_RAMHELPER_WRKAREA_END:
    pop ix
    ret

RAMHELPER_ADDRESS:
    ld bc, WRKAREA.RAMHELPER
	call WRKAREAPTR
    push ix
    pop hl
    ret

RAMHELPER_START:
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

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; get current slot for page 1
    ; Input: (none)
    ; Output: A - slot id for page 1
_GETSLT1__:
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
    jr  z,_NOEXP1__
_EXP1__:  
    inc  hl
    inc  hl
    inc  hl
    inc  hl
    ld  a,(hl)
    and  00001100b
    or  c
    or  80h
    ld  c,a
_NOEXP1__:  
    ld  a,c
    pop hl,de,bc
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    push af ; => store slot id on the stack
    push iy
    push bc
    ; get mapper slot, encoded in 0b00xxxxxx
    ld a, b
    and 0b11000000
    rlca
    rlca ; back to lower 2 bits

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; GET THE MAPPER SLOT ASSOCIATED WITH THIS INDEX
    ; Input: A - index in memory mapper table
    ; Output: A - slot id of selected mapper
GETMAPPER_SLOT:
    ld hl, 0000h ;=> pointer to start of mapper table
    ld de, 8
    pop bc ; was AF
_GETMAPPER_SLOT_AGAIN:
    ld a, b
    and a
    jr z, _GETMAPPER_SLOT_FOUND
    dec b
    add hl, de
    jr _GETMAPPER_SLOT_AGAIN
_GETMAPPER_SLOT_FOUND:
    ld a, (hl)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; select mapper slot
    ld h, 40h
    call ENASLT

    ; get jumpaddress, encoded in 0bxx000000
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    pop bc
    ld a, b
    and 0b00111111
    ld b, a
    add a,a ; times 2
    add b   ; times 3
    ld ixl, a
    ld ixh, 0x40
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    pop iy
    ; all set, let's now call the routine
_GETMAPPER_RETURN:
    ld hl, 0000h ; pointer to _RETURN
    push hl

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; GET A POINTER TO CALSEG
GETMAPPER_CALSEG:
    ld hl, 0000h ; => start of mapper jumptable
    ld bc, 0x0c
    add hl, bc
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    push hl ; push CAL_SEG
    ex af, af'
    exx
    ret ; trigger call to CAL_SEG

_RETURN:
    ex af,af'
    exx
    ; and back
    pop af ; <= get slot id from the stack
    ld h, 40h
    call ENASLT
    ;
    exx
    ex af,af'
    inc sp ; back to routine before calling us
    inc sp
    ret

RAMHELPER_END