ASM = sjasmplus
ASMFLAGS = --raw=$@ --sym=$(basename $@).sym --lst=$(basename $@).lst
OUTPUT_DIR = ../dist

all: $(OUTPUT_DIR)/usbkeybd.com
.PHONY: all clean copy

$(OUTPUT_DIR)/usbkeybd.com: main.asm keyboard.asm tsr.asm usb.asm print_dos.asm
	$(ASM) $(ASMFLAGS) $< 
	
clean:
	-rm $(OUTPUT_DIR)/*.rom
	-rm $(OUTPUT_DIR)/*.com
	-rm $(OUTPUT_DIR)/*.bin
	-rm $(OUTPUT_DIR)/*.sym
