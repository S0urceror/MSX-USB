#ifndef __DRIVER_H
#define __DRIVER_H

#define Z80_CARRY_MASK              0b00000001
#define Z80_SUBTRACT_MASK           0b00000010
#define Z80_PARITY_OVERFLOW_MASK    0b00000100
#define Z80_HALF_CARRY_MASK         0b00010000
#define Z80_ZERO_MASK               0b01000000
#define Z80_SIGN_MASK               0b10000000

typedef struct
{
    uint8_t mount_mode;
    bool    disk_change;
} workarea_t;

typedef struct
{
    uint8_t medium_type;
    uint16_t sector_size;
    uint32_t total_nr_sectors;
    uint8_t flags;
    uint16_t nr_cylinders;
    uint8_t nr_heads;
    uint8_t nr_sectors_track;
} luninfo_t;

typedef struct
{
/*
;+0 (1): Number of logical units, from 1 to 7. 1 if the device has no logical
;        units (which is functionally equivalent to having only one).
;+1 (1): Device flags, always zero in Beta 2.
*/
    uint8_t nr_luns;
    uint8_t flags;
} deviceinfo_t;

typedef enum
{
    OK = 0x00,
    NCOMP = 0xff,   // Incompatible disk.
    WRERR = 0xfe,   // Write error
    DISK = 0xfd,    // General unknown disk error
    NRDY = 0xfc,    // Not ready
    DATA = 0xfa,    // CRC error when reading
    RNF = 0xf9,     // Sector not found
    WPROT = 0xf8,   // Write protected media, or read-only logical unit
    UFORM = 0xf7,   // Unformatted disk
    SEEK = 0xf3,    // Seek error.
    IFORM = 0xf0,
    IDEVL = 0xb5,   // Invalid device or LUN
    IPARM = 0x8b
} diskerror_t;

#endif //__DRIVER_H