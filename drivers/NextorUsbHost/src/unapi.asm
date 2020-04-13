;
; unapi.ASM - UNAPI compliant MSX USB driver
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
ARG:    equ  0F847h
HOKVLD: equ  0FB20h
EXPTBL: equ  0FCC1h
EXTBIO: equ  0FFCAh
SLTWRK: equ  0FD09h
;First direct driver call entry point
DRV_DIRECT0: equ 7850h

DO_EXTBIO:
    push  hl
    push  bc
    push  af
    ;Check for 0x2222
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
    ;A=0: B=B+1 and jump to old hook
    pop  af
    pop  bc
    or  a
    jr  nz,DO_EXTBIO2
    ;A=0: B=B+1 and jump to old hook
    ;count the number of implementations of this API
    inc b
    pop hl
    ld  de,2222h
    ret

DO_EXTBIO2:
    ;A=Implementation Nr: Return A=Slot, B=Segment, HL=UNAPI entry address
    ; check which implementation?
    dec  a
    jr  nz,DO_EXTBIO3
    ; our implementation, return address and slot
    pop  hl
    xor a
    ld ix,GSLOT1
    call CALBNK
    ld  b,0FFh
    ld  hl, DRV_DIRECT0 ;UNAPI_ENTRY
    ld  de,2222h
    exx
    ld d,0  ;D'=0 --> don't execute old hook
    exx
    ret

    ;A>1: A=A-1, and jump to old hook
    ; not our implementation, check next one
DO_EXTBIO3:  
    ;A=A-1 already done
    pop hl
    ld  de,2222h
    ret

;--- Jump here to execute old EXTBIO code
JUMP_OLD2:
    ld  de,2222h
JUMP_OLD:  
    ;Assumes "push hl,bc,af" done
    pop  af
    pop  bc
    pop  hl
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