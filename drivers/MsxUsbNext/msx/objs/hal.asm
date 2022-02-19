;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.1.0 #12072 (Mac OS X ppc)
;--------------------------------------------------------
	.module hal
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _msx_wait
	.globl _printf
	.globl _text_columns
	.globl _msx_version
	.globl _supports_80_column_mode
	.globl _hal_init
	.globl _hal_deinit
	.globl _delay_ms
	.globl _write_command
	.globl _write_data
	.globl _read_data
	.globl _read_status
	.globl _error
	.globl _putchar
	.globl _getchar
	.globl _pressed_ESC
	.globl _read_data_multiple
	.globl _write_data_multiple
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_msx_version	=	0x002d
_text_columns	=	0xf3ae
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;hal.c:10: bool supports_80_column_mode()
;	---------------------------------
; Function supports_80_column_mode
; ---------------------------------
_supports_80_column_mode::
;hal.c:12: return msx_version>=1;
	ld	a,(#_msx_version + 0)
	sub	a, #0x01
	ld	a, #0x00
	rla
	xor	a, #0x01
	ld	l, a
;hal.c:13: }
	ret
;hal.c:15: void hal_init ()
;	---------------------------------
; Function hal_init
; ---------------------------------
_hal_init::
;hal.c:17: text_columns = 40;
	ld	hl, #_text_columns
	ld	(hl), #0x28
;hal.c:19: if (supports_80_column_mode())
	call	_supports_80_column_mode
	bit	0, l
	jr	Z, 00102$
;hal.c:20: text_columns = 80;
	ld	iy, #_text_columns
	ld	0 (iy), #0x50
00102$:
;hal.c:28: __endasm;    
	ld	iy,(#0xfcc1 -1) ;BIOS slot in iyh
	push	ix
	ld	ix,#0x006c ;address of BIOS routine
	call	0x001c ;interslot call
	pop	ix
;hal.c:29: }
	ret
;hal.c:30: void hal_deinit ()
;	---------------------------------
; Function hal_deinit
; ---------------------------------
_hal_deinit::
;hal.c:33: }
	ret
;hal.c:37: void msx_wait (uint16_t times_jiffy)  __z88dk_fastcall __naked
;	---------------------------------
; Function msx_wait
; ---------------------------------
_msx_wait::
;hal.c:52: __endasm; 
	ei
;	Wait a determined number of interrupts
;	Input: BC = number of 1/framerate interrupts to wait
;	Output: (none)
	    WAIT:
	halt	; waits 1/50th or 1/60th of a second till next interrupt
	dec	hl
	ld	a,h
	or	l
	jr	nz, WAIT
	ret
;hal.c:53: }
;hal.c:55: void delay_ms (uint16_t milliseconds)
;	---------------------------------
; Function delay_ms
; ---------------------------------
_delay_ms::
;hal.c:57: msx_wait (milliseconds/20);
	pop	de
	pop	bc
	push	bc
	push	de
	ld	hl, #0x0014
	push	hl
	push	bc
	call	__divuint
	pop	af
	pop	af
;hal.c:58: }
	jp	_msx_wait
;hal.c:60: void write_command (uint8_t command)  __z88dk_fastcall __naked
;	---------------------------------
; Function write_command
; ---------------------------------
_write_command::
;hal.c:66: __endasm;
	ld	a,l
	out	(#0x11),a
	ret
;hal.c:67: }
;hal.c:68: void write_data (uint8_t data)  __z88dk_fastcall __naked
;	---------------------------------
; Function write_data
; ---------------------------------
_write_data::
;hal.c:74: __endasm;
	ld	a,l
	out	(#0x10),a
	ret
;hal.c:75: }
;hal.c:76: uint8_t read_data ()  __z88dk_fastcall __naked
;	---------------------------------
; Function read_data
; ---------------------------------
_read_data::
;hal.c:82: __endasm;
	in	a,(#0x10)
	ld	l,a
	ret
;hal.c:83: }
;hal.c:84: uint8_t read_status ()  __z88dk_fastcall __naked
;	---------------------------------
; Function read_status
; ---------------------------------
_read_status::
;hal.c:90: __endasm;
	in	a,(#0x11)
	ld	l,a
	ret
;hal.c:91: }
;hal.c:93: void error (char* txt)
;	---------------------------------
; Function error
; ---------------------------------
_error::
;hal.c:95: printf (txt);
	pop	bc
	pop	hl
	push	hl
	push	bc
	push	hl
	call	_printf
	pop	af
;hal.c:99: __endasm;
	di
	halt
;hal.c:100: }
	ret
;hal.c:102: int putchar (int character)
;	---------------------------------
; Function putchar
; ---------------------------------
_putchar::
;hal.c:114: __endasm;
	ld	hl, #2
	add	hl, sp ;Bypass the return address of the function
	ld	a, (hl)
	ld	iy,(#0xfcc1 -1) ;BIOS slot in iyh
	push	ix
	ld	ix,#0x00a2 ;address of BIOS routine
	call	0x001c ;interslot call
	pop	ix
;hal.c:116: return character;
	ld	hl, #2
	add	hl, sp
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
;hal.c:117: }
	ret
;hal.c:120: int getchar ()
;	---------------------------------
; Function getchar
; ---------------------------------
_getchar::
;hal.c:131: __endasm;
	ld	iy,(#0xfcc1 -1) ;BIOS slot in iyh
	push	ix
	ld	ix,#0x009f ;address of BIOS routine
	call	0x001c ;interslot call
	pop	ix
	ld	h,#0
	ld	l,a
;hal.c:132: }
	ret
;hal.c:134: bool pressed_ESC() __z88dk_fastcall __naked
;	---------------------------------
; Function pressed_ESC
; ---------------------------------
_pressed_ESC::
;hal.c:157: __endasm;
;	character in keybuffer?
	ld	iy,(#0xfcc1 -1) ;BIOS slot in iyh
	push	ix
	ld	ix,#0x009c ;address of BIOS routine
	call	0x001c ;interslot call
	pop	ix
	ld	l,#0
	ret	z
;	yes? lets check if its ESCape
	ld	iy,(#0xfcc1 -1) ;BIOS slot in iyh
	push	ix
	ld	ix,#0x009f ;address of BIOS routine
	call	0x001c ;interslot call
	pop	ix
	cp	#27
	ld	l,#1
	ret	z
	ld	l,#0
	ret
;hal.c:158: }
;hal.c:160: void  read_data_multiple (uint8_t* buffer,uint8_t len)
;	---------------------------------
; Function read_data_multiple
; ---------------------------------
_read_data_multiple::
;hal.c:170: __endasm;
	ld	iy, #2
	add	iy,sp
	ld	b,+2(iy)
	ld	h,+1(iy)
	ld	l,+0(iy)
	ld	c, #0x10
	inir
;hal.c:171: }
	ret
;hal.c:172: void    write_data_multiple (uint8_t* buffer,uint8_t len)
;	---------------------------------
; Function write_data_multiple
; ---------------------------------
_write_data_multiple::
;hal.c:182: __endasm;
	ld	iy, #2
	add	iy,sp
	ld	b,+2(iy)
	ld	h,+1(iy)
	ld	l,+0(iy)
	ld	c, #0x10
	otir
;hal.c:183: }
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
