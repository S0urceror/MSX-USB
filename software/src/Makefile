CC = zcc
CCFLAGS = +msx
OUTPUT_DIR = ../dist

all: $(OUTPUT_DIR)/lsusb.com $(OUTPUT_DIR)/flash.com
.PHONY: all clean copy

$(OUTPUT_DIR)/lsusb.com: lsusb.c lsusb.h
	$(CC) $(CCFLAGS) -subtype=msxdos -o$(OUTPUT_DIR)/lsusb.com $< 

$(OUTPUT_DIR)/flash.com: flash.c flash.h flash.asm
	z80asm -x$(OUTPUT_DIR)/flashasm.lib flash.asm
	$(CC) $(CCFLAGS) -l$(OUTPUT_DIR)/flashasm.lib -subtype=msxdos -o$(OUTPUT_DIR)/flash.com $< 

clean:
	-rm $(OUTPUT_DIR)/*.rom
	-rm $(OUTPUT_DIR)/*.com
	-rm $(OUTPUT_DIR)/*.bin
	-rm $(OUTPUT_DIR)/*.sym
