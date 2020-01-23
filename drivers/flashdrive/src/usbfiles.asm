    org 0100h
    ld ix, BUF_DIR_ENTRY
    call _PRINTDIR
    ret

    include "print_dos.asm"
    include "driver_helpers.asm"
    include "ch376s_helpers.asm"
    include "ch376s.asm"

BUF_DIR_ENTRY: DS 040h

