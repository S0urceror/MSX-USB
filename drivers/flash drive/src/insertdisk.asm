    org 0100h

    call NEXTOR_CHECK ; first check if we're running NEXTOR 
    ret c
    ld a, 1 ; first driver
    call DRIVER_SLOT ; A holds slot ID in format E000SSPP
    ret c
    call GET_SLTWRK_FOR_SLOT ; HL holds pointer to GWORK area of driver
    ret c

    ld ix, hl
    ; copy scratch area to DISK_NAME removing all additional spaces, etc.
    ld hl, DISK_NAME
    call COPY_ARG1

    ld hl, DISK_NAME
    ld bc, 12
    call _STORE_DISK_NAME
	call _CLOSE_DISK_FILE ; close any file that was opened before opening a new one
	call _OPEN_DISK_FILE

    ret

;       Subroutine      Copy filename from scratch-area 5C (0:drivenr,1-8:filename,9-11:extension)
;       Inputs          HL - buffer to hold cleaned filename
;       Outputs         (none)
COPY_ARG1:
    ld de, 05ch
    ld a, (de) ; drivenr, not interested

    ld de, 05dh ; filename
    ld c, 8
    call _COPY_STR_NO_SPACE
    ld (hl), '.'
    inc hl
    ld de, 065h ; extension
    ld c,3
    call _COPY_STR_NO_SPACE
    ld (hl), 0
    ret

_COPY_STR_NO_SPACE:
    ld a, (de)
    cp a, 20h ; space
    ret z
    ld (hl),a
    inc hl
    inc de
    dec c
    jr nz, _COPY_STR_NO_SPACE
    ret


    include "nextor_helpers.asm"
    include "print_dos.asm"
    include "driver_helpers.asm"
    include "ch376s_helpers.asm"
    include "ch376s.asm"

DISK_NAME			db "ABCDABCD.ABC",0

