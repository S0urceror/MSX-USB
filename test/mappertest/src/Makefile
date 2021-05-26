ASM = sjasmplus
ASMFLAGS = --raw=$@ --sym=$(basename $@).sym --lst=$(basename $@).lst
OUTPUT_DIR = ../dist

all: $(OUTPUT_DIR)/test.rom
.PHONY: all clean copy

$(OUTPUT_DIR)/test.rom: test.asm segment.asm segmentlast.asm
	$(ASM) $(ASMFLAGS) $< 
	
clean:
	-rm $(OUTPUT_DIR)/*.rom
