ASM = sjasmplus
ASMFLAGS = --fullpath --raw=$@ --sym=$(basename $@).sym
RDASMFLAGS = --fullpath --raw=$@ --sym=$(basename $@).sym -D__ROOKIEDRIVE
OUTPUT_DIR = ../dist
KERNEL_DIR = ../kernel

all: $(OUTPUT_DIR)/driver.rom $(OUTPUT_DIR)/chgbnk.bin $(OUTPUT_DIR)/chgbnkrd.bin $(OUTPUT_DIR)/nextor.rom $(OUTPUT_DIR)/nextorrd.rom $(OUTPUT_DIR)/nextorlow.rom $(OUTPUT_DIR)/extra1k.dat

.PHONY: all clean copy

# bank switching variants
$(OUTPUT_DIR)/chgbnk.bin: chgbnk.asm
	$(ASM) $(ASMFLAGS) $< 

$(OUTPUT_DIR)/chgbnkrd.bin: chgbnk.asm
	$(ASM) $(ASMFLAGS) $< 

# driver variants
$(OUTPUT_DIR)/driver.rom: driver.asm driver_helpers.asm basic_extensions.asm print_bios.asm ch376s.asm ch376s_helpers.asm usbhost.asm nextordirect.asm
	$(ASM) $(ASMFLAGS) $<

$(OUTPUT_DIR)/driverrd.rom: driver_low.asm driver_helpers_low.asm flashdisk.asm print_bios.asm ch376s.asm ch376s_helpers.asm usbhost.asm nextordirect.asm scsi.asm scsi_helpers.asm
	$(ASM) $(RDASMFLAGS) $<

$(OUTPUT_DIR)/driver_low.rom: driver_low.asm driver_helpers_low.asm flashdisk.asm print_bios.asm ch376s.asm ch376s_helpers.asm usbhost.asm nextordirect.asm scsi.asm scsi_helpers.asm
	$(ASM) $(ASMFLAGS) $<

$(OUTPUT_DIR)/extra1k.dat: extra1k.asm
	$(ASM) $(ASMFLAGS) $<

# rom variants
$(OUTPUT_DIR)/nextor.rom: $(OUTPUT_DIR)/driver.rom $(OUTPUT_DIR)/chgbnk.bin $(OUTPUT_DIR)/extra1k.dat
	$(KERNEL_DIR)/mknexrom $(KERNEL_DIR)/Nextor-2.1.0-beta2.base.dat $(OUTPUT_DIR)/nextor.rom \
							/d:$(OUTPUT_DIR)/driver.rom /m:$(OUTPUT_DIR)/chgbnk.bin \
							/e:$(OUTPUT_DIR)/extra1k.dat

$(OUTPUT_DIR)/nextorlow.rom: $(OUTPUT_DIR)/driver_low.rom $(OUTPUT_DIR)/chgbnk.bin $(OUTPUT_DIR)/extra1k.dat
	$(KERNEL_DIR)/mknexrom $(KERNEL_DIR)/Nextor-2.1.0-beta2.base.dat $(OUTPUT_DIR)/nextorlow.rom \
							/d:$(OUTPUT_DIR)/driver_low.rom /m:$(OUTPUT_DIR)/chgbnk.bin \
							/e:$(OUTPUT_DIR)/extra1k.dat
	cat $(OUTPUT_DIR)/nextorlow.rom $(OUTPUT_DIR)/RDDISK.DSK > $(OUTPUT_DIR)/nextor_complete.rom
	
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
