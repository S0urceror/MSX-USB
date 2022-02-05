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
	.globl _delay_ms
	.globl _write_command
	.globl _write_data
	.globl _read_data
	.globl _read_status
	.globl _error
	.globl _putchar
	.globl _getchar
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
;hal.c:34: void msx_wait (uint16_t times_jiffy)  __z88dk_fastcall __naked
;	---------------------------------
; Function msx_wait
; ---------------------------------
_msx_wait::
;hal.c:49: __endasm; 
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
;hal.c:50: }
;hal.c:52: void delay_ms (uint16_t milliseconds)
;	---------------------------------
; Function delay_ms
; ---------------------------------
_delay_ms::
;hal.c:54: msx_wait (milliseconds/20);
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
;hal.c:55: }
	jp	_msx_wait
;hal.c:57: void write_command (uint8_t command)  __z88dk_fastcall __naked
;	---------------------------------
; Function write_command
; ---------------------------------
_write_command::
;hal.c:63: __endasm;
	ld	a,l
	out	(#0x11),a
	ret
;hal.c:64: }
;hal.c:65: void write_data (uint8_t data)  __z88dk_fastcall __naked
;	---------------------------------
; Function write_data
; ---------------------------------
_write_data::
;hal.c:71: __endasm;
	ld	a,l
	out	(#0x10),a
	ret
;hal.c:72: }
;hal.c:73: uint8_t read_data ()  __z88dk_fastcall __naked
;	---------------------------------
; Function read_data
; ---------------------------------
_read_data::
;hal.c:79: __endasm;
	in	a,(#0x10)
	ld	l,a
	ret
;hal.c:80: }
;hal.c:81: uint8_t read_status ()  __z88dk_fastcall __naked
;	---------------------------------
; Function read_status
; ---------------------------------
_read_status::
;hal.c:87: __endasm;
	in	a,(#0x11)
	ld	l,a
	ret
;hal.c:88: }
;hal.c:90: void error (char* txt)
;	---------------------------------
; Function error
; ---------------------------------
_error::
;hal.c:92: printf (txt);
	pop	bc
	pop	hl
	push	hl
	push	bc
	push	hl
	call	_printf
	pop	af
;hal.c:96: __endasm;
	di
	halt
;hal.c:97: }
	ret
;hal.c:99: int putchar (int character)
;	---------------------------------
; Function putchar
; ---------------------------------
_putchar::
;hal.c:111: __endasm;
	ld	hl, #2
	add	hl, sp ;Bypass the return address of the function
	ld	a, (hl)
	ld	iy,(#0xfcc1 -1) ;BIOS slot in iyh
	push	ix
	ld	ix,#0x00a2 ;address of BIOS routine
	call	0x001c ;interslot call
	pop	ix
;hal.c:113: return character;
	ld	hl, #2
	add	hl, sp
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
;hal.c:114: }
	ret
;hal.c:117: int getchar ()
;	---------------------------------
; Function getchar
; ---------------------------------
_getchar::
;hal.c:136: __endasm;
	_get_char_again:
;ld	iy,(#0xfcc1 -1) ;BIOS slot in iyh
;push	ix
;ld	ix,#0x009c ;address of BIOS routine
;call	0x001c ;interslot call
;pop	ix
;jr	z, _get_char_again
	ld	iy,(#0xfcc1 -1) ;BIOS slot in iyh
	push	ix
	ld	ix,#0x009f ;address of BIOS routine
	call	0x001c ;interslot call
	pop	ix
	ld	h,#0
	ld	l,a
;hal.c:137: }
	ret
;hal.c:139: void  read_data_multiple (uint8_t* buffer,uint8_t len)
;	---------------------------------
; Function read_data_multiple
; ---------------------------------
_read_data_multiple::
;hal.c:142: uint8_t* ptr=buffer;
	pop	de
	pop	bc
	push	bc
	push	de
;hal.c:143: for (cnt=0;cnt<len;cnt++)
	ld	e, #0x00
00103$:
	ld	hl, #4
	add	hl, sp
	ld	a, e
	sub	a, (hl)
	ret	NC
;hal.c:144: *(ptr++) = read_data();
	push	bc
	push	de
	call	_read_data
	ld	a, l
	pop	de
	pop	bc
	ld	(bc), a
	inc	bc
;hal.c:143: for (cnt=0;cnt<len;cnt++)
	inc	e
;hal.c:145: }
	jr	00103$
;hal.c:146: void    write_data_multiple (uint8_t* buffer,uint8_t len)
;	---------------------------------
; Function write_data_multiple
; ---------------------------------
_write_data_multiple::
;hal.c:149: uint8_t* ptr=buffer;
	pop	de
	pop	bc
	push	bc
	push	de
;hal.c:150: for (cnt=0;cnt<len;cnt++)
	ld	e, #0x00
00103$:
	ld	hl, #4
	add	hl, sp
	ld	a, e
	sub	a, (hl)
	ret	NC
;hal.c:151: write_data(*(ptr++));
	ld	a, (bc)
	ld	l, a
	inc	bc
	push	bc
	push	de
	call	_write_data
	pop	de
	pop	bc
;hal.c:150: for (cnt=0;cnt<len;cnt++)
	inc	e
;hal.c:152: }
	jr	00103$
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
