#ifndef __CH376S_H
#define __CH376S_H

// maximum packet length the CH376s can transmit or receive
#define MAX_PACKET_LENGTH 64

#define CMD_GET_IC_VER 0x01
#define CMD_SET_USB_SPEED 0x04
#define CMD_RESET_ALL 0x05
#define CMD_CHECK_EXIST 0x06
#define CMD_SET_USB_MODE 0x15
#define CMD_TEST_CONNECT 0x16
#define CMD_GET_STATUS 0x22
#define CMD_SET_USB_ADDR 0x13
#define CMD_SET_ENDP6 0x1C
#define CMD_SET_ENDP7 0x1D
#define CMD_RD_USB_DATA 0x27
#define CMD_RD_USB_DATA_UNLOCK     0x28
//#define CMD_WR_USB_DATA7 0x2B
#define CMD_WR_HOST_DATA 0x2C
#define CMD_SET_FILE_NAME 0x2F
#define CMD_DISK_CONNECT 0x30
#define CMD_DISK_MOUNT 0x31
#define CMD_OPEN_FILE 0x32
#define CMD_FILE_ENUM_GO 0x33
#define CMD_CLOSE_FILE 0x36
#define CMD_DIR_INFO_READ 0x37

#define CMD_BYTE_READ 0x3a
#define CMD_BYTE_RD_GO 0x3b

#define CMD_CLR_STALL 0x41
#define CMD_SET_ADDRESS 0x45
#define CMD_GET_DESCR 0x46
#define CMD_SET_CONFIG 0x49
#define CMD_SEC_LOCATE 0x4a
#define CMD_SEC_READ 0x4b
#define CMD_ISSUE_TOKEN 0x4F
#define CMD_ISSUE_TKN_X 0x4E
#define CMD_DISK_READ 0x54
#define CMD_DISK_RD_GO 0x55
#define CMD_DISK_WRITE 0x56
#define CMD_DISK_WR_GO 0x57
#define CMD_ABORT_NAK 0x17
#define CMD_GET_REGISTER 0x0A
#define CMD_SET_REGISTER 0x0B

#define USB_MODE_HOST_NON_SOF 0x05
#define USB_MODE_HOST 0x06
#define USB_MODE_HOST_RESET 0x07

#define USB_ERR_OPEN_DIR 0x41
#define USB_ERR_MISS_FILE 0x42
#define USB_ERR_FOUND_NAME 0x43

#define USB_INT_SUCCESS 0x14
#define USB_INT_CONNECT 0x15
#define USB_INT_DISCONNECT 0x16
#define USB_INT_BUF_OVER 0x17
#define USB_INT_USB_READY 0x18
#define USB_INT_DISK_READ 0x1d
#define USB_INT_DISK_WRITE 0x1e

#define CMD_RET_SUCCESS 0x51
#define CMD_RET_ABORT 0x52

#define VAR_FILE_BIT_FLAG 0x26

/* File directory information in FAT data area */
typedef struct 
{
    uint8_t DIR_Name [11];      /* 00H, file name, a total of 11 bytes, fill in the blanks */
    uint8_t DIR_Attr;           /* 0BH, file attributes, refer to the following instructions */
    uint8_t DIR_NTRes;          /* 0CH */
    uint8_t DIR_CrtTimeTenth;   /* 0DH, the time of file creation, counted in units of 0.1 seconds */
    uint16_t DIR_CrtTime;       /* 0EH, file creation time */
    uint16_t DIR_CrtDate;       /* 10H, date of file creation */
    uint16_t DIR_LstAccDate;    /* 12H, the date of the last access operation */
    uint16_t DIR_FstClusHI;     /* 14H */
    uint16_t DIR_WrtTime;       /* 16H, file modification time, refer to the previous macro MAKE_FILE_TIME */
    uint16_t DIR_WrtDate;       /* 18H, file modification date, refer to the previous macro MAKE_FILE_DATE */
    uint16_t DIR_FstClusLO;     /* 1AH */
    uint32_t DIR_FileSize;      /* 1CH, file length */
} fat_dir_info_t;

void ch376_reset_all();
bool ch376_plugged_in();
bool ch376_set_usb_host_mode(uint8_t mode);
bool ch376_connect_disk ();
bool ch376_mount_disk ();
uint8_t ch376_wait_status ();
uint8_t ch376_get_register_value (uint8_t reg);
bool ch376_open_file ();
bool ch376_open_directory ();
void ch376_set_filename (char* name);
bool ch376_open_search ();
bool ch376_next_search ();
void ch376_get_fat_info (fat_dir_info_t* info);
bool ch376_locate_sector (uint8_t* sector);
bool ch376_get_sector_LBA (uint8_t nr_sectors,uint8_t* sectors_allowed_lba);
bool ch376s_disk_read (uint8_t nr_sectors,uint8_t* lba,uint8_t* sector_buffer);
bool ch376s_disk_write (uint8_t nr_sectors,uint8_t* lba,uint8_t* sector_buffer);

#endif //__CH376S_H