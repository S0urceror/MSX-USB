#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include "../include/hal.h"


// LOW_LEVEL serial communication to CH376
///////////////////////////////////////////////////////////////////////////
const uint8_t WR_COMMAND = 1;
const uint8_t RD_STATUS = 2;
const uint8_t WR_DATA = 3;
const uint8_t RD_DATA = 4;
const uint8_t RD_INT = 5;
const uint8_t RD_DATA_MULTIPLE = 6;
const uint8_t WR_DATA_MULTIPLE = 7;
const uint8_t DATA_DUMP = 10;
const uint8_t SPI_WRITE_MULTIPLE = 11;

//#define   B115200 0010002
//#define   B230400 0010003
#define   B460800 0010004
#define   B500000 0010005
#define   B576000 0010006
#define   B921600 0010007
#define  B1000000 0010010
#define  B1152000 0010011
#define  B1500000 0010012
#define  B2000000 0010013
#define  B2500000 0010014
#define  B3000000 0010015
#define  B3500000 0010016
#define  B4000000 0010017
#define BAUDRATE B115200
int serial=-1;
static struct termios termios_old, termios_new;

bool supports_80_column_mode()
{
    return true;
}

void hal_init ()
{
    // setup serial 
    char device[] = "/dev/tty.usbmodem39528001";
    serial = open(device, O_RDWR | O_NOCTTY | O_NONBLOCK);
    if(serial == -1)
      error( "failed to open port" );
    if(!isatty(serial))
      error( "not serial" );
    fcntl(serial, F_SETFL, 0);
    
    struct termios  config;
    memset(&config, 0, sizeof(config));
    config.c_cflag |= CS8 | CLOCAL | CREAD;
    config.c_iflag |= IGNPAR;
    cfsetispeed (&config, B230400);
    cfsetospeed (&config, B230400);
     
    config.c_cc[VTIME]    = 1;   /* wait 0.1 * VTIME on new characters to arrive when blocking */
    config.c_cc[VMIN]     = 1;   /* blocking read until 1 chars received */
    
    tcflush(serial, TCIFLUSH);
    tcsetattr(serial, TCSANOW, &config); 

    // setup terminal/console
    tcgetattr(STDIN_FILENO, &termios_old);
    termios_new = termios_old;
    cfmakeraw(&termios_new);
    tcsetattr(STDIN_FILENO, TCSANOW, &termios_new);

}
void hal_deinit ()
{
    tcsetattr(STDIN_FILENO, TCSANOW, &termios_old);
    close (serial);
}

void write_command (uint8_t command)
{
    uint8_t cmd[] = {WR_COMMAND,command};
    write (serial,cmd,sizeof(cmd));
}
void write_data (uint8_t data)
{
    uint8_t cmd[] = {WR_DATA,data};
    write (serial,cmd,sizeof(cmd));
}
void write_data_multiple (uint8_t* buffer,uint8_t len)
{
    uint8_t cmd[] = {WR_DATA_MULTIPLE,len};
    write (serial,cmd,sizeof(cmd));
    write (serial,buffer,len);
}
uint8_t read_data ()
{
    uint8_t new_value;
    uint8_t cmd[] = {RD_DATA};
    write (serial,cmd,sizeof(cmd));
    read (serial,&new_value,1);
    return new_value;
}
void read_data_multiple (uint8_t* buffer,uint8_t len)
{
    int i;
    uint8_t *pTemp = buffer;

    uint8_t cmd[] = {RD_DATA_MULTIPLE,len};
    write (serial,cmd,sizeof(cmd));
    uint8_t bytes_read = 0;
    while (bytes_read<len)
    {
        uint8_t bytes = read (serial,buffer,len);
        if (bytes==0) 
            error ("did not receive data");
        bytes_read += bytes;
        buffer += bytes;
    }
}
uint8_t read_status ()
{
    uint8_t new_value;
    uint8_t cmd[] = {RD_STATUS};
    write (serial,cmd,sizeof(cmd));
    read (serial,&new_value,1);
    return new_value;
}
void delay_ms (uint16_t milliseconds)
{
    usleep (milliseconds*1000);
}
void error (char* txt)
{
    printf ("Error: %s\r\n",txt);
    exit (0);
}
