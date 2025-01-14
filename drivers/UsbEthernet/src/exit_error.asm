    ld b, 1
    ld c, (0062h)
    call BDOS
    ld c, (0h)
    jp BDOS