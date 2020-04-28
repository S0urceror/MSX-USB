;
; tsr.ASM - The resident bit of the USB HID keyboard driver.
;           Will be put in a free memory mapper segment.
;
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

CSRSW: equ 0FCA9h
PUTPNT EQU 0F3F8h
GETPNT EQU 0F3FAh
KEYBUF EQU 0FBF0h

   org 8000h
TSR_ORG:

TSR_START:
    call OLD_HCHGE
    ; show cursor
    ld a, 255
    ld (CSRSW),a
_SCAN_AGAIN:
    call READ_HID_KEYBOARD
    call c, UNHOOK_US ; when error or ALT+Q
    or a
    jr z, _SCAN_AGAIN

    call C0F55

    ret
 
    include "keyboard.asm"

;	Subroutine	put keycode in keyboardbuffer
;	Inputs		A = keycode
;	Outputs		________________________
;	Remark		entrypoint compatible among keyboard layout versions
C0F55:
	LD	HL,(PUTPNT)
	LD	(HL),A			; put in keyboardbuffer
	CALL	C10C2		; next postition in keyboardbuffer with roundtrip
	LD	A,(GETPNT)
	CP	L			    ; keyboard buffer full ?
	RET	Z			    ; yep, quit
	LD	(PUTPNT),HL		; update put pointer
    RET

;	Subroutine	increase keyboardbuffer pointer
;	Inputs		________________________
;	Outputs		________________________
C10C2:
	INC	HL			    ; increase pointer
	LD	A,L
	CP	(KEYBUF+40) AND 255
	RET	NZ			    ; not the end of buffer, quit
	LD	HL,KEYBUF		; wrap around to start of buffer
	RET

OLD_HCHGE:
    ; old H.CHGE is stored at 10th entry
    ld hl, (TSR_SCRATCH_AREA)
    ; select 10th
    ld bc, 10*8
    add hl, bc
    ; jump 
    jp (hl)

UNHOOK_US:
    di 
    ; old H.CHGE is stored at 10th entry
    ld hl, (TSR_SCRATCH_AREA)
    ; select 10th
    ld bc, 10*8
    add hl, bc
	LD	DE,H.CHGE
	LD	BC,5
	LDIR
    ei
    ret

   MODULE tsr
JP_MSXUSB:
    push af,bc
    ld c,a
    ld b,0
    ld ix, (TSR_JUMP_TABLE)
    add ix,bc
    pop bc,af
    jp (ix)
   ENDMODULE

; Input:    A: device address
;           E: endpoint id
; Output:   Everything preserved including Cy
;           E will contain DDDDEEEE (D=device address, E=endpoint id)
_PACK_E:
   push af ; preserve Cy
   sla a
   sla a
   sla a
   sla a
   and 0xf0
   or e
   ld e, a
   pop af
   ;
   ret

TSR_END:

TSR_SHARED_VARS_START:
TSR_KEYBOARD_INTERFACENR:       DB 0
TSR_KEYBOARD_ENDPOINTNR:        DB 0
TSR_KEYBOARD_MAX_PACKET_SIZE:   DB 0
TSR_SCRATCH_AREA:               DW 0
; MSX USB
TSR_JUMP_TABLE:                 DW 0 ; pointer to MSXUSB jumptable
TSR_SHARED_VARS_END: