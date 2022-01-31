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
	.globl _init_driver
	.globl _get_workarea_size
	.globl _interrupt
	.globl _get_workarea
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
	ld	hl, #0x0001
;driver.c:63: }
	ret
;driver.c:85: void init_driver (uint8_t reduced_drive_count,uint8_t nr_allocated_drives)
;	---------------------------------
; Function init_driver
; ---------------------------------
_init_driver::
	push	ix
	ld	ix,#0
	add	ix,sp
;driver.c:91: hal_init ();
	call	_hal_init
;driver.c:92: workarea_t* workarea = get_workarea();
	call	_get_workarea
;driver.c:93: usbdisk_init ();
	push	hl
	call	_usbdisk_init
	call	_usbdisk_select_dsk_file
	pop	de
	bit	0, l
	jr	Z, 00102$
;driver.c:96: printf ("+Opened disk image\r\n");
	push	de
	ld	hl, #___str_1
	push	hl
	call	_puts
	pop	af
	pop	de
;driver.c:97: workarea->mounted_file = true;
	ld	a, #0x01
	ld	(de), a
	jr	00104$
00102$:
;driver.c:101: printf ("+Full disk mode\r\n");
	push	de
	ld	hl, #___str_3
	push	hl
	call	_puts
	pop	af
	pop	de
;driver.c:102: workarea->mounted_file = false;
	xor	a, a
	ld	(de), a
00104$:
;driver.c:104: }
	pop	ix
	ret
___str_1:
	.ascii "+Opened disk image"
	.db 0x0d
	.db 0x00
___str_3:
	.ascii "+Full disk mode"
	.db 0x0d
	.db 0x00
;driver.c:116: uint8_t get_nr_drives_boottime (uint8_t reduced_drive_count,uint8_t dos_mode)
;	---------------------------------
; Function get_nr_drives_boottime
; ---------------------------------
_get_nr_drives_boottime::
;driver.c:122: return 1; // 1 drive requested
	ld	l, #0x01
;driver.c:123: }
	ret
;driver.c:135: uint16_t get_drive_config (uint8_t relative_drive_number,uint8_t dos_mode)
;	---------------------------------
; Function get_drive_config
; ---------------------------------
_get_drive_config::
;driver.c:141: return 0x0101; // device 1, lun 1
	ld	hl, #0x0101
;driver.c:142: }
	ret
;driver.c:180: uint8_t get_lun_info (uint8_t nr_lun,uint8_t nr_device,luninfo_t* luninfo)
;	---------------------------------
; Function get_lun_info
; ---------------------------------
_get_lun_info::
;driver.c:186: if (nr_lun==1 && nr_device==1)
	ld	iy, #2
	add	iy, sp
	ld	a, 0 (iy)
	dec	a
	jr	NZ, 00102$
	ld	a, 1 (iy)
	inc	iy
	dec	a
	jr	NZ, 00102$
;driver.c:188: memset (luninfo,0,sizeof (luninfo_t));
	ld	l, 1 (iy)
	ld	h, 2 (iy)
	inc	iy
	ld	b, #0x0c
00120$:
	ld	(hl), #0x00
	inc	hl
	djnz	00120$
;driver.c:189: luninfo->sector_size = 512;
	ld	c, 0 (iy)
	ld	b, 1 (iy)
	ld	l, c
	ld	h, b
	inc	hl
	ld	(hl), #0x00
	inc	hl
	ld	(hl), #0x02
;driver.c:190: luninfo->flags = 0b00000001; // ; removable + non-read only + no floppy
	ld	hl, #0x0007
	add	hl, bc
	ld	(hl), #0x01
;driver.c:191: return 0x00;
	ld	l, #0x00
	ret
00102$:
;driver.c:194: return 0x01;
	ld	l, #0x01
;driver.c:195: }
	ret
;driver.c:234: uint8_t get_device_info (uint8_t nr_info,uint8_t nr_device,uint8_t* info_buffer)
;	---------------------------------
; Function get_device_info
; ---------------------------------
_get_device_info::
	push	ix
	ld	ix,#0
	add	ix,sp
;driver.c:240: if (nr_device!=1)
	ld	a, 5 (ix)
	dec	a
	jr	Z, 00102$
;driver.c:241: return 1;
	ld	l, #0x01
	jr	00109$
00102$:
;driver.c:243: switch (nr_info)
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
;driver.c:245: case 0: // basic information
00103$:
;driver.c:246: ((deviceinfo_t*)info_buffer)->nr_luns = 0x01;
	ld	l, 6 (ix)
	ld	h, 7 (ix)
	ld	(hl), #0x01
;driver.c:247: ((deviceinfo_t*)info_buffer)->flags = 0x00;
	ld	c, 6 (ix)
	ld	b, 7 (ix)
	inc	bc
	xor	a, a
	ld	(bc), a
;driver.c:248: break;
	jr	00108$
;driver.c:249: case 1: // Manufacturer name string
00104$:
;driver.c:250: strcpy ((char*)info_buffer,"S0urceror");
	ld	e, 6 (ix)
	ld	d, 7 (ix)
	ld	hl, #___str_4
	xor	a, a
00141$:
	cp	a, (hl)
	ldi
	jr	NZ, 00141$
;driver.c:251: break;
	jr	00108$
;driver.c:252: case 2: // Device name string
00105$:
;driver.c:253: strcpy ((char*)info_buffer,"MSXUSBNext");
	ld	e, 6 (ix)
	ld	d, 7 (ix)
	ld	hl, #___str_5
	xor	a, a
00142$:
	cp	a, (hl)
	ldi
	jr	NZ, 00142$
;driver.c:254: break;
	jr	00108$
;driver.c:255: case 3: // Serial number string
00106$:
;driver.c:256: strcpy ((char*)info_buffer,"0000");
	ld	e, 6 (ix)
	ld	d, 7 (ix)
	ld	hl, #___str_6
	xor	a, a
00143$:
	cp	a, (hl)
	ldi
	jr	NZ, 00143$
;driver.c:257: break;
	jr	00108$
;driver.c:258: default:
00107$:
;driver.c:259: return 2;
	ld	l, #0x02
	jr	00109$
;driver.c:261: }
00108$:
;driver.c:262: return 0;
	ld	l, #0x00
00109$:
;driver.c:263: }
	pop	ix
	ret
___str_4:
	.ascii "S0urceror"
	.db 0x00
___str_5:
	.ascii "MSXUSBNext"
	.db 0x00
___str_6:
	.ascii "0000"
	.db 0x00
;driver.c:294: uint8_t get_device_status (uint8_t nr_lun,uint8_t nr_device)
;	---------------------------------
; Function get_device_status
; ---------------------------------
_get_device_status::
;driver.c:300: if (nr_device!=1 || nr_lun!=1)
	ld	iy, #3
	add	iy, sp
	ld	a, 0 (iy)
	dec	a
	jr	NZ, 00101$
	ld	a, -1 (iy)
	dec	a
	jr	Z, 00102$
00101$:
;driver.c:301: return 0;
	ld	l, #0x00
	ret
00102$:
;driver.c:303: return 1;
	ld	l, #0x01
;driver.c:304: }
	ret
;driver.c:306: void caps_flash () __z88dk_fastcall __naked
;	---------------------------------
; Function caps_flash
; ---------------------------------
_caps_flash::
;driver.c:321: __endasm;
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
;driver.c:322: }
;driver.c:349: diskerror_t read_or_write_sector (uint8_t read_or_write_flag, uint8_t nr_device, uint8_t nr_lun, uint8_t nr_sectors, uint32_t* sector, uint8_t* sector_buffer)
;	---------------------------------
; Function read_or_write_sector
; ---------------------------------
_read_or_write_sector::
	push	ix
	ld	ix,#0
	add	ix,sp
;driver.c:358: if (nr_device!=1 || nr_lun!=1)
	ld	a, 5 (ix)
	dec	a
	jr	NZ, 00101$
	ld	a, 6 (ix)
	dec	a
	jr	Z, 00102$
00101$:
;driver.c:359: return IDEVL;
	ld	l, #0xb5
	jr	00111$
00102$:
;driver.c:361: caps_flash ();
	call	_caps_flash
;driver.c:363: workarea_t* workarea = get_workarea();
	call	_get_workarea
;driver.c:364: if (workarea->mounted_file)
	ld	c, (hl)
;driver.c:367: if (!read_write_file_sectors (read_or_write_flag & Z80_CARRY_MASK,nr_sectors,sector,sector_buffer))
	ld	a, 4 (ix)
	and	a, #0x01
	ld	d, a
;driver.c:364: if (workarea->mounted_file)
	bit	0, c
	jr	Z, 00109$
;driver.c:367: if (!read_write_file_sectors (read_or_write_flag & Z80_CARRY_MASK,nr_sectors,sector,sector_buffer))
	ld	l, 10 (ix)
	ld	h, 11 (ix)
	push	hl
	ld	l, 8 (ix)
	ld	h, 9 (ix)
	push	hl
	ld	a, 7 (ix)
	push	af
	inc	sp
	push	de
	inc	sp
	call	_read_write_file_sectors
	pop	af
	pop	af
	pop	af
	bit	0, l
	jr	NZ, 00110$
;driver.c:368: return RNF;
	ld	l, #0xf9
	jr	00111$
00109$:
;driver.c:373: if (!read_write_disk_sectors (read_or_write_flag & Z80_CARRY_MASK,nr_sectors,sector,sector_buffer))
	ld	l, 10 (ix)
	ld	h, 11 (ix)
	push	hl
	ld	l, 8 (ix)
	ld	h, 9 (ix)
	push	hl
	ld	a, 7 (ix)
	push	af
	inc	sp
	push	de
	inc	sp
	call	_read_write_disk_sectors
	pop	af
	pop	af
	pop	af
	bit	0, l
	jr	NZ, 00110$
;driver.c:374: return RNF;
	ld	l, #0xf9
	jr	00111$
00110$:
;driver.c:377: caps_flash ();
	call	_caps_flash
;driver.c:379: return OK;
	ld	l, #0x00
00111$:
;driver.c:380: }
	pop	ix
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
