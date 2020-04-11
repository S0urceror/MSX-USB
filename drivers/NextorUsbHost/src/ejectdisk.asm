    org 0100h

    call NEXTOR_CHECK ; first check if we're running NEXTOR 
    ret c
    ld a, 1 ; first driver
    call DRIVER_SLOT ; A holds slot ID in format E000SSPP
    ret c
    call GET_SLTWRK_FOR_SLOT ; HL holds pointer to GWORK area of driver
    ret c

    ld ix, hl
	call _CLOSE_DISK_FILE
	ld hl, TXT_FILECLOSED_OKAY
    call PRINT

    ret

    include "nextor_helpers.asm"
    include "print_dos.asm"
    include "driver_helpers.asm"
    include "ch376s_helpers.asm"
    include "ch376s.asm"