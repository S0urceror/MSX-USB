ENASLT:     equ 0024h
EXPTBL:     equ 0FCC1h
EXTBIO:     equ  0FFCAh

; BLOAD header
    db 0x0fe
    dw BEGIN, ENDADR, START_BASIC
    org 0c000h
BEGIN:
START_BASIC:
    ; set page 1 to slot 1
    ld a, 1
    ld h, 40h
    call ENASLT

    xor a
    rlca ; bank number multiplied times 2 to select right 8k segment
	ld	(5000h),a
	inc	a ; plus 1
	ld	(7000h),a

    jp 0
ENDADR: