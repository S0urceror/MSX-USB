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
    printf ("MSXUSB-NXT v0.4 (c)Sourceror\r\n");
    ch376_reset_all();
    if (!ch376_plugged_in())
        error ("-CH376 NOT detected");
    //printf ("+CH376 detected\r\n");
    ch376_set_usb_host_mode(USB_MODE_HOST);
    if (!ch376_connect_disk ())
        error ("-Connect USB device");
    //printf ("+USB device connected\r\n");
    if (!ch376_mount_disk ())
        error ("-Not a valid disk");
    //printf ("+USB disk mounted\r\n");
}

char* toLower(char* s) {
  for(char *p=s; *p; p++) *p=tolower(*p);
  return s;
}
char* toUpper(char* s) {
  for(char *p=s; *p; p++) *p=toupper(*p);
  return s;
}

bool usbdisk_autoexec_dsk()
{
    uint8_t cnt_times;

    // open root directory
    ch376_set_filename ("/");
    if (!ch376_open_directory())
    {
        error ("-Directory not opened");
    }

    // try to open AUTOEXEC.DSK
    ch376_set_filename ("AUTOEXEC.DSK");
    if (ch376_open_file()==true)
    {
        printf ("\r\nStarting AUTOEXEC.DSK or press ESC ");
        for (cnt_times=3;cnt_times>0;cnt_times--)
        {
            delay_ms (1000);
            if (pressed_ESC())
                break;            
            printf (".");
        }
        if (cnt_times==0)
        {
            printf ("\r\n");
            return true;
        }
        else 
        {
            ch376_close_file ();
        }
    }
    return false;
}

#define MAX_FILES 26
select_mode_t usbdisk_select_dsk_file (char* start_directory)
{
    uint8_t nr_dsk_files_found;
    fat_dir_info_t info;
    char files[MAX_FILES][12];
    char filename[9];
    uint8_t nr_dsks_per_line;

    if (supports_80_column_mode())
        nr_dsks_per_line = 5;
    else
        nr_dsks_per_line = 2;

    nr_dsk_files_found=0;

    // open directory passed in the argument
    ch376_set_filename (start_directory);
    if (!ch376_open_directory())
    {
        error ("-Directory not opened");
    }

    // standard options
    printf ("\r\nSelect device:\r\n");
    printf ("1.FLOPPY       2.USBDRIVE\r\n\r\n");
    
    // browse directory
    ch376_set_filename ("*");
    if (!ch376_open_search ())
        error ("-No files found");
    
    printf ("Or, select DSK image [%s]:\r\n",start_directory);
    uint8_t cnt;
    do 
    {
        ch376_get_fat_info (&info);
        if (!(info.DIR_Attr&0x02)) // show non-hidden normal or archived files
        {
            if (info.DIR_Attr&0x20 || info.DIR_Attr==0x00)
            {
                if (info.DIR_Name[8]=='D' &&
                    info.DIR_Name[9]=='S' &&
                    info.DIR_Name[10]=='K')
                {
                    putchar ('A'+nr_dsk_files_found);
                    putchar ('.');
                    files[nr_dsk_files_found][11]='\0';
                    for (cnt=0;cnt<11;cnt++)
                    {
                        if (cnt==8)
                            putchar ('.');
                        putchar (info.DIR_Name[cnt]);
                        files[nr_dsk_files_found][cnt]=info.DIR_Name[cnt];
                    }
                    putchar (' ');
                    nr_dsk_files_found++;
                    if ((nr_dsk_files_found%nr_dsks_per_line) == 0)
                    {
                        putchar ('\r');
                        putchar ('\n');
                    }                    
                }
            }
            if (info.DIR_Attr&0x10)
            {
                putchar ('A'+nr_dsk_files_found);
                putchar ('.');
                putchar ('\\');
                files[nr_dsk_files_found][8]='\0';
                for (cnt=0;cnt<8;cnt++)
                {
                    putchar (tolower(info.DIR_Name[cnt]));
                    files[nr_dsk_files_found][cnt]=info.DIR_Name[cnt];
                }
                putchar (' ');
                putchar (' ');
                putchar (' ');
                putchar (' ');
                nr_dsk_files_found++;
                if ((nr_dsk_files_found%nr_dsks_per_line) == 0)
                {
                    putchar ('\r');
                    putchar ('\n');
                }
            }
        }
    }
    while (ch376_next_search () && nr_dsk_files_found<MAX_FILES);
    putchar ('\r');
    putchar ('\n');

    printf ("\r\n");
    while (true)
    {
        char c = getchar ();
        c = toupper (c);
        if (c>='A' && c<='A'+nr_dsk_files_found)
        {
            c-='A';
            if (files[c][8]=='\0')
            {
                // directory
                if (files[c][0]=='.')
                    return usbdisk_select_dsk_file ("/");
                else
                    return usbdisk_select_dsk_file (files[c]);
            }
            else
            {
                // files
                ch376_set_filename (files[c]);
                if (!ch376_open_file ())
                    error ("-DSK not opened\r\n");
                return DSK_IMAGE;
            }
        }
        if (c=='1')
            return FLOPPY;
        if (c=='2')
            return USB;
    }
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