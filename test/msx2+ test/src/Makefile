ASM = ~/Development/MSX/Compilers/sjasmplus/sjasmplus
ASMFLAGS = --raw=$@ --sym=$(basename $@).sym --lst=$(basename $@).lst
OUTPUT_DIR = ../dist

all: $(OUTPUT_DIR)/test.bin
.PHONY: all clean copy

$(OUTPUT_DIR)/test.bin: main.asm print_vdp.asm
	$(ASM) $(ASMFLAGS) $< 
	
clean:
	-rm $(OUTPUT_DIR)/*.rom
	-rm $(OUTPUT_DIR)/*.com
	-rm $(OUTPUT_DIR)/*.bin
	-rm $(OUTPUT_DIR)/*.sym
