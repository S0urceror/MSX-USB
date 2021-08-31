;
; driver.ASM - UNAPI compliant MSX USB driver
; Copyright (c) 2020 Mario Smit (S0urceror)
; Based on work of Néstor Soriano (Konamiman)
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

	org	4000h
	ds	4100h-$,0		; DRV_START must be at 4100h

DRV_START:

;-----------------------------------------------------------------------------
;
; Miscellaneous constants
;

;This is a 2 byte buffer to store the address of code to be executed.
;It is used by some of the kernel page 0 routines.
CODE_ADD:	equ	0F1D0h


;-----------------------------------------------------------------------------
;
; Driver configuration constants
;

;Driver version
VER_MAIN	equ	0
VER_SEC		equ	6
VER_REV		equ	0

;-----------------------------------------------------------------------------
;
; Error codes for DEV_RW
;
_NCOMP	equ	0FFh
_WRERR	equ	0FEh
_DISK	equ	0FDh
_NRDY	equ	0FCh
_DATA	equ	0FAh
_RNF	equ	0F9h
_WPROT	equ	0F8h
_UFORM	equ	0F7h
_SEEK	equ	0F3h
_IFORM	equ	0F0h
_IDEVL	equ	0B5h
_IPARM	equ	08Bh

;-----------------------------------------------------------------------------
;
; Routines and information available on kernel page 0
;

;* Get in A the current slot for page 1. Corrupts F.
;  Must be called by using CALBNK to bank 0:
;    xor a
;    ld ix,GSLOT1
;    call CALBNK
GSLOT1	equ	402Dh


;* This routine reads a byte from another bank.
;  Must be called by using CALBNK to the desired bank,
;  passing the address to be read in HL:
;    ld a,<bank number>
;    ld hl,<byte address>
;    ld ix,RDBANK
;    call CALBNK
RDBANK	equ	403Ch


;* This routine temporarily switches kernel main bank
;  (usually bank 0, but will be 3 when running in MSX-DOS 1 mode),
;  then invokes the routine whose address is at (CODE_ADD).
;  It is necessary to use this routine to invoke CALBAS
;  (so that kernel bank is correct in case of BASIC error)
;  and to invoke DOS functions via F37Dh hook.
;
;  Input:  Address of code to invoke in (CODE_ADD).
;          AF, BC, DE, HL, IX, IY passed to the called routine.
;  Output: AF, BC, DE, HL, IX, IY returned from the called routine.
CALLB0	equ	403Fh


;* Call a routine in another bank.
;  Must be used if the driver spawns across more than one bank.
;
;  Input:  A = bank number
;          IX = routine address
;          AF' = AF for the routine
;          HL' = Ix for the routine
;          BC, DE, HL, IY = input for the routine
;  Output: AF, BC, DE, HL, IX, IY returned from the called routine.
CALBNK	equ	4042h

;* Get in IX the address of the SLTWRK entry for the slot passed in A,
;  which will in turn contain a pointer to the allocated page 3
;  work area for that slot (0 if no work area was allocated).
;  If A=0, then it uses the slot currently switched in page 1.
;  Returns A=current slot for page 1, if A=0 was passed.
;  Corrupts F.
;  Must be called by using CALBNK to bank 0:
;    ld a,<slot number> (xor a for current page 1 slot)
;    ex af,af'
;    xor a
;    ld ix,GWORK
;    call CALBNK
GWORK	equ	4045h


;* This address contains one byte that tells how many banks
;  form the Nextor kernel (or alternatively, the first bank
;  number of the driver).
K_SIZE	equ	40FEh


;* This address contains one byte with the current bank number.
CUR_BANK	equ	40FFh

;-----------------------------------------------------------------------------
;
; Built-in format choice strings
;
NULL_MSG  equ     781Fh	;Null string (disk can't be formatted)
SING_DBL  equ     7820h ;"1-Single side / 2-Double side"


;-----------------------------------------------------------------------------
;
; Driver signature
;
	db	"NEXTOR_DRIVER",0


;-----------------------------------------------------------------------------
;
; Driver flags:
;    bit 0: 0 for drive-based, 1 for device-based
;    bit 2: 1 if the driver implements the DRV_CONFIG routine
;             (used by Nextor from v2.0.5)

	db	00000101b

;-----------------------------------------------------------------------------
;
; Reserved byte
;
	db	0


;-----------------------------------------------------------------------------
;
; Driver name
;
DRV_NAME:
	db	"MSXUSB Driver"
	ds	32-($-DRV_NAME)," "


;-----------------------------------------------------------------------------
;
; Jump table for the driver public routines
;

	; These routines are mandatory for all drivers
        ; (but probably you need to implement only DRV_INIT)
	jp	DRV_TIMI
	jp	DRV_VERSION
	jp	DRV_INIT
	jp	DRV_BASSTAT
	jp	DRV_BASDEV
    jp  DO_EXTBIO 	;DRV_EXTBIO
    jp  UNAPI_ENTRY ;DRV_DIRECT0
    jp  DRV_DIRECT1
    jp  DRV_DIRECT2
    jp  DRV_DIRECT3
    jp  DRV_DIRECT4
	jp	DRV_CONFIG
	ds	12

	; These routines are mandatory for device-based drivers
	jp	DEV_RW
	jp	DEV_INFO
	jp	DEV_STATUS
	jp	LUN_INFO

;=====
;=====  END of data that must be at fixed addresses
;=====

;-----------------------------------------------------------------------------
;
; Timer interrupt routine, it will be called on each timer interrupt
; (at 50 or 60Hz), but only if DRV_INIT returns Cy=1 on its first execution.

DRV_TIMI:
	ret

;-----------------------------------------------------------------------------
;
; Driver initialization routine, it is called twice:
;
; 1) First execution, for information gathering.
;    Input:
;      A = 0
;      B = number of available drives
;      HL = maximum size of allocatable work area in page 3
;      C: bit 5 set if user is requesting reduced drive count
;         (by pressing the 5 key)
;    Output:
;      A = number of required drives (for drive-based driver only)
;      HL = size of required work area in page 3
;      Cy = 1 if DRV_TIMI must be hooked to the timer interrupt, 0 otherwise
;
; 2) Second execution, for work area and hardware initialization.
;    Input:
;      A = 1
;      B = number of allocated drives for this controller
;      C: bit 5 set if user is requesting reduced drive count
;         (by pressing the 5 key)
;
;    The work area address can be obtained by using GWORK.
;
;    If first execution requests more work area than available,
;    second execution will not be done and DRV_TIMI will not be hooked
;    to the timer interrupt.
;
;    If first execution requests more drives than available,
;    as many drives as possible will be allocated, and the initialization
;    procedure will continue the normal way
;    (for drive-based drivers only. Device-based drivers always
;     get two allocated drives.)

DRV_INIT:
	ld	hl,WRKAREA	; size of work area
	or	a			; Clear Cy, no interrupts needed
	ret	z			; first call

	; second call
	call	MY_GWORK
	call	INIWORK		; Initialize the work-area

	IFDEF __MISTERSPI
	; DEBUG
	ld a, 1
	out 2fh, a
	; DEBUG
	ENDIF

	; initialize CH376s
	; ============================================
	; print welcome message
    ld hl, TXT_START
    call PRINT

	; enable the low-level MSXUSB driver
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	call USBHOST_INIT

	; enable the flash rom driver
	call FLASH_INIT

	; reset CH376s
    call CH_RESET
	; wait ~250ms
	ld bc, WAIT_ONE_SECOND/4
	call WAIT
	
	IFDEF __MISTERSPI	
	; make MISO the INT line
	call CH_SET_SD0_INT
	ENDIF

	; check if CH376s in the cartridge slot
    call CH_HW_TEST
    jr nc, _HW_TEST_OKAY
    ld hl, TXT_NOT_FOUND
    call PRINT
    ret

_HW_TEST_OKAY:
	ld a,(ix+WRKAREA.STATUS)
    set 0,a
    ld (ix+WRKAREA.STATUS),a
   	ld hl, TXT_FOUND
    call PRINT

	; check and display CH376s IC/firmware version
	ld hl, TXT_IC_VERSION
	call PRINT
	call CH_IC_VERSION
	add a, '0'
	call CHPUT
	ld hl, TXT_NEWLINE
	call PRINT

	; reset USB bus and device
    call USB_HOST_BUS_RESET

	; enumerate and initialise USB devices
	push ix
	call FN_CONNECT
	pop ix
	or a
	jp nz, _USB_MODE_OKAY
    ld hl, TXT_DEVICE_CHECK_NOK
    call PRINT
    ret
_USB_MODE_OKAY:
	push af
	ld a, "+"
	call CHPUT
	pop af
	push af
	add 0x30
	call CHPUT
	pop af
	ld a,(ix+WRKAREA.STATUS)
    set 1,a
    ld (ix+WRKAREA.STATUS),a
    ld hl, TXT_DEVICE_CHECK_OK
    call PRINT
	ld a, (ix+WRKAREA.STORAGE_DEVICE_INFO.DEVICE_ADDRESS)
	and a
	jr nz, _FOUND_
    ld hl, TXT_STORAGE_CHECK_NOK
    call PRINT
    ret
_FOUND_:
	ld hl, TXT_STORAGE_CHECK_OK
    call PRINT
	; start communicating with SCSI device
	call SCSI_MAX_LUNS
	ret c
	call SCSI_INIT
	call SCSI_INQUIRY
	jr nc, _INQUIRY_OKAY
	ld hl, TXT_INQUIRY_NOK
	call PRINT
	ret
_INQUIRY_OKAY:
	push ix
	;
	ld hl, TXT_INQUIRY_OK
	call PRINT
	ld bc, WRKAREA.SCSI_DEVICE_INFO.VENDORID
	call WRKAREAPTR
	ld hl, ix
	call PRINT
	ld hl, TXT_INQUIRY_OK
	call PRINT
	ld bc, WRKAREA.SCSI_DEVICE_INFO.PRODUCTID
	call WRKAREAPTR
	ld hl, ix
	call PRINT
	;
	pop ix
	ld a,(ix+WRKAREA.STATUS)
    set 2,a
    ld (ix+WRKAREA.STATUS),a

	ld hl, TXT_TEST_START
	call PRINT
_SCSI_TEST_AGAIN:
	call SCSI_TEST
	jr nc, _SCSI_TEST_OKAY
	call SCSI_REQUEST_SENSE
	jr _SCSI_TEST_AGAIN
_SCSI_TEST_OKAY:
	ld hl, TXT_TEST_OK
	call PRINT
	; return status disk present but changed
	ld a,(ix+WRKAREA.STATUS)
    set 3,a
	set 4,a
	set 5,a
    ld (ix+WRKAREA.STATUS),a
	ret
;-----------------------------------------------------------------------------
;
; Obtain the work area address for the driver or the device
; Input: (none)
; Output: IX=Pointer to the selected work area

MY_GWORK:
	push	af
	xor	a
	EX	AF,AF'
	XOR	A
	LD	IX,GWORK
	call CALBNK
	pop	af
	push de
	ld	e,(ix)			; de=Pointer to the WorkAREA in RAM 
	ld	d,(ix+1)
	ld	ix, de
	pop	de
	ret

;-----------------------------------------------------------------------------
;
; Obtain the work area address for the driver or the device
; Input: BC = delta in WKRAREA
; Output: IX=Pointer to the selected work area

WRKAREAPTR:
	call MY_GWORK
	add ix, bc
	ret


; ------------------------------------------------
; Initialize the Work-area
; ------------------------------------------------
INIWORK:
	; Clear the WorkArea
	ld hl, ix
	ld de, hl
	inc de
	ld bc,WRKAREA-1 ; size of wrkarea
	xor	a
	ld	(hl),a
	ldir

	; copy NXT_DIRECT to Work-area
	call NXT_DIRECT_WRKAREA
	ret
	
;-----------------------------------------------------------------------------
;
; Get driver configuration 
; (bit 2 of driver flags must be set if this routine is implemented)
;
; Input:
;   A = Configuration index
;   BC, DE, HL = Depends on the configuration
;
; Output:
;   A = 0: Ok
;       1: Configuration not available for the supplied index
;   BC, DE, HL = Depends on the configuration
DRV_CONFIG:
	call MY_GWORK
	dec a
	jr nz, _DEFAULT_CONFIG
; * Get number of drives at boot time (for device-based drivers only):
;   Input:
;     A = 1
;     B = 0 for DOS 2 mode, 1 for DOS 1 mode
;     C: bit 5 set if user is requesting reduced drive count
;        (by pressing the 5 key)
;   Output:
;     B = number of drives
_NR_DRIVES_AT_BOOT_TIME:
	ld a,(ix+WRKAREA.STATUS)
	ld b, 0
	bit 7,a ; ROMDRIVE
	jr z, _CHECK_USB
	inc b
_CHECK_USB:
	bit 3,a ; USB DRIVE INITIALIZED
	jr z, _CHECK_COMPLETE
	inc b
_CHECK_COMPLETE:
	xor a
	ret

; * Get default configuration for drive
;   Input:
;     A = 2
;     B = 0 for DOS 2 mode, 1 for DOS 1 mode
;     C = Relative drive number at boot time
;   Output:
;     B = Device index
;     C = LUN index
_DEFAULT_CONFIG:
	ld b, c
	inc b
	ld c, 1
	xor a
	ret

;-----------------------------------------------------------------------------
;
; Obtain driver version
;
; Input:  -
; Output: A = Main version number
;         B = Secondary version number
;         C = Revision number

DRV_VERSION:
	ld	a,VER_MAIN
	ld	b,VER_SEC
	ld	c,VER_REV
	ret


;-----------------------------------------------------------------------------
;
; BASIC expanded statement ("CALL") handler.
; Works the expected way, except that if invoking CALBAS is needed,
; it must be done via the CALLB0 routine in kernel page 0.

DRV_BASSTAT:
	scf
	ret

;-----------------------------------------------------------------------------
;
; BASIC expanded device handler.
; Works the expected way, except that if invoking CALBAS is needed,
; it must be done via the CALLB0 routine in kernel page 0.

DRV_BASDEV:
	scf
	ret


;-----------------------------------------------------------------------------
;
; Extended BIOS hook.
; Works the expected way, except that it must return
; D'=1 if the old hook must be called, D'=0 otherwise.
; It is entered with D'=1.

DRV_EXTBIO:
	ret


;-----------------------------------------------------------------------------
;
; Direct calls entry points.
; Calls to addresses 7850h, 7853h, 7856h, 7859h and 785Ch
; in kernel banks 0 and 3 will be redirected
; to DIRECT0/1/2/3/4 respectively.
; Receives all register data from the caller except IX and AF'.

;DRV_DIRECT0:
DRV_DIRECT1:
DRV_DIRECT2:
DRV_DIRECT3:
DRV_DIRECT4:
	ret

;=====
;=====  BEGIN of DEVICE-BASED specific routines
;=====

;-----------------------------------------------------------------------------
;
; Read or write logical sectors from/to a logical unit
;
;Input:    Cy=0 to read, 1 to write
;          A = Device number, 1 to 7
;          B = Number of sectors to read or write
;          C = Logical unit number, 1 to 7
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
DEV_RW:
	push af ; preserve A + flags
	ld a, c
	cp 1 ; lun 1 only
	jr z, _DEV_RW_CHECK_DRIVE
	ld a, _IDEVL
	ld b, 0
	pop af
	ret

_DEV_RW_CHECK_DRIVE:
	pop af ; restore A
	push af ; preserve flags
	cp 1 ; drive A:
	jr z, _DEV_RW_DRIVE_A
	cp 2 ; drive
	jr z, _DEV_RW_DRIVE_B
	;
	ld a, _IDEVL
	ld b, 0
	pop af
	ret

_DEV_RW_DRIVE_A:
	call MY_GWORK
	ld c,(ix+WRKAREA.STATUS)
	bit 7,c
	jp nz, DEV_RW_ROMDISK ; Drive A is ROM disk
	;jr DEV_RW_SCSI ; Drive A is USB Storage

_DEV_RW_DRIVE_B: ; Drive B is always USB storage
DEV_RW_SCSI:
	; CAPS ON
	in a, 0xaa
	res 6,a
	out 0xaa,a
	;
	pop af
	jr c, _DEV_WRITE
	call SCSI_READ
	jr c, _DEV_RW_ERR
	jr _DEV_RW_NEXT_4
_DEV_WRITE
	call SCSI_WRITE
	jr c, _DEV_RW_ERR
_DEV_RW_NEXT_4:
	; CAPS OFF
	in a, 0xaa
	set 6,a
	out 0xaa,a
	;
	xor a ; success
	ret
_DEV_RW_ERR
	; CAPS OFF
	in a, 0xaa
	set 6,a
	out 0xaa,a
	;
	ld a, _RNF
	ld b, 0
	ret


;-----------------------------------------------------------------------------
;
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
;         When basic information is requested,
;         buffer filled with the following information:
;
;+0 (1): Number of logical units, from 1 to 7. 1 if the device has no logical
;        units (which is functionally equivalent to having only one).
;+1 (1): Device flags, always zero in Beta 2.
;
; The strings must be printable ASCII string (ASCII codes 32 to 126),
; left justified and padded with spaces. All the strings are optional,
; if not available, an error must be returned.
; If a string is provided by the device in binary format, it must be reported
; as an hexadecimal, upper-cased string, preceded by the prefix "0x".
; The maximum length for a string is 64 characters;
; if the string is actually longer, the leftmost 64 characters
; should be provided.
;
; In the case of the serial number string, the same rules for the strings
; apply, except that it must be provided right-justified,
; and if it is too long, the rightmost characters must be
; provided, not the leftmost.

DEV_INFO:
	cp 1 ; drive A:
	jr z, _DEV_INFO_DRIVE_A
	cp 2 ; drive
	jr z, _DEV_INFO_DRIVE_B
	jr nz, _DEV_INFO_NOT_INSERTED
_DEV_INFO_DRIVE_A:
	call MY_GWORK
	ld a,(ix+WRKAREA.STATUS)
	bit 7,a
	jp nz, DEV_INFO_ROMDISK ; Drive A is ROM disk
	;jr DEV_INFO_SCSI ; Drive A is  USB storage
_DEV_INFO_DRIVE_B ; Drive B is always USB storage
DEV_INFO_SCSI:
	ld c, a
	ld a, b
	cp 0
	jr z,_DEV_INFO_BASIC
	cp 1
	jr z,_DEV_INFO_MANUFACTURER
	cp 2
	jr z,_DEV_INFO_DEVICE_NAME
	cp 3
	jr z,_DEV_INFO_SERIAL
	; else
	jr _DEV_INFO_NOT_INSERTED

_DEV_INFO_BASIC:
	ld (hl),1
	inc hl
	ld (hl),0
	xor a
	ret

_DEV_INFO_MANUFACTURER:
	ld de, hl
	ld bc, WRKAREA.SCSI_DEVICE_INFO.VENDORID
	call WRKAREAPTR
	ld hl,ix
	ld bc, 8
	ldir
	xor a
	ld (de),a
	ret

_DEV_INFO_DEVICE_NAME:
	ld de, hl
	ld bc, WRKAREA.SCSI_DEVICE_INFO.PRODUCTID
	call WRKAREAPTR
	ld hl,ix
	ld bc, 16
	ldir
	xor a
	ld (de),a
	ret

_DEV_INFO_SERIAL:
	ld de, hl
	ld bc, WRKAREA.SCSI_DEVICE_INFO.PRODUCTREV
	call WRKAREAPTR
	ld hl,ix
	ld bc, 4
	ldir
	xor a
	ld (de),a
	ret

_DEV_INFO_NOT_INSERTED:
	ld	a,1
	ret


;-----------------------------------------------------------------------------
;
; Obtain device status
;
;Input:   A = Device index, 1 to 7
;         B = Logical unit number, 1 to 7
;             0 to return the status of the device itself.
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
;
; Devices not supporting hot-plugging must always return status value 1.
; Non removable logical units may return values 0 and 1.
;
; The returned status is always relative to the previous invokation of
; DEV_STATUS itself. Please read the Driver Developer Guide for more info.

DEV_STATUS:
	; check LUN
	push af
	ld a, b
	cp 1
	jr nz, _DEV_STATUS_NO_EXIST
	pop af
	; check drive
	cp 1 ; drive A:
	jr z, _DEV_STATUS_DRIVE_A
	cp 2 ; drive
	jr z, _DEV_STATUS_DRIVE_B
	jr _DEV_STATUS_NO_EXIST2
_DEV_STATUS_NO_EXIST:
	pop af
_DEV_STATUS_NO_EXIST2:
	xor	a ; not available
	ret

_DEV_STATUS_DRIVE_A:
	call MY_GWORK
	ld a,(ix+WRKAREA.STATUS)
	bit 7,a
	jp nz, DEV_STATUS_ROMDISK ; Drive A is ROM disk
	;jr DEV_STATUS_SCSI ; Drive A is USB storage
DEV_STATUS_SCSI:
_DEV_STATUS_DRIVE_B: ; Drive B is always USB storage
	call	MY_GWORK
	; bit 0 = CH376s present, 
	; bit 1 = initialised, 
	; bit 2 = USB device present, 
	; bit 3 = USB device mounted,
	; bit 4 = virtual DSK inserted,
	; bit 5 = DSK changed
	ld a, (ix+WRKAREA.STATUS) 
	; DSK present?
	bit 4,a
	jr z, _DEV_STATUS_ERR
	; changed?
	bit 5,a
	jr z, _DEV_STATUS_NO_CHANGE
	res 5,a
	ld (ix+WRKAREA.STATUS),a
	ld a, 2 ; available, changed
	ret

_DEV_STATUS_NO_CHANGE:
	ld a, 1 ; available, no change
	ret

_DEV_STATUS_ERR:
	xor	a ; not available
	ret

;-----------------------------------------------------------------------------
;
; Obtain logical unit information
;
;Input:   A  = Device index, 1 to 7
;         B  = Logical unit number, 1 to 7
;         HL = Pointer to buffer in RAM.
;Output:  A = 0: Ok, buffer filled with information.
;             1: Error, device or logical unit not available,
;                or device index or logical unit number invalid.
;         On success, buffer filled with the following information:
;
;+0 (1): Medium type:
;        0: Block device
;        1: CD or DVD reader or recorder
;        2-254: Unused. Additional codes may be defined in the future.
;        255: Other
;+1 (2): Sector size, 0 if this information does not apply or is
;        not available.
;+3 (4): Total number of available sectors.
;        0 if this information does not apply or is not available.
;+7 (1): Flags:
;        bit 0: 1 if the medium is removable.
;        bit 1: 1 if the medium is read only. A medium that can dinamically
;               be write protected or write enabled is not considered
;               to be read-only.
;        bit 2: 1 if the LUN is a floppy disk drive.
;+8 (2): Number of cylinders
;+10 (1): Number of heads
;+11 (1): Number of sectors per track
;
; Number of cylinders, heads and sectors apply to hard disks only.
; For other types of device, these fields must be zero.

LUN_INFO:
	; check LUN
	push af
	ld a, b
	cp 1
	jr nz, _LUN_INFO_NO_EXIST
	pop af
	; check Drive
	cp 1 ; drive A:
	jr z, _LUN_INFO_DRIVE_A
	cp 2 ; drive
	jr z, _LUN_INFO_DRIVE_B
	jr _LUN_INFO_NO_EXIST2
_LUN_INFO_NO_EXIST:
	pop af
_LUN_INFO_NO_EXIST2:
	ld	a,1
	ret

_LUN_INFO_DRIVE_A:
	call MY_GWORK
	ld a,(ix+WRKAREA.STATUS)
	bit 7,a
	jp nz, LUN_INFO_ROMDISK ; Drive A is ROM disk
	;jr LUN_INFO_SCSI ; Drive A is USB storage
LUN_INFO_SCSI:
_LUN_INFO_DRIVE_B:
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
	ld (hl),00000001b ; removable + non-read only + no floppy
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


;=====
;=====  END of DEVICE-BASED specific routines
;=====

;-----------------------------------------------------------------------------
;
; End of the driver code

	include "flashdisk.asm"
	include "driver_helpers_low.asm"
	include "print_bios.asm"
	include "ch376s.asm"
	include "usbhost.asm"
	include "nextordirect.asm"
	include "scsi.asm"
	
DRV_END:

	ds	3ED0h-(DRV_END-DRV_START)

	end

