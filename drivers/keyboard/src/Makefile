ASM = sjasmplus
ASMFLAGS = --raw=$@ --sym=$(basename $@).sym
OUTPUT_DIR = ../dist

all: $(OUTPUT_DIR)/driver.bin $(OUTPUT_DIR)/isr.bin
.PHONY: all clean copy

$(OUTPUT_DIR)/driver.bin: driver.asm ch376s.asm print_bios.asm usb.asm keyboard.asm
	$(ASM) $(ASMFLAGS) $< 
	
$(OUTPUT_DIR)/isr.bin: isr.asm
	$(ASM) $(ASMFLAGS) $< 

clean:
	-rm $(OUTPUT_DIR)/*.rom
	-rm $(OUTPUT_DIR)/*.com
	-rm $(OUTPUT_DIR)/*.bin
	-rm $(OUTPUT_DIR)/*.sym

copy:
	cp $(OUTPUT_DIR)/main.bin /Volumes/Untitled
