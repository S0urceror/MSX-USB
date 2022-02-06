;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.1.0 #12072 (Mac OS X ppc)
;--------------------------------------------------------
	.module usbdisk
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _supports_80_column_mode
	.globl _error
	.globl _getchar
	.globl _ch376s_disk_write
	.globl _ch376s_disk_read
	.globl _ch376_get_sector_LBA
	.globl _ch376_locate_sector
	.globl _ch376_get_fat_info
	.globl _ch376_next_search
	.globl _ch376_open_search
	.globl _ch376_set_filename
	.globl _ch376_open_directory
	.globl _ch376_open_file
	.globl _ch376_mount_disk
	.globl _ch376_connect_disk
	.globl _ch376_set_usb_host_mode
	.globl _ch376_plugged_in
	.globl _ch376_reset_all
	.globl _toupper
	.globl _puts
	.globl _printf
	.globl _usbdisk_init
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
;../generic/usbdisk.c:13: printf ("MSXUSB-NXT v0.2 (c)Sourceror\r\n");
	ld	hl, #___str_1
	push	hl
	call	_puts
	pop	af
;../generic/usbdisk.c:14: ch376_reset_all();
	call	_ch376_reset_all
;../generic/usbdisk.c:15: if (!ch376_plugged_in())
	call	_ch376_plugged_in
	bit	0, l
	jr	NZ, 00102$
;../generic/usbdisk.c:16: error ("-CH376 NOT detected");
	ld	hl, #___str_2
	push	hl
	call	_error
	pop	af
00102$:
;../generic/usbdisk.c:17: printf ("+CH376 detected\r\n");
	ld	hl, #___str_4
	push	hl
	call	_puts
;../generic/usbdisk.c:18: ch376_set_usb_host_mode(USB_MODE_HOST);
	ld	h,#0x06
	ex	(sp),hl
	inc	sp
	call	_ch376_set_usb_host_mode
	inc	sp
;../generic/usbdisk.c:19: if (!ch376_connect_disk ())
	call	_ch376_connect_disk
	bit	0, l
	jr	NZ, 00104$
;../generic/usbdisk.c:20: error ("-Connect USB device");
	ld	hl, #___str_5
	push	hl
	call	_error
	pop	af
00104$:
;../generic/usbdisk.c:21: printf ("+USB device connected\r\n");
	ld	hl, #___str_7
	push	hl
	call	_puts
	pop	af
;../generic/usbdisk.c:22: if (!ch376_mount_disk ())
	call	_ch376_mount_disk
	bit	0, l
	jr	NZ, 00106$
;../generic/usbdisk.c:23: error ("-Not a valid disk");
	ld	hl, #___str_8
	push	hl
	call	_error
	pop	af
00106$:
;../generic/usbdisk.c:24: printf ("+USB disk mounted\r\n");
	ld	hl, #___str_10
	push	hl
	call	_puts
	pop	af
;../generic/usbdisk.c:25: }
	ret
___str_1:
	.ascii "MSXUSB-NXT v0.2 (c)Sourceror"
	.db 0x0d
	.db 0x00
___str_2:
	.ascii "-CH376 NOT detected"
	.db 0x00
___str_4:
	.ascii "+CH376 detected"
	.db 0x0d
	.db 0x00
___str_5:
	.ascii "-Connect USB device"
	.db 0x00
___str_7:
	.ascii "+USB device connected"
	.db 0x0d
	.db 0x00
___str_8:
	.ascii "-Not a valid disk"
	.db 0x00
___str_10:
	.ascii "+USB disk mounted"
	.db 0x0d
	.db 0x00
;../generic/usbdisk.c:28: select_mode_t usbdisk_select_dsk_file (bool whole_disk_allowed)
;	---------------------------------
; Function usbdisk_select_dsk_file
; ---------------------------------
_usbdisk_select_dsk_file::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-365
	add	hl, sp
	ld	sp, hl
;../generic/usbdisk.c:36: if (supports_80_column_mode())
	call	_supports_80_column_mode
	bit	0, l
	jr	Z, 00102$
;../generic/usbdisk.c:37: nr_dsks_per_line = 6;
	ld	-12 (ix), #0x06
	jr	00103$
00102$:
;../generic/usbdisk.c:39: nr_dsks_per_line = 3;
	ld	-12 (ix), #0x03
00103$:
;../generic/usbdisk.c:42: ch376_set_filename ("/DSKS");
	ld	hl, #___str_11
	push	hl
	call	_ch376_set_filename
	pop	af
;../generic/usbdisk.c:43: if (!ch376_open_directory())
	call	_ch376_open_directory
	bit	0, l
	jr	NZ, 00107$
;../generic/usbdisk.c:45: ch376_set_filename ("/");
	ld	hl, #___str_12
	push	hl
	call	_ch376_set_filename
	pop	af
;../generic/usbdisk.c:46: if (!ch376_open_directory())
	call	_ch376_open_directory
	bit	0, l
	jr	NZ, 00107$
;../generic/usbdisk.c:47: error ("-Directory not opened");
	ld	hl, #___str_13
	push	hl
	call	_error
	pop	af
00107$:
;../generic/usbdisk.c:49: ch376_set_filename ("*");
	ld	hl, #___str_14
	push	hl
	call	_ch376_set_filename
	pop	af
;../generic/usbdisk.c:50: if (!ch376_open_search ())
	call	_ch376_open_search
	bit	0, l
	jr	NZ, 00109$
;../generic/usbdisk.c:51: error ("-No files found");
	ld	hl, #___str_15
	push	hl
	call	_error
	pop	af
00109$:
;../generic/usbdisk.c:53: if (whole_disk_allowed)
	bit	0, 4 (ix)
	jr	Z, 00154$
;../generic/usbdisk.c:56: printf (" 1.FLOPPY   2.USBDRIVE\r\n");
	ld	hl, #___str_29
	push	hl
	call	_puts
	pop	af
;../generic/usbdisk.c:58: do 
00154$:
	ld	hl, #32
	add	hl, sp
	ld	-11 (ix), l
	ld	-10 (ix), h
	ld	hl, #344
	add	hl, sp
	ld	-9 (ix), l
	ld	-8 (ix), h
	ld	a, -9 (ix)
	ld	-7 (ix), a
	ld	a, -8 (ix)
	ld	-6 (ix), a
	ld	hl, #0
	add	hl, sp
	ld	-5 (ix), l
	ld	-4 (ix), h
	ld	a, -5 (ix)
	ld	-3 (ix), a
	ld	a, -4 (ix)
	ld	-2 (ix), a
	ld	-1 (ix), #0
00126$:
;../generic/usbdisk.c:60: ch376_get_fat_info (&info);
	ld	c, -5 (ix)
	ld	b, -4 (ix)
	push	bc
	call	_ch376_get_fat_info
	pop	af
;../generic/usbdisk.c:62: if ((info.DIR_Attr==0x20 || info.DIR_Attr==0x00) &&
	ld	l, -3 (ix)
	ld	h, -2 (ix)
	ld	de, #0x000b
	add	hl, de
	ld	a, (hl)
	cp	a, #0x20
	jr	Z, 00122$
	or	a, a
	jp	NZ, 00127$
00122$:
;../generic/usbdisk.c:63: info.DIR_Name[8]=='D' &&
	ld	c, -5 (ix)
	ld	b, -4 (ix)
	ld	hl, #8
	add	hl, bc
	ld	a, (hl)
	sub	a, #0x44
	jp	NZ,00127$
;../generic/usbdisk.c:64: info.DIR_Name[9]=='S' &&
	ld	c, -5 (ix)
	ld	b, -4 (ix)
	ld	hl, #9
	add	hl, bc
	ld	a, (hl)
	sub	a, #0x53
	jp	NZ,00127$
;../generic/usbdisk.c:65: info.DIR_Name[10]=='K')
	ld	c, -5 (ix)
	ld	b, -4 (ix)
	ld	hl, #10
	add	hl, bc
	ld	a, (hl)
	sub	a, #0x4b
	jp	NZ,00127$
;../generic/usbdisk.c:67: if (nr_dsk_files_found==0)
	ld	a, -1 (ix)
	or	a, a
	jr	NZ, 00116$
;../generic/usbdisk.c:69: if (!whole_disk_allowed)
	bit	0, 4 (ix)
	jr	NZ, 00113$
;../generic/usbdisk.c:70: printf ("Select DSK image:\r\n");
	ld	hl, #___str_21
	push	hl
	call	_puts
	pop	af
	jr	00116$
00113$:
;../generic/usbdisk.c:72: printf ("+Or, select DSK image:\r\n");
	ld	hl, #___str_23
	push	hl
	call	_puts
	pop	af
00116$:
;../generic/usbdisk.c:74: strncpy (files[nr_dsk_files_found],(char*)info.DIR_Name,11);
	ld	c, -1 (ix)
	ld	b, #0x00
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	a, -11 (ix)
	add	a, e
	ld	c, a
	ld	a, -10 (ix)
	adc	a, d
	ld	b, a
	ld	e, c
	ld	d, b
	ld	l, -5 (ix)
	ld	h, -4 (ix)
	push	bc
;size	4
;size	3
;size	2
;size	1
	ld	bc, #0x000b
	xor	a, a
00250$:
	cp	a, (hl)
	ldi
	jp	PO, 00249$
	jr	NZ, 00250$
00251$:
	dec	hl
	ldi
	jp	PE, 00251$
00249$:
	pop	bc
;../generic/usbdisk.c:75: files[nr_dsk_files_found][11] = '\0';
	ld	hl, #0x000b
	add	hl, bc
	ld	(hl), #0x00
;../generic/usbdisk.c:76: strncpy (filename,files[nr_dsk_files_found],8);
	ld	e, -9 (ix)
	ld	d, -8 (ix)
	ld	l, c
	ld	h, b
;size	4
;size	3
;size	2
;size	1
	ld	bc, #0x0008
	xor	a, a
00253$:
	cp	a, (hl)
	ldi
	jp	PO, 00252$
	jr	NZ, 00253$
00254$:
	dec	hl
	ldi
	jp	PE, 00254$
00252$:
;../generic/usbdisk.c:77: filename[8]='\0';
	ld	l, -9 (ix)
	ld	h, -8 (ix)
	ld	de, #0x0008
	add	hl, de
	ld	(hl), #0x00
;../generic/usbdisk.c:78: printf (" %c.%s",'A'+nr_dsk_files_found, filename);
	ld	c, -7 (ix)
	ld	b, -6 (ix)
	ld	e, -1 (ix)
	ld	d, #0x00
	ld	hl, #0x0041
	add	hl, de
	push	bc
	push	hl
	ld	hl, #___str_24
	push	hl
	call	_printf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
;../generic/usbdisk.c:79: nr_dsk_files_found++;
	inc	-1 (ix)
;../generic/usbdisk.c:80: if ((nr_dsk_files_found % nr_dsks_per_line) == 0)
	ld	h, -12 (ix)
	ld	l, -1 (ix)
	push	hl
	call	__moduchar
	pop	af
	ld	a, l
	or	a, a
	jr	NZ, 00127$
;../generic/usbdisk.c:81: printf ("\r\n");
	ld	hl, #___str_26
	push	hl
	call	_puts
	pop	af
00127$:
;../generic/usbdisk.c:84: while (ch376_next_search () && nr_dsk_files_found<MAX_FILES);
	call	_ch376_next_search
	bit	0, l
	jr	Z, 00161$
	ld	a, -1 (ix)
	sub	a, #0x1a
	jp	C, 00126$
00161$:
	ld	a, -1 (ix)
	ld	-2 (ix), a
;../generic/usbdisk.c:86: if (!whole_disk_allowed && nr_dsk_files_found==0)
	bit	0, 4 (ix)
	jr	NZ, 00130$
	ld	a, -1 (ix)
	or	a, a
	jr	NZ, 00130$
;../generic/usbdisk.c:87: return USB;
	ld	l, #0x01
	jr	00139$
00130$:
;../generic/usbdisk.c:89: printf ("\r\n");
	ld	hl, #___str_26
	push	hl
	call	_puts
	pop	af
;../generic/usbdisk.c:90: char c = getchar ();
	call	_getchar
;../generic/usbdisk.c:91: c = toupper (c);
	ld	h, #0x00
	push	hl
	call	_toupper
	pop	af
	ex	de, hl
;../generic/usbdisk.c:92: if (c>='A' && c<='A'+nr_dsk_files_found)
	ld	a, e
	sub	a, #0x41
	jr	C, 00135$
	ld	c, -2 (ix)
	ld	b, #0x00
	ld	hl, #0x0041
	add	hl, bc
	ld	c, e
	ld	b, #0x00
	ld	a, l
	sub	a, c
	ld	a, h
	sbc	a, b
	jp	PO, 00255$
	xor	a, #0x80
00255$:
	jp	M, 00135$
;../generic/usbdisk.c:94: c-='A';
	ld	a, e
	add	a, #0xbf
;../generic/usbdisk.c:95: ch376_set_filename (files[c]);
	ld	c, a
	ld	b, #0x00
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	a, e
	add	a, -11 (ix)
	ld	c, a
	ld	a, d
	adc	a, -10 (ix)
	ld	b, a
	push	bc
	call	_ch376_set_filename
	pop	af
;../generic/usbdisk.c:96: if (!ch376_open_file ())
	call	_ch376_open_file
	bit	0, l
	jr	NZ, 00133$
;../generic/usbdisk.c:97: error ("-DSK not opened\r\n");
	ld	hl, #___str_28
	push	hl
	call	_error
	pop	af
00133$:
;../generic/usbdisk.c:98: return DSK_IMAGE;
	ld	l, #0x02
	jr	00139$
00135$:
;../generic/usbdisk.c:100: if (c=='2')
	ld	a, e
	sub	a, #0x32
;../generic/usbdisk.c:101: return USB;
;../generic/usbdisk.c:102: return FLOPPY;
	ld	l, #0x01
	jr	Z, 00139$
	ld	l, #0x00
00139$:
;../generic/usbdisk.c:103: }
	ld	sp, ix
	pop	ix
	ret
___str_11:
	.ascii "/DSKS"
	.db 0x00
___str_12:
	.ascii "/"
	.db 0x00
___str_13:
	.ascii "-Directory not opened"
	.db 0x00
___str_14:
	.ascii "*"
	.db 0x00
___str_15:
	.ascii "-No files found"
	.db 0x00
___str_21:
	.ascii "Select DSK image:"
	.db 0x0d
	.db 0x00
___str_23:
	.ascii "+Or, select DSK image:"
	.db 0x0d
	.db 0x00
___str_24:
	.ascii " %c.%s"
	.db 0x00
___str_26:
	.db 0x0d
	.db 0x00
___str_28:
	.ascii "-DSK not opened"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_29:
	.ascii "+Select device:"
	.db 0x0d
	.db 0x0a
	.ascii " 1.FLOPPY   2.USBDRIVE"
	.db 0x0d
	.db 0x00
;../generic/usbdisk.c:105: bool read_write_file_sectors (bool writing,uint8_t nr_sectors,uint32_t* sector,uint8_t* sector_buffer)
;	---------------------------------
; Function read_write_file_sectors
; ---------------------------------
_read_write_file_sectors::
	ld	hl, #-10
	add	hl, sp
	ld	sp, hl
;../generic/usbdisk.c:108: if (!ch376_locate_sector ((uint8_t*)sector))
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
	jr	NZ, 00102$
;../generic/usbdisk.c:109: return false;
	ld	l, #0x00
	jp	00112$
00102$:
;../generic/usbdisk.c:110: if (!ch376_get_sector_LBA (nr_sectors,(uint8_t*) &sectors_lba))
	ld	hl, #0
	add	hl, sp
	ld	a, l
	ld	iy, #8
	add	iy, sp
	ld	0 (iy), a
	ld	1 (iy), h
	ld	c, 0 (iy)
	ld	b, 1 (iy)
	push	bc
	ld	hl, #15
	add	hl, sp
	ld	a, (hl)
	push	af
	inc	sp
	call	_ch376_get_sector_LBA
	pop	af
	inc	sp
	bit	0, l
	jr	NZ, 00104$
;../generic/usbdisk.c:111: return false;
	ld	l, #0x00
	jr	00112$
00104$:
;../generic/usbdisk.c:114: if (!ch376s_disk_read (sectors_lba[0],sectors_lba+4,sector_buffer))
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
;../generic/usbdisk.c:112: if (!writing)
	ld	hl, #12
	add	hl, sp
	bit	0, (hl)
	jr	NZ, 00110$
;../generic/usbdisk.c:114: if (!ch376s_disk_read (sectors_lba[0],sectors_lba+4,sector_buffer))
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
	jr	NZ, 00111$
;../generic/usbdisk.c:115: return false;
	ld	l, #0x00
	jr	00112$
00110$:
;../generic/usbdisk.c:119: if (!ch376s_disk_write (sectors_lba[0],sectors_lba+4,sector_buffer))
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
;../generic/usbdisk.c:120: return false;
;../generic/usbdisk.c:123: return true;
	ld	l, #0x00
	jr	Z, 00112$
00111$:
	ld	l, #0x01
00112$:
;../generic/usbdisk.c:124: }
	ld	iy, #10
	add	iy, sp
	ld	sp, iy
	ret
;../generic/usbdisk.c:126: bool read_write_disk_sectors (bool writing,uint8_t nr_sectors,uint32_t* sector,uint8_t* sector_buffer)
;	---------------------------------
; Function read_write_disk_sectors
; ---------------------------------
_read_write_disk_sectors::
	push	ix
	ld	ix,#0
	add	ix,sp
;../generic/usbdisk.c:130: if (!ch376s_disk_read (nr_sectors,(uint8_t*)sector,sector_buffer))
	ld	c, 6 (ix)
	ld	b, 7 (ix)
;../generic/usbdisk.c:128: if (!writing)
	bit	0, 4 (ix)
	jr	NZ, 00106$
;../generic/usbdisk.c:130: if (!ch376s_disk_read (nr_sectors,(uint8_t*)sector,sector_buffer))
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
	jr	NZ, 00107$
;../generic/usbdisk.c:131: return false;
	ld	l, #0x00
	jr	00108$
00106$:
;../generic/usbdisk.c:135: if (!ch376s_disk_write (nr_sectors,(uint8_t*)sector,sector_buffer))
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
;../generic/usbdisk.c:136: return false;
;../generic/usbdisk.c:139: return true;
	ld	l, #0x00
	jr	Z, 00108$
00107$:
	ld	l, #0x01
00108$:
;../generic/usbdisk.c:140: }
	pop	ix
	ret
;../generic/usbdisk.c:142: bool usbdisk_close_dsk_file ()
;	---------------------------------
; Function usbdisk_close_dsk_file
; ---------------------------------
_usbdisk_close_dsk_file::
;../generic/usbdisk.c:144: return ch376_close_file();
	call	_ch376_close_file
	ld	a, h
	or	a, l
	add	a, #0xff
	ld	a, #0x00
	rla
	ld	l, a
;../generic/usbdisk.c:145: }
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
