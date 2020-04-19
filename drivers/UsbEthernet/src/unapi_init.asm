;
; unapi_init.ASM - UNAPI initialisation with Ram Helper
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
HOKVLD_: equ  0FB20h
EXPTBL_: equ  0FCC1h
EXTBIO_: equ  0FFCAh
SLTWRK_: equ  0FD09h

HOOK_EXTBIO:
    ld  a,(HOKVLD_)
    bit  0,a
    jr  nz,OK_INIEXTB
    ; overwrite EXTBIO with RET's
    ld  hl,EXTBIO_
    ld  de,EXTBIO_+1
    ld  bc,5-1
    ld  (hl),0C9h  ;code for RET
    ldir
    or  1
    ld  (HOKVLD_),a
OK_INIEXTB:
    ;--- Save previous EXTBIO hook
    ld  de, OLD_EXTBIO
    ld  hl, EXTBIO_
    ld  bc,5
    ldir

    ;--- Patch EXTBIO hook
    di
    ld  a,0CDh  ;code for "CALL"
    ld  (EXTBIO_),a
    ld  hl,(RH_JUMPTABLE)
    ld  bc,6
    add hl,bc   ;Now HL points to segment call routine
    ld  (EXTBIO_+1),hl
    ; find back our mapper in the mapper table
    ld      hl,(RH_MAPTAB_ADD)
    ld      a,(MAPPER_SLOT)
    ld      bc,(RH_MAPTAB_ENTRY_SIZE)
    ld      b,0
    ld      d,a
    ld      e,0     ;Index on mappers table
_SRCHMAP:
    ld      a,(hl)
    cp      d
    jr      z,_MAPFND
    add     hl,bc   ;Next table entry
    inc     e
    jr      _SRCHMAP
_MAPFND:
    ld      a,e     ;A = Index of slot on mappers table
    rrca
    rrca
    and     11000000b       ;Entry point 4000h = index 0
    ld      (EXTBIO_+3),a

    ld  a, (MAPPER_SEGMENT)
    ld  (EXTBIO_+4),a
    ei
    ret
