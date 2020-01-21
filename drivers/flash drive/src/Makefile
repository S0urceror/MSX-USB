#ASM = java -jar /Users/mario/Development/msx/Compilers/glass.jar
ASM = /Users/mario/Development/msx/Compilers/sjasmplus/build/release/sjasmplus
#ASM = ~/Development/msx/cpm/cpm M80 =
ASMFLAGS = --raw=$@ --sym=$(basename $@).sym
OUTPUT_DIR = ../dist
KERNEL_DIR = ../kernel

all: $(OUTPUT_DIR)/driver.rom $(OUTPUT_DIR)/chgbnk.bin $(OUTPUT_DIR)/nextor.rom $(OUTPUT_DIR)/usbfiles.com $(OUTPUT_DIR)/insertdisk.com $(OUTPUT_DIR)/ejectdisk.com
.PHONY: all clean copy

$(OUTPUT_DIR)/chgbnk.bin: chgbnk.asm
	$(ASM) $(ASMFLAGS) $< 

$(OUTPUT_DIR)/usbfiles.com: usbfiles.asm print_dos.asm ch376s.asm ch376s_helpers.asm driver_helpers.asm
	$(ASM) $(ASMFLAGS) $< 

$(OUTPUT_DIR)/insertdisk.com: insertdisk.asm print_dos.asm ch376s.asm ch376s_helpers.asm driver_helpers.asm nextor_helpers.asm
	$(ASM) $(ASMFLAGS) $<

$(OUTPUT_DIR)/ejectdisk.com: ejectdisk.asm print_dos.asm ch376s.asm ch376s_helpers.asm driver_helpers.asm nextor_helpers.asm
	$(ASM) $(ASMFLAGS) $<

$(OUTPUT_DIR)/driver.rom: driver.asm driver_helpers.asm basic_extensions.asm print_bios.asm ch376s.asm ch376s_helpers.asm
	$(ASM) $(ASMFLAGS) $<

$(OUTPUT_DIR)/nextor.rom: $(OUTPUT_DIR)/driver.rom $(OUTPUT_DIR)/chgbnk.bin
	$(KERNEL_DIR)/mknexrom $(KERNEL_DIR)/Nextor-2.1.0-beta2.base.dat $(OUTPUT_DIR)/nextor.rom /d:$(OUTPUT_DIR)/driver.rom /m:$(OUTPUT_DIR)/chgbnk.bin
	cp $(OUTPUT_DIR)/nextor.rom /Users/mario/Library/Application\ Support/CocoaMSX/Machines/MSX2\ -\ Nextor
	
clean:
	-rm $(OUTPUT_DIR)/*.rom
	-rm $(OUTPUT_DIR)/*.com
	-rm $(OUTPUT_DIR)/*.bin
	-rm $(OUTPUT_DIR)/*.sym

copy:
	cp $(OUTPUT_DIR)/main.bin /Volumes/Untitled
