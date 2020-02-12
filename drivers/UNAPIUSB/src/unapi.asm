ARG:    equ  0F847h
HOKVLD: equ  0FB20h
EXPTBL: equ  0FCC1h
EXTBIO: equ  0FFCAh
SLTWRK: equ  0FD09h
;First direct driver call entry point
DRV_DIRECT0: equ 7850h

HOOK_EXTBIO:
    ld  a,(HOKVLD)
    bit  0,a
    jr  nz,OK_INIEXTB
    ; overwrite EXTBIO with RET's
    ld  hl,EXTBIO
    ld  de,EXTBIO+1
    ld  bc,5-1
    ld  (hl),0C9h  ;code for RET
    ldir
    or  1
    ld  (HOKVLD),a
OK_INIEXTB:
    ;--- Save previous EXTBIO hook
    call  GETSLT
    call  GETWRK
    ex  de,hl
    ld  hl,EXTBIO
    ld  bc,5
    ldir

    ;--- Patch EXTBIO hook
    di
    ld  a,0F7h  ;code for "RST 30h"
    ld  (EXTBIO),a
    call  GETSLT
    ld  (EXTBIO+1),a
    ld  hl,DO_EXTBIO
    ld  (EXTBIO+2),hl
    ei
    ret

DO_EXTBIO:
    push  hl
    push  bc
    push  af
    ; check for 0x2222
    ld  a,d
    cp  22h
    jr  nz,JUMP_OLD
    cp  e
    jr  nz,JUMP_OLD
    ;Check API ID
    ld  hl,UNAPI_ID
    ld  de,ARG
LOOP:  
    ld  a,(de)
    call  TOUPPER
    cp  (hl)
    jr  nz,JUMP_OLD2 ; does not match our API
    inc  hl
    inc  de
    or  a
    jr  nz,LOOP

    ;A=255: Jump to old hook
    ;ignore, for RAM helper
    pop  af
    push  af
    inc  a
    jr  z,JUMP_OLD2
    call  GETSLT
    call  GETWRK
    pop  af
    pop  bc
    or  a
    jr  nz,DO_EXTBIO2
    ;A=0: B=B+1 and jump to old hook
    ;count the number of implementations of this API
    inc  b
    ex  (sp),hl
    ld  de,2222h
    ret

DO_EXTBIO2:
    ;A=1: Return A=Slot, B=Segment, HL=UNAPI entry address
    ; check which implementation?
    dec  a
    jr  nz,DO_EXTBIO3
    ; our implementation, return address and slot
    pop  hl
    call  GETSLT
    ld  b,0FFh
    ld  hl,UNAPI_ENTRY
    ld  de,2222h
    ret

    ;A>1: A=A-1, and jump to old hook
    ; not our implementation, check next one
DO_EXTBIO3:  
    ;A=A-1 already done
    ex  (sp),hl
    ld  de,2222h
    ret

;--- Jump here to execute old EXTBIO code
JUMP_OLD2:
    ld  de,2222h
JUMP_OLD:  
    ;Assumes "push hl,bc,af" done
    push  de
    call  GETSLT
    call  GETWRK
    pop  de
    pop  af
    pop  bc
    ex  (sp),hl
    ret 

UNAPI_ENTRY:
    push  hl
    push  af
    ld  hl,FN_TABLE
    ; check if requested function nr < MAX_FN+1
    cp  MAX_FN+1
    jr  nc,UNAPI_UNDEFINED

UNAPI_OK:
    ; function nr times 2
    add  a,a
    push  de
    ld  e,a
    ld  d,0
    add  hl,de
    pop  de
    ; load in HL
    ld  a,(hl)
    inc  hl
    ld  h,(hl)
    ld  l,a
    ; jump in
    pop  af
    ex  (sp),hl
    ret

;--- Undefined function: return with registers unmodified
UNAPI_UNDEFINED:
    pop  af
    pop  hl
    ret


;****************************
;***  AUXILIARY ROUTINES  ***
;****************************

;--- Convert a character to upper-case if it is a lower-case letter
TOUPPER:
  cp  "a"
  ret  c
  cp  "z"+1
  ret  nc
  and  0DFh
  ret

    ;--- Get slot connected on page 1
    ;    Input:  -
    ;    Output: A = Slot number
    ;    Modifies: AF, HL, E, BC
GETSLT:
    di
    exx
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
    exx
    ei
    ret

    ;--- Obtain slot work area (8 bytes) on SLTWRK
    ;    Input:  A  = Slot number
    ;    Output: HL = Work area address
    ;    Modifies: AF, BC
GETWRK:
    ld  b,a
    rrca
    rrca
    rrca
    and  01100000b
    ld  c,a  ;C = Slot * 32
    ld  a,b
    rlca
    and  00011000b  ;A = Subslot * 8
    or  c
    ld  c,a
    ld  b,0
    ld  hl,SLTWRK
    add  hl,bc
    ret