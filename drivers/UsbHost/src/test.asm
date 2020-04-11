;--- Sample implementation of a MSX-UNAPI specification in ROM
;    By Konamiman, 5-2019
;
;    This code implements a sample mathematical specification, "SIMPLE_MATH",
;    which has just two functions:
;       Function 1: Returns HL = L + E
;       Function 2: Returns HL = L * E
;
;    You can compile it with sjasm (https://github.com/Konamiman/Sjasm/releases):
;    sjasm unapi-rom.asm math.rom
;
;    Search for "TODO" comments for what to change/extend when creating your own implementation.

;*******************
;***  CONSTANTS  ***
;*******************

;--- System variables and routines

CHPUT:  equ  00A2h
HOKVLD:  equ  0FB20h
EXPTBL:  equ  0FCC1h
EXTBIO:  equ  0FFCAh
SLTWRK:  equ  0FD09h
ARG:  equ  0F847h

;--- API version and implementation version

;TODO: Adjust for your implementation

API_V_P:  equ  1
API_V_S:  equ  0
ROM_V_P:  equ  1
ROM_V_S:  equ  0

;--- Maximum number of available standard and implementation-specific function numbers

;TODO: Adjust for your implementation

;Must be 0 to 127
MAX_FN:    equ  2

;Must be either zero (if no implementation-specific functions available), or 128 to 254
MAX_IMPFN:  equ  0


;********************************************
;***  ROM HEADER AND INITIALIZATION CODE  ***
;********************************************

  org  4000h

  ;--- ROM header

  db  "AB"
  dw  INIT
  ds  12

TXT_RETS DB "+HOKVLD zero, put 0xC9s\r\n",0
TXT_SAVE_PREVIOUS DB "+Saving old EXTBIO\r\n",0
TXT_PATCH DB "+Patching EXTBIO\r\n",0
TXT_DONE DB "+Done\r\n",0
TXT_CHECK_API_ID DB "?Check API ID\r\n",0

INIT:
  ;--- Initialize EXTBIO hook if necessary

  ld  a,(HOKVLD)
  bit  0,a
  jr  nz,OK_INIEXTB

  ld hl, TXT_RETS
  call PRINT
  ld  hl,EXTBIO
  ld  de,EXTBIO+1
  ld  bc,29-1
  ld  (hl),0C9h  ;code for RET
  ldir
OK_INIEXTB:
  ;--- Save previous EXTBIO hook
  ld hl, TXT_SAVE_PREVIOUS
  call PRINT
  call  GETSLT
  call  GETWRK
  ex  de,hl
  ld  hl,EXTBIO
  ld  bc,5
  ldir

  ;--- Patch EXTBIO hook
  ld hl, TXT_PATCH
  call PRINT
  di
  ld  a,0F7h  ;code for "RST 30h"
  ld  (EXTBIO),a
  call  GETSLT
  ld  (EXTBIO+1),a
  ld  hl,DO_EXTBIO
  ld  (EXTBIO+2),hl
  ld a, 1
  ld  (HOKVLD),a
  ei

  ;>>> UNAPI initialization finished, now perform
  ;    other ROM initialization tasks.

ROM_INIT:

  ;TODO: extend (or replace) with other initialization code as needed by your implementation
  ld hl, TXT_DONE
  call PRINT
  ;--- Show informative message

  ld  hl,INITMSG
PRINT_LOOP:
  ld  a,(hl)
  or  a
  jp  z,INIT2
  call  CHPUT
  inc  hl
  jr  PRINT_LOOP
INIT2:

  ret


;*******************************
;***  EXTBIO HOOK EXECUTION  ***
;*******************************

DO_EXTBIO:
  push  hl
  push  bc
  push  af
  ld  a,d
  cp  22h
  jr  nz,JUMP_OLD
  cp  e
  jr  nz,JUMP_OLD

  ;Check API ID
  ld hl, TXT_CHECK_API_ID
  call PRINT

  ld  hl,UNAPI_ID
  ld  de,ARG
LOOP:  ld  a,(de)
  call  TOUPPER
  cp  (hl)
  jr  nz,JUMP_OLD2
  inc  hl
  inc  de
  or  a
  jr  nz,LOOP

  ;A=255: Jump to old hook

  pop  af
  push  af
  inc  a
  jr  z,JUMP_OLD2

  ;A=0: B=B+1 and jump to old hook

  call  GETSLT
  call  GETWRK
  pop  af
  pop  bc
  or  a
  jr  nz,DO_EXTBIO2
  inc  b
  ex  (sp),hl
  ld  de,2222h
  ret
DO_EXTBIO2:

  ;A=1: Return A=Slot, B=Segment, HL=UNAPI entry address

  dec  a
  jr  nz,DO_EXTBIO3
  pop  hl
  call  GETSLT
  ld  b,0FFh
  ld  hl,UNAPI_ENTRY
  ld  de,2222h
  ret

  ;A>1: A=A-1, and jump to old hook

DO_EXTBIO3:  ;A=A-1 already done
  ex  (sp),hl
  ld  de,2222h
  ret

  ;--- Jump here to execute old EXTBIO code

JUMP_OLD2:
  ld  de,2222h
JUMP_OLD:  ;Assumes "push hl,bc,af" done
  push  de
  call  GETSLT
  call  GETWRK
  pop  de
  pop  af
  pop  bc
  ex  (sp),hl
  ret
  

;************************************
;***  FUNCTIONS ENTRY POINT CODE  ***
;************************************

UNAPI_ENTRY:
  push  hl
  push  af
  ld  hl,FN_TABLE
  bit  7,a

  if MAX_IMPFN >= 128

  jr  z,IS_STANDARD
  ld  hl,IMPFN_TABLE
  and  01111111b
  cp  MAX_IMPFN-128
  jr  z,OK_FNUM
  jr  nc,UNDEFINED
IS_STANDARD:

  else

  jr  nz,UNDEFINED

  endif

  cp  MAX_FN
  jr  z,OK_FNUM
  jr  nc,UNDEFINED

OK_FNUM:
  add  a,a
  push  de
  ld  e,a
  ld  d,0
  add  hl,de
  pop  de

  ld  a,(hl)
  inc  hl
  ld  h,(hl)
  ld  l,a

  pop  af
  ex  (sp),hl
  ret

  ;--- Undefined function: return with registers unmodified

UNDEFINED:
  pop  af
  pop  hl
  ret


;***********************************
;***  FUNCTIONS ADDRESSES TABLE  ***
;***********************************

;TODO: Adjust for the routines of your implementation

;--- Standard routines addresses table

FN_TABLE:
FN_0:  dw  FN_INFO
FN_1:  dw  FN_ADD
FN_2:  dw  FN_MULT


;--- Implementation-specific routines addresses table

  if MAX_IMPFN >= 128

IMPFN_TABLE:
FN_128:  dw  FN_DUMMY

  endif


;************************
;***  FUNCTIONS CODE  ***
;************************

;--- Mandatory routine 0: return API information
;    Input:  A  = 0
;    Output: HL = Descriptive string for this implementation, on this slot, zero terminated
;            DE = API version supported, D.E
;            BC = This implementation version, B.C.
;            A  = 0 and Cy = 0

FN_INFO:
  ld  bc,256*ROM_V_P+ROM_V_S
  ld  de,256*API_V_P+API_V_S
  ld  hl,APIINFO
  xor  a
  ret

;TODO: Replace the FN_* routines below with the appropriate routines for your implementation

;--- Sample routine 1: adds two 8-bit numbers
;    Input: E, L = Numbers to add
;    Output: HL = Result

FN_ADD:
  ld  h,0
  ld  d,0
  add  hl,de
  ret


;--- Sample routine 2: multiplies two 8-bit numbers
;    Input: E, L = Numbers to multiply
;    Output: HL = Result

FN_MULT:
  ld  b,e
  ld  e,l
  ld  d,0
  ld  hl,0
MULT_LOOP:
  add  hl,de
  djnz  MULT_LOOP
  ret


;****************************
;***  AUXILIARY ROUTINES  ***
;****************************

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
EXP1:  inc  hl
  inc  hl
  inc  hl
  inc  hl
  ld  a,(hl)
  and  00001100b
  or  c
  or  80h
  ld  c,a
NOEXP1:  ld  a,c
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


;--- Convert a character to upper-case if it is a lower-case letter

TOUPPER:
  cp  "a"
  ret  c
  cp  "z"+1
  ret  nc
  and  0DFh
  ret
  
;       Subroutine      Print nul-terminated text with the BIOS routine
;       Inputs          HL - pointer to text to print
;       Outputs         -------------------------------
PRINT:
    push af,hl
_PRINT_MORE:
    ld a,(hl)
    and a
    jr z, _PRINT_DONE
    call CHPUT
    inc hl
    jr _PRINT_MORE
_PRINT_DONE:
    pop hl,af
    ret


;**************
;***  DATA  ***
;**************

;TODO: Adjust this data for your implementation

  ;--- Specification identifier (up to 15 chars)
UNAPI_ID:
  db  "SIMPLE_MATH",0

  ;--- Implementation identifier (up to 63 chars and zero terminated)

APIINFO:
  db  "Konamiman's ROM implementation of SIMPLE_MATH UNAPI",0

  ;--- Other data

INITMSG:
  db  13,10,"UNAPI Sample ROM 1.0 (SIMPLE_MATH)",13,10
  db  "(c) 2019 by Konamiman",13,10
  db  13,10
  db  0

  ds  0C000h-$  ;Padding to make a 32K ROM