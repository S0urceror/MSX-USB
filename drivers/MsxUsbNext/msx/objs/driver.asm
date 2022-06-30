;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.0.0 #11528 (Linux)
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
;driver.c:39: printf ("interrupt\r\n");
	ld	hl, #___str_1
	push	hl
	call	_puts
	pop	af
;driver.c:41: }
	ret
___str_1:
	.ascii "interrupt"
	.db 0x0d
	.db 0x00
;driver.c:56: uint16_t get_workarea_size (uint8_t reduced_drive_count,uint8_t nr_available_drives)
;	---------------------------------
; Function get_workarea_size
; ---------------------------------
_get_workarea_size::
	push	ix
	ld	ix,#0
	add	ix,sp
;driver.c:59: printf ("get_workarea_size (%x,%x)\r\n",nr_available_drives,reduced_drive_count);
	ld	e, 4 (ix)
	ld	d, #0x00
	ld	c, 5 (ix)
	ld	b, #0x00
	push	de
	push	bc
	ld	hl, #___str_2
	push	hl
	call	_printf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
;driver.c:62: return sizeof (workarea_t);
	ld	hl, #0x0002
;driver.c:63: }
	pop	ix
	ret
___str_2:
	.ascii "get_workarea_size (%x,%x)"
	.db 0x0d
	.db 0x0a
	.db 0x00
;driver.c:85: void init_driver (uint8_t reduced_drive_count,uint8_t nr_allocated_drives)
;	---------------------------------
; Function init_driver
; ---------------------------------
_init_driver::
	push	ix
	ld	ix,#0
	add	ix,sp
;driver.c:88: printf ("init_driver (%x,%x)\r\n",nr_allocated_drives,reduced_drive_count);
	ld	e, 4 (ix)
	ld	d, #0x00
	ld	c, 5 (ix)
	ld	b, #0x00
	push	de
	push	bc
	ld	hl, #___str_3
	push	hl
	call	_printf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
;driver.c:91: hal_init ();
	call	_hal_init
;driver.c:92: workarea_t* workarea = get_workarea();
	call	_get_workarea
;driver.c:93: usbdisk_init ();
	push	hl
	call	_usbdisk_init
	call	_usbdisk_autoexec_dsk
	ld	a, l
	pop	hl
	bit	0, a
	jr	Z,00102$
;driver.c:95: workarea->mount_mode = 2;
	ld	(hl), #0x02
	jr	00103$
00102$:
;driver.c:97: workarea->mount_mode = usbdisk_select_dsk_file ("/");
	ld	bc, #___str_4+0
	push	hl
	push	bc
	call	_usbdisk_select_dsk_file
	pop	af
	ld	a, l
	pop	hl
	ld	(hl), a
00103$:
;driver.c:98: switch (workarea->mount_mode)
	ld	a, (hl)
	cp	a, #0x01
	jr	Z,00105$
	sub	a, #0x02
	jr	NZ,00106$
;driver.c:101: printf ("+Opened disk image\r\n");
	ld	hl, #___str_6
	push	hl
	call	_puts
	pop	af
;driver.c:102: break;
	jr	00108$
;driver.c:103: case 1:
00105$:
;driver.c:104: printf ("+Full disk mode\r\n");
	ld	hl, #___str_8
	push	hl
	call	_puts
	pop	af
;driver.c:105: break;
	jr	00108$
;driver.c:106: default:
00106$:
;driver.c:107: printf ("+Using floppy disk\r\n");
	ld	hl, #___str_10
	push	hl
	call	_puts
	pop	af
;driver.c:109: }   
00108$:
;driver.c:110: }
	pop	ix
	ret
___str_3:
	.ascii "init_driver (%x,%x)"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_4:
	.ascii "/"
	.db 0x00
___str_6:
	.ascii "+Opened disk image"
	.db 0x0d
	.db 0x00
___str_8:
	.ascii "+Full disk mode"
	.db 0x0d
	.db 0x00
___str_10:
	.ascii "+Using floppy disk"
	.db 0x0d
	.db 0x00
;driver.c:112: void onCallMOUNTDSK ()
;	---------------------------------
; Function onCallMOUNTDSK
; ---------------------------------
_onCallMOUNTDSK::
;driver.c:114: hal_init ();
	call	_hal_init
;driver.c:115: workarea_t* workarea = get_workarea();
	call	_get_workarea
;driver.c:116: usbdisk_init ();
	push	hl
	call	_usbdisk_init
	pop	hl
;driver.c:117: workarea->mount_mode = usbdisk_select_dsk_file ("/");
	ld	bc, #___str_11+0
	push	hl
	push	bc
	call	_usbdisk_select_dsk_file
	pop	af
	ld	a, l
	pop	hl
	ld	(hl), a
;driver.c:118: switch (workarea->mount_mode)
	ld	c, (hl)
	dec	a
	jr	Z,00102$
	ld	a, c
	sub	a, #0x02
	jr	NZ,00103$
;driver.c:121: printf ("+Opened disk image\r\n");
	ld	hl, #___str_13
	push	hl
	call	_puts
	pop	af
;driver.c:122: break;
	ret
;driver.c:123: case 1:
00102$:
;driver.c:124: printf ("+Full disk mode\r\n");
	ld	hl, #___str_15
	push	hl
	call	_puts
	pop	af
;driver.c:125: break;
	ret
;driver.c:126: default:
00103$:
;driver.c:127: printf ("+Using floppy disk\r\n");
	ld	hl, #___str_17
	push	hl
	call	_puts
	pop	af
;driver.c:129: }   
;driver.c:130: }
	ret
___str_11:
	.ascii "/"
	.db 0x00
___str_13:
	.ascii "+Opened disk image"
	.db 0x0d
	.db 0x00
___str_15:
	.ascii "+Full disk mode"
	.db 0x0d
	.db 0x00
___str_17:
	.ascii "+Using floppy disk"
	.db 0x0d
	.db 0x00
;driver.c:142: uint8_t get_nr_drives_boottime (uint8_t reduced_drive_count,uint8_t dos_mode)
;	---------------------------------
; Function get_nr_drives_boottime
; ---------------------------------
_get_nr_drives_boottime::
	push	ix
	ld	ix,#0
	add	ix,sp
;driver.c:145: printf ("get_nr_drives_boottime (%d,%d)\r\n",dos_mode,reduced_drive_count);
	ld	c, 4 (ix)
	ld	b, #0x00
	ld	e, 5 (ix)
	ld	d, #0x00
	push	bc
	push	de
	ld	hl, #___str_18
	push	hl
	call	_printf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
;driver.c:148: workarea_t* workarea = get_workarea();
	call	_get_workarea
;driver.c:149: if (workarea->mount_mode==0)
	ld	a, (hl)
;driver.c:150: return 0;
	or	a,a
	jr	NZ,00102$
	ld	l,a
	jr	00103$
00102$:
;driver.c:152: return 1; // 1 drive requested
	ld	l, #0x01
00103$:
;driver.c:153: }
	pop	ix
	ret
___str_18:
	.ascii "get_nr_drives_boottime (%d,%d)"
	.db 0x0d
	.db 0x0a
	.db 0x00
;driver.c:165: uint16_t get_drive_config (uint8_t relative_drive_number,uint8_t dos_mode)
;	---------------------------------
; Function get_drive_config
; ---------------------------------
_get_drive_config::
	push	ix
	ld	ix,#0
	add	ix,sp
;driver.c:168: printf ("get_config_drive (%d,%d)\r\n",dos_mode,relative_drive_number);
	ld	e, 4 (ix)
	ld	d, #0x00
	ld	c, 5 (ix)
	ld	b, #0x00
	push	de
	push	bc
	ld	hl, #___str_19
	push	hl
	call	_printf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
;driver.c:171: return 0x0101; // device 1, lun 1
	ld	hl, #0x0101
;driver.c:172: }
	pop	ix
	ret
___str_19:
	.ascii "get_config_drive (%d,%d)"
	.db 0x0d
	.db 0x0a
	.db 0x00
;driver.c:210: uint8_t get_lun_info (uint8_t nr_lun,uint8_t nr_device,luninfo_t* luninfo)
;	---------------------------------
; Function get_lun_info
; ---------------------------------
_get_lun_info::
	push	ix
	ld	ix,#0
	add	ix,sp
;driver.c:213: printf ("get_lun_info (%x,%x)\r\n",nr_device,nr_lun);
	ld	e, 4 (ix)
	ld	d, #0x00
	ld	c, 5 (ix)
	ld	b, #0x00
	push	de
	push	bc
	ld	hl, #___str_20
	push	hl
	call	_printf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
;driver.c:216: if (nr_lun==1 && nr_device==1)
	ld	a, 4 (ix)
	dec	a
	jr	NZ,00102$
	ld	a, 5 (ix)
	dec	a
	jr	NZ,00102$
;driver.c:218: memset (luninfo,0,sizeof (luninfo_t));
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	ld	b, #0x0c
00120$:
	ld	(hl), #0x00
	inc	hl
	djnz	00120$
;driver.c:220: luninfo->sector_size = 512;
	ld	c, 6 (ix)
	ld	b, 7 (ix)
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
	jr	00104$
00102$:
;driver.c:229: return 0x01;
	ld	l, #0x01
00104$:
;driver.c:230: }
	pop	ix
	ret
___str_20:
	.ascii "get_lun_info (%x,%x)"
	.db 0x0d
	.db 0x0a
	.db 0x00
;driver.c:269: uint8_t get_device_info (uint8_t nr_info,uint8_t nr_device,uint8_t* info_buffer)
;	---------------------------------
; Function get_device_info
; ---------------------------------
_get_device_info::
	push	ix
	ld	ix,#0
	add	ix,sp
;driver.c:272: printf ("get_device_info (%x,%x)\r\n",nr_device,nr_info);
	ld	e, 4 (ix)
	ld	d, #0x00
	ld	c, 5 (ix)
	ld	b, #0x00
	push	de
	push	bc
	ld	hl, #___str_21
	push	hl
	call	_printf
	ld	hl, #6
	add	hl, sp
	ld	sp, hl
;driver.c:275: if (nr_device!=1)
	ld	a, 5 (ix)
	dec	a
	jr	Z,00102$
;driver.c:276: return 1;
	ld	l, #0x01
	jr	00109$
00102$:
;driver.c:278: switch (nr_info)
	ld	a, 4 (ix)
	or	a, a
	jr	Z,00103$
	ld	a, 4 (ix)
	dec	a
	jr	Z,00104$
	ld	a, 4 (ix)
	sub	a, #0x02
	jr	Z,00105$
	ld	a, 4 (ix)
	sub	a, #0x03
	jr	Z,00106$
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
	ld	hl, #___str_22
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
	ld	hl, #___str_23
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
	ld	hl, #___str_24
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
___str_21:
	.ascii "get_device_info (%x,%x)"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_22:
	.ascii "S0urceror"
	.db 0x00
___str_23:
	.ascii "MSXUSBNext"
	.db 0x00
___str_24:
	.ascii "0000"
	.db 0x00
;driver.c:329: uint8_t get_device_status (uint8_t nr_lun,uint8_t nr_device)
;	---------------------------------
; Function get_device_status
; ---------------------------------
_get_device_status::
	push	ix
	ld	ix,#0
	add	ix,sp
;driver.c:336: printf ("get_device_status (%x,%x) = %d\r\n",nr_device,nr_lun,0);
	ld	c, 4 (ix)
	ld	b, #0x00
	ld	e, 5 (ix)
	ld	d, #0x00
;driver.c:333: if (nr_device!=1 || nr_lun!=1)
	ld	a, 5 (ix)
	dec	a
	jr	NZ,00101$
	ld	a, 4 (ix)
	dec	a
	jr	Z,00102$
00101$:
;driver.c:336: printf ("get_device_status (%x,%x) = %d\r\n",nr_device,nr_lun,0);
	ld	hl, #0x0000
	push	hl
	push	bc
	push	de
	ld	hl, #___str_25
	push	hl
	call	_printf
	ld	hl, #8
	add	hl, sp
	ld	sp, hl
;driver.c:338: return 0;
	ld	l, #0x00
	jr	00104$
00102$:
;driver.c:352: printf ("get_device_status (%x,%x) = %d\r\n",nr_device,nr_lun,1);
	ld	hl, #0x0001
	push	hl
	push	bc
	push	de
	ld	hl, #___str_25
	push	hl
	call	_printf
	ld	hl, #8
	add	hl, sp
	ld	sp, hl
;driver.c:354: return 1;
	ld	l, #0x01
00104$:
;driver.c:356: }
	pop	ix
	ret
___str_25:
	.ascii "get_device_status (%x,%x) = %d"
	.db 0x0d
	.db 0x0a
	.db 0x00
;driver.c:358: void caps_flash () __z88dk_fastcall __naked
;	---------------------------------
; Function caps_flash
; ---------------------------------
_caps_flash::
;driver.c:373: __endasm;
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
;driver.c:374: }
;driver.c:401: diskerror_t read_or_write_sector (uint8_t read_or_write_flag, uint8_t nr_device, uint8_t nr_lun, uint8_t nr_sectors, uint32_t* sector, uint8_t* sector_buffer)
;	---------------------------------
; Function read_or_write_sector
; ---------------------------------
_read_or_write_sector::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-7
	add	hl, sp
	ld	sp, hl
;driver.c:404: if (read_or_write_flag & Z80_CARRY_MASK)
	ld	a, 4 (ix)
	ld	-7 (ix), a
;driver.c:405: printf ("write (%x,%x,%x,%x)\r\n",nr_device,nr_lun,nr_sectors,*sector);
	ld	l, 8 (ix)
	ld	h, 9 (ix)
	ld	c, 7 (ix)
	ld	b, #0x00
	ld	e, 6 (ix)
	ld	d, #0x00
	ld	a, 5 (ix)
	ld	-6 (ix), a
	xor	a, a
	ld	-5 (ix), a
	push	de
	push	bc
	ex	de,hl
	ld	hl, #0x0007
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	pop	bc
	pop	de
;driver.c:404: if (read_or_write_flag & Z80_CARRY_MASK)
	bit	0, -7 (ix)
	jr	Z,00102$
;driver.c:405: printf ("write (%x,%x,%x,%x)\r\n",nr_device,nr_lun,nr_sectors,*sector);
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	push	hl
	push	bc
	push	de
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	push	hl
	ld	hl, #___str_26
	push	hl
	call	_printf
	ld	hl, #12
	add	hl, sp
	ld	sp, hl
	jr	00103$
00102$:
;driver.c:407: printf ("read (%x,%x,%x,%x)\r\n",nr_device,nr_lun,nr_sectors,*sector);
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	push	hl
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	push	hl
	push	bc
	push	de
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	push	hl
	ld	hl, #___str_27
	push	hl
	call	_printf
	ld	hl, #12
	add	hl, sp
	ld	sp, hl
00103$:
;driver.c:410: workarea_t* workarea = get_workarea();
	call	_get_workarea
;driver.c:413: if (nr_device!=1 || nr_lun!=1)
	ld	a, 5 (ix)
	dec	a
	jr	NZ,00104$
	ld	a, 6 (ix)
	dec	a
	jr	Z,00105$
00104$:
;driver.c:414: return IDEVL;
	ld	l, #0xb5
	jr	00114$
00105$:
;driver.c:416: caps_flash ();
	push	hl
	call	_caps_flash
	pop	hl
;driver.c:418: if (workarea->mount_mode==2)
	ld	c, (hl)
;driver.c:422: if (!read_write_file_sectors (read_or_write_flag & Z80_CARRY_MASK,nr_sectors,sector,sector_buffer))
	ld	a, -7 (ix)
	and	a, #0x01
	ld	e, a
;driver.c:418: if (workarea->mount_mode==2)
	ld	a, c
	sub	a, #0x02
	jr	NZ,00112$
;driver.c:422: if (!read_write_file_sectors (read_or_write_flag & Z80_CARRY_MASK,nr_sectors,sector,sector_buffer))
	ld	b, e
	ld	l, 10 (ix)
	ld	h, 11 (ix)
	push	hl
	ld	l, 8 (ix)
	ld	h, 9 (ix)
	push	hl
	ld	a, 7 (ix)
	push	af
	inc	sp
	push	bc
	inc	sp
	call	_read_write_file_sectors
	pop	af
	pop	af
	pop	af
	bit	0, l
	jr	NZ,00113$
;driver.c:423: return RNF;
	ld	l, #0xf9
	jr	00114$
00112$:
;driver.c:428: if (!read_write_disk_sectors (read_or_write_flag & Z80_CARRY_MASK,nr_sectors,sector,sector_buffer))
	ld	b, e
	ld	l, 10 (ix)
	ld	h, 11 (ix)
	push	hl
	ld	l, 8 (ix)
	ld	h, 9 (ix)
	push	hl
	ld	a, 7 (ix)
	push	af
	inc	sp
	push	bc
	inc	sp
	call	_read_write_disk_sectors
	pop	af
	pop	af
	pop	af
	bit	0, l
	jr	NZ,00113$
;driver.c:429: return RNF;
	ld	l, #0xf9
	jr	00114$
00113$:
;driver.c:432: caps_flash ();
	call	_caps_flash
;driver.c:434: return OK;
	ld	l, #0x00
00114$:
;driver.c:435: }
	ld	sp, ix
	pop	ix
	ret
___str_26:
	.ascii "write (%x,%x,%x,%x)"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_27:
	.ascii "read (%x,%x,%x,%x)"
	.db 0x0d
	.db 0x0a
	.db 0x00
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
