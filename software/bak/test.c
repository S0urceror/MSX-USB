#include <msx_fusion.h>
#include <stdio.h>
#include <stdlib.h>

extern unsigned char    *heap_top; 

int main(char** argv, int argc)
{
    printf ("Free heap: %x\r\n",heap_top);
    void* ptr = MMalloc (1024);
    printf ("%x\r\n",ptr);
    printf ("Free heap: %x\r\n",heap_top);
    
    return 0;
}