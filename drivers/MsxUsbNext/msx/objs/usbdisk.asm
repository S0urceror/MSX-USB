;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.1.0 #12072 (Mac OS X ppc)
;--------------------------------------------------------
	.module usbdisk
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _read_write_disk_sectors
	.globl _read_write_file_sectors
	.globl _usbdisk_select_dsk_file
	.globl _usbdisk_init
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
	.globl _puts
	.globl _printf
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
;../generic/usbdisk.c:8: void usbdisk_init ()
;	---------------------------------
; Function usbdisk_init
; ---------------------------------
_usbdisk_init::
;../generic/usbdisk.c:10: printf ("MSXUSB-NXT v0.1 (c)Sourceror\r\n");
	ld	hl, #___str_1
	push	hl
	call	_puts
	pop	af
;../generic/usbdisk.c:11: ch376_reset_all();
	call	_ch376_reset_all
;../generic/usbdisk.c:12: if (!ch376_plugged_in())
	call	_ch376_plugged_in
	bit	0, l
	jr	NZ, 00102$
;../generic/usbdisk.c:13: error ("-CH376 NOT detected");
	ld	hl, #___str_2
	push	hl
	call	_error
	pop	af
00102$:
;../generic/usbdisk.c:14: printf ("+CH376 detected\r\n");
	ld	hl, #___str_4
	push	hl
	call	_puts
;../generic/usbdisk.c:15: ch376_set_usb_host_mode(USB_MODE_HOST);
	ld	h,#0x06
	ex	(sp),hl
	inc	sp
	call	_ch376_set_usb_host_mode
	inc	sp
;../generic/usbdisk.c:16: if (!ch376_connect_disk ())
	call	_ch376_connect_disk
	bit	0, l
	jr	NZ, 00104$
;../generic/usbdisk.c:17: error ("-Connect USB device");
	ld	hl, #___str_5
	push	hl
	call	_error
	pop	af
00104$:
;../generic/usbdisk.c:18: printf ("+USB device connected\r\n");
	ld	hl, #___str_7
	push	hl
	call	_puts
	pop	af
;../generic/usbdisk.c:19: if (!ch376_mount_disk ())
	call	_ch376_mount_disk
	bit	0, l
	jr	NZ, 00106$
;../generic/usbdisk.c:20: error ("-Not a valid disk");
	ld	hl, #___str_8
	push	hl
	call	_error
	pop	af
00106$:
;../generic/usbdisk.c:21: printf ("+USB disk mounted\r\n");
	ld	hl, #___str_10
	push	hl
	call	_puts
	pop	af
;../generic/usbdisk.c:22: }
	ret
___str_1:
	.ascii "MSXUSB-NXT v0.1 (c)Sourceror"
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
;../generic/usbdisk.c:24: bool usbdisk_select_dsk_file ()
;	---------------------------------
; Function usbdisk_select_dsk_file
; ---------------------------------
_usbdisk_select_dsk_file::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-161
	add	hl, sp
	ld	sp, hl
;../generic/usbdisk.c:32: ch376_set_filename ("/");
	ld	hl, #___str_11
	push	hl
	call	_ch376_set_filename
	pop	af
;../generic/usbdisk.c:33: if (!ch376_open_directory())
	call	_ch376_open_directory
	bit	0, l
	jr	NZ, 00102$
;../generic/usbdisk.c:34: error ("-Directory not opened");
	ld	hl, #___str_12
	push	hl
	call	_error
	pop	af
00102$:
;../generic/usbdisk.c:36: ch376_set_filename ("*");
	ld	hl, #___str_13
	push	hl
	call	_ch376_set_filename
	pop	af
;../generic/usbdisk.c:37: if (!ch376_open_search ())
	call	_ch376_open_search
	bit	0, l
	jr	NZ, 00104$
;../generic/usbdisk.c:38: error ("-No files found");
	ld	hl, #___str_14
	push	hl
	call	_error
	pop	af
00104$:
;../generic/usbdisk.c:41: printf (" [D] USBDRIVE\r\n");
	ld	hl, #___str_24
	push	hl
	call	_puts
	pop	af
;../generic/usbdisk.c:42: do 
	ld	hl, #32
	add	hl, sp
	ex	de, hl
	ld	hl, #140
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
	ld	-6 (ix), a
	ld	a, -7 (ix)
	ld	-5 (ix), a
	ld	c, #0x00
00114$:
;../generic/usbdisk.c:44: ch376_get_fat_info (&info);
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	push	bc
	push	de
	push	hl
	call	_ch376_get_fat_info
	pop	af
	pop	de
	pop	bc
;../generic/usbdisk.c:46: if ((info.DIR_Attr==0x20 || info.DIR_Attr==0x00) &&
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	push	bc
	ld	bc, #0x000b
	add	hl, bc
	pop	bc
	ld	a, (hl)
	cp	a, #0x20
	jr	Z, 00110$
	or	a, a
	jp	NZ, 00115$
00110$:
;../generic/usbdisk.c:47: info.DIR_Name[8]=='D' &&
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	push	bc
	ld	bc, #0x0008
	add	hl, bc
	pop	bc
	ld	a, (hl)
	sub	a, #0x44
	jp	NZ,00115$
;../generic/usbdisk.c:48: info.DIR_Name[9]=='S' &&
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	push	bc
	ld	bc, #0x0009
	add	hl, bc
	pop	bc
	ld	a, (hl)
	sub	a, #0x53
	jp	NZ,00115$
;../generic/usbdisk.c:49: info.DIR_Name[10]=='K')
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	push	bc
	ld	bc, #0x000a
	add	hl, bc
	pop	bc
	ld	a, (hl)
;../generic/usbdisk.c:52: strncpy (files[nr_dsk_files_found],(char*)info.DIR_Name,11);
	sub	a,#0x4b
	jp	NZ,00115$
	ld	b,a
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, de
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	a, -4 (ix)
	ld	-2 (ix), a
	ld	a, -3 (ix)
	ld	-1 (ix), a
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	push	bc
	push	de
	ld	e, -2 (ix)
	ld	d, -1 (ix)
	ld	bc, #0x000b
	xor	a, a
00193$:
	cp	a, (hl)
	ldi
	jp	PO, 00192$
	jr	NZ, 00193$
00194$:
	dec	hl
	ldi
	jp	PE, 00194$
00192$:
	pop	de
	pop	bc
;../generic/usbdisk.c:53: files[nr_dsk_files_found][11] = '\0';
	ld	a, -4 (ix)
	add	a, #0x0b
	ld	b, a
	ld	a, -3 (ix)
	adc	a, #0x00
	ld	l, b
	ld	h, a
	ld	(hl), #0x00
;../generic/usbdisk.c:54: strncpy (filename,files[nr_dsk_files_found],8);
	ld	a, -12 (ix)
	ld	-2 (ix), a
	ld	a, -11 (ix)
	ld	-1 (ix), a
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	push	bc
	push	de
	ld	e, -2 (ix)
	ld	d, -1 (ix)
	ld	bc, #0x0008
	xor	a, a
00196$:
	cp	a, (hl)
	ldi
	jp	PO, 00195$
	jr	NZ, 00196$
00197$:
	dec	hl
	ldi
	jp	PE, 00197$
00195$:
	pop	de
	pop	bc
;../generic/usbdisk.c:55: filename[8]='\0';
	ld	a, -12 (ix)
	add	a, #0x08
	ld	b, a
	ld	a, -11 (ix)
	adc	a, #0x00
	ld	l, b
	ld	h, a
	ld	(hl), #0x00
;../generic/usbdisk.c:56: printf (" [%d] %s",nr_dsk_files_found+1, filename);
	ld	a, -10 (ix)
	ld	-4 (ix), a
	ld	a, -9 (ix)
	ld	-3 (ix), a
	ld	-2 (ix), c
	ld	-1 (ix), #0
	ld	l, c
	ld	h, #0
	inc	hl
	push	bc
	push	de
	push	hl
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	ex	(sp), hl
	push	hl
	ld	hl, #___str_19
	push	hl
	call	_printf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
	pop	de
	pop	bc
;../generic/usbdisk.c:57: if (nr_dsk_files_found%2)
	bit	0, -2 (ix)
	jr	Z, 00106$
;../generic/usbdisk.c:58: printf ("\r\n");
	push	bc
	push	de
	ld	hl, #___str_21
	push	hl
	call	_puts
	pop	af
	pop	de
	pop	bc
00106$:
;../generic/usbdisk.c:59: nr_dsk_files_found++;
	inc	c
00115$:
;../generic/usbdisk.c:62: while (ch376_next_search () && nr_dsk_files_found<9);
	push	bc
	push	de
	call	_ch376_next_search
	pop	de
	pop	bc
	bit	0, l
	jr	Z, 00116$
	ld	a, c
	sub	a, #0x09
	jp	C, 00114$
00116$:
;../generic/usbdisk.c:64: printf ("\r\n");
	push	bc
	push	de
	ld	hl, #___str_21
	push	hl
	call	_puts
	pop	af
	call	_getchar
	pop	de
	pop	bc
;../generic/usbdisk.c:66: if (c>='1' && c<='0'+nr_dsk_files_found)
	ld	-1 (ix), l
	ld	a, l
	sub	a, #0x31
	jr	C, 00120$
	ld	b, #0x00
	ld	hl, #0x0030
	add	hl, bc
	ld	c, -1 (ix)
	ld	b, #0x00
	ld	a, l
	sub	a, c
	ld	a, h
	sbc	a, b
	jp	PO, 00199$
	xor	a, #0x80
00199$:
	jp	M, 00120$
;../generic/usbdisk.c:68: c-='0';
	ld	a, -1 (ix)
	add	a, #0xd0
;../generic/usbdisk.c:69: ch376_set_filename (files[c-1]);
	dec	a
	ld	c, a
	rlca
	sbc	a, a
	ld	b, a
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, de
	push	hl
	call	_ch376_set_filename
	pop	af
;../generic/usbdisk.c:70: if (!ch376_open_file ())
	call	_ch376_open_file
	bit	0, l
	jr	NZ, 00118$
;../generic/usbdisk.c:71: error ("-DSK not opened\r\n");
	ld	hl, #___str_23
	push	hl
	call	_error
	pop	af
00118$:
;../generic/usbdisk.c:72: return true;
	ld	l, #0x01
	jr	00122$
00120$:
;../generic/usbdisk.c:74: return false;
	ld	l, #0x00
00122$:
;../generic/usbdisk.c:75: }
	ld	sp, ix
	pop	ix
	ret
___str_11:
	.ascii "/"
	.db 0x00
___str_12:
	.ascii "-Directory not opened"
	.db 0x00
___str_13:
	.ascii "*"
	.db 0x00
___str_14:
	.ascii "-No files found"
	.db 0x00
___str_19:
	.ascii " [%d] %s"
	.db 0x00
___str_21:
	.db 0x0d
	.db 0x00
___str_23:
	.ascii "-DSK not opened"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_24:
	.ascii "+Select DSK:"
	.db 0x0d
	.db 0x0a
	.ascii " [D] USBDRIVE"
	.db 0x0d
	.db 0x00
;../generic/usbdisk.c:77: bool read_write_file_sectors (bool writing,uint8_t nr_sectors,uint32_t* sector,uint8_t* sector_buffer)
;	---------------------------------
; Function read_write_file_sectors
; ---------------------------------
_read_write_file_sectors::
	ld	hl, #-10
	add	hl, sp
	ld	sp, hl
;../generic/usbdisk.c:80: if (!ch376_locate_sector ((uint8_t*)sector))
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
;../generic/usbdisk.c:81: return false;
	ld	l, #0x00
	jp	00112$
00102$:
;../generic/usbdisk.c:82: if (!ch376_get_sector_LBA (nr_sectors,(uint8_t*) &sectors_lba))
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
;../generic/usbdisk.c:83: return false;
	ld	l, #0x00
	jr	00112$
00104$:
;../generic/usbdisk.c:86: if (!ch376s_disk_read (sectors_lba[0],sectors_lba+4,sector_buffer))
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
;../generic/usbdisk.c:84: if (!writing)
	ld	hl, #12
	add	hl, sp
	bit	0, (hl)
	jr	NZ, 00110$
;../generic/usbdisk.c:86: if (!ch376s_disk_read (sectors_lba[0],sectors_lba+4,sector_buffer))
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
;../generic/usbdisk.c:87: return false;
	ld	l, #0x00
	jr	00112$
00110$:
;../generic/usbdisk.c:91: if (!ch376s_disk_write (sectors_lba[0],sectors_lba+4,sector_buffer))
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
;../generic/usbdisk.c:92: return false;
;../generic/usbdisk.c:95: return true;
	ld	l, #0x00
	jr	Z, 00112$
00111$:
	ld	l, #0x01
00112$:
;../generic/usbdisk.c:96: }
	ld	iy, #10
	add	iy, sp
	ld	sp, iy
	ret
;../generic/usbdisk.c:98: bool read_write_disk_sectors (bool writing,uint8_t nr_sectors,uint32_t* sector,uint8_t* sector_buffer)
;	---------------------------------
; Function read_write_disk_sectors
; ---------------------------------
_read_write_disk_sectors::
	push	ix
	ld	ix,#0
	add	ix,sp
;../generic/usbdisk.c:102: if (!ch376s_disk_read (nr_sectors,(uint8_t*)sector,sector_buffer))
	ld	c, 6 (ix)
	ld	b, 7 (ix)
;../generic/usbdisk.c:100: if (!writing)
	bit	0, 4 (ix)
	jr	NZ, 00106$
;../generic/usbdisk.c:102: if (!ch376s_disk_read (nr_sectors,(uint8_t*)sector,sector_buffer))
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
;../generic/usbdisk.c:103: return false;
	ld	l, #0x00
	jr	00108$
00106$:
;../generic/usbdisk.c:107: if (!ch376s_disk_write (nr_sectors,(uint8_t*)sector,sector_buffer))
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
;../generic/usbdisk.c:108: return false;
;../generic/usbdisk.c:111: return true;
	ld	l, #0x00
	jr	Z, 00108$
00107$:
	ld	l, #0x01
00108$:
;../generic/usbdisk.c:112: }
	pop	ix
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
