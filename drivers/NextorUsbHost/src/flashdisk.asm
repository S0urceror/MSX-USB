	IFDEF __ROOKIEDRIVE
BANK_SWITCH_ADDR equ 6000h
DISK_START_BANK equ 8
	ENDIF
	IFDEF __MISTERSPI
BANK_SWITCH_ADDR equ 6000h
BANK_SWITCH_ADDR2 equ 6800h
DISK_START_BANK equ 8
	ENDIF	
	IFDEF __MSXUSBCARTv1
BANK_SWITCH_ADDR equ 5000h
BANK_SWITCH_ADDR2 equ 7000h
DISK_START_BANK equ 8
	ENDIF

FLASH_INIT:
    push ix
    ; copy flash read code to WRKAREA
    ld hl, ix
    ld bc, WRKAREA.FLASH_READ
    add hl, bc
    push hl ; + points to FLASH_READ
    ex de, hl
    ld hl, FLASH_READ_START
    ld bc, FLASH_READ_END-FLASH_READ_START
    ldir
    ; check contents of flash sector 0
    ld de, 0c000h
    ld hl, 4000h
    ld bc, 2
    ld a, (CUR_BANK)
    ex af,af'
    ld a, DISK_START_BANK
    pop ix ; - points to FLASH_READ
    ld iy, _FLASH_INIT_NEXT
    push iy ; return address
    di
    jp (ix)
    ; update status in WRKAREA to indicate IF we have flash disk
_FLASH_INIT_NEXT:
    ei
	pop ix
	; starting with EBh FEh?
    ld a, (0c000h)
	cp 0EBh
	jr nz,_FLASH_INIT_NOK
    ld a, (0c001h)
	cp 0FEh
	jr nz,_FLASH_INIT_NOK
_FLASH_INIT_OK:
    ld a,(ix+WRKAREA.STATUS)
    set 7,a
    ld (ix+WRKAREA.STATUS),a
    ld hl, TXT_FLASHDISK_OK
    call PRINT
    ret
_FLASH_INIT_NOK:
    scf ; no flash disk at this place
    ret

FLASH_READ_START
; FLASH_READ - read a number of bytes from flash location
; Input: HL - source address
;        DE - destination address
;        BC - amount of bytes
;        A = bank number
;        A' = bank number to switch back to after done
FLASH_READ:
    IFNDEF __ROOKIEDRIVE
    rlca ; bank number multiplied times 2 to select right 8k segment
    ENDIF
    ld	(BANK_SWITCH_ADDR),a
    IFNDEF __ROOKIEDRIVE
    inc	a ; plus 1
	ld	(BANK_SWITCH_ADDR2),a
    ENDIF
	ldir
	ex af,af'
    IFNDEF __ROOKIEDRIVE
    rlca ; bank number multiplied times 2 to select right 8k segment
    ENDIF
	ld	(BANK_SWITCH_ADDR),a  
    IFNDEF __ROOKIEDRIVE
    inc	a ; plus 1
	ld	(BANK_SWITCH_ADDR2),a
    ENDIF
	ret
FLASH_READ_END:

;-----------------------------------------------------------------------------
;
; Read or write logical sectors from/to a logical unit
;
;Input:    Flags on stack: Cy=0 to read, 1 to write
;          B = Number of sectors to read or write
;          HL = Source or destination memory address for the transfer
;          DE = Address where the 4 byte sector number is stored.
;Output:   A = Error code (the same codes of MSX-DOS are used):
;              0: Ok
;              _IDEVL: Invalid device or LUN
;              _NRDY: Not ready
;              _DISK: General unknown disk error
;              _DATA: CRC error when reading
;              _RNF: Sector not found
;              _UFORM: Unformatted disk
;              _WPROT: Write protected media, or read-only logical unit
;              _WRERR: Write error
;              _NCOMP: Incompatible disk.
;              _SEEK: Seek error.
;         B = Number of sectors actually read (in case of error only)
DEV_RW_ROMDISK:
	pop af
	jr nc,_DEV_R_ROMDISK
	ld a, _WPROT ; not allowed to write to flash rom
	ld b, 0
	ret

_DEV_R_ROMDISK:
	; CAPS ON
	in a, 0xaa
	res 6,a
	out 0xaa,a
	;

	; calculate banknr and memory position based on (DE)
	ld ix, de
	ld e,(ix+0)
	ld d,(ix+1)
	push de
	; calculate banknr = sectornr / 32
	sra	d ;/2
	rr	e
	sra	d ;/4
	rr	e
	sra	d ;/8
	rr	e
	sra	d ;/16
	rr	e
	sra	d ;/32
	rr	e
	ld	a,e
	add	a, DISK_START_BANK
	ld  c,a
	; calculate memory location = ((sector MOD 32)*512)+#4000
	pop de
	ld	a,e
	and	%11111
	add	a,a
	add	a,0x40
	ld	d,a
	ld	e,0

	; DE points to source and HL points to destination => reverse
	ex de, hl

	; setup call to FLASH_READ
	push bc
	ld bc, WRKAREA.FLASH_READ
	call WRKAREAPTR
	pop bc

_DEV_R_ROMDISK_AGAIN:
	push bc
	ld a, (CUR_BANK)
    ex af,af'
	ld a, c
    ld bc, 512
	ld iy, _DEV_R_ROMDISK_NEXT
    push iy ; return address
	di
    jp (ix)
_DEV_R_ROMDISK_NEXT:
	ei
	pop bc
	bit	7,h	; need next bank ?
	jr	z,_DEV_R_ROMDISK_NEXT2
	ld	hl,#4000 ; YES
	inc	c
_DEV_R_ROMDISK_NEXT2:	
	djnz _DEV_R_ROMDISK_AGAIN
	
	; CAPS OFF
	in a, 0xaa
	set 6,a
	out 0xaa,a
	;
	xor a ; success
	ret

; Device information gathering
;
;Input:   A = Device index, 1 to 7
;         B = Information to return:
;             0: Basic information
;             1: Manufacturer name string
;             2: Device name string
;             3: Serial number string
;         HL = Pointer to a buffer in RAM
;Output:  A = Error code:
;             0: Ok
;             1: Device not available or invalid device index
;             2: Information not available, or invalid information index
DEV_INFO_ROMDISK:
	ld a, b
	cp 0
	jr z,_DEV_INFO_ROMDISK_BASIC
	cp 1
	jr z,_DEV_INFO_ROMDISK_MANUFACTURER
	cp 2
	jr z,_DEV_INFO_ROMDISK_DEVICE_NAME
	cp 3
	jr z,_DEV_INFO_ROMDISK_SERIAL
	; else
	ld a, 2
    ret

_DEV_INFO_ROMDISK_BASIC:
	ld (hl),1
	inc hl
	ld (hl),0
	xor a
	ret

_DEV_INFO_ROMDISK_MANUFACTURER:
	ld de, hl
	ld hl,RD_MANUFACTURER
	ld bc, 8
	ldir
	xor a
	ld (de),a
	ret

_DEV_INFO_ROMDISK_DEVICE_NAME:
	ld de, hl
    ld hl,RD_DEVICE_NAME
	ld bc, 16
	ldir
	xor a
	ld (de),a
	ret

_DEV_INFO_ROMDISK_SERIAL:
	ld de, hl
    ld hl,RD_SERIAL
	ld bc, 4
	ldir
	xor a
	ld (de),a
	ret

; Obtain device status
;
;Output:  A = Status for the specified logical unit,
;             or for the whole device if 0 was specified:
;                0: The device or logical unit is not available, or the
;                   device or logical unit number supplied is invalid.
;                1: The device or logical unit is available and has not
;                   changed since the last status request.
;                2: The device or logical unit is available and has changed
;                   since the last status request
;                   (for devices, the device has been unplugged and a
;                    different device has been plugged which has been
;                    assigned the same device index; for logical units,
;                    the media has been changed).
;                3: The device or logical unit is available, but it is not
;                   possible to determine whether it has been changed
;                   or not since the last status request.
DEV_STATUS_ROMDISK:
    ld a, 1
    ret

; Obtain logical unit information
;
;Input:   HL = Pointer to buffer in RAM.
;Output:  A = 0: Ok, buffer filled with information.
;             1: Error, device or logical unit not available,
;                or device index or logical unit number invalid.
LUN_INFO_ROMDISK:
    ; #0
	ld (hl),0 ; block device
	; #1
	inc hl
	ld (hl),00h
	inc hl
	ld (hl),02h ; 512 byte sector
	; #3
	inc hl
	ld (hl),00h
	inc hl
	ld (hl),00h
	inc hl
	ld (hl),00h
	inc hl
	ld (hl),00h
	; #7
	inc hl
	ld (hl),00000010b ; non-removable + read only + no floppy
	; #8
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), 0 ; cylinders/tracks
	; #10
	inc hl
	ld (hl), 0 ; heads
	; #11
	inc hl
	ld (hl), 0 ; sectors per track

	ld a, 0
	ret