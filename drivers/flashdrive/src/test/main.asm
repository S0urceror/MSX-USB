; BIOS CALLs
CHPUT       equ     00a2h

; BDOS CALL
BDOS	    equ	    0005h	; Set the address 0005h into label BDOS.
			                ; We can call several routines under MSX-DOS at address 0005h.

SLTATR      equ     0FCC9h

ROMSIZE     equ     08000h

; Compile flags
MSXBASIC    equ     1
MSXROM      equ     0
MSXDOS      equ     0
IMPLEMENT_PANIC_BUTTON equ 1
DEBUG       equ     0

; Header selection
    IF MSXBASIC = 1
        ; BLOAD header
        db 0x0fe
        dw BEGIN, ENDADR, START_BASIC
        org 0c004h
BEGIN:
        ; Call handler pointer in Bank 3 fixed offset 4
        DW CALL_HANDLER
START_BASIC:
        LD A,(#F344) ; SlotID of RAM in Bank 3 (#C000-#FFFF)
                     ; This variable is ready available only when disk drive is present.
        AND A
        JP M,.SKIP   ; SlotID has SubSlot information
        AND 3
.SKIP:
        AND 15
        LD E,A
        RLCA
        RLCA
        RLCA
        RLCA
        OR E
        AND 60
        LD D,0
        LD E,A
        LD HL,SLTATR+3 ; +3 for Bank 3
        ADD HL,DE
        SET 5,(HL)     ; Set bit 5 to enable CALL handler
        RET
    ENDIF
    IF MSXDOS = 1
        org 0100h
    ENDIF
    IF MSXROM = 1
        ; Compilation address
	    org 04000h	; 8000h can be also used here if Rom size is 16kB or less.
        ; ROM header (Put 0000h as address when unused)
	    db "AB"		; ID for auto-executable Rom at MSX start
	    dw START	    ; INIT - Main program execution address.
	    dw CALL_HANDLER	; CALLSTAT - Execution address of a program whose purpose is to add
			        ; instructions to the MSX-Basic using the CALL statement.
	    dw 0		; DEVICE - Execution address of a program used to control a device
			        ; built into the cartridge.
	    dw 0		; BASIC - Basic program pointer contained in ROM.
	    dw 0,0,0
    ENDIF
; CH376 commands
CH_CMD_RESET_ALL: equ 05h
CH_CMD_CHECK_EXIST: equ 06h
CH_CMD_SET_RETRY: equ 0Bh
CH_CMD_DELAY_100US: equ 0Fh
CH_CMD_SET_USB_ADDR: equ 13h
CH_CMD_SET_USB_MODE: equ 15h
CH_CMD_TEST_CONNECT: equ 16h
CH_CMD_ABORT_NAK: equ 17h
CH_CMD_GET_STATUS: equ 22h
CH_CMD_RD_USB_DATA0: equ 27h
CH_CMD_WR_HOST_DATA: equ 2Ch
CH_CMD_SET_FILE_NAME: equ 2Fh
CH_CMD_DISK_CONNECT: equ 30h
CH_CMD_DISK_MOUNT: equ 31h
CH_CMD_OPEN_FILE: equ 32h
CH_CMD_FILE_ENUM_GO: equ 33h
CH_CMD_FILE_CLOSE: equ 36h
CH_CMD_SET_ADDRESS: equ 45h
CH_CMD_GET_DESCR: equ 46h
CH_CMD_SET_CONFIG: equ 49h
CH_CMD_SEC_LOCATE: equ 4Ah
CH_CMD_SEC_READ: equ 4Bh
CH_CMD_ISSUE_TKN_X: equ 4Eh
CH_CMD_DISK_READ: equ 54h
CH_CMD_DISK_RD_GO: equ 55h

; return codes
CH_ST_RET_SUCCESS: equ 51h
CH_ST_RET_ABORT: equ 5Fh
; CH376 ports
CH_DATA_PORT           equ 0010h
CH_COMMAND_PORT        equ 0011h
; CH376 result codes
CH_USB_INT_SUCCESS:  equ 14h
CH_USB_INT_CONNECT:  equ 15h
CH_USB_INT_DISCONNECT: equ 16h
CH_USB_INT_BUF_OVER: equ 17h
CH_USB_INT_DISK_READ: equ 1dh
CH_USB_ERR_OPEN_DIR: equ 41h
CH_USB_ERR_MISS_FILE: equ 42h
CH_USB_ERR_FOUND_NAME: equ 43h
CH_USB_ERR_FILE_CLOSE: equ 0b4h
; own result codes
USB_ERR_PANIC_BUTTON_PRESSED: equ 0C1h

; USBDrive Z80 source code
;
;------------------------------------------------------------------------- 
START:
; print welcome message
    ld hl, TXT_START
    call PRINT

; check if CH376s in the cartridge slot
    call CH_HW_TEST
    jp nc, _HW_TEST_OKAY
    ld hl, TXT_NOT_FOUND
    call PRINT
    and a
    ret
_HW_TEST_OKAY:
    ld hl, TXT_FOUND
    call PRINT

; initialise CH376s
    call CH_RESET
    ld hl, TXT_RESET
    call PRINT

; set USB host mode
    ld a, 6 ; Host, generate SOF
    call CH_SET_USB_MODE
    jp nc, _USB_MODE_OKAY
    ld hl, TXT_MODE_NOT_SET
    call PRINT
    ret
_USB_MODE_OKAY
    ld hl, TXT_MODE_SET
    call PRINT

; connect disk
    call CH_CONNECT_DISK
    jp nc, _CONNECT_DISK_OKAY
    ld hl, TXT_DISK_NOT_CONNECTED
    call PRINT
    ret
_CONNECT_DISK_OKAY
    ld hl, TXT_DISK_CONNECTED
    call PRINT

; mount USB drive
    call CH_MOUNT_DISK
    jp nc, _MOUNT_DISK_OKAY
    ld hl, TXT_DISK_NOT_MOUNTED
    call PRINT
    ret
_MOUNT_DISK_OKAY
    ld hl, TXT_DISK_MOUNTED
    call PRINT

; after mounting information about make and model should be able to read
    ;UINT8	DeviceType;					/* 00H */
    ;UINT8	RemovableMedia;				/* 01H */
    ;UINT8	Versions;					/* 02H */
    ;UINT8	DataFormatAndEtc;			/* 03H */
    ;UINT8	AdditionalLength;			/* 04H */
    ;UINT8	Reserved1;
    ;UINT8	Reserved2;
    ;UINT8	MiscFlag;					/* 07H */
    ;UINT8	VendorIdStr[8];				/* 08H */
    ;UINT8	ProductIdStr[16];			/* 10H */
    ;UINT8	ProductRevStr[4];			/* 20H */
    ld hl, READ_BUFFER
    call CH_READ_DATA
    ld a, c
    or a
    jp nz, _READ_BUFFER_OKAY; we got data
    ld hl, TXT_NO_MAKE_MODEL
    call PRINT
    jp _NEXT
_READ_BUFFER_OKAY:
    ld hl, TXT_MAKE_MODEL
    call PRINT
    ld hl, READ_BUFFER+010h ; USB storage device, and information about manufacture and product
    call PRINT
    ld hl, TXT_NEWLINE
    call PRINT
_NEXT:
; print contents root directory
    ld hl, PATH_SEARCH_ROOT_DIR
    call CH_SET_FILE_NAME

    call CH_SEARCH_OPEN    
    jp nc, _DIR_ENTRY
    ld hl, TXT_ROOTDIR_NOT_OPENED
    call PRINT
    ret
    ;enumerate
_DIR_ENTRY
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
    ld hl, READ_BUFFER
    call CH_READ_DATA
    ld a, c
    or a
    jp nz, _READ_ENTRY_OKAY; we got data
    ld hl, TXT_NO_DIR_ENTRY
    call PRINT
    ret
_READ_ENTRY_OKAY:
    ld hl, READ_BUFFER ; Folder entry
    ld bc, 8
    call PRINT_BUFFER
    ld a, (READ_BUFFER + 0Bh)
    and 10h ; 4th bit indicates directory entry, no extension
    jp nz, _NO_EXT
    ld a,'.'
    call CHPUT
    ld hl, READ_BUFFER+8
    ld bc, 3
    call PRINT_BUFFER
_NO_EXT:
    ld hl, TXT_NEWLINE
    call PRINT
    ;check next
    call CH_SEARCH_NEXT
    jp nc, _DIR_ENTRY

; CD DSKS folder
    ld hl, PATH_DSKS
    call CH_SET_FILE_NAME

    call CH_DIR_OPEN    
    jp nc, _CONTINUE1
    ld hl, TXT_CD_FAILED
    call PRINT
    ret
_CONTINUE1:
    ld hl, TXT_CD_OKAY
    call PRINT
; open first file
    ld hl, PATH_MSXDOS2
    call CH_SET_FILE_NAME

    call CH_FILE_OPEN    
    jp nc, _CONTINUE2
    ld hl, TXT_FILEOPEN_FAILED
    call PRINT
    ret
_CONTINUE2:
    ld hl, TXT_FILEOPEN_OKAY
    call PRINT
    ; read sector 0
    ;
    ; CMD_SEC_LOCATE ; go to sector in opened file
    ld de,0 ; lower 16 bits of 32 bit file sector pointer
    ld hl,0 ; higher 16 bits of 32 bit file sector pointer
    call CH_SEC_LOCATE
    jp nc, _CONTINUE3
    ld hl, TXT_SEC_LOCATE_FAILED
    call PRINT
    ret 
_CONTINUE3:
    ld hl, TXT_SEC_LOCATE_OKAY
    call PRINT
    ld a, 1 ; 1 sector request to read
    call CH_SEC_READ ; de+hl contain a 4 byte disk LBA when succesful
    jp nc, _CONTINUE4
    ld hl, TXT_SEC_READ_FAILED
    call PRINT
    ret 
_CONTINUE4:
    push hl
    ld hl, TXT_SEC_READ_OKAY
    call PRINT
    pop hl
    ld ix, SECTOR_BUFFER ; pointer to sector buffer
    ; de + hl should contain a 4 byte LBA
    call CH_DISK_READ
    jp nc, _CONTINUE5
    ld hl, TXT_DISK_READ_FAILED
    call PRINT
    ret 
_CONTINUE5:
    ld hl, TXT_DISK_READ_OKAY
    call PRINT
; print sector
    if DEBUG=1
        ld hl, SECTOR_BUFFER
        ld bc, 512
        call PRINTHEX_BUFFER
    endif
; close file
    ld a,0 ; do not update file-length
    call CH_FILE_CLOSE
    ld hl, TXT_FILECLOSED_OKAY
    call PRINT
; unmount USB drive
    ret

; --------------------------------------
; CH_FILE_CLOSE
;
; Input: A = 1 if file-length is updated in dir, 0 if not
; Output: none
CH_FILE_CLOSE:
    ld b,a
    ld a, CH_CMD_FILE_CLOSE
    out (CH_COMMAND_PORT), a ; start reading
    ld a, b
    out (CH_DATA_PORT), a
    call CH_WAIT_INT_AND_GET_RESULT
    ret

; --------------------------------------
; CH_DISK_READ
;
; Input: IX = address of buffer to hold sector data
;        DE = lower 16 bits of 32 bit disk sector pointer
;        HL = higher 16 bits of 32 bit disk sector pointer
; Output: Cy = 1 on error
CH_DISK_READ:
    ld a, CH_CMD_DISK_READ
    out (CH_COMMAND_PORT), a ; start reading

    ld a,e
    out (CH_DATA_PORT), a
    ld a,d
    out (CH_DATA_PORT), a
    ld a,l
    out (CH_DATA_PORT), a
    ld a,h
    out (CH_DATA_PORT), a
    ld a, 1
    out (CH_DATA_PORT),a ; 1 sector at a time

    push ix
    pop hl ; hl now points to buffer

_DISK_READ_NEXT:
    call CH_WAIT_INT_AND_GET_RESULT
    cp CH_USB_INT_DISK_READ ; data read
    jp z, _DISK_READ_DATA
    cp CH_USB_INT_SUCCESS ; done reading
    jp z, _DISK_READ_SUCCESS
    scf ; error flag
    ret

_DISK_READ_DATA:
    if DEBUG=1 
        ld a,'.'
        call CHPUT
    endif
    ; read the contents of the sector in the buffer pointed by HL
    call CH_READ_DATA 
    ld a, c
    or a
    scf 
    ret z
    
    ld b,0
    add hl, bc ; advance buffer with the number of bytes read

    ld a, CH_CMD_DISK_RD_GO
    out (CH_COMMAND_PORT), a ; request next block
    jp _DISK_READ_NEXT

_DISK_READ_SUCCESS:
    or a
    ret

; --------------------------------------
; CH_SEC_READ
;
; Input: A = number of sectors requested to read from file pointer
; Output: Cy = 1 on error
;         DE = lower 16 bits of 32 bit disk sector pointer
;         HL = higher 16 bits of 32 bit disk sector pointer
CH_SEC_READ:
    ld a, CH_CMD_SEC_READ
    out (CH_COMMAND_PORT), a
    ld a, 1
    out (CH_DATA_PORT), a

    call CH_WAIT_INT_AND_GET_RESULT
    cp CH_USB_INT_SUCCESS ; file sector found
    scf ; error flag
    ret nz

    ld hl, READ_BUFFER
    call CH_READ_DATA ; read absolute sector number
    ld a, c
    or a
    scf 
    ret z

    ; we should have 8 bytes
    ; READ_BUFFER + 0,1,2,3 = nr. of sectors that we are allowed to read, zero is EOF
    ; READ_BUFFER + 4,5,6,7 = LBA absolute disk sector
    if DEBUG=1
        ld hl, READ_BUFFER
        ld bc, 8
        call PRINTHEX_BUFFER
        ld hl, TXT_NEWLINE
    endif
    call PRINT
    
    ld a, (READ_BUFFER)
    cp 1
    scf 
    ret nz ; return if the nr. allowed is not 1
    ; read absolute sector nr.
    ld de, (READ_BUFFER+4)
    ld hl, (READ_BUFFER+6)
    or a
    ret 

; --------------------------------------
; CH_SEC_LOCATE
;
; Input: DE = lower 16 bits of 32 bit file sector pointer
;        HL = higher 16 bits of 32 bit file sector pointer
; Output: Cy = 1 on error
CH_SEC_LOCATE:
    ld a, CH_CMD_SEC_LOCATE
    out (CH_COMMAND_PORT), a
    ld a,d
    out (CH_DATA_PORT), a
    ld a,e
    out (CH_DATA_PORT), a
    ld a,h
    out (CH_DATA_PORT), a
    ld a,l
    out (CH_DATA_PORT), a

    call CH_WAIT_INT_AND_GET_RESULT
    cp CH_USB_INT_SUCCESS ; file sector found
    scf ; error flag
    ret nz

    or a ; clear error flag
    ret

; --------------------------------------
; CH_SET_FILE_NAME
;
; Input: HL = pointer to filename or search path, buffer should be filled out to 13 chars
; Output: none
CH_SET_FILE_NAME:
    ld a, CH_CMD_SET_FILE_NAME
    out (CH_COMMAND_PORT), a
    ; write filename or search path, zero terminated
    ld c,CH_DATA_PORT
_SET_FILE_NAME_REPEAT:
    ld a,(hl) ; read from buffer
    out (c),a 
    inc hl
    or a ; stop if we read and output a 0?
    jp nz, _SET_FILE_NAME_REPEAT
    ret

; --------------------------------------
; CH_FILE_OPEN
;
; Input: none, opens the file previously set
; Output: Cy = 1 on error
CH_RESET:
    ;Clear the CH376 data buffer in case a reset was made
    ;while it was in the middle of a data transfer operation
    ;ld b,64
_HW_RESET_CLEAR_DATA_BUF:
    in a,(CH_DATA_PORT)
    djnz _HW_RESET_CLEAR_DATA_BUF

    ld a, CH_CMD_RESET_ALL
    out (CH_COMMAND_PORT), a
    
    ld bc,350
    call CH_DELAY
    ret 

    ;Input: BC = Delay duration in units of 0.1ms
CH_DELAY:
    ld a,CH_CMD_DELAY_100US
    out (CH_COMMAND_PORT),a
_CH_DELAY_LOOP:
    in a,(CH_DATA_PORT)
    or a
    jr z,_CH_DELAY_LOOP 
    dec bc
    ld a,b
    or c
    jr nz,CH_DELAY
    ret

; --------------------------------------
; CH_FILE_OPEN
;
; Input: none, opens the file previously set
; Output: Cy = 1 on error
CH_FILE_OPEN:
    ld a, CH_CMD_OPEN_FILE
    out (CH_COMMAND_PORT), a
    call CH_WAIT_INT_AND_GET_RESULT
    cp CH_USB_INT_SUCCESS ; file opened
    scf ; error flag
    ret nz
_FILE_OPEN_SUCCESS:
    or a ; clear error flag
    ret 
; --------------------------------------
; CH_DIR_OPEN
;
; Input: none, opens the directory previously set
; Output: Cy = 1 on error
CH_DIR_OPEN:
    ld a, CH_CMD_OPEN_FILE
    out (CH_COMMAND_PORT), a
    call CH_WAIT_INT_AND_GET_RESULT
    cp CH_USB_ERR_OPEN_DIR ; dir opened
    scf ; error flag
    ret nz
    or a ; clear error flag
    ret 
; --------------------------------------
; CH_SEARCH_OPEN
;
; Input: none, opens the wildcard-search previously set
; Output: Cy = 1 on error
CH_SEARCH_OPEN:
    ld a, CH_CMD_OPEN_FILE
    out (CH_COMMAND_PORT), a
    call CH_WAIT_INT_AND_GET_RESULT
    cp CH_USB_INT_DISK_READ ; search succesfull, at least 1 result
    scf ; error flag
    ret nz
    or a ; clear error flag
    ret 
; --------------------------------------
; CH_SEARCH_NEXT
;
; Input: none, iterates the search previously set
; Output: Cy = 1 on error
CH_SEARCH_NEXT:
    ld a, CH_CMD_FILE_ENUM_GO
    out (CH_COMMAND_PORT), a
    call CH_WAIT_INT_AND_GET_RESULT
    cp CH_USB_INT_DISK_READ ; search succesfull, at least 1 result
    scf ; error flag
    ret nz
    or a ; clear error flag
    ret 
; --------------------------------------
; CH_CHECK_INT_IS_ACTIVE
;
; Check the status of the INT pin of the CH376
; Input: none
; Output: Z if active, NZ if not active

CH_CHECK_INT_IS_ACTIVE:
    in a,(CH_COMMAND_PORT)
    and 80h
    ret

; -----------------------------------------------------------------------------
; HW_TEST: Check if the USB host controller hardware is operational
; -----------------------------------------------------------------------------
; Output: Cy = 0 if hardware is operational, 1 if it's not

CH_HW_TEST:
    ld a,34h
    call _HW_TEST_DO
    scf
    ret nz
    ld a,89h
    call _HW_TEST_DO
    scf
    ret nz
    or a
    ret

_HW_TEST_DO:
    ld b,a
    ld a,CH_CMD_CHECK_EXIST
    out (CH_COMMAND_PORT),a
    ld a,b
    xor 0FFh
    out (CH_DATA_PORT),a
    in a,(CH_DATA_PORT)
    cp b
    ret

; --------------------------------------
; CH_CONNECT_DISK
;
; Input: A = (none)
; Output: Cy = 1 on error
CH_CONNECT_DISK:
    ld a, CH_CMD_DISK_CONNECT
    out (CH_COMMAND_PORT), a
    call CH_WAIT_INT_AND_GET_RESULT
    cp CH_USB_INT_SUCCESS
    scf ; error flag
    ret nz
    or a ; clear error flag
    ret 

; --------------------------------------
; CH_MOUNT_DISK
;
; Input: A = (none)
; Output: Cy = 1 on error
CH_MOUNT_DISK:
    ld a, CH_CMD_DISK_MOUNT
    out (CH_COMMAND_PORT), a
    call CH_WAIT_INT_AND_GET_RESULT
    cp CH_USB_INT_SUCCESS
    scf ; error flag
    ret nz
    or a ; clear error flag
    ret 

; --------------------------------------
; CH_SET_USB_MODE
;
; Input: A = new USB mode:
;            5: Host, no SOF
;            6: Host, generate SOF
;            7: Host, generate SOF + bus reset
; Output: Cy = 1 on error

CH_SET_USB_MODE:
    ld b,a
    ld a,CH_CMD_SET_USB_MODE
    out (CH_COMMAND_PORT),a
    ld a,b
    out (CH_DATA_PORT),a

    ld b,255
_CH_WAIT_USB_MODE:
    in a,(CH_DATA_PORT)
    cp CH_ST_RET_SUCCESS
    jp z,_CH_CONFIGURE_RETRIES
    djnz _CH_WAIT_USB_MODE ; TODO: indefinately?
    scf
    ret
_CH_CONFIGURE_RETRIES:
    or a
    call HW_CONFIGURE_NAK_RETRY
    or a
    ret

; -----------------------------------------------------------------------------
; HW_CONFIGURE_NAK_RETRY
; -----------------------------------------------------------------------------
; Input: Cy = 0 to retry for a limited time when the device returns NAK
;               (this is the default)
;             1 to retry indefinitely (or for a long time) 
;               when the device returns NAK 

HW_CONFIGURE_NAK_RETRY:
    ld a,0FFh
    jr nc,_HW_CONFIGURE_NAK_RETRY_2
    ld a,0BFh
_HW_CONFIGURE_NAK_RETRY_2:
    push af
    ld a,CH_CMD_SET_RETRY
    out (CH_COMMAND_PORT),a
    ld a,25h    ;Fixed value, required by CH376
    out (CH_DATA_PORT),a
    ;Bits 7 and 6:
    ;  0x: Don't retry NAKs
    ;  10: Retry NAKs indefinitely (default)
    ;  11: Retry NAKs for 3s
    ;Bits 5-0: Number of retries after device timeout
    ;Default after reset and SET_USB_MODE is 8Fh
    pop af
    out (CH_DATA_PORT),a
    ret

; --------------------------------------
; CH_WRITE_DATA
;
; Write data to the CH data buffer
;
; Input:  HL = Source address of the data
;         B  = Length of the data
; Output: HL = HL + B
CH_WRITE_DATA:
    ld a,CH_CMD_WR_HOST_DATA
    out (CH_COMMAND_PORT),a
    ld c,CH_DATA_PORT
    ld a,b  
    out (c),a
    or a
    ret z

    otir
    ret

; --------------------------------------
; CH_READ_DATA
;
; Read data from the CH data buffer
;
; Input:  HL = Destination address for the data
; Output: C  = Amount of data received (0-64)
;         HL = HL + C

CH_READ_DATA:
    ld a,CH_CMD_RD_USB_DATA0
    out (CH_COMMAND_PORT),a
    in a,(CH_DATA_PORT)
    or a ; not zero?
    ld c, 0
    ret z   ;No data to transfer at all

    ; read data to (HL)
    ld b,a ; set counter nr bytes to read, first byte
    ld d,a ; backup counter
    ld c,CH_DATA_PORT
    inir
    ; prepare to return
    ld c,d
    ld (hl),0 ; zero at end of buffer - just in case
    or a
    ret

; --------------------------------------
; CH_WAIT_INT_AND_GET_RESULT
;
; Wait for INT to get active, execute GET_STATUS, 
; and return the matching USB error code
;
; Output: A = Result of GET_STATUS (an USB error code)
CH_WAIT_INT_AND_GET_RESULT:
    if IMPLEMENT_PANIC_BUTTON=1
        call PANIC_KEYS_PRESSED
        ld a,USB_ERR_PANIC_BUTTON_PRESSED
        ret z
    endif

    call CH_CHECK_INT_IS_ACTIVE
    jr nz,CH_WAIT_INT_AND_GET_RESULT    ;TODO: Perhaps add a timeout check here?

    call CH_GET_STATUS
    if DEBUG=1
        call PRINTHEX
    endif
    ret

; --------------------------------------
; CH_SET_NOSOF_MODE: Sets USB host mode without SOF
;
; This needs to run when a device disconnection is detected
;
; Output: A  = -1
;         Cy = 1 on error

CH_DO_SET_NOSOF_MODE:
    ld a,5
    call CH_SET_USB_MODE

    ld a,-1
    ret

; -----------------------------------------------------------------------------
; SNSMAT: Read the keyboard matrix
;
; This is the same SNSMAT provided by BIOS, it's copied here to avoid
; having to do an interslot call every time it's used
; -----------------------------------------------------------------------------

DO_SNSMAT:
    ld c,a
    di
    in a,(0AAh)
    and 0F0h
    add a,c
    out (0AAh),a
    ei
    in a,(0A9h)
    ret

    ;row 6:  F3     F2       F1  CODE    CAPS  GRAPH  CTRL   SHIFT
    ;row 7:  RET    SELECT   BS  STOP    TAB   ESC    F5     F4
    ;row 8:	 right  down     up  left    DEL   INS    HOME  SPACE


; -----------------------------------------------------------------------------
; SNSMAT: Print a string describing an USB error code
; -----------------------------------------------------------------------------
PANIC_KEYS_PRESSED:
    if IMPLEMENT_PANIC_BUTTON=1
        ;Return Z=1 if CAPS+ESC is pressed
        ld a,6
        call DO_SNSMAT
        and 1000b
        ld b,a
        ld a,7
        call DO_SNSMAT
        and 100b
        or b
        ret
    endif


; --------------------------------------
; CH_GET_STATUS
;
; Output: A = Status code
CH_GET_STATUS:
    ld a,CH_CMD_GET_STATUS
    out (CH_COMMAND_PORT),a
    in a,(CH_DATA_PORT)
    ret

;       Subroutine      Print a buffer of data in HEX
;       Inputs          HL - buffer to be printed
;                       BC - number of bytes
;       Outputs         ________________________
PRINTHEX_BUFFER:
    ld d,8
_PRINTHEX_LOOP:
    ld a, (hl)
    call PRINTHEX
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
PRINTHEX:
    push af
    push bc
    push de
    call NUMTOHEX
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
NUMTOHEX:
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

;       Subroutine      Print text with the right DOS/BIOS routine
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

CALBAS	EQU		#159
ERRHAND EQU     #406F
FRMEVL  EQU     #4C64
FRESTR	EQU		#67D0
CHRGTR  EQU     #4666
VALTYP  EQU     #F663
PROCNM	EQU		#FD89

CALL_HANDLER:
	PUSH    HL
	LD	HL,CMDS	        ; Table with "_" instructions
.CHKCMD:
	LD	DE,PROCNM
.LOOP1:	LD	A,(DE)
	CP	(HL)
	JR	NZ,.TONEXTCMD	; Not equal
	INC	DE
	INC	HL
	AND	A
	JR	NZ,.LOOP1	    ; No end of instruction name, go checking
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	POP	HL		        ; routine address
	CALL GETPREVCHAR
	CALL .CALLDE		; Call routine
	AND	A
	RET
.TONEXTCMD:
	LD	C,0FFH
	XOR	A
	CPIR			    ; Skip to end of instruction name
	INC	HL
	INC	HL		        ; Skip address
	CP	(HL)
	JR	NZ,.CHKCMD	    ; Not end of table, go checking
	POP	HL
    SCF
	RET

.CALLDE:
	PUSH	DE
	RET
 
;---------------------------
; List of available instructions (as ASCIIZ) and execute address (as word)
CMDS:
	db	"USBFILES",0      ; overview files in current directory
	dw	_USBFILES
 
	db	"USBCD",0      ; change current directory
	dw	_USBCD
 
	db	"INSERTDISK",0      ; mount a new .dsk
	dw	_INSERTDISK

	db	"EJECTDISK",0      ; unmount .dsk
	dw	_EJECTDISK
	
 	db	0               ; No more instructions
 
;---------------------------
_USBFILES:
    push hl
    call START
    pop hl
    or a
    ret

_EJECTDISK:
    push hl
    ld hl, TXT_START
    call PRINT
    pop hl
    or a
    ret

_USBCD:
	CALL	EVALTXTPARAM	; Evaluate text parameter
	PUSH	HL
    CALL    GETSTRPNT
    ld c, b
    ld b, 0
    call    PRINT_BUFFER
	POP	HL
	OR      A
	RET
;---------------------------
_INSERTDISK:
	CALL	EVALTXTPARAM	; Evaluate text parameter
	PUSH	HL
    CALL    GETSTRPNT
    ld c, b
    ld b, 0
    call    PRINT_BUFFER
	POP	HL
	OR      A
	RET
;---------------------------
 
GETSTRPNT:
; OUT:
; HL = String Address
; B  = Length
	LD      HL,(#F7F8)
	LD      B,(HL)
	INC     HL
	LD      E,(HL)
	INC     HL
	LD      D,(HL)
	EX      DE,HL
	RET
 
EVALTXTPARAM:
	CALL	CHKCHAR
	db	    "("             ; Check for (
	LD		IX,FRMEVL
	CALL	CALBAS			; Evaluate expression
	LD      A,(VALTYP)
	CP      3               ; Text type?
	JP      NZ,TYPE_MISMATCH
	PUSH	HL
	LD	    IX,FRESTR       ; Free the temporary string
	CALL	CALBAS
	POP	    HL
	CALL	CHKCHAR
	db	    ")"             ; Check for )
    RET
 
;CALBAS_B0:
;	push hl
;	ld hl, CALBAS
;	ld (CODE_ADD), hl
;	pop hl
;	call CALLB0
;	ret
 
CHKCHAR:
	CALL GETPREVCHAR	; Get previous basic char
	EX	(SP),HL
	CP	(HL) 	        ; Check if good char
	JR	NZ, SYNTAX_ERROR	; No, Syntax error
	INC	HL
	EX	(SP),HL
	INC	HL		; Get next basic char
 
GETPREVCHAR:
	DEC	HL
	LD	IX,CHRGTR
	JP  CALBAS
 
TYPE_MISMATCH:
    LD  E,13
    LD	IX,ERRHAND	; Call the Basic error handler
	JP	CALBAS
 
SYNTAX_ERROR:
    LD  E,2
	LD	IX,ERRHAND	; Call the Basic error handler
	JP	CALBAS

TXT_NEWLINE:            db "\r\n",0
TXT_START:              db "Starting CH376s driver\r\n",0
TXT_FOUND:              db "+CH376s connected\r\n",0
TXT_NOT_FOUND:          db "-CH376s NOT connected\r\n",0
TXT_MODE_SET:           db "+USB mode set\r\n",0
TXT_MODE_NOT_SET:       db "+USB mode NOT set\r\n",0
TXT_DISK_CONNECTED:     db "+Disk connected\r\n",0
TXT_DISK_NOT_CONNECTED: db "-Disk NOT connected\r\n",0
TXT_DISK_MOUNTED:       db "+Disk mounted\r\n",0
TXT_DISK_NOT_MOUNTED:   db "-Disk NOT mounted\r\n",0
TXT_NO_MAKE_MODEL:      db "-Device name NOT read\r\n",0
TXT_MAKE_MODEL:         db "+Device name: ",0
TXT_ROOTDIR_OPENED:     db "+Root directory opened\r\n",0
TXT_ROOTDIR_NOT_OPENED: db "-Root directory NOT opened\r\n",0
TXT_NO_DIR_ENTRY:       db "-Directory entry NOT read\r\n",0
TXT_CD_FAILED:          db "-Directory does NOT exist\r\n",0
TXT_FILEOPEN_FAILED:    db "-File NOT opened\r\n",0
TXT_SEC_LOCATE_FAILED:  db "-Cannot set file pointer to sector\r\n",0
TXT_SEC_READ_FAILED:    db "-Request sector failed\r\n",0
TXT_DISK_READ_FAILED:   db "-Disk read sector failed\r\n",0
TXT_CD_OKAY:            db "+Directory opened\r\n",0
TXT_FILEOPEN_OKAY:      db "+File opened\r\n",0
TXT_SEC_LOCATE_OKAY:    db "+File pointer set to sector\r\n",0
TXT_SEC_READ_OKAY:      db "+Sector read requested\r\n",0
TXT_DISK_READ_OKAY:     db "+Disk sector read\r\n",0
TXT_RESET:              db "+CH376s reset\r\n",0
TXT_FILECLOSED_OKAY:    db "+File closed\r\n",0

PATH_MSXDOS2: db "NEXTOR.DSK"
PATH_DSKS: db "DSKS",0
PATH_SEARCH_ROOT_DIR:  db "/*",0

; TODO: move to RAM/workspace
READ_BUFFER:    ds 040h,0 
SECTOR_BUFFER:  ds 512,0

ENDADR: 
    IF MSXROM = 1
        ; Padding with 255 to make the file of 16K size (can be 4K, 8K, 16k, etc) but
        ; some MSX emulators or Rom loaders can not load 4K/8K Roms.
        ; (Alternatively, include macros.asm and use ALIGN 4000H)
	    ds 4000h+ROMSIZE-ENDADR,255	; 8000h+ROMSIZE-ENDADR if org 8000h
    ENDIF

