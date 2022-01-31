
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
        if ((i%16)==0)
            printf ("\n");
        if ((i%4)==0)
            printf (" ");
        printf ("%02x ",*(data+i));
    }
    printf ("\n");
}

int main ()
{
    char sector_buffer[512];
    memset (sector_buffer,0,512);

    hal_init ();
    usbdisk_init ();
    if (usbdisk_select_dsk_file ())
    {
        printf ("+Opened disk image\r\n");
        uint32_t sector=0;
        read_write_file_sectors (false,1,&sector,(uint8_t*) sector_buffer);
        print_buffer ((uint8_t*) sector_buffer,512);
    }
    else
    {
        printf ("+Full disk mode\r\n");
        uint32_t sector=0;
        read_write_disk_sectors (false,1,&sector,(uint8_t*) sector_buffer);
        print_buffer ((uint8_t*) sector_buffer,512);
    }
}