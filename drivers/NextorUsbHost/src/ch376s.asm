;
; CH376s.ASM - Z80 assembly to communicate with the CH376s generic USB chip
; Copyright (c) 2019 Néstor Soriano (Konamiman), Mario Smit (S0urceror)
; 
; This program is free software: you can redistribute it and/or modify  
; it under the terms of the GNU General Public License as published by  
; the Free Software Foundation, version 3.
;
; This program is distributed in the hope that it will be useful, but 
; WITHOUT ANY WARRANTY; without even the implied warranty of 
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
; General Public License for more details.
;
; You should have received a copy of the GNU General Public License 
; along with this program. If not, see <http://www.gnu.org/licenses/>.
;

; CH376 commands
CH_CMD_GET_IC_VER equ 01h
CH_CMD_SET_SPEED: equ 04h
CH_CMD_RESET_ALL: equ 05h
CH_CMD_CHECK_EXIST: equ 06h
CH_CMD_SET_RETRY: equ 0Bh
CH_CMD_SET_SD0_INT: equ 0Bh
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
CH_CMD_BYTE_READ: equ 3ah
CH_CMD_BYTE_RD_GO: equ 3bh
CH_CMD_CLR_STALL equ 41h
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
    IFDEF __ROOKIEDRIVE
CH_DATA_PORT       equ 0020h
CH_COMMAND_PORT    equ 0021h
    ENDIF
    IFDEF __MISTERSPI
CH_DATA_PORT       equ 0020h
CH_STATUS_PORT     equ 0021h    
CH_COMMAND_PORT    equ 0021h
    ENDIF
    IFDEF __MSXUSBCARTv1
CH_DATA_PORT           equ 0010h
CH_COMMAND_PORT        equ 0011h
    ENDIF
; CH376 result codes
CH_USB_INT_SUCCESS:  equ 14h
CH_USB_INT_CONNECT:  equ 15h
CH_USB_INT_DISCONNECT: equ 16h
CH_USB_INT_BUF_OVER: equ 17h
CH_USB_INT_USB_READY: equ 18h
CH_USB_INT_DISK_READ: equ 1dh
CH_USB_INT_DISK_WRITE: equ 1eh
CH_USB_ERR_OPEN_DIR: equ 41h
CH_USB_ERR_MISS_FILE: equ 42h
CH_USB_ERR_FOUND_NAME: equ 43h
CH_USB_ERR_FILE_CLOSE: equ 0b4h
;--- PIDs
CH_PID_SETUP: equ 0Dh
CH_PID_IN: equ 09h
CH_PID_OUT: equ 01h
; own result codes
USB_ERR_PANIC_BUTTON_PRESSED: equ 0C1h

CH_BOOT_PROTOCOL: equ 0
; 2-set to 1.5 Mhz low-speed mode, 0-set to 12 Mhz high-speed mode (default)
CH_SPEED_LOW: equ 2
CH_SPEED_HIGH: equ 0
CH_MODE_HOST_RESET: equ 7
CH_MODE_HOST: equ 6

; --------------------------------------
; CH_FILE_CLOSE
;
; Input: A = 1 if file-length is updated in dir, 0 if not
; Output: none
;CH_FILE_CLOSE:
;    ld b,a
;    ld a, CH_CMD_FILE_CLOSE
;    out (CH_COMMAND_PORT), a ; start reading
;    ld a, b
;    out (CH_DATA_PORT), a
;    call CH_WAIT_INT_AND_GET_RESULT
;    ret

; --------------------------------------
; CH_FILE_READ
;
; Input: HL points to buffer to receive data
; Output: none
;CH_FILE_READ:
;    ld a, CH_CMD_BYTE_READ
;    out (CH_COMMAND_PORT), a ; start reading
;    ld a, 64 ; buffer size
;    out (CH_DATA_PORT), a ; 64 bytes requested
;    xor a
;    out (CH_DATA_PORT),a

;_FILE_READ_NEXT:
;    call CH_WAIT_INT_AND_GET_RESULT
;    cp CH_USB_INT_DISK_READ ; data read
;    jp z, _FILE_READ_DATA
;    cp CH_USB_INT_SUCCESS ; done reading
;    jp z, _FILE_READ_SUCCESS
;    scf ; error flag
;    ret

;_FILE_READ_DATA:
;    ; read the contents of the sector in the buffer pointed by HL
;    call CH_READ_DATA 
;    ld a, c
;    or a
;    scf 
;    ret z
;    
;    ld a, CH_CMD_BYTE_RD_GO
;    out (CH_COMMAND_PORT), a ; request next block
;    jp _FILE_READ_NEXT

;_FILE_READ_SUCCESS:
;    or a
;    ret

; --------------------------------------
; CH_DISK_READ
;
; Input: HL points to the read buffer
;        IX points to the IO_BUFFER
;        (IX) should contain a 4 byte sector allowed count plus a 4 byte LBA
;        can be overwritten.
; Output: Cy = 1 on error
;CH_DISK_READ:
;    ld a, CH_CMD_DISK_READ
;    out (CH_COMMAND_PORT), a ; start reading

;    ld a,(ix+4)
;    out (CH_DATA_PORT), a
;    ld a,(ix+5)
;    out (CH_DATA_PORT), a
;    ld a,(ix+6)
;    out (CH_DATA_PORT), a
;    ld a,(ix+7)
;    out (CH_DATA_PORT), a
;    ld a, (ix)
;    out (CH_DATA_PORT), a

;_DISK_READ_NEXT:
;    call CH_WAIT_INT_AND_GET_RESULT
;    cp CH_USB_INT_DISK_READ ; data read
;    jp z, _DISK_READ_DATA
;    cp CH_USB_INT_SUCCESS ; done reading
;    jp z, _DISK_READ_SUCCESS
;    scf ; error flag
;    ret

;_DISK_READ_DATA:
;    ; read the contents of the sector in the buffer pointed by HL
;    call CH_READ_DATA 
;    ld a, c
;    or a
;    scf 
;    ret z
    
;    ld a, CH_CMD_DISK_RD_GO
;    out (CH_COMMAND_PORT), a ; request next block
;    jp _DISK_READ_NEXT

;_DISK_READ_SUCCESS:
;    or a
;    ret

; --------------------------------------
; CH_DISK_WRITE
;
; Input: HL points to the write buffer
;        IX points to the IO buffer
;        (IX) should contain a 4 byte sector allowed count plus a 4 byte LBA
; Output: Cy = 1 on error
;CH_DISK_WRITE:
;    ld a, CH_CMD_DISK_WRITE
;    out (CH_COMMAND_PORT), a ; start writing

;    ld a,(ix+4)
;    out (CH_DATA_PORT), a
;    ld a,(ix+5)
;    out (CH_DATA_PORT), a
;    ld a,(ix+6)
;    out (CH_DATA_PORT), a
;    ld a,(ix+7)
;    out (CH_DATA_PORT), a
;    ld a, (ix)
;    out (CH_DATA_PORT), a

;    ; multiply sector count by 8 separate writes per sector
;    sla a
;    sla a
;    sla a
;    ld d, a

;_DISK_WRITE_NEXT:
;    call CH_WAIT_INT_AND_GET_RESULT
;    cp CH_USB_INT_DISK_WRITE ; ready to write data
;    jp z, _DISK_WRITE_DATA
;    cp CH_USB_INT_SUCCESS ; done reading
;    jp z, _DISK_WRITE_SUCCESS
;    scf ; error flag
;    ret

;_DISK_WRITE_DATA:
;    ; failsafe, check if d already points to zero
;    ld a, d
;    or a
;    jr z, _DISK_WRITE_SUCCESS

;    ; write the contents of the sector in the buffer pointed by HL
;    ld b, 64 ; 64 bytes per write
;    call CH_WRITE_DATA 
;    dec d

;    ld a, CH_CMD_DISK_WR_GO
;    out (CH_COMMAND_PORT), a ; request next block
;    jp _DISK_WRITE_NEXT

;_DISK_WRITE_SUCCESS:
;    or a
;    ret

; --------------------------------------
; CH_SEC_WRITE
;
; Input: A = number of sectors requested to read from file pointer
;        IX = IO_BUFFER address
; Output: Cy = 1 on error
;         (IX) contains LBA
;CH_SEC_WRITE:
;    ld b,a
;    ld a, CH_CMD_SEC_WRITE
;    out (CH_COMMAND_PORT), a
;    ld a, b
;    out (CH_DATA_PORT), a
;    jr _CH_SEC_IO

; --------------------------------------
; CH_SEC_READ
;
; Input: A = number of sectors requested to read from file pointer
;        IX = IO_BUFFER address
; Output: Cy = 1 on error
;         (IX) contains LBA
;CH_SEC_READ:
;    ld b,a
;    ld a, CH_CMD_SEC_READ
;    out (CH_COMMAND_PORT), a
;    ld a, b
;    out (CH_DATA_PORT), a

;_CH_SEC_IO
;    call CH_WAIT_INT_AND_GET_RESULT
;    cp CH_USB_INT_SUCCESS ; file sector found
;    scf ; error flag
;    ret nz

;    push hl,bc
;    ld hl,ix
;    call CH_READ_DATA ; read absolute sector number
;    ld a, c
;    pop bc,hl
;    ; we should have 8 bytes
;    ; READ_BUFFER + 0,1,2,3 = nr. of sectors that we are allowed to read/write, zero is EOF
;    ; READ_BUFFER + 4,5,6,7 = LBA absolute disk sector
;    or a
;    scf 
;    ret z ; return when no data read
;    ; number of allowed sectors > 0
;    ld a, (ix)
;    cp b
;    scf 
;    ret nz ; return if the nr. allowed is not 1
;    ; clear Cy
;    or a
;    ret 

; --------------------------------------
; CH_SEC_LOCATE
;
; Input: DE = points to address of 32 bit file sector pointer
; Output: Cy = 1 on error
;CH_SEC_LOCATE:
;    push de
;    ld a, CH_CMD_SEC_LOCATE
;    out (CH_COMMAND_PORT), a
;    ld a,(de)
;    out (CH_DATA_PORT), a
;    inc de
;    ld a,(de)
;    out (CH_DATA_PORT), a
;    inc de
;    ld a,(de)
;    out (CH_DATA_PORT), a
;    inc de
;    ld a,(de)
;    out (CH_DATA_PORT), a
;    pop de
;
;    call CH_WAIT_INT_AND_GET_RESULT
;    cp CH_USB_INT_SUCCESS ; file sector found
;    scf ; error flag
;    ret nz
;
;    or a ; clear error flag
;    ret

; --------------------------------------
; CH_SET_FILE_NAME
;
; Input: HL = pointer to filename or search path, buffer should be filled out to 13 chars
; Output: none
;CH_SET_FILE_NAME:
;    ld a, CH_CMD_SET_FILE_NAME
;    out (CH_COMMAND_PORT), a
;    ; write filename or search path, zero terminated
;    ld c,CH_DATA_PORT
;_SET_FILE_NAME_REPEAT:
;    ld a,(hl) ; read from buffer
;    out (c),a 
;    inc hl
;    or a ; stop if we read and output a 0?
;    jp nz, _SET_FILE_NAME_REPEAT
;    ret

; --------------------------------------
; CH_FILE_OPEN
;
; Input: none, opens the file previously set
; Output: Cy = 1 on error
;CH_FILE_OPEN:
;    ld a, CH_CMD_OPEN_FILE
;    out (CH_COMMAND_PORT), a
;    call CH_WAIT_INT_AND_GET_RESULT
;    cp CH_USB_INT_SUCCESS ; file opened
;    scf ; error flag
;    ret nz
;_FILE_OPEN_SUCCESS:
;    or a ; clear error flag
;    ret 
; --------------------------------------
; CH_DIR_OPEN
;
; Input: none, opens the directory previously set
; Output: Cy = 1 on error
;CH_DIR_OPEN:
;    ld a, CH_CMD_OPEN_FILE
;    out (CH_COMMAND_PORT), a
;    call CH_WAIT_INT_AND_GET_RESULT
;    cp CH_USB_ERR_OPEN_DIR ; dir opened
;    scf ; error flag
;    ret nz
;    or a ; clear error flag
;    ret 

; --------------------------------------
; CH_DIRTY_BUFFER
;
; Clear internal disk and file buffers
;
; Input: none
; Output: none
;CH_DIRTY_BUFFER:
;    ld a, CH_CMD_DIRTY_BUFFER
;    out (CH_COMMAND_PORT), a
;    ret 

; --------------------------------------
; CH_SEARCH_OPEN
;
; Input: none, opens the wildcard-search previously set
; Output: Cy = 1 on error
;CH_SEARCH_OPEN:
;    ld a, CH_CMD_OPEN_FILE
;    out (CH_COMMAND_PORT), a
;    call CH_WAIT_INT_AND_GET_RESULT
;    cp CH_USB_INT_DISK_READ ; search succesfull, at least 1 result
;    scf ; error flag
;    ret nz
;    or a ; clear error flag
;    ret 
; --------------------------------------
; CH_SEARCH_NEXT
;
; Input: none, iterates the search previously set
; Output: Cy = 1 on error
;CH_SEARCH_NEXT:
;    ld a, CH_CMD_FILE_ENUM_GO
;    out (CH_COMMAND_PORT), a
;    call CH_WAIT_INT_AND_GET_RESULT
;    cp CH_USB_INT_DISK_READ ; search succesfull, at least 1 result
;    scf ; error flag
;    ret nz
;    or a ; clear error flag
;    ret 

; --------------------------------------
; CH_CONNECT_DISK
;
; Input: A = (none)
; Output: Cy = 1 on error
;CH_CONNECT_DISK:
;    ld a, CH_CMD_DISK_CONNECT
;    out (CH_COMMAND_PORT), a
;    call CH_WAIT_INT_AND_GET_RESULT
;    cp CH_USB_INT_SUCCESS
;    scf ; error flag
;    ret nz
;    or a ; clear error flag
;    ret 

; --------------------------------------
; CH_MOUNT_DISK
;
; Input: A = (none)
; Output: Cy = 1 on error
;CH_MOUNT_DISK:
;    ld a, CH_CMD_DISK_MOUNT
;    out (CH_COMMAND_PORT), a
;    call CH_WAIT_INT_AND_GET_RESULT
;    cp CH_USB_INT_SUCCESS
;    scf ; error flag
;    ret nz
;    or a ; clear error flag
;    ret 

    MACRO SPIWAIT
    IFNDEF __NOWAIT
        push af
.notready:
        in a, (CH_STATUS_PORT)
        and 01h
        jr z,.notready    
        pop af
    ENDIF
    ENDM

    MACRO CH_SEND_COMMAND
    IFNDEF __MISTERSPI
        out (CH_COMMAND_PORT), a
    ELSE
        SPIWAIT
        out (CH_COMMAND_PORT), a
    ENDIF
    ENDM

    MACRO CH_RECEIVE_STATUS
    IFNDEF __MISTERSPI
        in a,(CH_COMMAND_PORT)
    ELSE
        in a,(CH_COMMAND_PORT)
    ENDIF
    ENDM

    MACRO CH_END_COMMAND
    IFDEF __MISTERSPI
        SPIWAIT
        push af
        xor a
        out (CH_COMMAND_PORT),a
        pop af
    ENDIF
    ENDM

    MACRO CH_SEND_DATA
    IFNDEF __MISTERSPI
        out (CH_DATA_PORT), a
    ELSE
        SPIWAIT
        out (CH_DATA_PORT), a
    ENDIF
    ENDM

    MACRO CH_SEND_DATA_MULTIPLE
    IFNDEF __MISTERSPI
        otir
    ELSE
.again:
        SPIWAIT
        ld a,(hl)
        out (CH_DATA_PORT), a
        inc hl
        djnz .again
    ENDIF
    ENDM

    MACRO CH_RECEIVE_DATA
    IFNDEF __MISTERSPI
        in a,(CH_DATA_PORT)
    ELSE
        SPIWAIT
        xor a
        out (CH_DATA_PORT), a
        SPIWAIT
        in a,(CH_DATA_PORT)
    ENDIF
    ENDM

    MACRO CH_RECEIVE_DATA_MULTIPLE
    IFNDEF __MISTERSPI
        inir
    ELSE
.again:
        CH_RECEIVE_DATA
        ld (hl),a
        inc hl
        djnz .again        
    ENDIF
    ENDM

; --------------------------------------
; CH_RESET
;
; Input: none
; Output: none
CH_RESET:
    ld a, CH_CMD_RESET_ALL
    CH_SEND_COMMAND   
    CH_END_COMMAND 
    ret

; --------------------------------------
; CH_IC_VERSION
;
; Input: none
; Output: A - version of CH376s IC/firmware
CH_IC_VERSION
    ; check IC version
    ld a, CH_CMD_GET_IC_VER
    CH_SEND_COMMAND
    CH_RECEIVE_DATA
    CH_END_COMMAND
    and 1fh
    ret

; --------------------------------------
; CH_SET_SD0_INT
;
; Input: none
; Output: none
CH_SET_SD0_INT:
    ld a, CH_CMD_SET_SD0_INT
    CH_SEND_COMMAND  
    ld a, 0x16
    CH_SEND_DATA
    ld a, 0x90
    CH_SEND_DATA
    CH_END_COMMAND 
    ret

; --------------------------------------
; CH_TEST_CONNECT
;
; Input: none
; Output: A contains USB_INT_CONNECT, USB_INT_DISCONNECT, USB_INT_USB_READY
CH_TEST_CONNECT:
    ld a,CH_CMD_TEST_CONNECT
    CH_SEND_COMMAND
_CH_WAIT_TEST_CONNECT:
    CH_RECEIVE_DATA
    or a
    jr z,_CH_WAIT_TEST_CONNECT
    CH_END_COMMAND
    ret 
    
; --------------------------------------
; CH_CHECK_INT_IS_ACTIVE
;
; Check the status of the INT pin of the CH376
; Input: none
; Output: Z if active, NZ if not active

CH_CHECK_INT_IS_ACTIVE:
    CH_RECEIVE_STATUS
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
    CH_SEND_COMMAND
    ld a,b
    xor 0FFh
    CH_SEND_DATA
    CH_RECEIVE_DATA
    cp b
    CH_END_COMMAND
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
    CH_SEND_COMMAND
    ld a,b
    CH_SEND_DATA

    ld b,255
_CH_WAIT_USB_MODE:
    CH_RECEIVE_DATA
    cp CH_ST_RET_SUCCESS
    jp z,CH_SET_USB_MODE_DONE
    djnz _CH_WAIT_USB_MODE ; TODO: indefinately?
    CH_END_COMMAND
    scf
    ret
CH_SET_USB_MODE_DONE:
    CH_END_COMMAND
    ret

; -----------------------------------------------------------------------------
; HW_CONFIGURE_NAK_RETRY
; -----------------------------------------------------------------------------
; Input: Cy = 0 to retry for a limited time when the device returns NAK
;               (this is the default)
;             1 to retry indefinitely (or for a long time) 
;               when the device returns NAK 

HW_CONFIGURE_NAK_RETRY:
    ld a,08Fh
    jr nc,HW_CONFIGURE_NAK_RETRY_2
    ld a,0FFh
HW_CONFIGURE_NAK_RETRY_2:
    push af
    ld a,CH_CMD_SET_RETRY
    CH_SEND_COMMAND
    ld a,25h    ;Fixed value, required by CH376
    CH_SEND_DATA
    ;Bits 7 and 6:
    ;  0x: Don't retry NAKs
    ;  10: Retry NAKs indefinitely (default)
    ;  11: Retry NAKs for 3s
    ;Bits 5-0: Number of retries after device timeout
    ;Default after reset and SET_USB_MODE is 8Fh
    pop af
    CH_SEND_DATA
    CH_END_COMMAND
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
    CH_SEND_COMMAND
    ld a,b  
    CH_SEND_DATA
    or a
    ret z
    ld c,CH_DATA_PORT
    CH_SEND_DATA_MULTIPLE
    CH_END_COMMAND
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
    CH_SEND_COMMAND
    CH_RECEIVE_DATA
    and a ; not zero?
    jr nz, .CH_READ_DATA_MORE
    CH_END_COMMAND
    ld c, 0
    ret ;No data to transfer at all
.CH_READ_DATA_MORE:
    ; read data to (HL)
    push af
    ld b,a ; set counter nr bytes to read, first byte
    ld c,CH_DATA_PORT
    CH_RECEIVE_DATA_MULTIPLE
    ; prepare to return
    pop af
    ld c,a
    CH_END_COMMAND
    ret

; --------------------------------------
; CH_WAIT_INT_AND_GET_RESULT
;
; Wait for INT to get active, execute GET_STATUS, 
; and return the matching USB error code
;
; Output: A = Result of GET_STATUS (an USB error code)
CH_WAIT_INT_AND_GET_RESULT:
    ;push bc
    ;call PANIC_KEYS_PRESSED
    ;pop bc
    ;ld a,USB_ERR_PANIC_BUTTON_PRESSED
    ;ret z
    push bc
    ld b,255
.CHECK_AGAIN:
    call CH_CHECK_INT_IS_ACTIVE
    jr z, .CHECK_DONE
    djnz .CHECK_AGAIN    ;TODO: Perhaps add a timeout check here?
.CHECK_DONE:
    pop bc
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
    CH_SEND_COMMAND
    CH_RECEIVE_DATA
    CH_END_COMMAND
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

; Generic USB command variables
target_device_address EQU 0
configuration_id EQU 0
string_id EQU 0
config_descriptor_size EQU 9
alternate_setting EQU 0
packet_filter EQU 0
control_interface_id EQU 0
; USB HID command variables
report_id EQU 0
duration EQU 0x80
interface_id EQU 0
protocol_id EQU 0
; USB HUB command variables
hub_descriptor_size EQU 0
feature_selector EQU 0
port EQU 0
value EQU 0
; USB Storage command variables
storage_interface_id EQU 0

; Generic USB commands
USB_DESCRIPTORS_START:
;
CMD_GET_DEVICE_DESCRIPTOR: DB 0x80,6,0,1,0,0,18,0
CMD_SET_ADDRESS: DB 0x00,0x05,target_device_address,0,0,0,0,0
CMD_SET_CONFIGURATION: DB 0x00,0x09,configuration_id,0,0,0,0,0
CMD_GET_STRING: DB 0x80,6,string_id,3,0,0,255,0
CMD_GET_CONFIG_DESCRIPTOR: DB 0x80,6,configuration_id,2,0,0,config_descriptor_size,0
CMD_SET_INTERFACE: DB 0x01,11,alternate_setting,0,interface_id,0,0,0
CMD_SET_PACKET_FILTER: DB 00100001b,0x43,packet_filter,0,control_interface_id,0,0,0
; USB HID commands
CMD_SET_IDLE: DB 0x21,0x0A,report_id,duration,interface_id,0,0,0
CMD_SET_PROTOCOL: DB 0x21,0x0B,protocol_id,0,interface_id,0,0,0
    ds 3*8,0 ; reserved
; USB HUB commands
CMD_GET_HUB_DESCRIPTOR: DB 10100000b,6,0,029h,0,0,hub_descriptor_size,0
CMD_SET_HUB_PORT_FEATURE: DB 00100011b,3,feature_selector,0,port,value,0,0
CMD_GET_HUB_PORT_STATUS: DB 10100011b,0,0,0,port,0,4,0
; USB STORAGE commands
CMD_GET_MAX_LUNS: DB 10100001b,11111110b,0,0,storage_interface_id,0,1,0
CMD_MASS_STORAGE_RESET: DB 00100001b,11111111b,0,0,storage_interface_id,0,0,0

USB_DESCRIPTORS_END:

; --------------------------------------
; CH_SET_TARGET_DEVICE_ADDRESS
;
; Set target USB device address for operation
;
; Input: A = Device address

CH_SET_TARGET_DEVICE_ADDRESS:
    push af
    ld a,CH_CMD_SET_USB_ADDR
    CH_SEND_COMMAND
    pop af
    CH_SEND_DATA
    CH_END_COMMAND
    ret

; --------------------------------------
; CH_ISSUE_TOKEN
;
; Send a token to the current target USB device
;
; Input: E = Endpoint number
;        B = PID, one of CH_PID_*
;        A = Toggle bit in bit 7 (for IN transfer)
;            Toggle bit in bit 6 (for OUT transfer)

CH_ISSUE_TOKEN:
    ld d,a
    ld a,CH_CMD_ISSUE_TKN_X
    CH_SEND_COMMAND
    ld a,d
    CH_SEND_DATA    ;Toggles
    ld a,e
    rla
    rla
    rla
    rla
    and 0F0h
    or b
    CH_SEND_DATA    ;Endpoint | PID
    CH_END_COMMAND
    ret

; -----------------------------------------------------------------------------
; HW_DATA_IN_TRANSFER: Perform a USB data IN transfer
; -----------------------------------------------------------------------------
; Input:  HL = Address of a buffer for the received data
;         BC = Data length
;         A  = Device address
;         D  = Maximum packet size for the endpoint
;         E  = Endpoint number
;         Cy = Current state of the toggle bit
; Output: A  = USB error code or success when all okay
;         BC = Amount of data actually received (only if no error)
;         Cy = New state of the toggle bit (even on error)

HW_DATA_IN_TRANSFER:
    call CH_SET_TARGET_DEVICE_ADDRESS

; This entry point is used when target device address is already set
CH_DATA_IN_TRANSFER:
    ld a,0  ;No XOR because that would damage flags
    rra     ;Toggle to bit 7 of A
    ld ix,0 ;IX = Received so far count
    push de
    pop iy  ;IY = EP max size + EP number

_CH_DATA_IN_LOOP:
    push af ;Toggle in bit 7
    push bc ;Remaining length

    ld e,iyl
    ld b,CH_PID_IN
    call CH_ISSUE_TOKEN

    call CH_WAIT_INT_AND_GET_RESULT
    cp CH_USB_INT_SUCCESS
    jr nz,_CH_DATA_IN_ERR   ;DONE if error

    call CH_READ_DATA
    ld b,0
    add ix,bc   ;Update received so far count
_CH_DATA_IN_NO_MORE_DATA:
    pop de
    pop af
    xor 80h     ;Update toggle
    push af
    push de

    ld a,c
    or a
    jr z,_CH_DATA_IN_DONE    ;DONE if no data received

    ex (sp),hl  ;Now HL = Remaining data length
    or a
    sbc hl,bc   ;Now HL = Updated remaning data length
    ld a,h
    or l
    ex (sp),hl  ;Remaining data length is back on the stack
    jr z,_CH_DATA_IN_DONE    ;DONE if no data remaining

    ld a,c
    cp iyh
    jr c,_CH_DATA_IN_DONE    ;DONE if transferred less than the EP size

    pop bc
    pop af  ;We need this to pass the next toggle to CH_ISSUE_TOKEN

    jr _CH_DATA_IN_LOOP

;Input: A=Error code (if ERR), in stack: remaining length, new toggle
_CH_DATA_IN_DONE:
    ld a, CH_USB_INT_SUCCESS
    jr _CH_DATA_IN_NEXT
_CH_DATA_IN_ERR:

_CH_DATA_IN_NEXT:
    ld d,a
    pop bc
    pop af
    rla ;Toggle back to Cy
    ld a,d
    push ix
    pop bc
    ret

; -----------------------------------------------------------------------------
; HW_DATA_OUT_TRANSFER: Perform a USB data OUT transfer
; -----------------------------------------------------------------------------
; Input:  HL = Address of a buffer for the data to be sent
;         BC = Data length
;         A  = Device address
;         D  = Maximum packet size for the endpoint
;         E  = Endpoint number
;         Cy = Current state of the toggle bit
; Output: A contains 00h when okay or CH376 error code
;         Cy = New state of the toggle bit (even on error)

HW_DATA_OUT_TRANSFER:
    call CH_SET_TARGET_DEVICE_ADDRESS

; This entry point is used when target device address is already set
CH_DATA_OUT_TRANSFER:
    push af
    ld a, b
    or c
    jr nz, CH_DATA_OUT_TRANSFER_CHECK_FINISHED
    pop af
    xor a
    ret
CH_DATA_OUT_TRANSFER_CHECK_FINISHED:   
    pop af

    ld a,0  ;No XOR because that would damage flags
    rra     ;Toggle to bit 6 of A
    rra
    push de
    pop iy  ;IY = EP size + EP number

_CH_DATA_OUT_LOOP:
    push af ;Toggle in bit 6
    push bc ;Remaining length

    ld a,b 
    or a
    ld a,iyh
    jr nz,_CH_DATA_OUT_DO
    ld a,c
    cp iyh
    jr c,_CH_DATA_OUT_DO
    ld a,iyh

_CH_DATA_OUT_DO:
    ;Here, A = Length of the next transfer: min(remaining length, EP size)

    ex (sp),hl
    ld e,a
    ld d,0
    or a
    sbc hl,de
    ex (sp),hl     ;Updated remaining data length to the stack

    ld b,a
    call CH_WRITE_DATA

    pop bc
    pop af  ;Retrieve toggle
    push af
    push bc

    ld e,iyl
    ld b,CH_PID_OUT
    call CH_ISSUE_TOKEN

    call CH_WAIT_INT_AND_GET_RESULT
    cp CH_USB_INT_SUCCESS
    jr nz,_CH_DATA_OUT_ERROR   ;DONE if error

    pop bc
    pop af
    xor 40h     ;Update toggle
    push af

    ld a,b
    or c
    jr z,_CH_DATA_OUT_DONE  ;DONE if no more data to transfer

    pop af  ;We need this to pass the next toggle to CH_ISSUE_TOKEN

    jr _CH_DATA_OUT_LOOP

;Input: A=Error code, in stack: remaining length, new toggle
_CH_DATA_OUT_ERROR:
    pop bc
_CH_DATA_OUT_DONE: 
    ld d,a
    pop af
    rla ;Toggle back to Cy
    rla
    ld a,d ; A contains zero when okay or CH376 error code
    ret

; -----------------------------------------------------------------------------
; HW_CONTROL_TRANSFER: Perform a USB control transfer on endpoint 0
;
; The size and direction of the transfer are taken from the contents
; of the setup packet.
; -----------------------------------------------------------------------------
; Input:  HL = Address of a 8 byte buffer with the setup packet
;         DE = Address of the input or output data buffer
;         A  = Device address
;         B  = Maximum packet size for endpoint 0
; Output: A  = USB error code
;         BC = Amount of data actually transferred (if IN transfer and no error)

HW_CONTROL_TRANSFER:
    call CH_SET_TARGET_DEVICE_ADDRESS

    push af
    push hl
    push bc
    push de

    ; SETUP STAGE
    ; -----------
    ld b,8
    call CH_WRITE_DATA  ;Write SETUP data packet    

    xor a    ;Toggle bit = 0
    ld e,0
    ld b,CH_PID_SETUP
    call CH_ISSUE_TOKEN

    call CH_WAIT_INT_AND_GET_RESULT
    cp CH_USB_INT_SUCCESS
    jp nz, _HW_CONTROL_TRANSFER_ERROR
 
    pop hl  ;HL = Data address (was DE)
    pop de  ;D  = Endpoint size (was B)
    pop ix  ;IX = Address of setup packet (was HL)    
    pop af  ;A  = Device address
    ld c,(ix+6)
    ld b,(ix+7) ;BC = Data length
    ld e,0      ;E  = Endpoint number
    scf         ;Use toggle = 1
    push af ; device address
    push de ; endpoint size in D
    push hl ; data address
    push ix ; packet address

    ; check if IN or OUT transaction
    bit 7,(ix)
    jr nz,_CH_CONTROL_DATA_IN_TRANSFER
    jr CH_CONTROL_DATA_OUT_TRANSFER

    ; DATA IN STAGE
    ; -------------
_CH_CONTROL_DATA_IN_TRANSFER:
    call CH_DATA_IN_TRANSFER
    cp CH_USB_INT_SUCCESS
    jr z,_CH_CONTROL_STATUS_TRANSFER
    jr _CH_CONTROL_HANDLE_ERROR
    
    ; DATA OUT STAGE
    ; -------------
CH_CONTROL_DATA_OUT_TRANSFER:
    call CH_DATA_OUT_TRANSFER
    ; check return code of OUT transfer
    and a
    jr z,_CH_CONTROL_STATUS_TRANSFER

_CH_CONTROL_HANDLE_ERROR:
    and 0x2f
    cp 0x2e ; STALL
    ; for now not handling other problems NAK, TIMEOUT, UNEXPECTED
    ; recover stack and quit with error code in A
    jp nz,_HW_CONTROL_TRANSFER_ERROR ;

    ; restore initial register
    pop hl ; packet address
    ; clear stall in or out endpoint 0
    ld a,CH_CMD_CLR_STALL
    CH_SEND_COMMAND
    ld bc, WAIT_ONE_SECOND/4
    call WAIT
    ld a,(hl)
    and 0x80
    CH_SEND_DATA
    CH_END_COMMAND
    call CH_WAIT_INT_AND_GET_RESULT
    cp CH_USB_INT_SUCCESS
    jr z, _RETRY_AGAIN
    ; not interested in preserving original values
    pop ix
    pop ix
    pop ix
    ld bc, 0
    ret
_RETRY_AGAIN:
    ; restore rest of initial registers and try again
    pop de ; data address
    pop bc ; endpoint packet size in B
    pop af ; device address in A
    jp HW_CONTROL_TRANSFER
_CH_CONTROL_STATUS_TRANSFER:
    pop hl ; packet address
    ; not interested in preserving other values
    pop ix
    pop ix
    pop ix
    ; STATUS STAGE
    ; -----------
    push bc ; preserve amount of bytes read/written
    ld e,0 ; endpoint 0
    ; check IN/OUT
    ld a, (hl)
    and 0x80
    jr z, _STATUS_OUT
    ld a, b
    or c
    jr z, _STATUS_OUT
_STATUS_IN:
    ld b,CH_PID_OUT
    ld a,40h
    jr _STATUS_NEXT
_STATUS_OUT:
    ld b,CH_PID_IN
    ld a,80h
_STATUS_NEXT:
    call CH_ISSUE_TOKEN
    call CH_WAIT_INT_AND_GET_RESULT
    ;cp CH_USB_INT_SUCCESS
    ;jr nz, _STATUS_NEXT_ERROR
    ld a, (hl)
    and 0x80
    jr nz, _STATUS_NEXT_IN
_STATUS_NEXT_OUT:
    ; do an empty read
    ld a,CH_CMD_RD_USB_DATA0
    CH_SEND_COMMAND
    CH_RECEIVE_DATA
    CH_END_COMMAND
    and a
    ; not empty?
    jr nz, _STATUS_NEXT_ERROR
_STATUS_NEXT_IN:
    pop bc
    ld a, CH_USB_INT_SUCCESS
    ret
_STATUS_NEXT_ERROR:
    pop bc
    ld a, CH_USB_INT_DISCONNECT
    ret
_HW_CONTROL_TRANSFER_ERROR:
    pop ix
    pop ix
    pop ix
    pop ix
    ret

; --------------------------------------
; CH_SET_SPEED
;
; Input: A=speed value
; Output: Cy=0 no error, Cy=1 error
CH_SET_SPEED:
    push bc
    ld b,a
    ld a,CH_CMD_SET_SPEED
    CH_SEND_COMMAND
    ld a,b
    CH_SEND_DATA
    CH_END_COMMAND
    or a; clear Cy
    pop bc
    ret