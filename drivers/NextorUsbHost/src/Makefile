ASM = sjasmplus
ASMFLAGS = --fullpath --raw=$@ --sym=$(basename $@).sym
OUTPUT_DIR = ../dist
KERNEL_DIR = ../kernel

all: $(OUTPUT_DIR)/driver.rom $(OUTPUT_DIR)/chgbnk.bin $(OUTPUT_DIR)/nextor.rom $(OUTPUT_DIR)/extra1k.dat

.PHONY: all clean copy

$(OUTPUT_DIR)/chgbnk.bin: chgbnk.asm
	$(ASM) $(ASMFLAGS) $< 

$(OUTPUT_DIR)/driver.rom: driver.asm driver_helpers.asm basic_extensions.asm print_bios.asm ch376s.asm ch376s_helpers.asm usbhost.asm nextordirect.asm ramhelper.asm
	$(ASM) $(ASMFLAGS) $<

$(OUTPUT_DIR)/extra1k.dat: extra1k.asm
	$(ASM) $(ASMFLAGS) $<

$(OUTPUT_DIR)/nextor.rom: $(OUTPUT_DIR)/driver.rom $(OUTPUT_DIR)/chgbnk.bin $(OUTPUT_DIR)/extra1k.dat
	$(KERNEL_DIR)/mknexrom $(KERNEL_DIR)/Nextor-2.1.0-beta2.base.dat $(OUTPUT_DIR)/nextor.rom \
							/d:$(OUTPUT_DIR)/driver.rom /m:$(OUTPUT_DIR)/chgbnk.bin \
							/e:$(OUTPUT_DIR)/extra1k.dat
	
clean:
	-rm $(OUTPUT_DIR)/*.rom
	-rm $(OUTPUT_DIR)/*.com
	-rm $(OUTPUT_DIR)/*.bin
	-rm $(OUTPUT_DIR)/*.sym

copy:
	cp $(OUTPUT_DIR)/main.bin /Volumes/Untitled
