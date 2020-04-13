ASM = sjasmplus
ASMFLAGS = --raw=$@ --sym=$(basename $@).sym
OUTPUT_DIR = ../dist

all: $(OUTPUT_DIR)/direct.bin
.PHONY: all clean copy

$(OUTPUT_DIR)/direct.bin: main.asm
	$(ASM) $(ASMFLAGS) $< 
	
clean:
	-rm $(OUTPUT_DIR)/*.rom
	-rm $(OUTPUT_DIR)/*.com
	-rm $(OUTPUT_DIR)/*.bin
	-rm $(OUTPUT_DIR)/*.sym
