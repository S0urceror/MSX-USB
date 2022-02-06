#include <stdbool.h>
#include <string.h>
#include <stdint.h>
#include <stdio.h>
#include "../include/hal.h"
#include "../include/ch376s.h"

void ch376_reset_all()
{
    write_command (CMD_RESET_ALL);
    delay_ms (100);
}
bool ch376_plugged_in()
{
    uint8_t value = 190;
    uint8_t new_value;

    write_command (CMD_CHECK_EXIST);
    write_data(value);
    new_value = read_data ();
    value = value ^ 255;

    if (new_value != value)
        return false;
    return true;
}
bool ch376_set_usb_host_mode(uint8_t mode)
{
    write_command(CMD_SET_USB_MODE);
    write_data(mode);
    delay_ms (250);
    uint8_t value;
    value = read_data();
    if ( value == CMD_RET_SUCCESS )
        return true;
    return false;
}
bool ch376_connect_disk ()
{
    write_command (CMD_DISK_CONNECT);
    if (ch376_wait_status ()!=USB_INT_SUCCESS)
        return false;
    return true;
}
bool ch376_mount_disk ()
{
    write_command (CMD_DISK_MOUNT);
    if (ch376_wait_status ()!=USB_INT_SUCCESS)
        return false;
    return true;
}

uint8_t ch376_wait_status ()
{
    uint8_t interrupt;
    //uint8_t counter = 100;
    //while (counter>0)
    while (true)
    {
        interrupt=read_status();
        if ((interrupt&0x80)==0)
            break;
        //counter --;
    }
    //if (counter<=0)
    //    return 0;

    write_command(CMD_GET_STATUS);
    return read_data ();
}

uint8_t ch376_get_register_value (uint8_t reg)
{
    write_command (CMD_GET_REGISTER);
    write_data (reg); 
    return read_data ();
}

void ch376_set_filename (char* name)
{
    write_command (CMD_SET_FILE_NAME);
    write_data_multiple ((uint8_t*) name,strlen(name));
    write_data (0);
}
bool ch376_open_file ()
{
    write_command (CMD_OPEN_FILE);
    if (ch376_wait_status ()!=USB_INT_SUCCESS)
        return false;
    return true;
}
bool ch376_close_file ()
{
    write_command (CMD_CLOSE_FILE);
    write_data (0);
    if (ch376_wait_status ()!=USB_INT_SUCCESS)
        return false;
    return true;
}
bool ch376_open_directory ()
{
    write_command (CMD_OPEN_FILE);
    if (ch376_wait_status ()!=USB_ERR_OPEN_DIR)
        return false;
    return true;
}
bool ch376_open_search ()
{
    // start enumerating
    write_command (CMD_OPEN_FILE);
    if (ch376_wait_status ()!=USB_INT_DISK_READ)
        return false;
    return true;
}
bool ch376_next_search ()
{
    // continue enumerating
    write_command (CMD_FILE_ENUM_GO);
    if (ch376_wait_status ()!=USB_INT_DISK_READ)
        return false;
    return true;
}
void ch376_get_fat_info (fat_dir_info_t* info)
{
    // get file info
    write_command(CMD_RD_USB_DATA);
    uint8_t len = read_data();
    read_data_multiple ((uint8_t*) info,len);
}

bool ch376_locate_sector (uint8_t* sector)
{
    write_command (CMD_SEC_LOCATE);
    write_data (sector[0]);
    write_data (sector[1]);
    write_data (sector[2]);
    write_data (sector[3]);

    if (ch376_wait_status ()!=USB_INT_SUCCESS)
        return false;
    return true;    
}

bool ch376_get_sector_LBA (uint8_t nr_sectors,uint8_t* sectors_allowed_lba)
{
    write_command (CMD_SEC_READ);
    write_data (nr_sectors);
    if (ch376_wait_status ()!=USB_INT_SUCCESS)
        return false;

    // we should get 8 bytes
    // READ_BUFFER + 0,1,2,3 = nr. of sectors that we are allowed to read/write, zero is EOF
    // READ_BUFFER + 4,5,6,7 = LBA absolute disk sector
    write_command(CMD_RD_USB_DATA);
    uint8_t len = read_data();
    read_data_multiple (sectors_allowed_lba,len);

    return true;
}

bool ch376s_disk_read (uint8_t nr_sectors,uint8_t* lba,uint8_t* sector_buffer)
{
    write_command (CMD_DISK_READ);
    write_data (lba[0]);
    write_data (lba[1]);
    write_data (lba[2]);
    write_data (lba[3]);
    write_data (nr_sectors);

    do
    {
        uint8_t status = ch376_wait_status ();
        if (status==USB_INT_SUCCESS)
            return true;
        if (status!=USB_INT_DISK_READ)
            return false;

        write_command(CMD_RD_USB_DATA);
        uint8_t len = read_data();
        read_data_multiple (sector_buffer,len);
        sector_buffer+=len;
        write_command (CMD_DISK_RD_GO);
    }
    while (true);
}

bool ch376s_disk_write (uint8_t nr_sectors,uint8_t* lba,uint8_t* sector_buffer)
{
    write_command (CMD_DISK_WRITE);
    write_data (lba[0]);
    write_data (lba[1]);
    write_data (lba[2]);
    write_data (lba[3]);
    write_data (nr_sectors);

    uint8_t cnt_write;
    uint8_t blocks = nr_sectors*(512/MAX_PACKET_LENGTH);
    for (cnt_write = 0;cnt_write < blocks;cnt_write++)
    {
        uint8_t status = ch376_wait_status ();
        if (status==USB_INT_SUCCESS)
            return true;
        if (status!=USB_INT_DISK_WRITE)
            return false;

        write_command(CMD_WR_HOST_DATA);
        write_data(MAX_PACKET_LENGTH);
        write_data_multiple (sector_buffer,MAX_PACKET_LENGTH);
        sector_buffer+=MAX_PACKET_LENGTH;
        write_command (CMD_DISK_WR_GO);
    }
    return true;
}