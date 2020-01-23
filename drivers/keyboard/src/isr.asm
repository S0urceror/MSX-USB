;
; USB-HID keyboard driver
; Copyright (c) 2019 Mario Smit (S0urceror)
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

    DEFINE DEBUG 0

H.CHGE EQU 0FDC2h	
SCNCNT EQU 0F3F6H
PUTPNT EQU 0F3F8h
GETPNT EQU 0F3FAh
KEYBUF EQU 0FBF0h

; BLOAD header
    db 0x0fe
    dw BEGIN, ENDADR, START_BASIC
    org 0c000h
BEGIN:
START_BASIC:
    ld hl,TXT_DRIVER_START
    call PRINT

    ; okay, install H.TIMI hook
    di
    ; save old one
    LD	HL,H.CHGE
	LD	DE,OLD_HCHGE
	LD	BC,5
	LDIR
    ; install new one
    ld hl, H.CHGE
    ld (hl),0C3h ; JP
    LD	HL,NEW_HTIMI
	LD	(H.CHGE+1),HL
    ei
    ret

NEW_HTIMI:
    ld a, (CAPS_TOGGLE) ; get stored toggle value
    out (0ABh),a
    xor 1
    ld (CAPS_TOGGLE),a

    pop af ; call address
	pop	BC, DE, HL ; saved registers
    ld a, 'M'
    ret
    call C0F55

    jp OLD_HCHGE		;old HOOK call  

;	Subroutine	put keycode in keyboardbuffer
;	Inputs		A = keycode
;	Outputs		________________________
;	Remark		entrypoint compatible among keyboard layout versions

C0F55:
	LD	HL,(PUTPNT)
	LD	(HL),A			; put in keyboardbuffer
	CALL	C10C2			; next postition in keyboardbuffer with roundtrip
	LD	A,(GETPNT)
	CP	L			; keyboard buffer full ?
	RET	Z			; yep, quit
	LD	(PUTPNT),HL		; update put pointer
    RET

;	Subroutine	increase keyboardbuffer pointer
;	Inputs		________________________
;	Outputs		________________________

C10C2:
	INC	HL			; increase pointer
	LD	A,L
	CP	(KEYBUF+40) AND 255
	RET	NZ			; not the end of buffer, quit
	LD	HL,KEYBUF		; wrap around to start of buffer
	RET

    include "print_bios.asm"

TXT_NEWLINE:        DB "\r\n",0
TXT_DRIVER_START:   DB "USB HID Driver started\r\n",0
OLD_HCHGE: DS 5,0
ALREADY_RUNNING     DB 0
CAPS_TOGGLE: DB 00001100b
ENDADR: 