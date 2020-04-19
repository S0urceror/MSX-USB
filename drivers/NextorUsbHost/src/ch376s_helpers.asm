PATH_SEARCH_DIR:  db "/*",0

;UINT8	DIR_Name[11];					/* 00H */
;UINT8	DIR_Attr;						/* 0BH */
;UINT8	DIR_NTRes;						/* 0CH */
;UINT8	DIR_CrtTimeTenth;				/* 0DH */
;UINT16	DIR_CrtTime;					/* 0EH */
;UINT16	DIR_CrtDate;					/* 10H */
;UINT16	DIR_LstAccDate;					/* 12H */
;UINT16	DIR_FstClusHI;					/* 14H */
;UINT16	DIR_WrtTime;					/* 16H */
;UINT16	DIR_WrtDate;					/* 18H */
;UINT16	DIR_FstClusLO;					/* 1AH */
;UINT32	DIR_FileSize;					/* 1CH */
_PRINTDIR:
	; print contents directory
    ld hl, TXT_USB_DRIVE
    call PRINT
    ld hl, ix
    ld bc, WRKAREA.DIR_NAME
    add hl,bc
    call PRINT
    ld hl, TXT_NEWLINE
    call PRINT
    ; disk file open?
    ld a, (ix+WRKAREA.STATUS)
    and 00010000b ; file is open, use root wildcard
    jr z, _NORMAL_WILDCARD
    call _CLOSE_DISK_FILE
    ld hl, TXT_ROOT_WILDCARD
    jr _SEARCH
_NORMAL_WILDCARD:
    ld hl, TXT_WILDCARD
_SEARCH:
    call CH_SET_FILE_NAME
    call CH_SEARCH_OPEN    
    ;
    push af
    ld bc, WRKAREA.IO_BUFFER
    add ix,bc
    pop af
    ;
    jp nc, _DIR_ENTRY
    ld hl, TXT_DIR_NOT_OPENED
    call PRINT
    ret
    ;enumerate
_DIR_ENTRY
    ld hl, ix
    call CH_READ_DATA
    ld a, c
    or a
    jp nz, _READ_ENTRY_OKAY; we got data
    ld hl, TXT_NO_DIR_ENTRY
    call PRINT
    ret
_READ_ENTRY_OKAY:
	ld a, (ix + 0Bh)
	and 00001110b ; Hidden, System or Volume (or LFN)?
	jr nz, _ENTRY_HIDDEN
	ld a, (ix + 0Bh)
    and 10h ; 4th bit indicates directory entry, write <DIR>
    jr z, _DIRECTORY_ENTRY_FILE
	ld hl, TXT_DIRECTORY_ENTRY
	call PRINT
_DIRECTORY_ENTRY_FILE:
    ld hl, ix ; Folder entry
    ld bc, 8
    call _PRINT_DIR_ENTRY

	ld a, (ix + 0Bh)
    and 10h ; 4th bit indicates directory entry, no extension
    jr nz, _READ_ENTRY_NEXT

    ld a,'.'
    call PRINT_CHAR
	
	ld hl, ix ; Folder entry
	ld bc,8
	add hl, bc
    ld bc, 3
    call _PRINT_DIR_ENTRY
_READ_ENTRY_NEXT:
    ld hl, TXT_NEWLINE
    call PRINT
    ;check next
_ENTRY_HIDDEN:
    call CH_SEARCH_NEXT
    jr nc, _DIR_ENTRY
	ret


;       Subroutine      Print a buffer of data in chars
;       Inputs          HL - buffer to be printed
;                       BC - max number of bytes
;       Outputs         ________________________
_PRINT_DIR_ENTRY:
    ld a, (hl)
	cp ' '
	jr z,_PRINT_DIR_ENTRY_DONE
    call PRINT_CHAR
    inc hl
    dec bc
    ld a,b
    or c
    jp nz, _PRINT_DIR_ENTRY
_PRINT_DIR_ENTRY_DONE:
    ret

;       Subroutine      Copies new diskname to WRKAREA
;       Inputs          IX - start of WRKAREA, HL - pointer to new diskname, BC - number of bytes
;       Outputs         HL - pointer to stored diskname
_STORE_DISK_NAME:
	push bc, hl
	ld hl, ix
	ld bc, WRKAREA.DSK_NAME
	add hl, bc
	ex de,hl
	pop hl, bc
	push de
	ldir ; save DSK name
	xor a
	ld (de),a ; trailing zero
	pop hl ; ix + WRKAREA.DSK_NAME
	ret

;       Subroutine      Copies new dirname to WRKAREA
;       Inputs          IX - start of WRKAREA, HL - pointer to new dirname, BC - number of bytes
;       Outputs         HL - pointer to stored dirname
_STORE_DIR_NAME:
	push bc, hl
	ld hl, ix
	ld bc, WRKAREA.DIR_NAME
	add hl, bc
	ex de,hl
	pop hl, bc
	push de
	ldir ; save DIR name
	xor a
	ld (de),a ; trailing zero
	pop hl ; ix + WRKAREA.DIR_NAME
	ret

;       Subroutine      Opens the disk file
;       Inputs          IX - start of WRKAREA, HL - pointer to zero-terminated diskname
;       Outputs         (none)
_OPEN_DISK_FILE:
	call CH_SET_FILE_NAME
    call CH_FILE_OPEN    
    jp nc, _OPEN_DISK_FILE_NEXT
	ld (ix+WRKAREA.STATUS),00001111b
    ld hl, TXT_FILEOPEN_FAILED
    call PRINT
    ret
_OPEN_DISK_FILE_NEXT:
	ld (ix+WRKAREA.STATUS),00111111b
    ld hl, TXT_FILEOPEN_OKAY
    call PRINT
	ret

;       Subroutine      Opens the disk file
;       Inputs          IX - start of WRKAREA
;       Outputs         (none)
_CLOSE_DISK_FILE:
    ld (ix+WRKAREA.STATUS),00001111b
	xor a
	call CH_FILE_CLOSE
    ret