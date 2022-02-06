#ifndef __HAL_H_
#define __HAL_H_

void hal_init ();
void hal_deinit ();
#ifndef __SDCC

    void    write_command (uint8_t command);
    void    write_data (uint8_t data);
    uint8_t read_data ();
    uint8_t read_status ();
#else
    #ifndef ROOKIEDRIVE
        #define CMD_PORT 0x11
        #define DATA_PORT 0x10
    #else
        #define CMD_PORT 0x21
        #define DATA_PORT 0x20
    #endif
    void    write_command (uint8_t command)  __z88dk_fastcall __naked;
    void    write_data (uint8_t data)  __z88dk_fastcall __naked;
    uint8_t read_data ()  __z88dk_fastcall __naked;
    uint8_t read_status ()  __z88dk_fastcall __naked;
    int     putchar (int character);
    int     getchar ();
#endif
void    read_data_multiple (uint8_t* buffer,uint8_t len);
void    write_data_multiple (uint8_t* buffer,uint8_t len);
void    delay_ms (uint16_t milliseconds);
void    error (char* txt);
bool    supports_80_column_mode ();




#endif //__HAL_H_