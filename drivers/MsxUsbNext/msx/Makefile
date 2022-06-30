# tools
CPP = sdcc
GCC = gcc #this is to compile mknexrom to the current platform. if you are using macos, you can change to clang --crisag
ASM = sdasz80
SJASM = sjasmplus
HEX2BIN := hex2bin
# compiler flags
VERBOSE = --verbose
DEFINES = -DNODEBUG
PLATFORM = -mz80
ADDR_CODE = 0x4200
ADDR_DATA = 0xc800
CPP_FLAGS = $(VERBOSE) $(PLATFORM) -c $(DEFINES)
CPP_OUTPUT_DIR = ./objs
CRT0_SRC_DIR = .
SJASMFLAGS = --fullpath --raw=$@ --sym=$(basename $@).sym --lst=$(basename $@).lst
# link flags
LNK = sdcc
LNK_OUTPUT_DIR = ./build
LNK_FLAGS = -mz80 --code-loc $(ADDR_CODE) --data-loc $(ADDR_DATA) --no-std-crt0
OBJS := $(CPP_OUTPUT_DIR)/msxromcrt0.rel $(CPP_OUTPUT_DIR)/driver.rel $(CPP_OUTPUT_DIR)/ch376s.rel $(CPP_OUTPUT_DIR)/hal.rel $(CPP_OUTPUT_DIR)/usbdisk.rel
BIN := $(LNK_OUTPUT_DIR)/driver.rom
IHX := $(LNK_OUTPUT_DIR)/driver.ihx
KERNEL_DIR := ./kernel

# distribution
DIST_OUTPUT_DIR = ./dist
ROM := $(DIST_OUTPUT_DIR)/nextor.rom
MKNEXROM := $(KERNEL_DIR)/mknexrom

# make all
all: $(MKNEXROM) $(ROM)

$(CPP_OUTPUT_DIR)/driver.rel: driver.c
	$(CPP) $(CPP_FLAGS) -o $@ $< 
$(CPP_OUTPUT_DIR)/msxromcrt0.rel: $(CRT0_SRC_DIR)/msxromcrt0.s
	$(ASM) -o $@ $< 
$(CPP_OUTPUT_DIR)/ch376s.rel: ../generic/ch376s.c
	$(CPP) $(CPP_FLAGS) -o $@ $< 	
$(CPP_OUTPUT_DIR)/usbdisk.rel: ../generic/usbdisk.c
	$(CPP) $(CPP_FLAGS) -o $@ $< 	
$(CPP_OUTPUT_DIR)/hal.rel: hal.c
	$(CPP) $(CPP_FLAGS) -o $@ $< 

$(IHX): $(OBJS)
	$(LNK) $(LNK_FLAGS) -o $@ $^ 

$(BIN): $(IHX)
	$(HEX2BIN) -e rom $^

# make clean
clean:
	-rm $(CPP_OUTPUT_DIR)/*.*
	-rm $(LNK_OUTPUT_DIR)/*.*
	-rm $(KERNEL_DIR)/mknexrom

$(LNK_OUTPUT_DIR)/extra1k.dat: extra1k.asm
	$(SJASM) $(SJASMFLAGS) $<

# bank switching variants
$(LNK_OUTPUT_DIR)/chgbnk.bin: chgbnk.asm
	$(SJASM) $(SJASMFLAGS) $< 

# generates mknexrom in the current architecture
$(MKNEXROM): $(KERNEL_DIR)/mknexrom
	$(GCC) $(KERNEL_DIR)/mknexrom.c -o $(KERNEL_DIR)/mknexrom

$(ROM): $(LNK_OUTPUT_DIR)/driver.rom $(LNK_OUTPUT_DIR)/chgbnk.bin $(LNK_OUTPUT_DIR)/extra1k.dat 
	$(KERNEL_DIR)/mknexrom $(KERNEL_DIR)/Nextor-2.1.1-beta2.base.dat $(DIST_OUTPUT_DIR)/nextor.rom \
							/d:$(LNK_OUTPUT_DIR)/driver.rom /m:$(LNK_OUTPUT_DIR)/chgbnk.bin \
							/e:$(LNK_OUTPUT_DIR)/extra1k.dat
							