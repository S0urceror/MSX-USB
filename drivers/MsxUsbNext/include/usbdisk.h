#ifndef __USB_DISK_H
#define __USB_DISK_H

typedef enum
{
    FLOPPY,
    USB,
    DSK_IMAGE
} select_mode_t;

void usbdisk_init ();
select_mode_t usbdisk_select_dsk_file (bool whole_disk_allowed);
bool read_write_file_sectors (bool writing,uint8_t nr_sectors,uint32_t* nr_sector,uint8_t* sector_buffer);
bool read_write_disk_sectors (bool writing,uint8_t nr_sectors,uint32_t* nr_sector,uint8_t* sector_buffer);
bool usbdisk_close_dsk_file();

#endif // __USB_DISK_H