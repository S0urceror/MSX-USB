;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.1.0 #12072 (Mac OS X x86_64)
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
;driver.c:11: workarea_t* get_workarea() __z88dk_fastcall __naked
;	---------------------------------
; Function get_workarea
; ---------------------------------
_get_workarea::
;driver.c:26: __endasm;
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
;driver.c:27: } 
;driver.c:35: void interrupt ()
;	---------------------------------
; Function interrupt
; ---------------------------------
_interrupt::
;driver.c:40: }
	ret
;driver.c:55: uint16_t get_workarea_size (uint8_t reduced_drive_count,uint8_t nr_available_drives)
;	---------------------------------
; Function get_workarea_size
; ---------------------------------
_get_workarea_size::
;driver.c:61: return 100;//sizeof (workarea_t);
	ld	hl, #0x0064
;driver.c:62: }
	ret
;driver.c:86: void init_driver (uint8_t reduced_drive_count,uint8_t nr_allocated_drives)
;	---------------------------------
; Function init_driver
; ---------------------------------
_init_driver::
	push	ix
	ld	ix,#0
	add	ix,sp
;driver.c:92: hal_init ();
	call	_hal_init
;driver.c:93: workarea_t* workarea = get_workarea();
	call	_get_workarea
;driver.c:94: usbdisk_init ();
	push	hl
	call	_usbdisk_init
	pop	de
;driver.c:95: workarea->disk_change = true;
	ld	l, e
	ld	h, d
	inc	hl
	ld	(hl), #0x01
;driver.c:96: if (usbdisk_autoexec_dsk()==true)
	push	de
	call	_usbdisk_autoexec_dsk
	pop	de
	bit	0, l
	jr	Z, 00102$
;driver.c:97: workarea->mount_mode = 2;
	ld	a, #0x02
	ld	(de), a
	jr	00103$
00102$:
;driver.c:99: workarea->mount_mode = usbdisk_select_dsk_file ("/");
	push	de
	ld	hl, #___str_0
	push	hl
	call	_usbdisk_select_dsk_file
	pop	af
	ld	a, l
	pop	de
	ld	(de), a
00103$:
;driver.c:100: switch (workarea->mount_mode)
	ld	a, (de)
	cp	a, #0x01
	jr	Z, 00105$
	sub	a, #0x02
	jr	NZ, 00106$
;driver.c:103: printf ("+Opened disk image\r\n");
	ld	hl, #___str_2
	push	hl
	call	_puts
	pop	af
;driver.c:104: break;
	jr	00108$
;driver.c:105: case 1:
00105$:
;driver.c:106: printf ("+Full disk mode\r\n");
	ld	hl, #___str_4
	push	hl
	call	_puts
	pop	af
;driver.c:107: break;
	jr	00108$
;driver.c:108: default:
00106$:
;driver.c:109: printf ("+Using floppy disk\r\n");
	ld	hl, #___str_6
	push	hl
	call	_puts
	pop	af
;driver.c:111: }   
00108$:
;driver.c:112: }
	pop	ix
	ret
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
;driver.c:114: void onCallMOUNTDSK ()
;	---------------------------------
; Function onCallMOUNTDSK
; ---------------------------------
_onCallMOUNTDSK::
;driver.c:116: hal_init ();
	call	_hal_init
;driver.c:117: workarea_t* workarea = get_workarea();
	call	_get_workarea
;driver.c:118: workarea->disk_change = true;
	ld	e, l
	ld	d, h
	inc	hl
	ld	(hl), #0x01
;driver.c:119: usbdisk_init ();
	push	de
	call	_usbdisk_init
	ld	hl, #___str_7
	push	hl
	call	_usbdisk_select_dsk_file
	pop	af
	ld	a, l
	pop	de
	ld	(de), a
;driver.c:121: switch (workarea->mount_mode)
	push	af
	ld	a, (de)
	ld	c, a
	pop	af
	dec	a
	jr	Z, 00102$
	ld	a, c
	sub	a, #0x02
	jr	NZ, 00103$
;driver.c:124: printf ("+Opened disk image\r\n");
	ld	hl, #___str_9
	push	hl
	call	_puts
	pop	af
;driver.c:125: break;
	ret
;driver.c:126: case 1:
00102$:
;driver.c:127: printf ("+Full disk mode\r\n");
	ld	hl, #___str_11
	push	hl
	call	_puts
	pop	af
;driver.c:128: break;
	ret
;driver.c:129: default:
00103$:
;driver.c:130: printf ("+Using floppy disk\r\n");
	ld	hl, #___str_13
	push	hl
	call	_puts
	pop	af
;driver.c:132: }   
;driver.c:133: }
	ret
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
;driver.c:145: uint8_t get_nr_drives_boottime (uint8_t reduced_drive_count,uint8_t dos_mode)
;	---------------------------------
; Function get_nr_drives_boottime
; ---------------------------------
_get_nr_drives_boottime::
;driver.c:151: workarea_t* workarea = get_workarea();
	call	_get_workarea
;driver.c:152: if (workarea->mount_mode==0)
	ld	a, (hl)
;driver.c:153: return 0;
	or	a,a
	jr	NZ, 00102$
	ld	l,a
	ret
00102$:
;driver.c:155: return 1; // 1 drive requested
	ld	l, #0x01
;driver.c:156: }
	ret
;driver.c:168: uint16_t get_drive_config (uint8_t relative_drive_number,uint8_t dos_mode)
;	---------------------------------
; Function get_drive_config
; ---------------------------------
_get_drive_config::
;driver.c:174: return 0x0101; // device 1, lun 1
	ld	hl, #0x0101
;driver.c:175: }
	ret
;driver.c:213: uint8_t get_lun_info (uint8_t nr_lun,uint8_t nr_device,luninfo_t* luninfo)
;	---------------------------------
; Function get_lun_info
; ---------------------------------
_get_lun_info::
;driver.c:219: if (nr_lun==1 && nr_device==1)
	ld	iy, #2
	add	iy, sp
	ld	a, 0 (iy)
	dec	a
	jr	NZ, 00102$
	ld	a, 1 (iy)
	inc	iy
	dec	a
	jr	NZ, 00102$
;driver.c:221: memset (luninfo,0,sizeof (luninfo_t));
	ld	l, 1 (iy)
	ld	h, 2 (iy)
	inc	iy
	ld	b, #0x0c
00120$:
	ld	(hl), #0x00
	inc	hl
	djnz	00120$
;driver.c:223: luninfo->sector_size = 512;
	ld	c, 0 (iy)
	ld	b, 1 (iy)
	ld	l, c
	ld	h, b
	inc	hl
	ld	(hl), #0x00
	inc	hl
	ld	(hl), #0x02
;driver.c:225: luninfo->flags = 0b00000001; // ; removable + non-read only + no floppy
	ld	hl, #0x0007
	add	hl, bc
	ld	(hl), #0x01
;driver.c:229: return 0x00;
	ld	l, #0x00
	ret
00102$:
;driver.c:232: return 0x01;
	ld	l, #0x01
;driver.c:233: }
	ret
;driver.c:272: uint8_t get_device_info (uint8_t nr_info,uint8_t nr_device,uint8_t* info_buffer)
;	---------------------------------
; Function get_device_info
; ---------------------------------
_get_device_info::
	push	ix
	ld	ix,#0
	add	ix,sp
;driver.c:278: if (nr_device!=1)
	ld	a, 5 (ix)
	dec	a
	jr	Z, 00102$
;driver.c:279: return 1;
	ld	l, #0x01
	jr	00109$
00102$:
;driver.c:281: switch (nr_info)
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
;driver.c:283: case 0: // basic information
00103$:
;driver.c:284: ((deviceinfo_t*)info_buffer)->nr_luns = 0x01;
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	ld	(hl), #0x01
;driver.c:285: ((deviceinfo_t*)info_buffer)->flags = 0x00;
	ld	c, 6 (ix)
	ld	b, 7 (ix)
	inc	bc
	xor	a, a
	ld	(bc), a
;driver.c:286: break;
	jr	00108$
;driver.c:287: case 1: // Manufacturer name string
00104$:
;driver.c:288: strcpy ((char*)info_buffer,"S0urceror");
	ld	e, 6 (ix)
	ld	d, 7 (ix)
	ld	hl, #___str_14
	xor	a, a
00141$:
	cp	a, (hl)
	ldi
	jr	NZ, 00141$
;driver.c:289: break;
	jr	00108$
;driver.c:290: case 2: // Device name string
00105$:
;driver.c:291: strcpy ((char*)info_buffer,"MSXUSBNext");
	ld	e, 6 (ix)
	ld	d, 7 (ix)
	ld	hl, #___str_15
	xor	a, a
00142$:
	cp	a, (hl)
	ldi
	jr	NZ, 00142$
;driver.c:292: break;
	jr	00108$
;driver.c:293: case 3: // Serial number string
00106$:
;driver.c:294: strcpy ((char*)info_buffer,"0000");
	ld	e, 6 (ix)
	ld	d, 7 (ix)
	ld	hl, #___str_16
	xor	a, a
00143$:
	cp	a, (hl)
	ldi
	jr	NZ, 00143$
;driver.c:295: break;
	jr	00108$
;driver.c:296: default:
00107$:
;driver.c:297: return 2;
	ld	l, #0x02
	jr	00109$
;driver.c:299: }
00108$:
;driver.c:300: return 0;
	ld	l, #0x00
00109$:
;driver.c:301: }
	pop	ix
	ret
___str_14:
	.ascii "S0urceror"
	.db 0x00
___str_15:
	.ascii "MSXUSBNext"
	.db 0x00
___str_16:
	.ascii "0000"
	.db 0x00
;driver.c:332: uint8_t get_device_status (uint8_t nr_lun,uint8_t nr_device)
;	---------------------------------
; Function get_device_status
; ---------------------------------
_get_device_status::
;driver.c:338: if (nr_device!=1 || nr_lun!=1)
	ld	iy, #3
	add	iy, sp
	ld	a, 0 (iy)
	dec	a
	jr	NZ, 00101$
	ld	a, -1 (iy)
	dec	a
	jr	Z, 00102$
00101$:
;driver.c:339: return 0;
	ld	l, #0x00
	ret
00102$:
;driver.c:341: workarea_t* workarea = get_workarea();
	call	_get_workarea
;driver.c:342: if (workarea->disk_change)
	inc	hl
	bit	0, (hl)
	jr	Z, 00105$
;driver.c:344: workarea->disk_change = false;
	ld	(hl), #0x00
;driver.c:345: return 2;
	ld	l, #0x02
	ret
00105$:
;driver.c:348: return 1;
	ld	l, #0x01
;driver.c:349: }
	ret
;driver.c:351: void caps_flash () __z88dk_fastcall __naked
;	---------------------------------
; Function caps_flash
; ---------------------------------
_caps_flash::
;driver.c:366: __endasm;
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
;driver.c:367: }
;driver.c:406: diskerror_t read_or_write_sector (uint8_t read_or_write_flag, uint8_t nr_device, uint8_t nr_lun, uint8_t nr_sectors, uint32_t* sector, uint8_t* sector_buffer)
;	---------------------------------
; Function read_or_write_sector
; ---------------------------------
_read_or_write_sector::
	push	ix
	ld	ix,#0
	add	ix,sp
;driver.c:423: workarea_t* workarea = get_workarea();
	call	_get_workarea
;driver.c:426: if (nr_device!=1 || nr_lun!=1)
	ld	a, 5 (ix)
	dec	a
	jr	NZ, 00101$
	ld	a, 6 (ix)
	dec	a
	jr	Z, 00102$
00101$:
;driver.c:427: return IDEVL;
	ld	l, #0xb5
	jr	00111$
00102$:
;driver.c:429: caps_flash ();
	push	hl
	call	_caps_flash
	pop	hl
;driver.c:431: if (workarea->mount_mode==2)
	ld	e, (hl)
;driver.c:435: if (!read_write_file_sectors (read_or_write_flag & Z80_CARRY_MASK,nr_sectors,sector,sector_buffer))
	ld	a, 4 (ix)
	and	a, #0x01
	ld	c, a
;driver.c:431: if (workarea->mount_mode==2)
	ld	a, e
	sub	a, #0x02
	jr	NZ, 00109$
;driver.c:435: if (!read_write_file_sectors (read_or_write_flag & Z80_CARRY_MASK,nr_sectors,sector,sector_buffer))
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
;driver.c:443: return RNF;
	ld	l, #0xf9
	jr	00111$
00109$:
;driver.c:449: if (!read_write_disk_sectors (read_or_write_flag & Z80_CARRY_MASK,nr_sectors,sector,sector_buffer))
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
;driver.c:457: return RNF;
	ld	l, #0xf9
	jr	00111$
00110$:
;driver.c:461: caps_flash ();
	call	_caps_flash
;driver.c:463: return OK;
	ld	l, #0x00
00111$:
;driver.c:464: }
	pop	ix
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
