;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.1.0 #12072 (Mac OS X ppc)
;--------------------------------------------------------
	.module ch376s
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _delay_ms
	.globl _write_data_multiple
	.globl _read_data_multiple
	.globl _read_status
	.globl _read_data
	.globl _write_data
	.globl _write_command
	.globl _strlen
	.globl _ch376_reset_all
	.globl _ch376_plugged_in
	.globl _ch376_set_usb_host_mode
	.globl _ch376_connect_disk
	.globl _ch376_mount_disk
	.globl _ch376_wait_status
	.globl _ch376_get_register_value
	.globl _ch376_set_filename
	.globl _ch376_open_file
	.globl _ch376_open_directory
	.globl _ch376_open_search
	.globl _ch376_next_search
	.globl _ch376_get_fat_info
	.globl _ch376_locate_sector
	.globl _ch376_get_sector_LBA
	.globl _ch376s_disk_read
	.globl _ch376s_disk_write
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
;../generic/ch376s.c:8: void ch376_reset_all()
;	---------------------------------
; Function ch376_reset_all
; ---------------------------------
_ch376_reset_all::
;../generic/ch376s.c:10: write_command (CMD_RESET_ALL);
	ld	l, #0x05
	call	_write_command
;../generic/ch376s.c:11: delay_ms (100);
	ld	hl, #0x0064
	push	hl
	call	_delay_ms
	pop	af
;../generic/ch376s.c:12: }
	ret
;../generic/ch376s.c:13: bool ch376_plugged_in()
;	---------------------------------
; Function ch376_plugged_in
; ---------------------------------
_ch376_plugged_in::
;../generic/ch376s.c:18: write_command (CMD_CHECK_EXIST);
	ld	l, #0x06
	call	_write_command
;../generic/ch376s.c:19: write_data(value);
	ld	l, #0xbe
	call	_write_data
;../generic/ch376s.c:20: new_value = read_data ();
	call	_read_data
	ld	a, l
;../generic/ch376s.c:23: if (new_value != value)
	sub	a, #0x41
;../generic/ch376s.c:24: return false;
;../generic/ch376s.c:25: return true;
	ld	l, #0x00
	ret	NZ
	ld	l, #0x01
;../generic/ch376s.c:26: }
	ret
;../generic/ch376s.c:27: bool ch376_set_usb_host_mode(uint8_t mode)
;	---------------------------------
; Function ch376_set_usb_host_mode
; ---------------------------------
_ch376_set_usb_host_mode::
;../generic/ch376s.c:29: write_command(CMD_SET_USB_MODE);
	ld	l, #0x15
	call	_write_command
;../generic/ch376s.c:30: write_data(mode);
	ld	iy, #2
	add	iy, sp
	ld	l, 0 (iy)
	call	_write_data
;../generic/ch376s.c:31: delay_ms (250);
	ld	hl, #0x00fa
	push	hl
	call	_delay_ms
	pop	af
;../generic/ch376s.c:33: value = read_data();
	call	_read_data
	ld	a, l
;../generic/ch376s.c:34: if ( value == CMD_RET_SUCCESS )
	sub	a, #0x51
;../generic/ch376s.c:35: return true;
;../generic/ch376s.c:36: return false;
	ld	l, #0x01
	ret	Z
	ld	l, #0x00
;../generic/ch376s.c:37: }
	ret
;../generic/ch376s.c:38: bool ch376_connect_disk ()
;	---------------------------------
; Function ch376_connect_disk
; ---------------------------------
_ch376_connect_disk::
;../generic/ch376s.c:40: write_command (CMD_DISK_CONNECT);
	ld	l, #0x30
	call	_write_command
;../generic/ch376s.c:41: if (ch376_wait_status ()!=USB_INT_SUCCESS)
	call	_ch376_wait_status
	ld	a, l
	sub	a, #0x14
;../generic/ch376s.c:42: return false;
;../generic/ch376s.c:43: return true;
	ld	l, #0x00
	ret	NZ
	ld	l, #0x01
;../generic/ch376s.c:44: }
	ret
;../generic/ch376s.c:45: bool ch376_mount_disk ()
;	---------------------------------
; Function ch376_mount_disk
; ---------------------------------
_ch376_mount_disk::
;../generic/ch376s.c:47: write_command (CMD_DISK_MOUNT);
	ld	l, #0x31
	call	_write_command
;../generic/ch376s.c:48: if (ch376_wait_status ()!=USB_INT_SUCCESS)
	call	_ch376_wait_status
	ld	a, l
	sub	a, #0x14
;../generic/ch376s.c:49: return false;
;../generic/ch376s.c:50: return true;
	ld	l, #0x00
	ret	NZ
	ld	l, #0x01
;../generic/ch376s.c:51: }
	ret
;../generic/ch376s.c:53: uint8_t ch376_wait_status ()
;	---------------------------------
; Function ch376_wait_status
; ---------------------------------
_ch376_wait_status::
;../generic/ch376s.c:58: while (true)
00104$:
;../generic/ch376s.c:60: interrupt=read_status();
	call	_read_status
	ld	a, l
;../generic/ch376s.c:61: if ((interrupt&0x80)==0)
	rlca
	jr	C, 00104$
;../generic/ch376s.c:68: write_command(CMD_GET_STATUS);
	ld	l, #0x22
	call	_write_command
;../generic/ch376s.c:69: return read_data ();
;../generic/ch376s.c:70: }
	jp	_read_data
;../generic/ch376s.c:72: uint8_t ch376_get_register_value (uint8_t reg)
;	---------------------------------
; Function ch376_get_register_value
; ---------------------------------
_ch376_get_register_value::
;../generic/ch376s.c:74: write_command (CMD_GET_REGISTER);
	ld	l, #0x0a
	call	_write_command
;../generic/ch376s.c:75: write_data (reg); 
	ld	iy, #2
	add	iy, sp
	ld	l, 0 (iy)
	call	_write_data
;../generic/ch376s.c:76: return read_data ();
;../generic/ch376s.c:77: }
	jp	_read_data
;../generic/ch376s.c:79: void ch376_set_filename (char* name)
;	---------------------------------
; Function ch376_set_filename
; ---------------------------------
_ch376_set_filename::
;../generic/ch376s.c:81: write_command (CMD_SET_FILE_NAME);
	ld	l, #0x2f
	call	_write_command
;../generic/ch376s.c:82: write_data_multiple ((uint8_t*) name,strlen(name));
	pop	bc
	pop	hl
	push	hl
	push	bc
	push	hl
	call	_strlen
	pop	af
	ld	a, l
	push	af
	inc	sp
	ld	hl, #3
	add	hl, sp
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	push	bc
	call	_write_data_multiple
	pop	af
	inc	sp
;../generic/ch376s.c:83: write_data (0);
	ld	l, #0x00
;../generic/ch376s.c:84: }
	jp	_write_data
;../generic/ch376s.c:85: bool ch376_open_file ()
;	---------------------------------
; Function ch376_open_file
; ---------------------------------
_ch376_open_file::
;../generic/ch376s.c:87: write_command (CMD_OPEN_FILE);
	ld	l, #0x32
	call	_write_command
;../generic/ch376s.c:88: if (ch376_wait_status ()!=USB_INT_SUCCESS)
	call	_ch376_wait_status
	ld	a, l
	sub	a, #0x14
;../generic/ch376s.c:89: return false;
;../generic/ch376s.c:90: return true;
	ld	l, #0x00
	ret	NZ
	ld	l, #0x01
;../generic/ch376s.c:91: }
	ret
;../generic/ch376s.c:92: bool ch376_open_directory ()
;	---------------------------------
; Function ch376_open_directory
; ---------------------------------
_ch376_open_directory::
;../generic/ch376s.c:94: write_command (CMD_OPEN_FILE);
	ld	l, #0x32
	call	_write_command
;../generic/ch376s.c:95: if (ch376_wait_status ()!=USB_ERR_OPEN_DIR)
	call	_ch376_wait_status
	ld	a, l
	sub	a, #0x41
;../generic/ch376s.c:96: return false;
;../generic/ch376s.c:97: return true;
	ld	l, #0x00
	ret	NZ
	ld	l, #0x01
;../generic/ch376s.c:98: }
	ret
;../generic/ch376s.c:99: bool ch376_open_search ()
;	---------------------------------
; Function ch376_open_search
; ---------------------------------
_ch376_open_search::
;../generic/ch376s.c:102: write_command (CMD_OPEN_FILE);
	ld	l, #0x32
	call	_write_command
;../generic/ch376s.c:103: if (ch376_wait_status ()!=USB_INT_DISK_READ)
	call	_ch376_wait_status
	ld	a, l
	sub	a, #0x1d
;../generic/ch376s.c:104: return false;
;../generic/ch376s.c:105: return true;
	ld	l, #0x00
	ret	NZ
	ld	l, #0x01
;../generic/ch376s.c:106: }
	ret
;../generic/ch376s.c:107: bool ch376_next_search ()
;	---------------------------------
; Function ch376_next_search
; ---------------------------------
_ch376_next_search::
;../generic/ch376s.c:110: write_command (CMD_FILE_ENUM_GO);
	ld	l, #0x33
	call	_write_command
;../generic/ch376s.c:111: if (ch376_wait_status ()!=USB_INT_DISK_READ)
	call	_ch376_wait_status
	ld	a, l
	sub	a, #0x1d
;../generic/ch376s.c:112: return false;
;../generic/ch376s.c:113: return true;
	ld	l, #0x00
	ret	NZ
	ld	l, #0x01
;../generic/ch376s.c:114: }
	ret
;../generic/ch376s.c:115: void ch376_get_fat_info (fat_dir_info_t* info)
;	---------------------------------
; Function ch376_get_fat_info
; ---------------------------------
_ch376_get_fat_info::
;../generic/ch376s.c:118: write_command(CMD_RD_USB_DATA);
	ld	l, #0x27
	call	_write_command
;../generic/ch376s.c:119: uint8_t len = read_data();
	call	_read_data
	ld	a, l
;../generic/ch376s.c:120: read_data_multiple ((uint8_t*) info,len);
	pop	de
	pop	bc
	push	bc
	push	de
	push	af
	inc	sp
	push	bc
	call	_read_data_multiple
	pop	af
	inc	sp
;../generic/ch376s.c:121: }
	ret
;../generic/ch376s.c:123: bool ch376_locate_sector (uint8_t* sector)
;	---------------------------------
; Function ch376_locate_sector
; ---------------------------------
_ch376_locate_sector::
;../generic/ch376s.c:125: write_command (CMD_SEC_LOCATE);
	ld	l, #0x4a
	call	_write_command
;../generic/ch376s.c:126: write_data (sector[0]);
	pop	de
	pop	bc
	push	bc
	push	de
	ld	a, (bc)
	ld	l, a
	push	bc
	call	_write_data
	pop	bc
;../generic/ch376s.c:127: write_data (sector[1]);
	ld	l, c
	ld	h, b
	inc	hl
	ld	l, (hl)
	push	bc
	call	_write_data
	pop	bc
;../generic/ch376s.c:128: write_data (sector[2]);
	ld	l, c
	ld	h, b
	inc	hl
	inc	hl
	ld	l, (hl)
	push	bc
	call	_write_data
	pop	bc
;../generic/ch376s.c:129: write_data (sector[3]);
	ld	hl, #3
	add	hl, bc
	ld	l, (hl)
	call	_write_data
;../generic/ch376s.c:131: if (ch376_wait_status ()!=USB_INT_SUCCESS)
	call	_ch376_wait_status
	ld	a, l
	sub	a, #0x14
;../generic/ch376s.c:132: return false;
;../generic/ch376s.c:133: return true;    
	ld	l, #0x00
	ret	NZ
	ld	l, #0x01
;../generic/ch376s.c:134: }
	ret
;../generic/ch376s.c:136: bool ch376_get_sector_LBA (uint8_t nr_sectors,uint8_t* sectors_allowed_lba)
;	---------------------------------
; Function ch376_get_sector_LBA
; ---------------------------------
_ch376_get_sector_LBA::
;../generic/ch376s.c:138: write_command (CMD_SEC_READ);
	ld	l, #0x4b
	call	_write_command
;../generic/ch376s.c:139: write_data (nr_sectors);
	ld	iy, #2
	add	iy, sp
	ld	l, 0 (iy)
	call	_write_data
;../generic/ch376s.c:140: if (ch376_wait_status ()!=USB_INT_SUCCESS)
	call	_ch376_wait_status
	ld	a, l
	sub	a, #0x14
	jr	Z, 00102$
;../generic/ch376s.c:141: return false;
	ld	l, #0x00
	ret
00102$:
;../generic/ch376s.c:146: write_command(CMD_RD_USB_DATA);
	ld	l, #0x27
	call	_write_command
;../generic/ch376s.c:147: uint8_t len = read_data();
	call	_read_data
	ld	a, l
;../generic/ch376s.c:148: read_data_multiple (sectors_allowed_lba,len);
	push	af
	inc	sp
	ld	hl, #4
	add	hl, sp
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	push	bc
	call	_read_data_multiple
	pop	af
	inc	sp
;../generic/ch376s.c:150: return true;
	ld	l, #0x01
;../generic/ch376s.c:151: }
	ret
;../generic/ch376s.c:153: bool ch376s_disk_read (uint8_t nr_sectors,uint8_t* lba,uint8_t* sector_buffer)
;	---------------------------------
; Function ch376s_disk_read
; ---------------------------------
_ch376s_disk_read::
;../generic/ch376s.c:155: write_command (CMD_DISK_READ);
	ld	l, #0x54
	call	_write_command
;../generic/ch376s.c:156: write_data (lba[0]);
	ld	hl, #3
	add	hl, sp
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	ld	a, (bc)
	ld	l, a
	push	bc
	call	_write_data
	pop	bc
;../generic/ch376s.c:157: write_data (lba[1]);
	ld	l, c
	ld	h, b
	inc	hl
	ld	l, (hl)
	push	bc
	call	_write_data
	pop	bc
;../generic/ch376s.c:158: write_data (lba[2]);
	ld	l, c
	ld	h, b
	inc	hl
	inc	hl
	ld	l, (hl)
	push	bc
	call	_write_data
	pop	bc
;../generic/ch376s.c:159: write_data (lba[3]);
	ld	hl, #3
	add	hl, bc
	ld	l, (hl)
	call	_write_data
;../generic/ch376s.c:160: write_data (nr_sectors);
	ld	iy, #2
	add	iy, sp
	ld	l, 0 (iy)
	call	_write_data
;../generic/ch376s.c:162: do
00105$:
;../generic/ch376s.c:164: uint8_t status = ch376_wait_status ();
	call	_ch376_wait_status
	ld	a, l
;../generic/ch376s.c:165: if (status==USB_INT_SUCCESS)
	cp	a, #0x14
	jr	NZ, 00102$
;../generic/ch376s.c:166: return true;
	ld	l, #0x01
	ret
00102$:
;../generic/ch376s.c:167: if (status!=USB_INT_DISK_READ)
	sub	a, #0x1d
	jr	Z, 00104$
;../generic/ch376s.c:168: return false;
	ld	l, #0x00
	ret
00104$:
;../generic/ch376s.c:170: write_command(CMD_RD_USB_DATA);
	ld	l, #0x27
	call	_write_command
;../generic/ch376s.c:171: uint8_t len = read_data();
	call	_read_data
	ld	b, l
;../generic/ch376s.c:172: read_data_multiple (sector_buffer,len);
	push	bc
	push	bc
	inc	sp
	ld	hl, #8
	add	hl, sp
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	push	bc
	call	_read_data_multiple
	pop	af
	inc	sp
	pop	bc
;../generic/ch376s.c:173: sector_buffer+=len;
	ld	hl, #5
	add	hl, sp
	ld	a, (hl)
	add	a, b
	ld	(hl), a
	jr	NC, 00128$
	inc	hl
	inc	(hl)
00128$:
;../generic/ch376s.c:174: write_command (CMD_DISK_RD_GO);
	ld	l, #0x55
	call	_write_command
;../generic/ch376s.c:176: while (true);
;../generic/ch376s.c:177: }
	jr	00105$
;../generic/ch376s.c:179: bool ch376s_disk_write (uint8_t nr_sectors,uint8_t* lba,uint8_t* sector_buffer)
;	---------------------------------
; Function ch376s_disk_write
; ---------------------------------
_ch376s_disk_write::
	push	ix
	ld	ix,#0
	add	ix,sp
;../generic/ch376s.c:181: write_command (CMD_DISK_WRITE);
	ld	l, #0x56
	call	_write_command
;../generic/ch376s.c:182: write_data (lba[0]);
	ld	c, 5 (ix)
	ld	b, 6 (ix)
	ld	a, (bc)
	ld	l, a
	push	bc
	call	_write_data
	pop	bc
;../generic/ch376s.c:183: write_data (lba[1]);
	ld	l, c
	ld	h, b
	inc	hl
	ld	l, (hl)
	push	bc
	call	_write_data
	pop	bc
;../generic/ch376s.c:184: write_data (lba[2]);
	ld	l, c
	ld	h, b
	inc	hl
	inc	hl
	ld	l, (hl)
	push	bc
	call	_write_data
	pop	bc
;../generic/ch376s.c:185: write_data (lba[3]);
	ld	hl, #3
	add	hl, bc
	ld	l, (hl)
	call	_write_data
;../generic/ch376s.c:186: write_data (nr_sectors);
	ld	l, 4 (ix)
	call	_write_data
;../generic/ch376s.c:189: uint8_t blocks = nr_sectors*(512/MAX_PACKET_LENGTH);
	ld	a, 4 (ix)
	add	a, a
	add	a, a
	add	a, a
	ld	c, a
;../generic/ch376s.c:190: for (cnt_write = 0;cnt_write < blocks;cnt_write++)
	ld	l, 7 (ix)
	ld	h, 8 (ix)
	ld	b, #0x00
00107$:
	ld	a, b
	sub	a, c
	jr	NC, 00105$
;../generic/ch376s.c:192: uint8_t status = ch376_wait_status ();
	push	hl
	push	bc
	call	_ch376_wait_status
	ld	a, l
	pop	bc
	pop	hl
;../generic/ch376s.c:193: if (status==USB_INT_SUCCESS)
	cp	a, #0x14
	jr	NZ, 00102$
;../generic/ch376s.c:194: return true;
	ld	l, #0x01
	jr	00109$
00102$:
;../generic/ch376s.c:195: if (status!=USB_INT_DISK_WRITE)
	sub	a, #0x1e
	jr	Z, 00104$
;../generic/ch376s.c:196: return false;
	ld	l, #0x00
	jr	00109$
00104$:
;../generic/ch376s.c:198: write_command(CMD_WR_HOST_DATA);
	push	hl
	push	bc
	ld	l, #0x2c
	call	_write_command
	ld	l, #0x40
	call	_write_data
	pop	bc
	pop	hl
;../generic/ch376s.c:200: write_data_multiple (sector_buffer,MAX_PACKET_LENGTH);
	push	hl
	push	bc
	ld	a, #0x40
	push	af
	inc	sp
	push	hl
	call	_write_data_multiple
	pop	af
	inc	sp
	pop	bc
	pop	hl
;../generic/ch376s.c:201: sector_buffer+=MAX_PACKET_LENGTH;
	ld	de, #0x0040
	add	hl, de
;../generic/ch376s.c:202: write_command (CMD_DISK_WR_GO);
	push	hl
	push	bc
	ld	l, #0x57
	call	_write_command
	pop	bc
	pop	hl
;../generic/ch376s.c:190: for (cnt_write = 0;cnt_write < blocks;cnt_write++)
	inc	b
	jr	00107$
00105$:
;../generic/ch376s.c:204: return true;
	ld	l, #0x01
00109$:
;../generic/ch376s.c:205: }
	pop	ix
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
