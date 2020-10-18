;
; USB-HID keyboard driver
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

INTFLG equ 0FC9Bh
; CH376 result codes
CH_USB_INT_SUCCESS:  equ 14h
CH_USB_INT_CONNECT:  equ 15h
CH_USB_INT_DISCONNECT: equ 16h
CH_USB_INT_BUF_OVER: equ 17h
CH_USB_INT_DISK_READ: equ 1dh
CH_USB_INT_DISK_WRITE: equ 1eh
CH_USB_ERR_OPEN_DIR: equ 41h
CH_USB_ERR_MISS_FILE: equ 42h
CH_USB_ERR_FOUND_NAME: equ 43h
CH_USB_ERR_FILE_CLOSE: equ 0b4h

; READ_HID_KEYBOARD: reads the current state of the keyboard
; Input: (none)
; Output: Cy on error or when Quit key is pressed
READ_HID_KEYBOARD:
    ;
    ld a, (USB_READ_TOGGLE) ; get stored toggle value
    rla ; high bit shifted to Cy
    ;
    ld hl, USB_HID_BOOT_KEYBOARD_BUFFER
    ld bc, BOOT_KEYBOARD_INPUT_REPORT
    ld a, (TSR_KEYBOARD_MAX_PACKET_SIZE)
    ld d, a
    ld a, (TSR_KEYBOARD_ENDPOINTNR)
    ld e, a
    ld a, (TSR_DEVICE_ADDRESS)
    call _PACK_E
    ;ld a, USB_DATA_IN_TRANSFER
    call TSR_FN_DATA_IN_TRANSFER ; A=USB result code, Cy=toggle bit, BC = Amount of data actually received
    ;
    push af
    ld a, 0 ; deliberately no XOR because that wipes Cy
    rra ; Cy stored in high bit of A
    ld (USB_READ_TOGGLE),a ; stored in memory
    pop af
    ;
    cp CH_USB_INT_SUCCESS
    jr z, _READ_HID_CONTINUE
    xor a; clear A and Cy
    ret
_READ_HID_CONTINUE:
    call KEYPRESS
    ret z ; no keys pressed
    ld c, a ; store A
    
; check our special Quit character: ALT+Q
    cp 0x14 ; pressed Q?
    jr nz, _READ_HID_CONTINUE1
    ld a, b
    and 0x04 ; LEFT ALT
    jr z, _READ_HID_CONTINUE1
    scf
    ret
;
_READ_HID_CONTINUE1:
    xor a
    ld (INTFLG), a
    ld a, c ; restore A
; check STOP and/or CTRL-STOP
    cp 0x48 ; pressed Pause/Break?
    jr nz, _READ_HID_CONTINUE2
    ld a, 4
    ld (INTFLG), a
    ld a, b
    and 0x01 ; LEFT CTRL
    jr z, _READ_HID_CONTINUE2
    ld a, 3
    ld (INTFLG), a
    ret
;

_READ_HID_CONTINUE2:
    ld a, c ; restore A
    call CONVERT_SCANCODE
    or a; clear Cy
    ret

; Input: IX = points to boot protocol keyboard buffer
; Output: A = scancode of new keypress
;         B = modifier flags (SHIFT, ALT, META, etc)
KEYPRESS:
    ld ix, USB_HID_BOOT_KEYBOARD_BUFFER
    ld iy, OLD_HID_BOOT_KEYBOARD_BUFFER
    
    ld a, (ix+BOOT_KEYBOARD_INPUT_REPORT.Keycode6)
    ld c, (iy+BOOT_KEYBOARD_INPUT_REPORT.Keycode6)
    cp c
    jr nz, KEYPRESS_DONE ; haven't seen before, must be new keypress, we're done

    ld a, (ix+BOOT_KEYBOARD_INPUT_REPORT.Keycode5)
    ld c, (iy+BOOT_KEYBOARD_INPUT_REPORT.Keycode5)
    cp c
    jr nz, KEYPRESS_DONE ; haven't seen before, must be new keypress, we're done

    ld a, (ix+BOOT_KEYBOARD_INPUT_REPORT.Keycode4)
    ld c, (iy+BOOT_KEYBOARD_INPUT_REPORT.Keycode4)
    cp c
    jr nz, KEYPRESS_DONE ; haven't seen before, must be new keypress, we're done
    
    ld a, (ix+BOOT_KEYBOARD_INPUT_REPORT.Keycode3)
    ld c, (iy+BOOT_KEYBOARD_INPUT_REPORT.Keycode3)
    cp c
    jr nz, KEYPRESS_DONE ; haven't seen before, must be new keypress, we're done

    ld a, (ix+BOOT_KEYBOARD_INPUT_REPORT.Keycode2)
    ld c, (iy+BOOT_KEYBOARD_INPUT_REPORT.Keycode2)
    cp c
    jr nz, KEYPRESS_DONE ; haven't seen before, must be new keypress, we're done
    
    ld a, (ix+BOOT_KEYBOARD_INPUT_REPORT.Keycode1)
    ld c, (iy+BOOT_KEYBOARD_INPUT_REPORT.Keycode1)
    cp c
    jr nz, KEYPRESS_DONE ; haven't seen before, must be new keypress, we're done

KEYPRESS_DONE:
    ; make a copy of the keyboard buffer
    ld hl, USB_HID_BOOT_KEYBOARD_BUFFER
    ld de, OLD_HID_BOOT_KEYBOARD_BUFFER
    ld bc, BOOT_KEYBOARD_INPUT_REPORT
    ldir

    ld b, (ix+BOOT_KEYBOARD_INPUT_REPORT.bModifierKeys)
    or a ; set Z flag according to contents A
    ret

_SCANCODES_ASCII: 
;   scancode,normal,shifted,ctrl
    DB 0,0,0
    DB 0,0,0
    DB 0,0,0
    DB 0,0,0
    DB 'a','A',0
    DB 'b','B',2
    DB 'c','C',3
    DB 'd','D',0
    DB 'e','E',5
    DB 'f','F',6
    DB 'g','G',0
    DB 'h','H',0
    DB 'i','I',0
    DB 'j','J',0
    DB 'k','K',0
    DB 'l','L',0
    ;0x10
    DB 'm','M',0
    DB 'n','N',14
    DB 'o','O',15
    DB 'p','P',16
    DB 'q','Q',17
    DB 'r','R',0
    DB 's','S',19
    DB 't','T',20
    DB 'u','U',21
    DB 'v','V',0
    DB 'w','W',0
    DB 'x','X',0
    DB 'y','Y',25
    DB 'z','Z',26
    DB '1','!',0
    DB '2','@',0
    ;0x20
    DB '3','#',0
    DB '4','$',0
    DB '5','%',0
    DB '6','^',0
    DB '7','&',0
    DB '8','*',0
    DB '9','(',0
    DB '0',')',0
    DB 13,13,0 ; ENTER
    DB 27,27,7 ; ESC
    DB 8,8,0  ; BACKSPACE
    DB 9,9,0  ; TAB
    DB ' ',' ',0; SPACE
    DB '-','_',0
    DB '=','+',0
    DB '[','{',0
    ;0x30
    DB ']','}',0
    DB '\','|',0
    DB 0x5c,0x7c,0
    DB ';',':',0
    DB "\'","\"",0
    DB '`','~',0
    DB ',','<',0
    DB '.','>',0
    DB '/','?',0
    DB 0,0,0
    DB 0,0,0
    DB 0,0,0
    DB 0,0,0
    DB 0,0,0
    DB 0,0,0
    DB 0,0,0
    ;0x40
    DB 0,0,0
    DB 0,0,0
    DB 0,0,0
    DB 0,0,0
    DB 0,0,0
    DB 0,0,0
    DB 0,0,0
    DB 0,0,0
    DB 0,0,0
    DB 0x12,0x12,0 ; insert key
    DB 0xb,0xc,0 ; home key
    DB 0x13,0,0 ; page up key
    DB 0x7f,0x7f,0 ; delete key
    DB 0x0e,0,0 ; end key
    DB 0,0,0 ; page down key
    DB 0x1c,6,0x0e ; right arrow
    ;0x50
    DB 0x1d,2,2 ; left arrow
    DB 0x1f,0x1f,0 ; down arrow
    DB 0x1e,0x1e,0 ; up arrow

_SCANCODES_ASCII_END:

; A = SCANCODE
; B = MODIFIER
;     KEY_MOD_LCTRL  0x01
;     KEY_MOD_LSHIFT 0x02
;     KEY_MOD_LALT   0x04
;     KEY_MOD_LMETA  0x08
;     KEY_MOD_RCTRL  0x10
;     KEY_MOD_RSHIFT 0x20
;     KEY_MOD_RALT   0x40
;     KEY_MOD_RMETA  0x80
CONVERT_SCANCODE:
    ld d, b ; modifier keys
    ; calculate a times 3
    ld c, a
    add a, a ; times 2
    add a, c ; times 3
    ld b, 0
    ld c, a
    ld hl, _SCANCODES_ASCII
    add hl,bc

    ld a, d ; modifier keys
    and a
    jr z, _CONTINUE
    inc hl
    cp 0x02
    jr z, _CONTINUE
    cp 0x20
    jr z, _CONTINUE
    inc hl
    cp 0x01
    jr z, _CONTINUE
    cp 0x10
    jr z, _CONTINUE
    xor a
    ret ; do not support
_CONTINUE
    ; insert found ASCII code from table into keybuffer
    ld a, (hl)
    ret

    STRUCT BOOT_KEYBOARD_INPUT_REPORT
bModifierKeys: DB 0
bReserved: DB 0
Keycode1: DB 0
Keycode2: DB 0
Keycode3: DB 0
Keycode4: DB 0
Keycode5: DB 0
Keycode6: DB 0
    ENDS
    
USB_READ_TOGGLE: db 0
USB_HID_BOOT_KEYBOARD_BUFFER: BOOT_KEYBOARD_INPUT_REPORT
OLD_HID_BOOT_KEYBOARD_BUFFER: BOOT_KEYBOARD_INPUT_REPORT
