    ORG 04000h
    DB  "AB"
    DW  MAIN
    DS  12

MAIN:
    ld hl, TXT_SEGMENT
    call PRINT
    ld a, X
    add a, '0'
    cp '9'+1
    jr c, BELOW_ZERO
    add a, 'A'-'9'-1
BELOW_ZERO:
    call CHPUT
    ld hl, TXT_NEWLINE
    call PRINT
    ld bc, WAIT_ONE_SECOND/2
    call WAIT

    ld a, X+1 ; next segment nr
    ld (05000h),a
    jr MAIN

WAIT_ONE_SECOND	equ 60 ; max 60Hz

;-----------------------------------------------------------------------------
;
; Wait a determined number of interrupts
; Input: BC = number of 1/framerate interrupts to wait
; Output: (none)
WAIT:
	halt
	dec bc
	ld a,b
	or c
	jr nz, WAIT
	ret

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

TXT_SEGMENT: DB "SEGMENT ",0
TXT_NEWLINE: DB 13,10,0

    DS 06000h-$,0
