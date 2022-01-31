ASM = sjasmplus
ASMFLAGS = --fullpath --raw=$@ --sym=$(basename $@).sym -D__ROOKIEDRIVE
OUTPUT_DIR = ../dist
KERNEL_DIR = ../kernel

all: $(OUTPUT_DIR)/driverrd.rom $(OUTPUT_DIR)/chgbnkrd.bin $(OUTPUT_DIR)/nextorrd.rom $(OUTPUT_DIR)/extra1k.dat
.PHONY: all clean copy

$(OUTPUT_DIR)/chgbnkrd.bin: chgbnk.asm
	$(ASM) $(ASMFLAGS) $< 

$(OUTPUT_DIR)/driverrd.rom: driver.asm driver_helpers.asm basic_extensions.asm print_bios.asm ch376s.asm ch376s_helpers.asm usbhost.asm nextordirect.asm ramhelper.asm
	$(ASM) $(ASMFLAGS) $<

$(OUTPUT_DIR)/extra1k.dat: extra1k.asm
	$(ASM) $(ASMFLAGS) $<

$(OUTPUT_DIR)/nextorrd.rom: $(OUTPUT_DIR)/driverrd.rom $(OUTPUT_DIR)/chgbnkrd.bin $(OUTPUT_DIR)/extra1k.dat
	$(KERNEL_DIR)/mknexrom $(KERNEL_DIR)/Nextor-2.1.0-beta2.base.dat $(OUTPUT_DIR)/nextorrd.rom \
							/d:$(OUTPUT_DIR)/driverrd.rom /m:$(OUTPUT_DIR)/chgbnkrd.bin \
							/e:$(OUTPUT_DIR)/extra1k.dat
	
clean:
	-rm $(OUTPUT_DIR)/*.rom
	-rm $(OUTPUT_DIR)/*.com
	-rm $(OUTPUT_DIR)/*.bin
	-rm $(OUTPUT_DIR)/*.sym

copy:
	cp $(OUTPUT_DIR)/main.bin /Volumes/Untitled
