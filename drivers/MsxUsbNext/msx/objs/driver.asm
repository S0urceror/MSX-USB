;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.1.0 #12072 (Mac OS X ppc)
;--------------------------------------------------------
	.module driver
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _read_or_write_sector
	.globl _caps_flash
	.globl _get_device_status
	.globl _get_device_info
	.globl _get_lun_info
	.globl _get_drive_config
	.globl _get_nr_drives_boottime
	.globl _onCallMOUNTDSK
	.globl _init_driver
	.globl _get_workarea_size
	.globl _interrupt
	.globl _get_workarea
	.globl _usbdisk_close_dsk_file
	.globl _read_write_disk_sectors
	.globl _read_write_file_sectors
	.globl _usbdisk_select_dsk_file
	.globl _usbdisk_init
	.globl _hal_init
	.globl _puts
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
;driver.c:12: workarea_t* get_workarea() __z88dk_fastcall __naked
;	---------------------------------
; Function get_workarea
; ---------------------------------
_get_workarea::
;driver.c:27: __endasm;
	GWORK	.equ 0x4045
	CALBNK	.equ 0x4042
	push	ix
	xor	a
	ex	af,af' ;'
	xor	a
	LD	ix,#GWORK
	call	CALBNK
	ld	l,0(ix)
	ld	h,1(ix)
	pop	ix
	ret
;driver.c:28: } 
;driver.c:36: void interrupt ()
;	---------------------------------
; Function interrupt
; ---------------------------------
_interrupt::
;driver.c:41: }
	ret
;driver.c:56: uint16_t get_workarea_size (uint8_t reduced_drive_count,uint8_t nr_available_drives)
;	---------------------------------
; Function get_workarea_size
; ---------------------------------
_get_workarea_size::
;driver.c:62: return sizeof (workarea_t);
	ld	hl, #0x0002
;driver.c:63: }
	ret
;driver.c:85: void init_driver (uint8_t reduced_drive_count,uint8_t nr_allocated_drives)
;	---------------------------------
; Function init_driver
; ---------------------------------
_init_driver::
;driver.c:91: hal_init ();
	call	_hal_init
;driver.c:92: workarea_t* workarea = get_workarea();
	call	_get_workarea
;driver.c:93: usbdisk_init ();
	push	hl
	call	_usbdisk_init
	ld	a, #0x01
	push	af
	inc	sp
	call	_usbdisk_select_dsk_file
	ld	a, l
	inc	sp
	pop	hl
	ld	(hl), a
;driver.c:95: switch (workarea->mount_mode)
	ld	c, (hl)
	dec	a
	jr	Z, 00102$
	ld	a, c
	sub	a, #0x02
	jr	NZ, 00103$
;driver.c:98: printf ("+Opened disk image\r\n");
	ld	hl, #___str_1
	push	hl
	call	_puts
	pop	af
;driver.c:99: break;
	ret
;driver.c:100: case 1:
00102$:
;driver.c:101: printf ("+Full disk mode\r\n");
	ld	hl, #___str_3
	push	hl
	call	_puts
	pop	af
;driver.c:102: break;
	ret
;driver.c:103: default:
00103$:
;driver.c:104: printf ("+Using floppy disk\r\n");
	ld	hl, #___str_5
	push	hl
	call	_puts
	pop	af
;driver.c:106: }   
;driver.c:107: }
	ret
___str_1:
	.ascii "+Opened disk image"
	.db 0x0d
	.db 0x00
___str_3:
	.ascii "+Full disk mode"
	.db 0x0d
	.db 0x00
___str_5:
	.ascii "+Using floppy disk"
	.db 0x0d
	.db 0x00
;driver.c:109: void onCallMOUNTDSK ()
;	---------------------------------
; Function onCallMOUNTDSK
; ---------------------------------
_onCallMOUNTDSK::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
;driver.c:112: workarea_t* workarea = get_workarea();
	call	_get_workarea
	ex	(sp), hl
;driver.c:113: if (workarea->mount_mode == 2)
	pop	hl
	push	hl
	ld	a, (hl)
	sub	a, #0x02
	jr	NZ, 00102$
;driver.c:115: usbdisk_close_dsk_file ();
	call	_usbdisk_close_dsk_file
00102$:
;driver.c:118: hal_init ();
	call	_hal_init
;driver.c:119: workarea->mount_mode = usbdisk_select_dsk_file (false);
	xor	a, a
	push	af
	inc	sp
	call	_usbdisk_select_dsk_file
	ld	a, l
	inc	sp
	pop	hl
	push	hl
	ld	(hl), a
;driver.c:120: switch (workarea->mount_mode)
	sub	a, #0x02
	jr	NZ, 00104$
;driver.c:123: printf ("+Opened disk image\r\n");
	ld	hl, #___str_7
	push	hl
	call	_puts
	pop	af
;driver.c:124: workarea->disk_change = true;
	pop	hl
	push	hl
	inc	hl
	ld	(hl), #0x01
;driver.c:125: break;
	jr	00106$
;driver.c:126: default:
00104$:
;driver.c:127: printf ("-Not a valid choice\r\n");
	ld	hl, #___str_9
	push	hl
	call	_puts
	pop	af
;driver.c:129: }
00106$:
;driver.c:130: }
	ld	sp, ix
	pop	ix
	ret
___str_7:
	.ascii "+Opened disk image"
	.db 0x0d
	.db 0x00
___str_9:
	.ascii "-Not a valid choice"
	.db 0x0d
	.db 0x00
;driver.c:142: uint8_t get_nr_drives_boottime (uint8_t reduced_drive_count,uint8_t dos_mode)
;	---------------------------------
; Function get_nr_drives_boottime
; ---------------------------------
_get_nr_drives_boottime::
;driver.c:148: workarea_t* workarea = get_workarea();
	call	_get_workarea
;driver.c:149: if (workarea->mount_mode==0)
	ld	a, (hl)
;driver.c:150: return 0;
	or	a,a
	jr	NZ, 00102$
	ld	l,a
	ret
00102$:
;driver.c:152: return 1; // 1 drive requested
	ld	l, #0x01
;driver.c:153: }
	ret
;driver.c:165: uint16_t get_drive_config (uint8_t relative_drive_number,uint8_t dos_mode)
;	---------------------------------
; Function get_drive_config
; ---------------------------------
_get_drive_config::
;driver.c:171: return 0x0101; // device 1, lun 1
	ld	hl, #0x0101
;driver.c:172: }
	ret
;driver.c:210: uint8_t get_lun_info (uint8_t nr_lun,uint8_t nr_device,luninfo_t* luninfo)
;	---------------------------------
; Function get_lun_info
; ---------------------------------
_get_lun_info::
;driver.c:216: if (nr_lun==1 && nr_device==1)
	ld	iy, #2
	add	iy, sp
	ld	a, 0 (iy)
	dec	a
	jr	NZ, 00102$
	ld	a, 1 (iy)
	inc	iy
	dec	a
	jr	NZ, 00102$
;driver.c:218: memset (luninfo,0,sizeof (luninfo_t));
	ld	l, 1 (iy)
	ld	h, 2 (iy)
	inc	iy
	ld	b, #0x0c
00120$:
	ld	(hl), #0x00
	inc	hl
	djnz	00120$
;driver.c:220: luninfo->sector_size = 512;
	ld	c, 0 (iy)
	ld	b, 1 (iy)
	ld	l, c
	ld	h, b
	inc	hl
	ld	(hl), #0x00
	inc	hl
	ld	(hl), #0x02
;driver.c:222: luninfo->flags = 0b00000001; // ; removable + non-read only + no floppy
	ld	hl, #0x0007
	add	hl, bc
	ld	(hl), #0x01
;driver.c:226: return 0x00;
	ld	l, #0x00
	ret
00102$:
;driver.c:229: return 0x01;
	ld	l, #0x01
;driver.c:230: }
	ret
;driver.c:269: uint8_t get_device_info (uint8_t nr_info,uint8_t nr_device,uint8_t* info_buffer)
;	---------------------------------
; Function get_device_info
; ---------------------------------
_get_device_info::
	push	ix
	ld	ix,#0
	add	ix,sp
;driver.c:275: if (nr_device!=1)
	ld	a, 5 (ix)
	dec	a
	jr	Z, 00102$
;driver.c:276: return 1;
	ld	l, #0x01
	jr	00109$
00102$:
;driver.c:278: switch (nr_info)
	ld	a, 4 (ix)
	or	a, a
	jr	Z, 00103$
	ld	a, 4 (ix)
	dec	a
	jr	Z, 00104$
	ld	a, 4 (ix)
	sub	a, #0x02
	jr	Z, 00105$
	ld	a, 4 (ix)
	sub	a, #0x03
	jr	Z, 00106$
	jr	00107$
;driver.c:280: case 0: // basic information
00103$:
;driver.c:281: ((deviceinfo_t*)info_buffer)->nr_luns = 0x01;
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	ld	(hl), #0x01
;driver.c:282: ((deviceinfo_t*)info_buffer)->flags = 0x00;
	ld	c, 6 (ix)
	ld	b, 7 (ix)
	inc	bc
	xor	a, a
	ld	(bc), a
;driver.c:283: break;
	jr	00108$
;driver.c:284: case 1: // Manufacturer name string
00104$:
;driver.c:285: strcpy ((char*)info_buffer,"S0urceror");
	ld	e, 6 (ix)
	ld	d, 7 (ix)
	ld	hl, #___str_10
	xor	a, a
00141$:
	cp	a, (hl)
	ldi
	jr	NZ, 00141$
;driver.c:286: break;
	jr	00108$
;driver.c:287: case 2: // Device name string
00105$:
;driver.c:288: strcpy ((char*)info_buffer,"MSXUSBNext");
	ld	e, 6 (ix)
	ld	d, 7 (ix)
	ld	hl, #___str_11
	xor	a, a
00142$:
	cp	a, (hl)
	ldi
	jr	NZ, 00142$
;driver.c:289: break;
	jr	00108$
;driver.c:290: case 3: // Serial number string
00106$:
;driver.c:291: strcpy ((char*)info_buffer,"0000");
	ld	e, 6 (ix)
	ld	d, 7 (ix)
	ld	hl, #___str_12
	xor	a, a
00143$:
	cp	a, (hl)
	ldi
	jr	NZ, 00143$
;driver.c:292: break;
	jr	00108$
;driver.c:293: default:
00107$:
;driver.c:294: return 2;
	ld	l, #0x02
	jr	00109$
;driver.c:296: }
00108$:
;driver.c:297: return 0;
	ld	l, #0x00
00109$:
;driver.c:298: }
	pop	ix
	ret
___str_10:
	.ascii "S0urceror"
	.db 0x00
___str_11:
	.ascii "MSXUSBNext"
	.db 0x00
___str_12:
	.ascii "0000"
	.db 0x00
;driver.c:329: uint8_t get_device_status (uint8_t nr_lun,uint8_t nr_device)
;	---------------------------------
; Function get_device_status
; ---------------------------------
_get_device_status::
;driver.c:335: if (nr_device!=1 || nr_lun!=1)
	ld	iy, #3
	add	iy, sp
	ld	a, 0 (iy)
	dec	a
	jr	NZ, 00101$
	ld	a, -1 (iy)
	dec	a
	jr	Z, 00102$
00101$:
;driver.c:336: return 0;
	ld	l, #0x00
	ret
00102$:
;driver.c:338: workarea_t* workarea = get_workarea();
	call	_get_workarea
;driver.c:339: if (workarea->disk_change)
	inc	hl
	bit	0, (hl)
;driver.c:340: return 2;
;driver.c:342: return 1;
	ld	l, #0x02
	ret	NZ
	ld	l, #0x01
;driver.c:343: }
	ret
;driver.c:345: void caps_flash () __z88dk_fastcall __naked
;	---------------------------------
; Function caps_flash
; ---------------------------------
_caps_flash::
;driver.c:360: __endasm;
;	CAPS FLASH
	in	a, (0xaa)
	bit	6,a
	jr	z, _CAPS_FLASH_ON
	res	6,a
	jr	_CAPS_FLASH
	_CAPS_FLASH_ON:
	set	6,a
	_CAPS_FLASH:
	out	(0xaa),a
	ret
;
;driver.c:361: }
;driver.c:388: diskerror_t read_or_write_sector (uint8_t read_or_write_flag, uint8_t nr_device, uint8_t nr_lun, uint8_t nr_sectors, uint32_t* sector, uint8_t* sector_buffer)
;	---------------------------------
; Function read_or_write_sector
; ---------------------------------
_read_or_write_sector::
	push	ix
	ld	ix,#0
	add	ix,sp
;driver.c:397: workarea_t* workarea = get_workarea();
	call	_get_workarea
;driver.c:400: if (nr_device!=1 || nr_lun!=1)
	ld	a, 5 (ix)
	dec	a
	jr	NZ, 00101$
	ld	a, 6 (ix)
	dec	a
	jr	Z, 00102$
00101$:
;driver.c:401: return IDEVL;
	ld	l, #0xb5
	jr	00111$
00102$:
;driver.c:403: caps_flash ();
	push	hl
	call	_caps_flash
	pop	hl
;driver.c:405: if (workarea->mount_mode==2)
	ld	e, (hl)
;driver.c:409: if (!read_write_file_sectors (read_or_write_flag & Z80_CARRY_MASK,nr_sectors,sector,sector_buffer))
	ld	a, 4 (ix)
	and	a, #0x01
	ld	c, a
;driver.c:405: if (workarea->mount_mode==2)
	ld	a, e
	sub	a, #0x02
	jr	NZ, 00109$
;driver.c:409: if (!read_write_file_sectors (read_or_write_flag & Z80_CARRY_MASK,nr_sectors,sector,sector_buffer))
	ld	a, c
	ld	l, 10 (ix)
	ld	h, 11 (ix)
	push	hl
	ld	l, 8 (ix)
	ld	h, 9 (ix)
	push	hl
	ld	h, 7 (ix)
	push	hl
	inc	sp
	push	af
	inc	sp
	call	_read_write_file_sectors
	pop	af
	pop	af
	pop	af
	bit	0, l
	jr	NZ, 00110$
;driver.c:410: return RNF;
	ld	l, #0xf9
	jr	00111$
00109$:
;driver.c:415: if (!read_write_disk_sectors (read_or_write_flag & Z80_CARRY_MASK,nr_sectors,sector,sector_buffer))
	ld	a, c
	ld	l, 10 (ix)
	ld	h, 11 (ix)
	push	hl
	ld	l, 8 (ix)
	ld	h, 9 (ix)
	push	hl
	ld	h, 7 (ix)
	push	hl
	inc	sp
	push	af
	inc	sp
	call	_read_write_disk_sectors
	pop	af
	pop	af
	pop	af
	bit	0, l
	jr	NZ, 00110$
;driver.c:416: return RNF;
	ld	l, #0xf9
	jr	00111$
00110$:
;driver.c:419: caps_flash ();
	call	_caps_flash
;driver.c:421: return OK;
	ld	l, #0x00
00111$:
;driver.c:422: }
	pop	ix
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
