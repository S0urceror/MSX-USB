ENASLT:     equ 0024h
RAMAD1: EQU #F342

    org 0A000h
; BLOAD header
    db 0x0fe
    dw BEGIN, ENDADR, START_BASIC
BEGIN:
START_BASIC:
    ; select slot 1 in page 0 and 1
    in a, (0a8h)
    ; clear page 0 and 1
    and 11110000b
    or 00000101b
    ; set new value
    out (0a8h),a

    ; set all mapper segments
    xor a
    ld	(1000h),a
    inc a
    ld  (3000h),a
    inc a
    ld  (5000h),a
	inc	a ; plus 1
	ld	(7000h),a

    call PRINT_INIT
    ; check flash id's
    ld hl, #0555
    ld a, #AA
    ld (hl),a
    ld hl, #02AA
    ld a, #55
    ld (hl),a
    ld hl, #0555
    ld a, #90
    ld (hl),a
    ld a, (#0000)
    call PRINT_HEX ; manufacturer
    ld a, ' '
    call PRINT_CHAR
    ld a, (#0001)
    call PRINT_HEX ; device
    ld a, ' '
    call PRINT_CHAR

    ; check flash id's
    ld hl, #4555
    ld a, #AA
    ld (hl),a
    ld hl, #42AA
    ld a, #55
    ld (hl),a
    ld hl, #4555
    ld a, #90
    ld (hl),a
    ld a, (#4000)
    call PRINT_HEX ; manufacturer
    ld a, ' '
    call PRINT_CHAR
    ld a, (#4001)
    call PRINT_HEX ; device

    di
    halt

    include "print_vdp.asm"


ENDADR:

; BLOAD "flashtst.bin",r