#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdbool.h>
#include "include/bios.h"
#include "include/driver.h"
#include "../include/hal.h"
#include "../include/usbdisk.h"


// return the pointer to the allocated workarea
workarea_t* get_workarea() __z88dk_fastcall __naked
{
    __asm
    GWORK .equ 0x4045
    CALBNK .equ 0x4042
    push ix
    xor a
    ex af,af' ;'
    xor a
    LD	ix,#GWORK
	call CALBNK
    ld l,0(ix)
    ld h,1(ix)
    pop ix
    ret
    __endasm;
} 

/*
    ;-----------------------------------------------------------------------------
    ;
    ; Timer interrupt routine, it will be called on each timer interrupt
    ; (at 50 or 60Hz), but only if DRV_INIT returns Cy=1 on its first execution.
*/
void interrupt ()
{
    #ifdef DEBUG
        printf ("interrupt\r\n");
    #endif
}

/*
    ; 1) First execution, for information gathering.
    ;    Input:
    ;      A = 0
    ;      B = number of available drives
    ;      HL = maximum size of allocatable work area in page 3
    ;      C: bit 5 set if user is requesting reduced drive count
    ;         (by pressing the 5 key)
    ;    Output:
    ;      A = number of required drives (for drive-based driver only)
    ;      HL = size of required work area in page 3
    ;      Cy = 1 if DRV_TIMI must be hooked to the timer interrupt, 0 otherwise
*/
uint16_t get_workarea_size (uint8_t reduced_drive_count,uint8_t nr_available_drives)
{
    #ifdef DEBUG
        printf ("get_workarea_size (%x,%x)\r\n",nr_available_drives,reduced_drive_count);
    #endif

    return sizeof (workarea_t);
}

/*
    ; 2) Second execution, for work area and hardware initialization.
    ;    Input:
    ;      A = 1
    ;      B = number of allocated drives for this controller
    ;      C: bit 5 set if user is requesting reduced drive count
    ;         (by pressing the 5 key)
    ;
    ;    The work area address can be obtained by using GWORK.
    ;
    ;    If first execution requests more work area than available,
    ;    second execution will not be done and DRV_TIMI will not be hooked
    ;    to the timer interrupt.
    ;
    ;    If first execution requests more drives than available,
    ;    as many drives as possible will be allocated, and the initialization
    ;    procedure will continue the normal way
    ;    (for drive-based drivers only. Device-based drivers always
    ;     get two allocated drives.)
*/
void init_driver (uint8_t reduced_drive_count,uint8_t nr_allocated_drives)
{
    #ifdef DEBUG
        printf ("init_driver (%x,%x)\r\n",nr_allocated_drives,reduced_drive_count);
    #endif

    hal_init ();
    workarea_t* workarea = get_workarea();
    usbdisk_init ();
    workarea->mount_mode = usbdisk_select_dsk_file (true);
    switch (workarea->mount_mode)
    {
        case 2:
            printf ("+Opened disk image\r\n");
            break;
        case 1:
            printf ("+Full disk mode\r\n");
            break;
        default:
            printf ("+Using floppy disk\r\n");
            break;
    }   
}

void onCallMOUNTDSK ()
{
    // close previous DSK file, if needed
    workarea_t* workarea = get_workarea();
    if (workarea->mount_mode == 2)
    {
        usbdisk_close_dsk_file ();
    }

    hal_init ();
    workarea->mount_mode = usbdisk_select_dsk_file (false);
    switch (workarea->mount_mode)
    {
        case 2:
            printf ("+Opened disk image\r\n");
            workarea->disk_change = true;
            break;
        default:
            printf ("-Not a valid choice\r\n");
            break;
    }
}

/*
; * Get number of drives at boot time (for device-based drivers only):
;   Input:
;     A = 1
;     B = 0 for DOS 2 mode, 1 for DOS 1 mode
;     C: bit 5 set if user is requesting reduced drive count
;        (by pressing the 5 key)
;   Output:
;     B = number of drives
*/ 
uint8_t get_nr_drives_boottime (uint8_t reduced_drive_count,uint8_t dos_mode)
{
    #ifdef DEBUG
        printf ("get_nr_drives_boottime (%d,%d)\r\n",dos_mode,reduced_drive_count);
    #endif

    workarea_t* workarea = get_workarea();
    if (workarea->mount_mode==0)
        return 0;

    return 1; // 1 drive requested
}

/*
; * Get default configuration for drive
;   Input:
;     A = 2
;     B = 0 for DOS 2 mode, 1 for DOS 1 mode
;     C = Relative drive number at boot time
;   Output:
;     B = Device index
;     C = LUN index
*/
uint16_t get_drive_config (uint8_t relative_drive_number,uint8_t dos_mode)
{
    #ifdef DEBUG
        printf ("get_config_drive (%d,%d)\r\n",dos_mode,relative_drive_number);
    #endif

    return 0x0101; // device 1, lun 1
}

/*
;-----------------------------------------------------------------------------
;
; Obtain logical unit information
;
;Input:   A  = Device index, 1 to 7
;         B  = Logical unit number, 1 to 7
;         HL = Pointer to buffer in RAM.
;Output:  A = 0: Ok, buffer filled with information.
;             1: Error, device or logical unit not available,
;                or device index or logical unit number invalid.
;         On success, buffer filled with the following information:
;
;+0 (1): Medium type:
;        0: Block device
;        1: CD or DVD reader or recorder
;        2-254: Unused. Additional codes may be defined in the future.
;        255: Other
;+1 (2): Sector size, 0 if this information does not apply or is
;        not available.
;+3 (4): Total number of available sectors.
;        0 if this information does not apply or is not available.
;+7 (1): Flags:
;        bit 0: 1 if the medium is removable.
;        bit 1: 1 if the medium is read only. A medium that can dinamically
;               be write protected or write enabled is not considered
;               to be read-only.
;        bit 2: 1 if the LUN is a floppy disk drive.
;+8 (2): Number of cylinders
;+10 (1): Number of heads
;+11 (1): Number of sectors per track
;
; Number of cylinders, heads and sectors apply to hard disks only.
; For other types of device, these fields must be zero.
*/

uint8_t get_lun_info (uint8_t nr_lun,uint8_t nr_device,luninfo_t* luninfo)
{
    #ifdef DEBUG
        printf ("get_lun_info (%x,%x)\r\n",nr_device,nr_lun);
    #endif

    if (nr_lun==1 && nr_device==1)
    {
        memset (luninfo,0,sizeof (luninfo_t));
        //luninfo->medium_type = 0;
        luninfo->sector_size = 512;
        //luninfo->total_nr_sectors = 1440;
        luninfo->flags = 0b00000001; // ; removable + non-read only + no floppy
        //luninfo->nr_cylinders = 80;
        //luninfo->nr_heads = 2;
        //luninfo->nr_sectors_track = 9;
        return 0x00;
    }
    // indicate error
    return 0x01;
}

/*
;-----------------------------------------------------------------------------
;
; Device information gathering
;
;Input:   A = Device index, 1 to 7
;         B = Information to return:
;             0: Basic information
;             1: Manufacturer name string
;             2: Device name string
;             3: Serial number string
;         HL = Pointer to a buffer in RAM
;Output:  A = Error code:
;             0: Ok
;             1: Device not available or invalid device index
;             2: Information not available, or invalid information index
;         When basic information is requested,
;         buffer filled with the following information:
;
;+0 (1): Number of logical units, from 1 to 7. 1 if the device has no logical
;        units (which is functionally equivalent to having only one).
;+1 (1): Device flags, always zero in Beta 2.
;
; The strings must be printable ASCII string (ASCII codes 32 to 126),
; left justified and padded with spaces. All the strings are optional,
; if not available, an error must be returned.
; If a string is provided by the device in binary format, it must be reported
; as an hexadecimal, upper-cased string, preceded by the prefix "0x".
; The maximum length for a string is 64 characters;
; if the string is actually longer, the leftmost 64 characters
; should be provided.
;
; In the case of the serial number string, the same rules for the strings
; apply, except that it must be provided right-justified,
; and if it is too long, the rightmost characters must be
; provided, not the leftmost.
*/
uint8_t get_device_info (uint8_t nr_info,uint8_t nr_device,uint8_t* info_buffer)
{
    #ifdef DEBUG
        printf ("get_device_info (%x,%x)\r\n",nr_device,nr_info);
    #endif

    if (nr_device!=1)
        return 1;

    switch (nr_info)
    {
        case 0: // basic information
                ((deviceinfo_t*)info_buffer)->nr_luns = 0x01;
                ((deviceinfo_t*)info_buffer)->flags = 0x00;
                break;
        case 1: // Manufacturer name string
                strcpy ((char*)info_buffer,"S0urceror");
                break;
        case 2: // Device name string
                strcpy ((char*)info_buffer,"MSXUSBNext");
                break;
        case 3: // Serial number string
                strcpy ((char*)info_buffer,"0000");
                break;
        default:
                return 2;
                break;
    }
    return 0;
}
/*
;-----------------------------------------------------------------------------
;
; Obtain device status
;
;Input:   A = Device index, 1 to 7
;         B = Logical unit number, 1 to 7
;             0 to return the status of the device itself.
;Output:  A = Status for the specified logical unit,
;             or for the whole device if 0 was specified:
;                0: The device or logical unit is not available, or the
;                   device or logical unit number supplied is invalid.
;                1: The device or logical unit is available and has not
;                   changed since the last status request.
;                2: The device or logical unit is available and has changed
;                   since the last status request
;                   (for devices, the device has been unplugged and a
;                    different device has been plugged which has been
;                    assigned the same device index; for logical units,
;                    the media has been changed).
;                3: The device or logical unit is available, but it is not
;                   possible to determine whether it has been changed
;                   or not since the last status request.
;
; Devices not supporting hot-plugging must always return status value 1.
; Non removable logical units may return values 0 and 1.
;
; The returned status is always relative to the previous invokation of
; DEV_STATUS itself. Please read the Driver Developer Guide for more info.
*/
uint8_t get_device_status (uint8_t nr_lun,uint8_t nr_device)
{
    #ifdef DEBUG
        printf ("get_device_status (%x,%x)\r\n",nr_device,nr_lun);
    #endif

    if (nr_device!=1 || nr_lun!=1)
        return 0;

    workarea_t* workarea = get_workarea();
    if (workarea->disk_change)
        return 2;

    return 1;
}

void caps_flash () __z88dk_fastcall __naked
{
    __asm
    ; CAPS FLASH
	in a, (0xaa)
    bit 6,a
    jr z, _CAPS_FLASH_ON
	res 6,a
    jr _CAPS_FLASH
_CAPS_FLASH_ON:
    set 6,a
_CAPS_FLASH:
	out (0xaa),a
    ret
	;
    __endasm;
}

/*
;-----------------------------------------------------------------------------
;
; Read or write logical sectors from/to a logical unit
;
;Input:    Cy=0 to read, 1 to write
;          A = Device number, 1 to 7
;          B = Number of sectors to read or write
;          C = Logical unit number, 1 to 7
;          HL = Source or destination memory address for the transfer
;          DE = Address where the 4 byte sector number is stored.
;Output:   A = Error code (the same codes of MSX-DOS are used):
;              0: Ok
;              _IDEVL: Invalid device or LUN
;              _NRDY: Not ready
;              _DISK: General unknown disk error
;              _DATA: CRC error when reading
;              _RNF: Sector not found
;              _UFORM: Unformatted disk
;              _WPROT: Write protected media, or read-only logical unit
;              _WRERR: Write error
;              _NCOMP: Incompatible disk.
;              _SEEK: Seek error.
;         B = Number of sectors actually read (in case of error only)
*/
diskerror_t read_or_write_sector (uint8_t read_or_write_flag, uint8_t nr_device, uint8_t nr_lun, uint8_t nr_sectors, uint32_t* sector, uint8_t* sector_buffer)
{
    #ifdef DEBUG
    if (read_or_write_flag & Z80_CARRY_MASK)
        printf ("write (%x,%x,%x,%x)\r\n",nr_device,nr_lun,nr_sectors,*sector);
    else
        printf ("read (%x,%x,%x,%x)\r\n",nr_device,nr_lun,nr_sectors,*sector);
    #endif

    workarea_t* workarea = get_workarea();
    //if (workarea->mount_mode==0)
    //    return NRDY;
    if (nr_device!=1 || nr_lun!=1)
        return IDEVL;

    caps_flash ();

    if (workarea->mount_mode==2)
    {
        // single DSK file mode
        // we assume file has been opened before and has not been closed
        if (!read_write_file_sectors (read_or_write_flag & Z80_CARRY_MASK,nr_sectors,sector,sector_buffer))
            return RNF;
    }
    else
    {
        // whole disk mode
        if (!read_write_disk_sectors (read_or_write_flag & Z80_CARRY_MASK,nr_sectors,sector,sector_buffer))
            return RNF;
    }

    caps_flash ();

    return OK;
}
