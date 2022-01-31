# MSXUSB makefile
#
# Creates 3 variants of the Nextor driver for different hardware
# MSXUSBCARTv1 	- SCC mapper cartridge with ports 0x10 and 0x11
# ROOKIEDRIVE	- ASCII16 mapper cartridge with ports 0x20 and 0x21
# MISTERSPI		- CH376s module connected via SPI to MiSTerFPGA

ASM = sjasmplus
ASMFLAGS = --fullpath --raw=$@ --sym=$(basename $@).sym --lst=$(basename $@).lst -D__MSXUSBCARTv1
RDASMFLAGS = --fullpath --raw=$@ --sym=$(basename $@).sym --lst=$(basename $@).lst -D__ROOKIEDRIVE
MSTRASMFLAGS = --fullpath --raw=$@ --sym=$(basename $@).sym --lst=$(basename $@).lst -D__MISTERSPI #-D__NOWAIT
OMSTRASMFLAGS = --fullpath --raw=$@ --sym=$(basename $@).sym --lst=$(basename $@).lst -D__MISTERSPI -D__NOWAIT
OUTPUT_DIR = ../dist
KERNEL_DIR = ../kernel
RDDISK_DIR = ../ramdsk
OCM_ROM_DIR = ../../../../../fpga/OCM/sdbios/make/roms

all: $(OUTPUT_DIR)/chgbnk.bin $(OUTPUT_DIR)/chgbnkrd.bin $(OUTPUT_DIR)/nextor.rom $(OUTPUT_DIR)/nextorrd.rom $(OUTPUT_DIR)/nextormstr.rom $(OUTPUT_DIR)/nextoromstr.rom $(OUTPUT_DIR)/extra1k.dat $(OUTPUT_DIR)/OCM-BIOS.DAT $(OUTPUT_DIR)/msxusb.vhd

.PHONY: all

$(OUTPUT_DIR)/extra1k.dat: extra1k.asm
	$(ASM) $(ASMFLAGS) $<

# bank switching variants
$(OUTPUT_DIR)/chgbnk.bin: chgbnk.asm
	$(ASM) $(ASMFLAGS) $< 

$(OUTPUT_DIR)/chgbnkrd.bin: chgbnk.asm
	$(ASM) $(RDASMFLAGS) $< 

$(OUTPUT_DIR)/chgbnkmstr.bin: chgbnk.asm
	$(ASM) $(MSTRASMFLAGS) $< 

# nextor driver variants
$(OUTPUT_DIR)/drivermstr.rom: driver_low.asm driver_helpers_low.asm flashdisk.asm print_bios.asm ch376s.asm ch376s_helpers.asm usbhost.asm nextordirect.asm scsi.asm scsi_helpers.asm
	$(ASM) $(MSTRASMFLAGS) $<

$(OUTPUT_DIR)/driveromstr.rom: driver_low.asm driver_helpers_low.asm flashdisk.asm print_bios.asm ch376s.asm ch376s_helpers.asm usbhost.asm nextordirect.asm scsi.asm scsi_helpers.asm
	$(ASM) $(OMSTRASMFLAGS) $<

$(OUTPUT_DIR)/driverrd.rom: driver_low.asm driver_helpers_low.asm flashdisk.asm print_bios.asm ch376s.asm ch376s_helpers.asm usbhost.asm nextordirect.asm scsi.asm scsi_helpers.asm
	$(ASM) $(RDASMFLAGS) $<

$(OUTPUT_DIR)/driver.rom: driver_low.asm driver_helpers_low.asm flashdisk.asm print_bios.asm ch376s.asm ch376s_helpers.asm usbhost.asm nextordirect.asm scsi.asm scsi_helpers.asm
	$(ASM) $(ASMFLAGS) $<

# Nextor variants
# MSXUSB HW on port 0x10 and 0x11 and SCC bank switching
$(OUTPUT_DIR)/nextor.rom: $(OUTPUT_DIR)/driver.rom $(OUTPUT_DIR)/chgbnk.bin $(OUTPUT_DIR)/extra1k.dat
	$(KERNEL_DIR)/mknexrom $(KERNEL_DIR)/Nextor-2.1.0.base.dat $(OUTPUT_DIR)/nextor.rom \
							/d:$(OUTPUT_DIR)/driver.rom /m:$(OUTPUT_DIR)/chgbnk.bin \
							/e:$(OUTPUT_DIR)/extra1k.dat
	cat $(OUTPUT_DIR)/nextor.rom $(RDDISK_DIR)/RDDISK.DSK > $(OUTPUT_DIR)/nextor_complete.rom
	
# ROOKIEDRV HW on port 0x20 and 0x21 and ASCII16 bank switching
$(OUTPUT_DIR)/nextorrd.rom: $(OUTPUT_DIR)/driverrd.rom $(OUTPUT_DIR)/chgbnkrd.bin $(OUTPUT_DIR)/extra1k.dat
	$(KERNEL_DIR)/mknexrom $(KERNEL_DIR)/Nextor-2.1.0.base.dat $(OUTPUT_DIR)/nextorrd.rom \
							/d:$(OUTPUT_DIR)/driverrd.rom /m:$(OUTPUT_DIR)/chgbnkrd.bin \
							/e:$(OUTPUT_DIR)/extra1k.dat
	cat $(OUTPUT_DIR)/nextorrd.rom $(RDDISK_DIR)/RDDISK.DSK > $(OUTPUT_DIR)/nextorrd_complete.rom

# MiSTer HW (OCM) on port 0x20 and 0x21 and ASCII8 bank switching with SPI interface and wait on async IO
$(OUTPUT_DIR)/nextormstr.rom: $(OUTPUT_DIR)/drivermstr.rom $(OUTPUT_DIR)/chgbnkmstr.bin $(OUTPUT_DIR)/extra1k.dat
	$(KERNEL_DIR)/mknexrom $(KERNEL_DIR)/Nextor-2.1.0.base.dat $(OUTPUT_DIR)/nextormstr.rom \
							/d:$(OUTPUT_DIR)/drivermstr.rom /m:$(OUTPUT_DIR)/chgbnkmstr.bin \
							/e:$(OUTPUT_DIR)/extra1k.dat
# OpenMSX emulated MiSTer HW (OCM) on port 0x20 and 0x21 and ASCII8 bank switching with SPI and no wait on async IO
$(OUTPUT_DIR)/nextoromstr.rom: $(OUTPUT_DIR)/driveromstr.rom $(OUTPUT_DIR)/chgbnkmstr.bin $(OUTPUT_DIR)/extra1k.dat
	$(KERNEL_DIR)/mknexrom $(KERNEL_DIR)/Nextor-2.1.0.base.dat $(OUTPUT_DIR)/nextoromstr.rom \
							/d:$(OUTPUT_DIR)/driveromstr.rom /m:$(OUTPUT_DIR)/chgbnkmstr.bin \
							/e:$(OUTPUT_DIR)/extra1k.dat

# create OCM VHD
OCM_DISK = $(OUTPUT_DIR)/nextormstr.rom
OCM_MAIN = $(OCM_ROM_DIR)/a1wsxbsl.rom
OCM_SPECIAL = $(OCM_ROM_DIR)/xbasic21.rom
OCM_MUSIC =$(OCM_ROM_DIR)/msx2pmus.rom
OCM_SUB = $(OCM_ROM_DIR)/2pextrtc.rom
OCM_KANJI = $(OCM_ROM_DIR)/kn2plfix.rom
OCM_EXTRA = $(OCM_ROM_DIR)/free16kb.rom
OCM_JIS1 =$(OCM_ROM_DIR)/a1xxjis1.rom
OCM_JIS2 =$(OCM_ROM_DIR)/a1xxjis2.rom

# copy /B "%DISK%"+"%MAIN%"+"%SPECIAL%"+"%MUSIC%"+"%SUB%"+"%KANJI%"+"%EXTRA%"+"%JIS1%"+"%JIS2%" "%OUTPUT%" >nul
$(OUTPUT_DIR)/OCM-BIOS.DAT: $(OUTPUT_DIR)/nextormstr.rom
	cat $(OCM_DISK) $(OCM_MAIN) $(OCM_SPECIAL) $(OCM_MUSIC) $(OCM_SUB) $(OCM_KANJI) $(OCM_EXTRA) $(OCM_JIS1) $(OCM_JIS2) > $(OUTPUT_DIR)/OCM-BIOS.DAT

$(OUTPUT_DIR)/msxusb.vhd: $(OUTPUT_DIR)/OCM-BIOS.DAT
	cp msx.vhd $(OUTPUT_DIR)/image.vhd
	/opt/homebrew/bin/mformat -i $(OUTPUT_DIR)/image.vhd@@512 -t 16 -h 255 -n 63 -H 1 -m 248
	/opt/homebrew/bin/mcopy -i $(OUTPUT_DIR)/image.vhd@@512 $(OUTPUT_DIR)/OCM-BIOS.DAT ::
	/opt/homebrew/bin/mattrib -i $(OUTPUT_DIR)/image.vhd@@512 +h ::OCM-BIOS.DAT
	mv $(OUTPUT_DIR)/image.vhd $(OUTPUT_DIR)/msxusb.vhd
	
clean:
	-rm $(OUTPUT_DIR)/*.rom
	-rm $(OUTPUT_DIR)/*.bin
	-rm $(OUTPUT_DIR)/*.sym
	-rm $(OUTPUT_DIR)/*.lst
	-rm $(OUTPUT_DIR)/*.dat
	-rm $(OUTPUT_DIR)/*.DAT
	-rm $(OUTPUT_DIR)/*.vhd

