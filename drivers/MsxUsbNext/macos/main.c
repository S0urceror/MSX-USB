
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdbool.h>
#include "../include/hal.h"
#include "../include/usbdisk.h"

void print_buffer (uint8_t* data, uint16_t length)
{
    for (int i=0;i<length;i++)
    {
        if (i>0 && (i%16)==0)
            printf ("\r\n");
        if ((i%4)==0)
            printf (" ");
        printf ("%02x ",*(data+i));
    }
    printf ("\n");
}

int main ()
{
    uint8_t mount_mode;
    uint32_t sector=0;
    char sector_buffer[512];
    memset (sector_buffer,0,512);

    hal_init ();
    usbdisk_init ();
    mount_mode = usbdisk_select_dsk_file ();
    switch (mount_mode)
    {
        case 2:
            printf ("+Opened disk image\r\n");
            read_write_file_sectors (false,1,&sector,(uint8_t*) sector_buffer);
            print_buffer ((uint8_t*) sector_buffer,512);
            break;
        case 1:
            printf ("+Full disk mode\r\n");
            read_write_disk_sectors (false,1,&sector,(uint8_t*) sector_buffer);
            print_buffer ((uint8_t*) sector_buffer,512);
            break;
        default:
            printf ("+Using floppy disk\r\n");
            break;
    }   

    hal_deinit();
}