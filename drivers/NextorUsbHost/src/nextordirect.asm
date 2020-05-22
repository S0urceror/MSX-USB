;
; nextordirect.ASM - directly call into nextor driver code
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

;EXPTBL:     equ 0FCC1h
;CALBNK:	    equ	04042h
ENASLT:     equ 0024h

NXT_DIRECT_WRKAREA:
    push ix
    ld bc, WRKAREA.NXT_DIRECT
	call WRKAREAPTR
    push ix
    pop de
    ld hl, NXT_DIRECT_START
    ld bc, NXT_DIRECT_END - NXT_DIRECT_START
    ldir
    pop ix
    ret

; Example jumptable
;    call NXT_DIRECT ; 3 bytes - call to switching code
;    DB 1            ; 1 byte  - ROM slot number
;    DB 7            ; 1 byte  - ROM segment
;    DW FN_CHECK     ; 2 bytes - address to call
                     ; =============
                     ; 7 bytes total per entry

NXT_DIRECT_START:
    exx         ; save registers
    ex af,af'   ; save flags
    ; get all the parameters following our instruction pointed by stack
    ex (sp),hl
    ld b, (hl)
    inc hl
    ld c, (hl)
    inc hl
    ld e, (hl)
    inc hl
    ld d, (hl)
    ex (sp),hl
    ; ld ix, de
    push de
    pop ix
    ; store current slot for page 1
    jr _GETSLT1_

_NXT_DIRECT_CONTINUE:
    push af
    ; select ROM slot
    ld a, b
    ld h, 40h
    push bc
    call ENASLT 
    ei
    pop bc
    ; call Nextor Function
    ld a, c
    exx ; load registers
    call CALBNK ; Important to use this instead of DRV_DIRECTx calls
                ; DRV_DIRECTx is only on bank 0 which could be switched away when interrupt routine fires
                ; CALBNK is smart enough to store old bank number and switch back after done
    ex af,af' ; save A + Flags
    exx       ; save registers
    ; and back
    pop af
    call ENASLT
    ei
    ;
    exx       ; load registers
    ex af,af' ; load A + Flags
    inc sp ; go back to previous stack entry, saves a RET in the jumptable
    inc sp
    ret

;--- Get slot connected on page 1
;    Input:  -
;    Output: A = Slot number
;    Modifies: AF, HL, E, BC
_GETSLT1_:
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
    jr  z,_NOEXP1_
_EXP1_:  
    inc  hl
    inc  hl
    inc  hl
    inc  hl
    ld  a,(hl)
    and  00001100b
    or  c
    or  80h
    ld  c,a
_NOEXP1_:  
    ld  a,c
    pop hl,de,bc
    jr _NXT_DIRECT_CONTINUE

NXT_DIRECT_END: DB 0