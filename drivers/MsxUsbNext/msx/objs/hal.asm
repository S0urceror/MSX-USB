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
;hal.c:7: void hal_init ()
;	---------------------------------
; Function hal_init
; ---------------------------------
_hal_init::
;hal.c:10: }
	ret
;hal.c:13: void msx_wait (uint16_t times_jiffy)  __z88dk_fastcall __naked
;	---------------------------------
; Function msx_wait
; ---------------------------------
_msx_wait::
;hal.c:28: __endasm; 
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
;hal.c:29: }
;hal.c:31: void delay_ms (uint16_t milliseconds)
;	---------------------------------
; Function delay_ms
; ---------------------------------
_delay_ms::
;hal.c:33: msx_wait (milliseconds/20);
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
;hal.c:34: }
	jp	_msx_wait
;hal.c:36: void write_command (uint8_t command)  __z88dk_fastcall __naked
;	---------------------------------
; Function write_command
; ---------------------------------
_write_command::
;hal.c:42: __endasm;
	ld	a,l
	out	(#0x11),a
	ret
;hal.c:43: }
;hal.c:44: void write_data (uint8_t data)  __z88dk_fastcall __naked
;	---------------------------------
; Function write_data
; ---------------------------------
_write_data::
;hal.c:50: __endasm;
	ld	a,l
	out	(#0x10),a
	ret
;hal.c:51: }
;hal.c:52: uint8_t read_data ()  __z88dk_fastcall __naked
;	---------------------------------
; Function read_data
; ---------------------------------
_read_data::
;hal.c:58: __endasm;
	in	a,(#0x10)
	ld	l,a
	ret
;hal.c:59: }
;hal.c:60: uint8_t read_status ()  __z88dk_fastcall __naked
;	---------------------------------
; Function read_status
; ---------------------------------
_read_status::
;hal.c:66: __endasm;
	in	a,(#0x11)
	ld	l,a
	ret
;hal.c:67: }
;hal.c:69: void error (char* txt)
;	---------------------------------
; Function error
; ---------------------------------
_error::
;hal.c:71: printf (txt);
	pop	bc
	pop	hl
	push	hl
	push	bc
	push	hl
	call	_printf
	pop	af
;hal.c:75: __endasm;
	di
	halt
;hal.c:76: }
	ret
;hal.c:78: int putchar (int character)
;	---------------------------------
; Function putchar
; ---------------------------------
_putchar::
;hal.c:90: __endasm;
	ld	hl, #2
	add	hl, sp ;Bypass the return address of the function
	ld	a, (hl)
	ld	iy,(#0xfcc1 -1) ;BIOS slot in iyh
	push	ix
	ld	ix,#0x00a2 ;address of BIOS routine
	call	0x001c ;interslot call
	pop	ix
;hal.c:92: return character;
	ld	hl, #2
	add	hl, sp
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
;hal.c:93: }
	ret
;hal.c:95: int getchar ()
;	---------------------------------
; Function getchar
; ---------------------------------
_getchar::
;hal.c:113: __endasm;
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
	ld	l,a
;hal.c:114: }
	ret
;hal.c:116: void  read_data_multiple (uint8_t* buffer,uint8_t len)
;	---------------------------------
; Function read_data_multiple
; ---------------------------------
_read_data_multiple::
;hal.c:119: uint8_t* ptr=buffer;
	pop	de
	pop	bc
	push	bc
	push	de
;hal.c:120: for (cnt=0;cnt<len;cnt++)
	ld	e, #0x00
00103$:
	ld	hl, #4
	add	hl, sp
	ld	a, e
	sub	a, (hl)
	ret	NC
;hal.c:121: *(ptr++) = read_data();
	push	bc
	push	de
	call	_read_data
	ld	a, l
	pop	de
	pop	bc
	ld	(bc), a
	inc	bc
;hal.c:120: for (cnt=0;cnt<len;cnt++)
	inc	e
;hal.c:122: }
	jr	00103$
;hal.c:123: void    write_data_multiple (uint8_t* buffer,uint8_t len)
;	---------------------------------
; Function write_data_multiple
; ---------------------------------
_write_data_multiple::
;hal.c:126: uint8_t* ptr=buffer;
	pop	de
	pop	bc
	push	bc
	push	de
;hal.c:127: for (cnt=0;cnt<len;cnt++)
	ld	e, #0x00
00103$:
	ld	hl, #4
	add	hl, sp
	ld	a, e
	sub	a, (hl)
	ret	NC
;hal.c:128: write_data(*(ptr++));
	ld	a, (bc)
	ld	l, a
	inc	bc
	push	bc
	push	de
	call	_write_data
	pop	de
	pop	bc
;hal.c:127: for (cnt=0;cnt<len;cnt++)
	inc	e
;hal.c:129: }
	jr	00103$
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
