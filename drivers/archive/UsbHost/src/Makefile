ASM = sjasmplus
ASMFLAGS = --raw=$@ --sym=$(basename $@).sym
OUTPUT_DIR = ../dist

all: $(OUTPUT_DIR)/unapiusb.rom
.PHONY: all clean copy

$(OUTPUT_DIR)/unapiusb.rom: main.asm unapi.asm usb_descriptors.asm ch376s.asm
# $(OUTPUT_DIR)/unapiusb.rom: test.asm
	$(ASM) $(ASMFLAGS) $< 
	
clean:
	-rm $(OUTPUT_DIR)/*.rom
	-rm $(OUTPUT_DIR)/*.com
	-rm $(OUTPUT_DIR)/*.bin
	-rm $(OUTPUT_DIR)/*.sym
