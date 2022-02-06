;----------------------------------------------------------
;		msxromcrt0.s - by S0urceror - 2022
;
;		Template for Nextor drivers for MSX 
;----------------------------------------------------------

	.globl _interrupt
	.globl _get_workarea_size,_init_driver
	.globl _get_nr_drives_boottime,_get_drive_config
	.globl _get_lun_info
	.globl _read_or_write_sector
	.globl _get_device_status
	.globl _get_device_info

; settings
GLOBALS_INITIALIZER = 0 	; we have global vars to initialize?
CALL_EXPANSION = 1			; we want to add BASIC calls
BIOS_PROCNM  .equ 0xfd89
;-----------------------------------------------------------------------------
;
; Driver configuration constants
;
;Driver version
	VER_MAIN	.equ	0
	VER_SEC		.equ	2
	VER_REV		.equ	0

.if GLOBALS_INITIALIZER
	.globl  l__INITIALIZER
    .globl  s__INITIALIZED
    .globl  s__INITIALIZER
.endif

;   ====================================
;   ========== HEADER SEGMENT ==========
;   ====================================
	.area	_HEADER (ABS)
  	.org	#0x4000
	.rept 	0x100
		.byte 0x00
	.endm
	
DRV_START:
;-----------------------------------------------------------------------------
;
; Driver signature
;
	.ascii	"NEXTOR_DRIVER"
	.db		#0

;-----------------------------------------------------------------------------
;
; Driver flags:
;    bit 0: 0 for drive-based, 1 for device-based
;    bit 2: 1 if the driver implements the DRV_CONFIG routine
;             (used by Nextor from v2.0.5)

	.db		#0b00000101

;-----------------------------------------------------------------------------
;
; Reserved byte
;
	.db		#0


;-----------------------------------------------------------------------------
;
; Driver name
;
DRV_NAME:
	.ascii	"MSXUSB Next Driver"
	.rept 32-(.-DRV_NAME)
		.byte " "
	.endm

;-----------------------------------------------------------------------------
;
; Jump table for the driver public routines
;

	; These routines are mandatory for all drivers
    ; (but probably you need to implement only DRV_INIT)
	jp	_interrupt
	jp	DRV_VERSION
	jp	DRV_INIT
.if CALL_EXPANSION
	jp	call_expansion	; BASIC's CALL instruction expansion routine
.else
	jp	DRV_BASSTAT				; BASIC's CALL instruction not expanded
.endif
	jp	DRV_BASDEV
    jp  DRV_EXTBIO
    jp  DRV_DIRECT0
    jp  DRV_DIRECT1
    jp  DRV_DIRECT2
    jp  DRV_DIRECT3
    jp  DRV_DIRECT4
	jp	DRV_CONFIG
	.ds	12

	; These routines are mandatory for device-based drivers
	jp	DEV_RW
	jp	DEV_INFO
	jp	DEV_STATUS
	jp	LUN_INFO

;=====
;=====  END of data that must be at fixed addresses
;=====

DRV_INIT:
    ;-----------------------------------------------------------------------------
    ;
    ; Driver initialization routine, it is called twice:
    ;

    ; first or second try?
    and a
	jr z, __init_1st
	jr nz, __init_2nd
__init_1st:
	push bc
    call _get_workarea_size
	pop bc
	xor a
	ret
__init_2nd:	
	push bc
    call _init_driver
	pop bc
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
	ld	a,#VER_MAIN
	ld	b,#VER_SEC
	ld	c,#VER_REV
	ret

DRV_CONFIG:
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
	cp #1
    jr z, __option1
	cp #2
	jr z, __option2
__option_unknown:	
	ld a, #1
	ret
__option1:
	push bc
	call _get_nr_drives_boottime
	pop bc
	ld b, l	; return C-language return value in L via B
	xor a 	; indicate success
	ret
__option2:
	push bc
    call _get_drive_config
	pop bc
	push hl
	pop bc  ; return C-language return value in HL via BC
	xor a 	; indicate success
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

DRV_DIRECT0:
DRV_DIRECT1:
DRV_DIRECT2:
DRV_DIRECT3:
DRV_DIRECT4:
	ret

;=====
;=====  BEGIN of DEVICE-BASED specific routines
;=====


DEV_RW:
	push hl
	push de
	push bc
	push af
	call _read_or_write_sector
	pop af
	pop bc
	pop af
	pop af
	ld a,l
	ret

DEV_INFO:
	push hl
	ld c, b
	ld b, a
	push bc
	call _get_device_info
	pop af
	pop af
	ld a, l
	ret

DEV_STATUS:
	ld c, b
	ld b, a
	push bc
	call _get_device_status
	pop af
	ld a, l
	ret



LUN_INFO:
	push hl
	ld c, b
	ld b, a
	push bc
	call _get_lun_info
	pop af
	pop af
	ld a, l
	ret

;=====
;=====  END of DEVICE-BASED specific routines
;=====

;----------------------------------------------------------
;	Step 1: Initialize heap pointer
init::
	ld		hl, #_HEAP_start
	ld		(#_heap_top), hl

;----------------------------------------------------------
;	Step 2: Initialize globals
    call    gsinit

;----------------------------------------------------------
;	Step 5: Run application
	; halt processor
	DI
	HALT

;----------------------------------------------------------
;	Segments order
;----------------------------------------------------------
	.area _CODE
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _INITIALIZER
	.area _ROMDATA
	.area _DATA
	.area _INITIALIZED
	.area _HEAP

;   ==================================
;   ========== HOME SEGMENT ==========
;   ==================================
	.area _HOME
.if CALL_EXPANSION
STR_COMPARE = 1
call_expansion:
	exx
	ld		hl, #callStatementIndex
	jr		callExpansionParseStmt

callExpansionStmtNotFound:
	pop hl

callExpansionParseStmt:	
;	get pointer to statement in table
	xor		a
	ld		e, (hl)
	inc		hl
	ld		d, (hl)
	cp		e
	jr nz,	callExpansionNotEndOfList
	cp		d
	jr nz,	callExpansionNotEndOfList
;	statement not found; end expansion
	exx
	scf
	ret

callExpansionNotEndOfList:
	inc		hl
	push	hl

;	get pointer to statement in CALL
	ld		hl, #BIOS_PROCNM
	call	compareString
	jr nz,	callExpansionStmtNotFound
;	statement found; execute and exit
	pop		hl
	inc		de
	push	de
	exx
	pop		de				; *handler
	push	hl				; parameters
	ld		hl, #callExpansionFinalize
	push	hl				; finalize
	ex		de, hl
	ld		e, (hl)
	inc		hl
	ld		d, (hl)
	push	de				; handler
	ret						; calls handler with return to finalize below
							; handler must return hl pointing to end of command (end of line or ":")
	
callExpansionFinalize:
; at this point, hl must be pointing to end of command (end of line or ":")
	pop		hl
	or		a				; resets CY flag
	ret
.endif

.if STR_COMPARE
compareString::
	ld		a, (hl)
	ld		b, a
	ld		a, (de)
	cp		b
	ret nz
	cp		#0
	ret z
	inc		hl
	inc		de
	jr		compareString
.endif

;   =====================================
;   ========== GSINIT SEGMENTS ==========
;   =====================================
	.area	_GSINIT
gsinit::
.if GLOBALS_INITIALIZER
    ld      bc,#l__INITIALIZER
    ld      a,b
    or      a,c
    jp	z,  gsinit_next
    ld	    de,#s__INITIALIZED
    ld      hl,#s__INITIALIZER
    ldir
.endif

	.area	_GSFINAL
gsinit_next:
    ret
	
;   ======================================
;   ========== ROM_DATA SEGMENT ==========
;   ======================================
	.area	_ROMDATA
.if CALL_EXPANSION
	callStatementIndex:
	.dw callStatement_MOUNTDSK
	.dw       #0
	.globl _onCallMOUNTDSK
	callStatement_MOUNTDSK::
	.ascii    'MOUNTDSK\0'
	.dw _onCallMOUNTDSK
.endif
	
;   ==================================
;   ========== DATA SEGMENT ==========
;   ==================================
	.area	_DATA

_heap_top::
	.blkw	1

;   ==================================
;   ========== HEAP SEGMENT ==========
;   ==================================
	.area	_HEAP
_HEAP_start::

