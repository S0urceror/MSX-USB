#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "../include/ch376s.h"
#include "../include/hal.h"

void usbdisk_init ()
{
    printf ("MSXUSB-NXT v0.1 (c)Sourceror\r\n");
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

bool usbdisk_select_dsk_file ()
{
    uint8_t nr_dsk_files_found;
    fat_dir_info_t info;
    char files[9][12];
    char filename[9];

    nr_dsk_files_found=0;
    ch376_set_filename ("/");
    if (!ch376_open_directory())
        error ("-Directory not opened");

    ch376_set_filename ("*");
    if (!ch376_open_search ())
        error ("-No files found");
    
    printf ("+Select DSK:\r\n");
    printf (" [D] USBDRIVE\r\n");
    do 
    {
        ch376_get_fat_info (&info);
        // check for normal files with DSK extension
        if ((info.DIR_Attr==0x20 || info.DIR_Attr==0x00) &&
            info.DIR_Name[8]=='D' &&
            info.DIR_Name[9]=='S' &&
            info.DIR_Name[10]=='K')
        {
            
            strncpy (files[nr_dsk_files_found],(char*)info.DIR_Name,11);
            files[nr_dsk_files_found][11] = '\0';
            strncpy (filename,files[nr_dsk_files_found],8);
            filename[8]='\0';
            printf (" [%d] %s",nr_dsk_files_found+1, filename);
            if (nr_dsk_files_found%2)
                printf ("\r\n");
            nr_dsk_files_found++;
        }
    } 
    while (ch376_next_search () && nr_dsk_files_found<9);

    printf ("\r\n");
    char c = getchar ();
    if (c>='1' && c<='0'+nr_dsk_files_found)
    {
        c-='0';
        ch376_set_filename (files[c-1]);
        if (!ch376_open_file ())
            error ("-DSK not opened\r\n");
        return true;
    }
    return false;
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