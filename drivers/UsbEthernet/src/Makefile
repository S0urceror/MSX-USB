ASM = sjasmplus
ASMFLAGS = --raw=$@ --sym=$(basename $@).sym --lst=$(basename $@).lst
OUTPUT_DIR = ../dist

all: $(OUTPUT_DIR)/usbether.com
.PHONY: all clean copy

$(OUTPUT_DIR)/usbether.com: main.asm tsr.asm usb.asm usb_descriptors.asm unapi_init.asm unapi.asm
	$(ASM) $(ASMFLAGS) $< 
	
clean:
	-rm $(OUTPUT_DIR)/*.rom
	-rm $(OUTPUT_DIR)/*.com
	-rm $(OUTPUT_DIR)/*.bin
	-rm $(OUTPUT_DIR)/*.sym
