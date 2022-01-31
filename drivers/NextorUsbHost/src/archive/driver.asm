    ; CH376s disk driver for Nextor 2.1
    ; By S0urceror, 2/2020
    ;
    ; This code can be used as the basis for developing
    ; a real disk driver: just set DRV_TYPE appropriately,
    ; change the driver name and version at DRV_NAME and VER_*, and
    ; implement the required routines depending on the driver type.
    ;
    ; See the Nextor driver development guide for more details.

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
VER_MAIN	equ	1
VER_SEC		equ	0
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
	db	"USB Drive"
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
;
; * Get number of drives at boot time (for device-based drivers only):
;   Input:
;     A = 1
;     B = 0 for DOS 2 mode, 1 for DOS 1 mode
;     C: bit 5 set if user is requesting reduced drive count
;        (by pressing the 5 key)
;   Output:
;     B = number of drives
;
; * Get default configuration for drive
;   Input:
;     A = 2
;     B = 0 for DOS 2 mode, 1 for DOS 1 mode
;     C = Relative drive number at boot time
;   Output:
;     B = Device index
;     C = LUN index

DRV_CONFIG:
	dec a
	jr nz, _DEF_CONFIG ; A was 2
	; A was 1
	ld b, 1 ; number of drives requested, iregardless of DOS version
	ret
_DEF_CONFIG:
	xor a
	ld b, 1
	; LUN index = relative drive number at boot time + 1
	inc c
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

; DRV_INIT is structured as follows:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; check if ch376s is connected, reset ch376s
; reset usb bus, make us usb host
; read device descriptor, what is connected?
; 1 - nothing?
; 2 - storage device?
;     assign device id 1
;     use high-level driver in CH376s
; 3 - hub?
;     assign device id 1
;     how many ports?
;     init all ports
;     something connected?
;     assign device-id (2..nrports+1) and reset it's usb bus via hub
; 4 - something else?
;     assign device id 1
;     another MSXUSB UNAPI driver can do something with it
;     like MSXUSB Ethernet and Keyboard drivers

DRV_INIT:
	ld	hl,WRKAREA	; size of work area
	or	a			; Clear Cy, no interrupts needed
	ret	z			; first call

	; second call
	call	MY_GWORK
	call	INIWORK		; Initialize the work-area

	; initialize CH376s
	; ============================================
	; print welcome message
    ld hl, TXT_START
    call PRINT

	; enable the low-level MSXUSB driver
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	call USBHOST_INIT

	; check if CH376s in the cartridge slot
    call CH_HW_TEST
    jr nc, _HW_TEST_OKAY
    ld hl, TXT_NOT_FOUND
    call PRINT
    and a
    ret
_HW_TEST_OKAY:
	ld (ix+WRKAREA.STATUS),00000001b
   	ld hl, TXT_FOUND
    call PRINT

	; initialise CH376s
    call CH_RESET
    ld hl, TXT_RESET
    call PRINT
	ld bc, WAIT_ONE_SECOND/5
	call WAIT

	; reset bus and device
	call USB_HOST_BUS_RESET
	jp nc, _USB_MODE_OKAY
    ld hl, TXT_MODE_NOT_SET
    call PRINT
    ret
_USB_MODE_OKAY:
	ld (ix+WRKAREA.STATUS),00000011b
    ld hl, TXT_MODE_SET
    call PRINT

	; connect disk
    call CH_CONNECT_DISK
    jr nc, _CONNECT_DISK_OKAY
    ld hl, TXT_DISK_NOT_CONNECTED
    call PRINT
    ret
_CONNECT_DISK_OKAY:
	ld (ix+WRKAREA.STATUS),00000111b
    ld hl, TXT_DISK_CONNECTED
    call PRINT

	; mount USB drive
    call CH_MOUNT_DISK
    jr nc, _MOUNT_DISK_OKAY
    ld hl, TXT_DISK_NOT_MOUNTED
    call PRINT
    ret
_MOUNT_DISK_OKAY
	ld (ix+WRKAREA.STATUS),00001111b
    ld hl, TXT_DISK_MOUNTED
    call PRINT

	; after mounting information about make and model should be able to read
	ld bc, WRKAREA.DEVICE_INFO
	call WRKAREAPTR
	ld hl,ix
    call CH_READ_DATA
    ld a, c
    or a
    jr nz, _READ_BUFFER_OKAY; we got data
    ld hl, TXT_NO_MAKE_MODEL
    call PRINT
    jr _NEXT
_READ_BUFFER_OKAY:
    ld hl, TXT_MAKE_MODEL
    call PRINT
	ld bc, WRKAREA.DEVICE_INFO.PRODUCTID
	call WRKAREAPTR
	ld hl,ix
    call PRINT
    ld hl, TXT_NEWLINE
    call PRINT
_NEXT
	; try to load autoexec.txt
	ld hl, TXT_AUTOEXEC_TXT
	call CH_SET_FILE_NAME
	call CH_FILE_OPEN
	jr nc, _FILE_OPEN_OKAY1
	; No? Try to load nextor.dsk
	ld hl, TXT_NEXTOR_DSK
	jr _OPEN_DSK
_FILE_OPEN_OKAY1:
	; read first line of text in autoexec.txt => HL
	ld bc, WRKAREA.IO_BUFFER
	call WRKAREAPTR
	ld hl,ix
	call CH_FILE_READ
	ld hl,ix
	; terminate first \n to zero
_NEWLINE_START:
	ld a, (hl)
	cp "\n"
	jr nz, _NEWLINE_NEXT
	xor a
	ld (hl), a
_NEWLINE_NEXT:
	or a
	inc hl
	jr nz, _NEWLINE_START
	;
	xor a
	call CH_FILE_CLOSE
	;
	ld hl,ix
_OPEN_DSK
    ld bc, 12
	call MY_GWORK
    call _STORE_DISK_NAME
	call CH_SET_FILE_NAME
    call CH_FILE_OPEN    
    jr nc, _FILE_OPEN_OKAY2
    ld hl, TXT_FILEOPEN_FAILED
    call PRINT
    ret
	
_FILE_OPEN_OKAY2:
	call MY_GWORK
	ld (ix+WRKAREA.STATUS),00111111b
    ld hl, TXT_FILEOPEN_OKAY
    call PRINT
	; print opened file
	ld hl, ix
	ld bc, WRKAREA.DSK_NAME
	add hl,bc
	call PRINT
	ld hl, TXT_NEWLINE
	call PRINT

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
	jp INIT_CALLS

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
	jr nc, _DEV_R_NEXT
	ld iyl,1 ; 1 denotes Write
	jr _DEV_RW_NEXT_1
_DEV_R_NEXT:
	ld iyl,0 ; 0 denotes Read
_DEV_RW_NEXT_1:
	cp 1 ; device 1 only
	jr z, _DEV_RW_NEXT_2
	ld a, _IDEVL
	ld b, 0
	ret
_DEV_RW_NEXT_2:
	ld a, c
	cp 1 ; lun 1 only
	jr z, _DEV_RW_NEXT_4
	ld a, _IDEVL
	ld b, 0
	ret
_DEV_RW_NEXT_4:
	call CH_SEC_LOCATE
    jr nc, _DEV_RW_NEXT_5
	ld a, _NRDY
	ld b, 0
	ret
_DEV_RW_NEXT_5:
	push bc
	ld bc, WRKAREA.IO_BUFFER
	call WRKAREAPTR
	pop bc
	ld a,iyl
	or a
	ld a, b ; request B sectors to read or write
	push af ; retain flags
   	call z, CH_SEC_READ ; when successful (ix) contains a 4 byte sector allowed count plus a 4 byte disk LBA
	pop af
	call nz, CH_SEC_WRITE ; when succesful (ix) contains a 4 byte sector allowed count plus a 4 byte disk LBA
    jr nc, _DEV_RW_NEXT_6
    ld a, _RNF
	ld b, 0
	ret
_DEV_RW_NEXT_6:
	ld a,iyl
	or a
	push hl
	; (ix) should contain a 4 byte sector allowed count plus a 4 byte LBA
    push af ; retain flags
   	call z, CH_DISK_READ; (hl) read buffer
	pop af
	call nz, CH_DISK_WRITE; (hl) write buffer
	pop hl
    jr nc, _DEV_RW_NEXT_7
	ld a, _DATA
	ld b, 0
	ret
_DEV_RW_NEXT_7:
	xor a ; success
	ld	b, 1 ; nr of sectors read/write
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
;+0 (1): Numer of logical units, from 1 to 7. 1 if the device has no logical
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
	cp 1 ; only device 1
	jr nz, _DEV_INFO_NOT_INSERTED
	
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
	ld bc, WRKAREA.DEVICE_INFO.VENDORID
	call WRKAREAPTR

	ld hl,ix
	ld bc, 8
	ldir
	xor a
	ret

_DEV_INFO_DEVICE_NAME:
	ld de, hl
	ld bc, WRKAREA.DEVICE_INFO.PRODUCTID
	call WRKAREAPTR

	ld hl,ix
	ld bc, 16
	ldir
	xor a
	ret

_DEV_INFO_SERIAL:
	ld a,2 ; information not available
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
	cp 1
	jr nz, _DEV_STATUS_NO_EXIST
	ld a, b
	cp 1
	jr nz, _DEV_STATUS_NO_EXIST

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

_DEV_STATUS_NO_EXIST:
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
	cp 1
	jr nz, _LUN_INFO_NO_EXIST
	ld a, b
	cp 1
	jr nz, _LUN_INFO_NO_EXIST

	;;;;;;; 128MB diskimages
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
	ld (hl),04h
	inc hl
	ld (hl),00h ; 262144 sectors * 512 bytes = 134.217.728 bytes
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

_LUN_INFO_NO_EXIST:
	ld	a,1
	ret

	;;;;;;; 720KB diskimages
	; device 1, lun 1
	; TODO: read actual boot sector of DSK file
	;ld (hl),0 ; block device
	;inc hl
	;ld (hl),00h
	;inc hl
	;ld (hl),02h ; 512 byte sector
	;inc hl
	;ld (hl),0a0h
	;inc hl
	;ld (hl),05h
	;inc hl
	;ld (hl),00h
	;inc hl
	;ld (hl),00h ; 1440 sectors
	;inc hl
	;;ld (hl),00000001b ; removable + non-read only + no floppy
	;inc hl
	;ld (hl), 80
	;inc hl
	;ld (hl), 0 ; cylinders/tracks
	;inc hl
	;ld (hl), 1 ; heads
	;inc hl
	;ld (hl), 9 ; sectors per track

;=====
;=====  END of DEVICE-BASED specific routines
;=====

;-----------------------------------------------------------------------------
;
; End of the driver code

	include "driver_helpers.asm"
	include "print_bios.asm"
	include "basic_extensions.asm"
	include "ch376s.asm"
	include "usbhost.asm"
	include "nextordirect.asm"
;	include "ramhelper.asm"
	
DRV_END:

	ds	3ED0h-(DRV_END-DRV_START)

	end

