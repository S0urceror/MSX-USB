#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "../include/usbdisk.h"
#include "../include/ch376s.h"
#include "../include/hal.h"

void usbdisk_init ()
{
    printf ("MSXUSB-NXT v0.2 (c)Sourceror\r\n");
    ch376_reset_all();
    if (!ch376_plugged_in())
        error ("-CH376 NOT detected");
    printf ("+CH376 detected\r\n");
    ch376_set_usb_host_mode(USB_MODE_HOST);
    if (!ch376_connect_disk ())
        error ("-Connect USB device");
    printf ("+USB device connected\r\n");
    if (!ch376_mount_disk ())
        error ("-Not a valid disk");
    printf ("+USB disk mounted\r\n");
}

#define MAX_FILES 26
select_mode_t usbdisk_select_dsk_file (bool whole_disk_allowed)
{
    uint8_t nr_dsk_files_found;
    fat_dir_info_t info;
    char files[MAX_FILES][12];
    char filename[9];
    uint8_t nr_dsks_per_line;

    if (supports_80_column_mode())
        nr_dsks_per_line = 6;
    else
        nr_dsks_per_line = 3;

    nr_dsk_files_found=0;
    ch376_set_filename ("/DSKS");
    if (!ch376_open_directory())
    {
        ch376_set_filename ("/");
        if (!ch376_open_directory())
            error ("-Directory not opened");
    }
    ch376_set_filename ("*");
    if (!ch376_open_search ())
        error ("-No files found");
    
    if (whole_disk_allowed)
    {
        printf ("+Select device:\r\n");
        printf (" 1.FLOPPY   2.USBDRIVE\r\n");
    }
    do 
    {
        ch376_get_fat_info (&info);
        // check for normal files with DSK extension
        if ((info.DIR_Attr==0x20 || info.DIR_Attr==0x00) &&
            info.DIR_Name[8]=='D' &&
            info.DIR_Name[9]=='S' &&
            info.DIR_Name[10]=='K')
        {
            if (nr_dsk_files_found==0)
            {
                if (!whole_disk_allowed)
                    printf ("Select DSK image:\r\n");
                else
                    printf ("+Or, select DSK image:\r\n");
            }
            strncpy (files[nr_dsk_files_found],(char*)info.DIR_Name,11);
            files[nr_dsk_files_found][11] = '\0';
            strncpy (filename,files[nr_dsk_files_found],8);
            filename[8]='\0';
            printf (" %c.%s",'A'+nr_dsk_files_found, filename);
            nr_dsk_files_found++;
            if ((nr_dsk_files_found % nr_dsks_per_line) == 0)
                printf ("\r\n");
        }
    } 
    while (ch376_next_search () && nr_dsk_files_found<MAX_FILES);

    if (!whole_disk_allowed && nr_dsk_files_found==0)
        return USB;

    printf ("\r\n");
    char c = getchar ();
    c = toupper (c);
    if (c>='A' && c<='A'+nr_dsk_files_found)
    {
        c-='A';
        ch376_set_filename (files[c]);
        if (!ch376_open_file ())
            error ("-DSK not opened\r\n");
        return DSK_IMAGE;
    }
    if (c=='2')
        return USB;
    return FLOPPY;
}

bool read_write_file_sectors (bool writing,uint8_t nr_sectors,uint32_t* sector,uint8_t* sector_buffer)
{
    uint8_t sectors_lba[8];
    if (!ch376_locate_sector ((uint8_t*)sector))
        return false;
    if (!ch376_get_sector_LBA (nr_sectors,(uint8_t*) &sectors_lba))
        return false;
    if (!writing)
    {
        if (!ch376s_disk_read (sectors_lba[0],sectors_lba+4,sector_buffer))
            return false;
    }
    else
    {
        if (!ch376s_disk_write (sectors_lba[0],sectors_lba+4,sector_buffer))
            return false;
    }

    return true;
}

bool read_write_disk_sectors (bool writing,uint8_t nr_sectors,uint32_t* sector,uint8_t* sector_buffer)
{
    if (!writing)
    {
        if (!ch376s_disk_read (nr_sectors,(uint8_t*)sector,sector_buffer))
            return false;
    }
    else
    {
        if (!ch376s_disk_write (nr_sectors,(uint8_t*)sector,sector_buffer))
            return false;
    }
    
    return true;
}

bool usbdisk_close_dsk_file ()
{
    return ch376_close_file();
}