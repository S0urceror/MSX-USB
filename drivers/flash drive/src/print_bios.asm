; ---------------------------------------------------------
; Miscellanous helper functions
;
;

CHPUT   EQU     #A2

;       Subroutine      Print a buffer of data in HEX
;       Inputs          HL - buffer to be printed
;                       BC - number of bytes
;       Outputs         ________________________
PRINTHEX_BUFFER:
    ld d,8
_PRINTHEX_LOOP:
    ld a, (hl)
    call PRINT_HEX
    ld a, 020h
    call CHPUT
    inc hl
    dec bc
    ; decrement d and check if zero
    dec d
    ld a, d
    and a
    jr nz, _PRINTHEX_NEXT
    push hl
    ld hl, TXT_NEWLINE
    call PRINT
    ld d,8
    pop hl

_PRINTHEX_NEXT:
    ld a,b
    or c
    jp nz, _PRINTHEX_LOOP
    ret

;       Subroutine      Print a buffer of data in chars
;       Inputs          HL - buffer to be printed
;                       BC - number of bytes
;       Outputs         ________________________
PRINT_BUFFER:
    ld a, (hl)
    call CHPUT
    inc hl
    dec bc
    ld a,b
    or c
    jp nz, PRINT_BUFFER
    ret

;       Subroutine      Print 8-bit hexidecimal number
;       Inputs          A - number to be printed - 0ABh
;       Outputs         ________________________
PRINT_HEX:
    push af
    push bc
    push de
    call __NUMTOHEX
    ld a, d
    call CHPUT
    ld a, e
    call CHPUT
    pop de
    pop bc
    pop af
    ret
;       Subroutine      Convert 8-bit hexidecimal number to ASCII reprentation
;       Inputs          A - number to be printed - 0ABh
;       Outputs         DE - two byte ASCII values - D=65 / 'A' and E=66 / 'B'
__NUMTOHEX:
    ld c, a   ; a = number to convert
    call _NTH1
    ld d, a
    ld a, c
    call _NTH2
    ld e, a
    ret  ; return with hex number in de
_NTH1:
    rra
    rra
    rra
    rra
_NTH2:
    or 0F0h
    daa
    add a, 0A0h
    adc a, 040h ; Ascii hex at this point (0 to F)   
    ret

;       Subroutine      Print char with the DOS routine
;       Inputs          A - char to print
;       Outputs         -------------------------------
PRINT_CHAR:
    call CHPUT
    ret

;       Subroutine      Print nul-terminated text with the BIOS routine
;       Inputs          HL - pointer to text to print
;       Outputs         -------------------------------
PRINT:
    push af
_PRINT_MORE:
    ld a,(hl)
    and a
    jr z, _PRINT_DONE
    call CHPUT
    inc hl
    jr _PRINT_MORE
_PRINT_DONE:
    pop af
    ret

; Set page 0 SlotId
; Input: A - SlotId
; Registers: AF, BC, DE, HL
; Remarks: ISR must preserve page 0 SlotId and page 3 memory mapping. Function must be placed within address range [4000h, BFFFh]
BEEP equ 0c0h
SLTTBL equ 0FCC5h
CLS	equ	0Ch
setpg0:
	ld c, a ; save
	; primary slot
	and 3 ; get only primary slot
	ld b, a ; B = primary slot for page 0
	in a, (0a8h)
	and 0fch ; clean page 0
	or b
	out (0a8h), a
	; secondary slot
	ld a, c ; restore original SlotId value
	rlca ; check for expanded bit
	ret nc ; if not expanded return
	rrca
	and 00ch ; get only subslot
	rrca ; put it for page 0
	rrca
	ld c, a ; C = secondary slot for page 0
	; set SLTTBL on HL
	ld hl, SLTTBL
	ld d, 0
	ld e, b ; add primary slot value to SLTTBL
	add hl, de ; HL = SLTTBL pointer
	; check if is the same already in SSSR
	ld a, (hl) ; get SLTTBL
	ld d, a ; save
	and 3 ; get only page 0
	xor c ; compare if the same
	ret z ; if xor = 0 then is the same, return
	; pre-compute new SSSR
	ld a, d ; recover SLTTBL
	and 0fch ; clean page 0
	or c ; set secondary slot for page 0
	ld e, a ; E = new SSSR
	ld a, b ; recover primary slot
	rrca ; set it for page 3
	rrca
	ld b, a ; B = primary slot for page 3
	; change SSSR
	in a, (0a8h)
	ld d, a ; save original value
	and 03fh ; clean page 3
	or b
	di ; we are going to change page 3
	out (0a8h), a ; set page 3 for SSSR
	ld a, e ; recover new SSSR
	ld (0ffffh), a ; set new SSSR
	ld a, d ; restore page 3
	out (0a8h), a
	; update SLTTBL
	ld a, e ; recover new SSSR
	ld (hl), a ; save on its corresponding SLTTBL
	ei ; finished with page 3
	ret

; call BIOS
;BIOSCHPUT:
;	push af,bc,de,hl
;	ld a, 00000000b ; non extended slot 0-0
;	call setpg0
;	pop hl,de,bc,af

	; BIOS working
;	call CHPUT

;	push af,bc,de,hl
;	ld a, 10001011b ; extended slot 3-2
;	call setpg0
;	pop hl,de,bc,af
;	ret

