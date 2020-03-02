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

    DEFINE DEBUG 1

H.CHGE EQU 0FDC2h	
SCNCNT EQU 0F3F6H
PUTPNT EQU 0F3F8h
GETPNT EQU 0F3FAh
KEYBUF EQU 0FBF0h
KILBUF EQU 00156h
CSRSW EQU 0FCA9h

; BLOAD header
    db 0x0fe
    dw BEGIN, ENDADR, START_BASIC
    org 0c000h
BEGIN:
START_BASIC:
    ld hl,TXT_DRIVER_START
    call PRINT
    ; allocate work area
    ld ix, WRKAREA
    ; initialise USB HID
    call INIT_USBHID_KEYBOARD
    jr nc, _NEXT
    ld hl, TXT_DRIVER_STOP
    call PRINT
    ret
_NEXT:
    ; okay, install H.CHGE hook
    di
    ; save old one
    LD	HL,H.CHGE
	LD	DE,OLD_HCHGE
	LD	BC,5
	LDIR
    ; install new one
    ld hl, H.CHGE
    ld (hl),0C3h ; JP
    LD	HL,NEW_HCHGE
	LD	(H.CHGE+1),HL
    ei
    IF DEBUG==1
        ld hl,TXT_INSTALLED_ISR
        call PRINT
        ld hl, OLD_HCHGE
        ld bc, 5
        call PRINTHEX_BUFFER
    ENDIF
    ret

UNHOOK_US:
    di 
    LD	HL,OLD_HCHGE
	LD	DE,H.CHGE
	LD	BC,5
	LDIR
    ei
    IF DEBUG==1
        ld hl,TXT_UNINSTALLED_ISR
        call PRINT
    ENDIF
    call KILBUF
    ld a, 0x0b ; CR when ending
    ret

NEW_HCHGE:
    call OLD_HCHGE
    ; show cursor
    ld a, 255
    ld (CSRSW),a
_SCAN_AGAIN:
    call READ_HID_KEYBOARD
    call c, UNHOOK_US ; when error or ALT+Q
    or a
    jr z, _SCAN_AGAIN

    pop bc ; call address
    pop	bc, de, hl ; saved registers
    ret

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

    include "ch376s.asm"
    include "print_bios.asm"
    include "usb.asm"
    include "keyboard.asm"

TXT_NEWLINE: DB "\r\n",0
TXT_DRIVER_START: DB "USB HID Driver starting\r\n",0
TXT_DRIVER_STOP: DB "-USB HID keyboard not detected\r\n",0

    IF DEBUG==1
TXT_INSTALLED_ISR: DB "+H.CHGE hook installed\r\n",0
TXT_UNINSTALLED_ISR: DB "\r\n+H.CHGE hook uninstalled\r\n",0
    ENDIF

OLD_HCHGE: DS 5,0
WRKAREA: DS DEVICE_DESCRIPTOR+CONFIG_DESCRIPTOR+INTERFACE_DESCRIPTOR*3+ENDPOINT_DESCRIPTOR*3+HID_DESCRIPTOR*3,0
CAPS_TOGGLE: DB 00001100b
ENDADR: 