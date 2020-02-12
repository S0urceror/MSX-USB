CC = zcc
CCFLAGS = +msx
OUTPUT_DIR = ../dist

all: $(OUTPUT_DIR)/lsusb.bin
.PHONY: all clean copy

$(OUTPUT_DIR)/lsusb.bin: lsusb.c lsusb.h
	$(CC) $(CCFLAGS) -create-app -subtype=disk -o$(OUTPUT_DIR)/lsusb.bin $< 

clean:
	-rm $(OUTPUT_DIR)/*.rom
	-rm $(OUTPUT_DIR)/*.com
	-rm $(OUTPUT_DIR)/*.bin
	-rm $(OUTPUT_DIR)/*.sym
