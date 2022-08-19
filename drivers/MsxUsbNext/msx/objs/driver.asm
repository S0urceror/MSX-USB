;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Mac OS X ppc)
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
	.globl _read_write_disk_sectors
	.globl _read_write_file_sectors
	.globl _usbdisk_select_dsk_file
	.globl _usbdisk_autoexec_dsk
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
	ld	de, #0x0002
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
	ld	c, l
	ld	b, h
;driver.c:93: workarea->disk_change = false;
	ld	e, c
	ld	d, b
	inc	de
	xor	a, a
	ld	(de), a
;driver.c:94: usbdisk_init ();
	push	bc
	call	_usbdisk_init
	call	_usbdisk_autoexec_dsk
	ld	e, a
	pop	bc
	bit	0, e
	jr	Z, 00102$
;driver.c:96: workarea->mount_mode = 2;
	ld	a, #0x02
	ld	(bc), a
	jr	00103$
00102$:
;driver.c:98: workarea->mount_mode = usbdisk_select_dsk_file ("/");
	push	bc
	ld	hl, #___str_0
	call	_usbdisk_select_dsk_file
	pop	bc
	ld	(bc), a
00103$:
;driver.c:99: switch (workarea->mount_mode)
	ld	a, (bc)
	cp	a, #0x01
	jr	Z, 00105$
	sub	a, #0x02
	jr	NZ, 00106$
;driver.c:102: printf ("+Opened disk image\r\n");
;driver.c:103: break;
	ld	hl, #___str_2
	jp	_puts
;driver.c:104: case 1:
00105$:
;driver.c:105: printf ("+Full disk mode\r\n");
;driver.c:106: break;
	ld	hl, #___str_4
	jp	_puts
;driver.c:107: default:
00106$:
;driver.c:108: printf ("+Using floppy disk\r\n");
	ld	hl, #___str_6
;driver.c:110: }   
;driver.c:111: }
	jp	_puts
___str_0:
	.ascii "/"
	.db 0x00
___str_2:
	.ascii "+Opened disk image"
	.db 0x0d
	.db 0x00
___str_4:
	.ascii "+Full disk mode"
	.db 0x0d
	.db 0x00
___str_6:
	.ascii "+Using floppy disk"
	.db 0x0d
	.db 0x00
;driver.c:113: void onCallMOUNTDSK ()
;	---------------------------------
; Function onCallMOUNTDSK
; ---------------------------------
_onCallMOUNTDSK::
;driver.c:115: hal_init ();
	call	_hal_init
;driver.c:116: workarea_t* workarea = get_workarea();
	call	_get_workarea
;driver.c:117: workarea->disk_change = true;
;	spillPairReg hl
;	spillPairReg hl
	ld	e, l
	ld	d, h
;	spillPairReg hl
;	spillPairReg hl
	inc	hl
	ld	(hl), #0x01
;driver.c:118: usbdisk_init ();
	push	de
	call	_usbdisk_init
	ld	hl, #___str_7
	call	_usbdisk_select_dsk_file
	pop	de
	ld	(de), a
;driver.c:120: switch (workarea->mount_mode)
	push	af
	ld	a, (de)
	ld	c, a
	pop	af
	dec	a
	jr	Z, 00102$
	ld	a, c
	sub	a, #0x02
	jr	NZ, 00103$
;driver.c:123: printf ("+Opened disk image\r\n");
;driver.c:124: break;
	ld	hl, #___str_9
	jp	_puts
;driver.c:125: case 1:
00102$:
;driver.c:126: printf ("+Full disk mode\r\n");
;driver.c:127: break;
	ld	hl, #___str_11
	jp	_puts
;driver.c:128: default:
00103$:
;driver.c:129: printf ("+Using floppy disk\r\n");
	ld	hl, #___str_13
;driver.c:131: }   
;driver.c:132: }
	jp	_puts
___str_7:
	.ascii "/"
	.db 0x00
___str_9:
	.ascii "+Opened disk image"
	.db 0x0d
	.db 0x00
___str_11:
	.ascii "+Full disk mode"
	.db 0x0d
	.db 0x00
___str_13:
	.ascii "+Using floppy disk"
	.db 0x0d
	.db 0x00
;driver.c:144: uint8_t get_nr_drives_boottime (uint8_t reduced_drive_count,uint8_t dos_mode)
;	---------------------------------
; Function get_nr_drives_boottime
; ---------------------------------
_get_nr_drives_boottime::
;driver.c:150: workarea_t* workarea = get_workarea();
	call	_get_workarea
;driver.c:151: if (workarea->mount_mode==0)
	ld	a, (hl)
;driver.c:152: return 0;
	or	a,a
	ret	Z
;driver.c:154: return 1; // 1 drive requested
	ld	a, #0x01
;driver.c:155: }
	ret
;driver.c:167: uint16_t get_drive_config (uint8_t relative_drive_number,uint8_t dos_mode)
;	---------------------------------
; Function get_drive_config
; ---------------------------------
_get_drive_config::
;driver.c:173: return 0x0101; // device 1, lun 1
	ld	de, #0x0101
;driver.c:174: }
	ret
;driver.c:212: uint8_t get_lun_info (uint8_t nr_lun,uint8_t nr_device,luninfo_t* luninfo)
;	---------------------------------
; Function get_lun_info
; ---------------------------------
_get_lun_info::
	ld	c, a
;driver.c:218: if (nr_lun==1 && nr_device==1)
	dec	c
	jr	NZ, 00102$
	dec	l
	jr	NZ, 00102$
;driver.c:220: memset (luninfo,0,sizeof (luninfo_t));
	pop	de
	pop	hl
	push	hl
	push	de
	ld	b, #0x0c
00120$:
	ld	(hl), #0x00
	inc	hl
	djnz	00120$
;driver.c:222: luninfo->sector_size = 512;
	pop	hl
	pop	bc
	push	bc
	push	hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	inc	hl
	ld	(hl), #0x00
	inc	hl
	ld	(hl), #0x02
;driver.c:224: luninfo->flags = 0b00000001; // ; removable + non-read only + no floppy
	ld	hl, #0x0007
	add	hl, bc
	ld	(hl), #0x01
;driver.c:228: return 0x00;
	xor	a, a
	jr	00104$
00102$:
;driver.c:231: return 0x01;
	ld	a, #0x01
00104$:
;driver.c:232: }
	pop	hl
	pop	bc
	jp	(hl)
;driver.c:271: uint8_t get_device_info (uint8_t nr_info,uint8_t nr_device,uint8_t* info_buffer)
;	---------------------------------
; Function get_device_info
; ---------------------------------
_get_device_info::
	ld	c, a
;driver.c:277: if (nr_device!=1)
	dec	l
	jr	Z, 00102$
;driver.c:278: return 1;
	ld	a, #0x01
	jr	00109$
00102$:
;driver.c:280: switch (nr_info)
	ld	a, c
	or	a, a
	jr	Z, 00103$
	ld	a, c
	dec	a
	jr	Z, 00104$
	ld	a,c
	cp	a,#0x02
	jr	Z, 00105$
	sub	a, #0x03
	jr	Z, 00106$
	jr	00107$
;driver.c:282: case 0: // basic information
00103$:
;driver.c:283: ((deviceinfo_t*)info_buffer)->nr_luns = 0x01;
	pop	de
	pop	hl
	push	hl
	push	de
	ld	(hl), #0x01
;driver.c:284: ((deviceinfo_t*)info_buffer)->flags = 0x00;
	pop	hl
	pop	bc
	push	bc
	push	hl
	inc	bc
	xor	a, a
	ld	(bc), a
;driver.c:285: break;
	jr	00108$
;driver.c:286: case 1: // Manufacturer name string
00104$:
;driver.c:287: strcpy ((char*)info_buffer,"S0urceror");
	ld	iy, #2
	add	iy, sp
	ld	e, 0 (iy)
	ld	d, 1 (iy)
	ld	hl, #___str_14
	xor	a, a
00141$:
	cp	a, (hl)
	ldi
	jr	NZ, 00141$
;driver.c:288: break;
	jr	00108$
;driver.c:289: case 2: // Device name string
00105$:
;driver.c:290: strcpy ((char*)info_buffer,"MSXUSBNext");
	ld	iy, #2
	add	iy, sp
	ld	e, 0 (iy)
	ld	d, 1 (iy)
	ld	hl, #___str_15
	xor	a, a
00142$:
	cp	a, (hl)
	ldi
	jr	NZ, 00142$
;driver.c:291: break;
	jr	00108$
;driver.c:292: case 3: // Serial number string
00106$:
;driver.c:293: strcpy ((char*)info_buffer,"0000");
	ld	iy, #2
	add	iy, sp
	ld	e, 0 (iy)
	ld	d, 1 (iy)
	ld	hl, #___str_16
	xor	a, a
00143$:
	cp	a, (hl)
	ldi
	jr	NZ, 00143$
;driver.c:294: break;
	jr	00108$
;driver.c:295: default:
00107$:
;driver.c:296: return 2;
	ld	a, #0x02
	jr	00109$
;driver.c:298: }
00108$:
;driver.c:299: return 0;
	xor	a, a
00109$:
;driver.c:300: }
	pop	hl
	pop	bc
	jp	(hl)
___str_14:
	.ascii "S0urceror"
	.db 0x00
___str_15:
	.ascii "MSXUSBNext"
	.db 0x00
___str_16:
	.ascii "0000"
	.db 0x00
;driver.c:331: uint8_t get_device_status (uint8_t nr_lun,uint8_t nr_device)
;	---------------------------------
; Function get_device_status
; ---------------------------------
_get_device_status::
	ld	c, a
;driver.c:337: if (nr_device!=1 || nr_lun!=1)
	dec	l
	jr	NZ, 00101$
	dec	c
	jr	Z, 00102$
00101$:
;driver.c:338: return 0;
	xor	a, a
	ret
00102$:
;driver.c:340: workarea_t* workarea = get_workarea();
	call	_get_workarea
;driver.c:341: if (workarea->disk_change)
	inc	hl
	bit	0, (hl)
	jr	Z, 00105$
;driver.c:343: workarea->disk_change = false;
	ld	(hl), #0x00
;driver.c:344: return 2;
	ld	a, #0x02
	ret
00105$:
;driver.c:347: return 1;
	ld	a, #0x01
;driver.c:348: }
	ret
;driver.c:350: void caps_flash () __z88dk_fastcall __naked
;	---------------------------------
; Function caps_flash
; ---------------------------------
_caps_flash::
;driver.c:365: __endasm;
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
;driver.c:366: }
;driver.c:393: diskerror_t read_or_write_sector (uint8_t read_or_write_flag, uint8_t nr_device, uint8_t nr_lun, uint8_t nr_sectors, uint32_t* sector, uint8_t* sector_buffer)
;	---------------------------------
; Function read_or_write_sector
; ---------------------------------
_read_or_write_sector::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	c, a
	ld	b, l
;driver.c:402: workarea_t* workarea = get_workarea();
	push	bc
	call	_get_workarea
	pop	bc
;driver.c:405: if (nr_device!=1 || nr_lun!=1)
	djnz	00101$
	ld	a, 4 (ix)
	dec	a
	jr	Z, 00102$
00101$:
;driver.c:406: return IDEVL;
	ld	a, #0xb5
	jr	00111$
00102$:
;driver.c:408: caps_flash ();
	push	hl
	push	bc
	call	_caps_flash
	pop	bc
	pop	hl
;driver.c:410: if (workarea->mount_mode==2)
	ld	b, (hl)
;driver.c:414: if (!read_write_file_sectors (read_or_write_flag & Z80_CARRY_MASK,nr_sectors,sector,sector_buffer))
	ld	a, c
	and	a, #0x01
	ld	c, a
;driver.c:410: if (workarea->mount_mode==2)
	ld	a, b
	sub	a, #0x02
	jr	NZ, 00109$
;driver.c:414: if (!read_write_file_sectors (read_or_write_flag & Z80_CARRY_MASK,nr_sectors,sector,sector_buffer))
	ld	l, 8 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 9 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	l, 6 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 7 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	l, 5 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	a, c
	call	_read_write_file_sectors
	bit	0,a
	jr	NZ, 00110$
;driver.c:415: return RNF;
	ld	a, #0xf9
	jr	00111$
00109$:
;driver.c:420: if (!read_write_disk_sectors (read_or_write_flag & Z80_CARRY_MASK,nr_sectors,sector,sector_buffer))
	ld	l, 8 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 9 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	l, 6 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 7 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	l, 5 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	a, c
	call	_read_write_disk_sectors
	bit	0,a
	jr	NZ, 00110$
;driver.c:421: return RNF;
	ld	a, #0xf9
	jr	00111$
00110$:
;driver.c:424: caps_flash ();
	call	_caps_flash
;driver.c:426: return OK;
	xor	a, a
00111$:
;driver.c:427: }
	pop	ix
	pop	hl
	pop	bc
	pop	bc
	pop	bc
	jp	(hl)
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
