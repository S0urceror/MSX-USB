;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.0.0 #11528 (Linux)
;--------------------------------------------------------
	.module usbdisk
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _toUpper
	.globl _toLower
	.globl _supports_80_column_mode
	.globl _error
	.globl _delay_ms
	.globl _pressed_ESC
	.globl _getchar
	.globl _putchar
	.globl _ch376_get_ic_version
	.globl _ch376s_disk_write
	.globl _ch376s_disk_read
	.globl _ch376_get_sector_LBA
	.globl _ch376_locate_sector
	.globl _ch376_get_fat_info
	.globl _ch376_next_search
	.globl _ch376_open_search
	.globl _ch376_set_filename
	.globl _ch376_open_directory
	.globl _ch376_close_file
	.globl _ch376_open_file
	.globl _ch376_set_usb_host_mode
	.globl _ch376_plugged_in
	.globl _ch376_reset_all
	.globl _toupper
	.globl _tolower
	.globl _puts
	.globl _printf
	.globl _usbdisk_init
	.globl _usbdisk_autoexec_dsk
	.globl _usbdisk_select_dsk_file
	.globl _read_write_file_sectors
	.globl _read_write_disk_sectors
	.globl _usbdisk_close_dsk_file
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
;../generic/usbdisk.c:11: void usbdisk_init ()
;	---------------------------------
; Function usbdisk_init
; ---------------------------------
_usbdisk_init::
;../generic/usbdisk.c:14: printf ("Support for USB floppy drives by (c)The Retro Hacker\r\n");
	ld	hl, #___str_6
	push	hl
	call	_puts
	pop	af
;../generic/usbdisk.c:15: ch376_reset_all();
	call	_ch376_reset_all
;../generic/usbdisk.c:16: if (!ch376_plugged_in())
	call	_ch376_plugged_in
	bit	0, l
	jr	NZ,00102$
;../generic/usbdisk.c:18: error ("-CH376 NOT detected");
	ld	hl, #___str_4
	push	hl
	call	_error
	pop	af
	jr	00103$
00102$:
;../generic/usbdisk.c:22: const uint8_t ver = ch376_get_ic_version();
	call	_ch376_get_ic_version
;../generic/usbdisk.c:23: printf ("\n+CH376 detected (version %d)\r\n",ver);
	ld	h, #0x00
	ld	bc, #___str_5+0
	push	hl
	push	bc
	call	_printf
	pop	af
	pop	af
00103$:
;../generic/usbdisk.c:27: ch376_set_usb_host_mode(USB_MODE_HOST);
	ld	a, #0x06
	push	af
	inc	sp
	call	_ch376_set_usb_host_mode
	inc	sp
;../generic/usbdisk.c:37: }
	ret
___str_4:
	.ascii "-CH376 NOT detected"
	.db 0x00
___str_5:
	.db 0x0a
	.ascii "+CH376 detected (version %d)"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_6:
	.ascii "MSXUSB-NXT v0.5 (c)Sourceror"
	.db 0x0d
	.db 0x0a
	.ascii "Support for USB floppy drives by (c)The Retro Hacker"
	.db 0x0d
	.db 0x00
;../generic/usbdisk.c:39: char* toLower(char* s) {
;	---------------------------------
; Function toLower
; ---------------------------------
_toLower::
;../generic/usbdisk.c:40: for(char *p=s; *p; p++) *p=tolower(*p);
	pop	de
	pop	bc
	push	bc
	push	de
00103$:
	ld	a, (bc)
	or	a, a
	jr	Z,00101$
	ld	e, a
	ld	d, #0x00
	push	bc
	push	de
	call	_tolower
	pop	af
	pop	bc
	ld	a, l
	ld	(bc), a
	inc	bc
	jr	00103$
00101$:
;../generic/usbdisk.c:41: return s;
	pop	bc
	pop	hl
	push	hl
	push	bc
;../generic/usbdisk.c:42: }
	ret
;../generic/usbdisk.c:43: char* toUpper(char* s) {
;	---------------------------------
; Function toUpper
; ---------------------------------
_toUpper::
;../generic/usbdisk.c:44: for(char *p=s; *p; p++) *p=toupper(*p);
	pop	de
	pop	bc
	push	bc
	push	de
00103$:
	ld	a, (bc)
	or	a, a
	jr	Z,00101$
	ld	e, a
	ld	d, #0x00
	push	bc
	push	de
	call	_toupper
	pop	af
	pop	bc
	ld	a, l
	ld	(bc), a
	inc	bc
	jr	00103$
00101$:
;../generic/usbdisk.c:45: return s;
	pop	bc
	pop	hl
	push	hl
	push	bc
;../generic/usbdisk.c:46: }
	ret
;../generic/usbdisk.c:48: bool usbdisk_autoexec_dsk()
;	---------------------------------
; Function usbdisk_autoexec_dsk
; ---------------------------------
_usbdisk_autoexec_dsk::
;../generic/usbdisk.c:53: ch376_set_filename ("/");
	ld	hl, #___str_7
	push	hl
	call	_ch376_set_filename
	pop	af
;../generic/usbdisk.c:54: if (!ch376_open_directory())
	call	_ch376_open_directory
	bit	0, l
	jr	NZ,00102$
;../generic/usbdisk.c:56: error ("-Directory not opened");
	ld	hl, #___str_8
	push	hl
	call	_error
	pop	af
00102$:
;../generic/usbdisk.c:60: ch376_set_filename ("AUTOEXEC.DSK");
	ld	hl, #___str_9
	push	hl
	call	_ch376_set_filename
	pop	af
;../generic/usbdisk.c:61: if (ch376_open_file()==true)
	call	_ch376_open_file
	bit	0, l
	jr	Z,00110$
;../generic/usbdisk.c:63: printf ("\r\nStarting AUTOEXEC.DSK or press ESC ");
	ld	hl, #___str_10
	push	hl
	call	_printf
	pop	af
;../generic/usbdisk.c:64: for (cnt_times=3;cnt_times>0;cnt_times--)
	ld	bc, #0x0303
00111$:
;../generic/usbdisk.c:66: delay_ms (1000);
	push	bc
	ld	hl, #0x03e8
	push	hl
	call	_delay_ms
	pop	af
	call	_pressed_ESC
	pop	bc
	bit	0, l
	jr	NZ,00105$
;../generic/usbdisk.c:69: printf (".");
	push	bc
	ld	hl, #___str_11
	push	hl
	call	_printf
	pop	af
	pop	bc
;../generic/usbdisk.c:64: for (cnt_times=3;cnt_times>0;cnt_times--)
	dec	c
	ld	b, c
	ld	a, c
	or	a, a
	jr	NZ,00111$
00105$:
;../generic/usbdisk.c:71: if (cnt_times==0)
	ld	a, b
	or	a, a
	jr	NZ,00107$
;../generic/usbdisk.c:73: printf ("\r\n");
	ld	hl, #___str_13
	push	hl
	call	_puts
	pop	af
;../generic/usbdisk.c:74: return true;
	ld	l, #0x01
	ret
00107$:
;../generic/usbdisk.c:78: ch376_close_file ();
	call	_ch376_close_file
00110$:
;../generic/usbdisk.c:81: return false;
	ld	l, #0x00
;../generic/usbdisk.c:82: }
	ret
___str_7:
	.ascii "/"
	.db 0x00
___str_8:
	.ascii "-Directory not opened"
	.db 0x00
___str_9:
	.ascii "AUTOEXEC.DSK"
	.db 0x00
___str_10:
	.db 0x0d
	.db 0x0a
	.ascii "Starting AUTOEXEC.DSK or press ESC "
	.db 0x00
___str_11:
	.ascii "."
	.db 0x00
___str_13:
	.db 0x0d
	.db 0x00
;../generic/usbdisk.c:85: select_mode_t usbdisk_select_dsk_file (char* start_directory)
;	---------------------------------
; Function usbdisk_select_dsk_file
; ---------------------------------
_usbdisk_select_dsk_file::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-366
	add	hl, sp
	ld	sp, hl
;../generic/usbdisk.c:93: if (supports_80_column_mode())
	call	_supports_80_column_mode
	bit	0, l
	jr	Z,00102$
;../generic/usbdisk.c:94: nr_dsks_per_line = 5;
	ld	-13 (ix), #0x05
	jr	00103$
00102$:
;../generic/usbdisk.c:96: nr_dsks_per_line = 2;
	ld	-13 (ix), #0x02
00103$:
;../generic/usbdisk.c:98: nr_dsk_files_found=0;
	xor	a, a
	ld	-2 (ix), a
;../generic/usbdisk.c:101: ch376_set_filename (start_directory);
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	push	hl
	call	_ch376_set_filename
	pop	af
;../generic/usbdisk.c:102: if (!ch376_open_directory())
	call	_ch376_open_directory
	bit	0, l
	jr	NZ,00105$
;../generic/usbdisk.c:104: error ("-Directory not opened");
	ld	hl, #___str_14
	push	hl
	call	_error
	pop	af
00105$:
;../generic/usbdisk.c:109: printf ("1.FLOPPY       2.USBDRIVE\r\n\r\n");
	ld	hl, #___str_26
	push	hl
	call	_puts
;../generic/usbdisk.c:112: ch376_set_filename ("*");
	ld	hl, #___str_19
	ex	(sp),hl
	call	_ch376_set_filename
	pop	af
;../generic/usbdisk.c:113: if (!ch376_open_search ())
	call	_ch376_open_search
	bit	0, l
	jr	NZ,00107$
;../generic/usbdisk.c:114: error ("-No files found");
	ld	hl, #___str_20
	push	hl
	call	_error
	pop	af
00107$:
;../generic/usbdisk.c:116: printf ("Or, select DSK image [%s]:\r\n",start_directory);
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	push	hl
	ld	hl, #___str_21
	push	hl
	call	_printf
	pop	af
	pop	af
;../generic/usbdisk.c:118: do 
	ld	hl, #32
	add	hl, sp
	ld	-12 (ix), l
	ld	-11 (ix), h
	ld	a, -12 (ix)
	ld	-10 (ix), a
	ld	a, -11 (ix)
	ld	-9 (ix), a
	ld	hl, #0
	add	hl, sp
	ld	-8 (ix), l
	ld	-7 (ix), h
	ld	a, -8 (ix)
	add	a, #0x0b
	ld	-6 (ix), a
	ld	a, -7 (ix)
	adc	a, #0x00
	ld	-5 (ix), a
00128$:
;../generic/usbdisk.c:120: ch376_get_fat_info (&info);
	ld	c, -8 (ix)
	ld	b, -7 (ix)
	push	bc
	call	_ch376_get_fat_info
	pop	af
;../generic/usbdisk.c:121: if (!(info.DIR_Attr&0x02)) // show non-hidden normal or archived files
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	a, (hl)
	ld	-1 (ix), a
	bit	1, -1 (ix)
	jp	NZ,00129$
;../generic/usbdisk.c:123: if (info.DIR_Attr&0x20 || info.DIR_Attr==0x00)
	bit	5, -1 (ix)
	jr	NZ,00117$
	ld	a, -1 (ix)
	or	a, a
	jp	NZ, 00118$
00117$:
;../generic/usbdisk.c:125: if (info.DIR_Name[8]=='D' &&
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	ld	de, #0x0008
	add	hl, de
	ld	a, (hl)
	sub	a, #0x44
	jp	NZ,00118$
;../generic/usbdisk.c:126: info.DIR_Name[9]=='S' &&
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	ld	de, #0x0009
	add	hl, de
	ld	a, (hl)
	sub	a, #0x53
	jp	NZ,00118$
;../generic/usbdisk.c:127: info.DIR_Name[10]=='K')
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	ld	de, #0x000a
	add	hl, de
	ld	a, (hl)
	sub	a, #0x4b
	jp	NZ,00118$
;../generic/usbdisk.c:129: putchar ('A'+nr_dsk_files_found);
	ld	c, -2 (ix)
	ld	b, #0x00
	ld	hl, #0x0041
	add	hl, bc
	push	hl
	call	_putchar
;../generic/usbdisk.c:130: putchar ('.');
	ld	hl, #0x002e
	ex	(sp),hl
	call	_putchar
	pop	af
;../generic/usbdisk.c:131: files[nr_dsk_files_found][11]='\0';
	ld	c, -2 (ix)
	ld	b, #0x00
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	a, -12 (ix)
	add	a, e
	ld	c, a
	ld	a, -11 (ix)
	adc	a, d
	ld	b, a
	ld	hl, #0x000b
	add	hl, bc
	ld	(hl), #0x00
;../generic/usbdisk.c:132: for (cnt=0;cnt<11;cnt++)
	ld	-4 (ix), c
	ld	-3 (ix), b
	ld	c, #0x00
00149$:
;../generic/usbdisk.c:134: if (cnt==8)
	ld	a, c
	sub	a, #0x08
	jr	NZ,00109$
;../generic/usbdisk.c:135: putchar ('.');
	push	bc
	ld	hl, #0x002e
	push	hl
	call	_putchar
	pop	af
	pop	bc
00109$:
;../generic/usbdisk.c:136: putchar (info.DIR_Name[cnt]);
	ld	a, -8 (ix)
	add	a, c
	ld	e, a
	ld	a, -7 (ix)
	adc	a, #0x00
	ld	d, a
	ld	a, (de)
	ld	l, a
	ld	h, #0x00
	push	bc
	push	de
	push	hl
	call	_putchar
	pop	af
	pop	de
	pop	bc
;../generic/usbdisk.c:137: files[nr_dsk_files_found][cnt]=info.DIR_Name[cnt];
	ld	a, -4 (ix)
	add	a, c
	ld	b, a
	ld	a, -3 (ix)
	adc	a, #0x00
	push	af
	ld	a, (de)
	ld	e, a
	pop	af
	ld	l, b
	ld	h, a
	ld	(hl), e
;../generic/usbdisk.c:132: for (cnt=0;cnt<11;cnt++)
	inc	c
	ld	a, c
	sub	a, #0x0b
	jr	C,00149$
;../generic/usbdisk.c:139: putchar (' ');
	ld	hl, #0x0020
	push	hl
	call	_putchar
	pop	af
;../generic/usbdisk.c:140: nr_dsk_files_found++;
	inc	-2 (ix)
;../generic/usbdisk.c:141: if ((nr_dsk_files_found%nr_dsks_per_line) == 0)
	ld	h, -13 (ix)
	ld	l, -2 (ix)
	push	hl
	call	__moduchar
	pop	af
	ld	a, l
	or	a, a
	jr	NZ,00118$
;../generic/usbdisk.c:143: putchar ('\r');
	ld	hl, #0x000d
	push	hl
	call	_putchar
;../generic/usbdisk.c:144: putchar ('\n');
	ld	hl, #0x000a
	ex	(sp),hl
	call	_putchar
	pop	af
00118$:
;../generic/usbdisk.c:148: if (info.DIR_Attr&0x10)
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	bit	4, (hl)
	jp	Z,00129$
;../generic/usbdisk.c:150: putchar ('A'+nr_dsk_files_found);
	ld	c, -2 (ix)
	ld	b, #0x00
	ld	hl, #0x0041
	add	hl, bc
	push	hl
	call	_putchar
;../generic/usbdisk.c:151: putchar ('.');
	ld	hl, #0x002e
	ex	(sp),hl
	call	_putchar
;../generic/usbdisk.c:152: putchar ('\\');
	ld	hl, #0x005c
	ex	(sp),hl
	call	_putchar
	pop	af
;../generic/usbdisk.c:153: files[nr_dsk_files_found][8]='\0';
	ld	c, -2 (ix)
	ld	b, #0x00
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	a, -10 (ix)
	add	a, e
	ld	c, a
	ld	a, -9 (ix)
	adc	a, d
	ld	b, a
	ld	hl, #0x0008
	add	hl, bc
	ld	(hl), #0x00
;../generic/usbdisk.c:154: for (cnt=0;cnt<8;cnt++)
	ld	-4 (ix), c
	ld	-3 (ix), b
	xor	a, a
	ld	-1 (ix), a
00151$:
;../generic/usbdisk.c:156: putchar (tolower(info.DIR_Name[cnt]));
	ld	a, -8 (ix)
	add	a, -1 (ix)
	ld	c, a
	ld	a, -7 (ix)
	adc	a, #0x00
	ld	b, a
	ld	a, (bc)
	ld	e, a
	ld	d, #0x00
	push	bc
	push	de
	call	_tolower
	ex	(sp),hl
	call	_putchar
	pop	af
	pop	bc
;../generic/usbdisk.c:157: files[nr_dsk_files_found][cnt]=info.DIR_Name[cnt];
	ld	a, -4 (ix)
	add	a, -1 (ix)
	ld	e, a
	ld	a, -3 (ix)
	adc	a, #0x00
	ld	d, a
	ld	a, (bc)
	ld	(de), a
;../generic/usbdisk.c:154: for (cnt=0;cnt<8;cnt++)
	inc	-1 (ix)
	ld	a, -1 (ix)
	sub	a, #0x08
	jr	C,00151$
;../generic/usbdisk.c:159: putchar (' ');
	ld	hl, #0x0020
	push	hl
	call	_putchar
;../generic/usbdisk.c:160: putchar (' ');
	ld	hl, #0x0020
	ex	(sp),hl
	call	_putchar
;../generic/usbdisk.c:161: putchar (' ');
	ld	hl, #0x0020
	ex	(sp),hl
	call	_putchar
;../generic/usbdisk.c:162: putchar (' ');
	ld	hl, #0x0020
	ex	(sp),hl
	call	_putchar
	pop	af
;../generic/usbdisk.c:163: nr_dsk_files_found++;
	inc	-2 (ix)
;../generic/usbdisk.c:164: if ((nr_dsk_files_found%nr_dsks_per_line) == 0)
	ld	h, -13 (ix)
	ld	l, -2 (ix)
	push	hl
	call	__moduchar
	pop	af
	ld	a, l
	or	a, a
	jr	NZ,00129$
;../generic/usbdisk.c:166: putchar ('\r');
	ld	hl, #0x000d
	push	hl
	call	_putchar
;../generic/usbdisk.c:167: putchar ('\n');
	ld	hl, #0x000a
	ex	(sp),hl
	call	_putchar
	pop	af
00129$:
;../generic/usbdisk.c:172: while (ch376_next_search () && nr_dsk_files_found<MAX_FILES);
	call	_ch376_next_search
	bit	0, l
	jr	Z,00130$
	ld	a, -2 (ix)
	sub	a, #0x1a
	jp	C, 00128$
00130$:
;../generic/usbdisk.c:173: putchar ('\r');
	ld	hl, #0x000d
	push	hl
	call	_putchar
;../generic/usbdisk.c:174: putchar ('\n');
	ld	hl, #0x000a
	ex	(sp),hl
	call	_putchar
;../generic/usbdisk.c:176: printf ("\r\n");
	ld	hl, #___str_23
	ex	(sp),hl
	call	_puts
	pop	af
;../generic/usbdisk.c:177: while (true)
00147$:
;../generic/usbdisk.c:179: char c = getchar ();
	call	_getchar
;../generic/usbdisk.c:180: c = toupper (c);
	ld	h, #0x00
	push	hl
	call	_toupper
	pop	af
;../generic/usbdisk.c:181: if (c>='A' && c<='A'+nr_dsk_files_found)
	ld	-1 (ix), l
	ld	a, l
	sub	a, #0x41
	jr	C,00140$
	ld	c, -2 (ix)
	ld	b, #0x00
	ld	hl, #0x0041
	add	hl, bc
	ld	c, -1 (ix)
	ld	b, #0x00
	ld	a, l
	sub	a, c
	ld	a, h
	sbc	a, b
	jp	PO, 00300$
	xor	a, #0x80
00300$:
	jp	M, 00140$
;../generic/usbdisk.c:183: c-='A';
	ld	a, -1 (ix)
	add	a, #0xbf
;../generic/usbdisk.c:184: if (files[c][8]=='\0')
	ld	c, a
	ld	b, #0x00
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	a, -12 (ix)
	add	a, e
	ld	e, a
	ld	a, -11 (ix)
	adc	a, d
	ld	d, a
	ld	l, e
	ld	h, d
	ld	bc, #0x0008
	add	hl, bc
	ld	a, (hl)
;../generic/usbdisk.c:190: return usbdisk_select_dsk_file (files[c]);
	ld	c, e
	ld	b, d
;../generic/usbdisk.c:184: if (files[c][8]=='\0')
	or	a, a
	jr	NZ,00137$
;../generic/usbdisk.c:187: if (files[c][0]=='.')
	ld	a, (de)
	sub	a, #0x2e
	jr	NZ,00132$
;../generic/usbdisk.c:188: return usbdisk_select_dsk_file ("/");
	ld	hl, #___str_24
	push	hl
	call	_usbdisk_select_dsk_file
	pop	af
	jr	00153$
00132$:
;../generic/usbdisk.c:190: return usbdisk_select_dsk_file (files[c]);
	push	bc
	call	_usbdisk_select_dsk_file
	pop	af
	jr	00153$
00137$:
;../generic/usbdisk.c:195: ch376_set_filename (files[c]);
	push	bc
	call	_ch376_set_filename
	pop	af
;../generic/usbdisk.c:196: if (!ch376_open_file ())
	call	_ch376_open_file
	bit	0, l
	jr	NZ,00135$
;../generic/usbdisk.c:197: error ("-DSK not opened\r\n");
	ld	hl, #___str_25
	push	hl
	call	_error
	pop	af
00135$:
;../generic/usbdisk.c:198: return DSK_IMAGE;
	ld	l, #0x02
	jr	00153$
00140$:
;../generic/usbdisk.c:201: if (c=='1')
	ld	a, -1 (ix)
;../generic/usbdisk.c:202: return FLOPPY;
	sub	a,#0x31
	jr	NZ,00143$
	ld	l,a
	jr	00153$
00143$:
;../generic/usbdisk.c:203: if (c=='2')
	ld	a, -1 (ix)
	sub	a, #0x32
	jp	NZ,00147$
;../generic/usbdisk.c:204: return USB;
	ld	l, #0x01
00153$:
;../generic/usbdisk.c:206: }
	ld	sp, ix
	pop	ix
	ret
___str_14:
	.ascii "-Directory not opened"
	.db 0x00
___str_19:
	.ascii "*"
	.db 0x00
___str_20:
	.ascii "-No files found"
	.db 0x00
___str_21:
	.ascii "Or, select DSK image [%s]:"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_23:
	.db 0x0d
	.db 0x00
___str_24:
	.ascii "/"
	.db 0x00
___str_25:
	.ascii "-DSK not opened"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_26:
	.db 0x0d
	.db 0x0a
	.ascii "Select device:"
	.db 0x0d
	.db 0x0a
	.ascii "1.FLOPPY       2.USBDRIVE"
	.db 0x0d
	.db 0x0a
	.db 0x0d
	.db 0x00
;../generic/usbdisk.c:208: bool read_write_file_sectors (bool writing,uint8_t nr_sectors,uint32_t* sector,uint8_t* sector_buffer)
;	---------------------------------
; Function read_write_file_sectors
; ---------------------------------
_read_write_file_sectors::
	ld	hl, #-10
	add	hl, sp
	ld	sp, hl
;../generic/usbdisk.c:211: if (!ch376_locate_sector ((uint8_t*)sector))
	ld	hl, #14
	add	hl, sp
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	push	bc
	call	_ch376_locate_sector
	pop	af
	ld	c, l
	bit	0, c
	jr	NZ,00102$
;../generic/usbdisk.c:212: return false;
	ld	l, #0x00
	jp	00112$
00102$:
;../generic/usbdisk.c:213: if (!ch376_get_sector_LBA (nr_sectors,(uint8_t*) &sectors_lba))
	ld	hl, #0
	add	hl, sp
	ld	iy, #8
	add	iy, sp
	ld	0 (iy), l
	ld	1 (iy), h
	ld	c, 0 (iy)
	ld	b, 1 (iy)
	push	bc
	ld	hl, #15+0
	add	hl, sp
	ld	a, (hl)
	push	af
	inc	sp
	call	_ch376_get_sector_LBA
	pop	af
	inc	sp
	bit	0, l
	jr	NZ,00104$
;../generic/usbdisk.c:214: return false;
	ld	l, #0x00
	jr	00112$
00104$:
;../generic/usbdisk.c:217: if (!ch376s_disk_read (sectors_lba[0],sectors_lba+4,sector_buffer))
	ld	iy, #8
	add	iy, sp
	ld	a, 0 (iy)
	add	a, #0x04
	ld	c, a
	ld	a, 1 (iy)
	adc	a, #0x00
	ld	l, 0 (iy)
	ld	h, 1 (iy)
	ld	d, (hl)
	ld	b, a
;../generic/usbdisk.c:215: if (!writing)
	ld	hl, #12+0
	add	hl, sp
	bit	0, (hl)
	jr	NZ,00110$
;../generic/usbdisk.c:217: if (!ch376s_disk_read (sectors_lba[0],sectors_lba+4,sector_buffer))
	ld	hl, #16
	add	hl, sp
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	push	hl
	push	bc
	push	de
	inc	sp
	call	_ch376s_disk_read
	pop	af
	pop	af
	inc	sp
	bit	0, l
	jr	NZ,00111$
;../generic/usbdisk.c:218: return false;
	ld	l, #0x00
	jr	00112$
00110$:
;../generic/usbdisk.c:222: if (!ch376s_disk_write (sectors_lba[0],sectors_lba+4,sector_buffer))
	ld	hl, #16
	add	hl, sp
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	push	hl
	push	bc
	push	de
	inc	sp
	call	_ch376s_disk_write
	pop	af
	pop	af
	inc	sp
	bit	0, l
;../generic/usbdisk.c:223: return false;
;../generic/usbdisk.c:226: return true;
	ld	l, #0x00
	jr	Z,00112$
00111$:
	ld	l, #0x01
00112$:
;../generic/usbdisk.c:227: }
	ld	iy, #10
	add	iy, sp
	ld	sp, iy
	ret
;../generic/usbdisk.c:229: bool read_write_disk_sectors (bool writing,uint8_t nr_sectors,uint32_t* sector,uint8_t* sector_buffer)
;	---------------------------------
; Function read_write_disk_sectors
; ---------------------------------
_read_write_disk_sectors::
	push	ix
	ld	ix,#0
	add	ix,sp
;../generic/usbdisk.c:233: if (!ch376s_disk_read (nr_sectors,(uint8_t*)sector,sector_buffer))
	ld	c, 6 (ix)
	ld	b, 7 (ix)
;../generic/usbdisk.c:231: if (!writing)
	bit	0, 4 (ix)
	jr	NZ,00106$
;../generic/usbdisk.c:233: if (!ch376s_disk_read (nr_sectors,(uint8_t*)sector,sector_buffer))
	ld	l, 8 (ix)
	ld	h, 9 (ix)
	push	hl
	push	bc
	ld	a, 5 (ix)
	push	af
	inc	sp
	call	_ch376s_disk_read
	pop	af
	pop	af
	inc	sp
	bit	0, l
	jr	NZ,00107$
;../generic/usbdisk.c:234: return false;
	ld	l, #0x00
	jr	00108$
00106$:
;../generic/usbdisk.c:238: if (!ch376s_disk_write (nr_sectors,(uint8_t*)sector,sector_buffer))
	ld	l, 8 (ix)
	ld	h, 9 (ix)
	push	hl
	push	bc
	ld	a, 5 (ix)
	push	af
	inc	sp
	call	_ch376s_disk_write
	pop	af
	pop	af
	inc	sp
	bit	0, l
;../generic/usbdisk.c:239: return false;
;../generic/usbdisk.c:242: return true;
	ld	l, #0x00
	jr	Z,00108$
00107$:
	ld	l, #0x01
00108$:
;../generic/usbdisk.c:243: }
	pop	ix
	ret
;../generic/usbdisk.c:245: bool usbdisk_close_dsk_file ()
;	---------------------------------
; Function usbdisk_close_dsk_file
; ---------------------------------
_usbdisk_close_dsk_file::
;../generic/usbdisk.c:247: return ch376_close_file();
;../generic/usbdisk.c:248: }
	jp	_ch376_close_file
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
