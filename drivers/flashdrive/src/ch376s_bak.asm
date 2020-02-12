CH_DEBUG:       equ     1

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
CH_CMD_DIRTY_BUFFER: equ 25h
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
CH_CMD_SEC_WRITE: equ 4Ch
CH_CMD_ISSUE_TKN_X: equ 4Eh
CH_CMD_DISK_READ: equ 54h
CH_CMD_DISK_RD_GO: equ 55h
CH_CMD_DISK_WRITE: equ 56h
CH_CMD_DISK_WR_GO: equ 57h

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
CH_USB_INT_DISK_WRITE: equ 1eh
CH_USB_ERR_OPEN_DIR: equ 41h
CH_USB_ERR_MISS_FILE: equ 42h
CH_USB_ERR_FOUND_NAME: equ 43h
CH_USB_ERR_FILE_CLOSE: equ 0b4h
; own result codes
USB_ERR_PANIC_BUTTON_PRESSED: equ 0C1h

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
; Input: HL points to the read buffer
;        IX points to the IO_BUFFER
;        (IX) should contain a 4 byte sector allowed count plus a 4 byte LBA
;        can be overwritten.
; Output: Cy = 1 on error
CH_DISK_READ:
    ld a, CH_CMD_DISK_READ
    out (CH_COMMAND_PORT), a ; start reading

    ;ld ix, hl
    ld a,(ix+4)
    out (CH_DATA_PORT), a
    ld a,(ix+5)
    out (CH_DATA_PORT), a
    ld a,(ix+6)
    out (CH_DATA_PORT), a
    ld a,(ix+7)
    out (CH_DATA_PORT), a
    ld a, (ix)
    out (CH_DATA_PORT), a

_DISK_READ_NEXT:
    call CH_WAIT_INT_AND_GET_RESULT
    cp CH_USB_INT_DISK_READ ; data read
    jp z, _DISK_READ_DATA
    cp CH_USB_INT_SUCCESS ; done reading
    jp z, _DISK_READ_SUCCESS
    scf ; error flag
    ret

_DISK_READ_DATA:
    ; read the contents of the sector in the buffer pointed by HL
    call CH_READ_DATA 
    ld a, c
    or a
    scf 
    ret z
    
    ld a, CH_CMD_DISK_RD_GO
    out (CH_COMMAND_PORT), a ; request next block
    jp _DISK_READ_NEXT

_DISK_READ_SUCCESS:
    or a
    ret

; --------------------------------------
; CH_DISK_WRITE
;
; Input: HL points to the write buffer
;        IX points to the IO buffer
;        (IX) should contain a 4 byte sector allowed count plus a 4 byte LBA
; Output: Cy = 1 on error
CH_DISK_WRITE:
    ld a, CH_CMD_DISK_WRITE
    out (CH_COMMAND_PORT), a ; start writing

    ;ld ix, hl
    ld a,(ix+4)
    out (CH_DATA_PORT), a
    ld a,(ix+5)
    out (CH_DATA_PORT), a
    ld a,(ix+6)
    out (CH_DATA_PORT), a
    ld a,(ix+7)
    out (CH_DATA_PORT), a
    ld a, (ix)
    out (CH_DATA_PORT), a

    ; multiply sector count by 8 separate writes per sector
    sla a
    sla a
    sla a
    ld d, a

_DISK_WRITE_NEXT:
    call CH_WAIT_INT_AND_GET_RESULT
    cp CH_USB_INT_DISK_WRITE ; ready to write data
    jp z, _DISK_WRITE_DATA
    cp CH_USB_INT_SUCCESS ; done reading
    jp z, _DISK_WRITE_SUCCESS
    scf ; error flag
    ret

_DISK_WRITE_DATA:
    ; failsafe, check if d already points to zero
    ld a, d
    or a
    jr z, _DISK_WRITE_SUCCESS

    ; write the contents of the sector in the buffer pointed by HL
    ld b, 64 ; 64 bytes per write
    call CH_WRITE_DATA 
    dec d

    ld a, CH_CMD_DISK_WR_GO
    out (CH_COMMAND_PORT), a ; request next block
    jp _DISK_WRITE_NEXT

_DISK_WRITE_SUCCESS:
    or a
    ret

; --------------------------------------
; CH_SEC_WRITE
;
; Input: A = number of sectors requested to read from file pointer
;        IX = IO_BUFFER address
; Output: Cy = 1 on error
;         (IX) contains LBA
CH_SEC_WRITE:
    ld b,a
    ld a, CH_CMD_SEC_WRITE
    out (CH_COMMAND_PORT), a
    ld a, b
    out (CH_DATA_PORT), a
    jr _CH_SEC_IO

; --------------------------------------
; CH_SEC_READ
;
; Input: A = number of sectors requested to read from file pointer
;        IX = IO_BUFFER address
; Output: Cy = 1 on error
;         (IX) contains LBA
CH_SEC_READ:
    ld b,a
    ld a, CH_CMD_SEC_READ
    out (CH_COMMAND_PORT), a
    ld a, b
    out (CH_DATA_PORT), a

_CH_SEC_IO
    call CH_WAIT_INT_AND_GET_RESULT
    cp CH_USB_INT_SUCCESS ; file sector found
    scf ; error flag
    ret nz

    push hl,bc
    ld hl,ix
    call CH_READ_DATA ; read absolute sector number
    ld a, c
    pop bc,hl
    ; we should have 8 bytes
    ; READ_BUFFER + 0,1,2,3 = nr. of sectors that we are allowed to read/write, zero is EOF
    ; READ_BUFFER + 4,5,6,7 = LBA absolute disk sector
    or a
    scf 
    ret z ; return when no data read
    ; number of allowed sectors > 0
    ld a, (ix)
    cp b
    scf 
    ret nz ; return if the nr. allowed is not 1
    ; clear Cy
    or a
    ret 

; --------------------------------------
; CH_SEC_LOCATE
;
; Input: DE = points to address of 32 bit file sector pointer
; Output: Cy = 1 on error
CH_SEC_LOCATE:
    push de
    ld a, CH_CMD_SEC_LOCATE
    out (CH_COMMAND_PORT), a
    ld a,(de)
    out (CH_DATA_PORT), a
    inc de
    ld a,(de)
    out (CH_DATA_PORT), a
    inc de
    ld a,(de)
    out (CH_DATA_PORT), a
    inc de
    ld a,(de)
    out (CH_DATA_PORT), a
    pop de

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
; CH_RESET
;
; Clear the CH376 data buffer in case a reset was made
; while it was in the middle of a data transfer operation
;
; Input: none
; Output: none
CH_RESET:
    ret
;    ld b,64
;_HW_RESET_CLEAR_DATA_BUF:
;    in a,(CH_DATA_PORT)
;    djnz _HW_RESET_CLEAR_DATA_BUF

    ld a, CH_CMD_RESET_ALL
    out (CH_COMMAND_PORT), a
    
    ld bc,1000
_HW_RESET_WAIT:
    dec bc
    ld a,b
    or c
    jr nz,_HW_RESET_WAIT

    ld a,CH_CMD_TEST_CONNECT
    out (CH_COMMAND_PORT),a
_CH_WAIT_TEST_CONNECT:
    in a,(CH_DATA_PORT)
    or a
    jr z,_CH_WAIT_TEST_CONNECT
;    ld bc,350
;    call CH_DELAY
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
; CH_DIRTY_BUFFER
;
; Clear internal disk and file buffers
;
; Input: none
; Output: none
CH_DIRTY_BUFFER:
    ld a, CH_CMD_DIRTY_BUFFER
    out (CH_COMMAND_PORT), a
    ret 

; --------------------------------------
; CH_SEARCH_OPEN
;
; Input: none, opens the wildcard-search previously set
; Output: Cy = 1 on error
CH_SEARCH_OPEN:
    ;call CH_DIRTY_BUFFER

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
    push af
    ld b,a ; set counter nr bytes to read, first byte
    ld c,CH_DATA_PORT
    inir
    ; prepare to return
    pop af
    ld c,a
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
    push bc
    call PANIC_KEYS_PRESSED
    pop bc
    ld a,USB_ERR_PANIC_BUTTON_PRESSED
    ret z

    call CH_CHECK_INT_IS_ACTIVE
    jr nz,CH_WAIT_INT_AND_GET_RESULT    ;TODO: Perhaps add a timeout check here?
    call CH_GET_STATUS
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

; --------------------------------------
; CH_GET_STATUS
;
; Output: A = Status code
CH_GET_STATUS:
    ld a,CH_CMD_GET_STATUS
    out (CH_COMMAND_PORT),a
    in a,(CH_DATA_PORT)
    ret

; -----------------------------------------------------------------------------
; SNSMAT: Print a string describing an USB error code
; -----------------------------------------------------------------------------
PANIC_KEYS_PRESSED:
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
