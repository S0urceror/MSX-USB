# Executables
CC = sdcc
ASM = sdasz80
HEXBIN = hex2bin

# Flags
CRT0 = crt0_msxdos_advanced.rel
ADDR_CODE = 0x0180
ADDR_DATA = 0
VERBOSE = --verbose
PLATFORM = -mz80
CCFLAGS = $(VERBOSE) $(PLATFORM) --code-loc $(ADDR_CODE) --data-loc $(ADDR_DATA) --no-std-crt0 --opt-code-size --out-fmt-ihx

# Directories
INCLUDES = -I../../../Libraries/fusion-c/header -I../../../Libraries/fusion-c/include -I../../../Libraries/asmlib -I./src -I./uip
FUSIONLIB = ../../../Libraries/fusion-c/include
LIBS = ../../../Libraries/fusion-c/lib/fusion.lib ../../../Libraries/asmlib/asm.lib
OBJECTS = $(FUSIONLIB)/$(CRT0) $(FUSIONLIB)/putchar_msxdos.rel $(FUSIONLIB)/printf.rel
SRCDIR = src
UIPDIR = uip
BUILDDIR = build
DISTDIR = dist

# Target
TARGET = hello

# Sources
UIP_SOURCES = uip.c uip_arp.c uiplib.c psock.c timer.c uip-neighbor.c
SOURCES = main.c msxusbecm.c hello-world.c clock-arch.c dhcpc.c 
RELS = $(addprefix $(BUILDDIR)/,$(SOURCES:.c=.rel) $(UIP_SOURCES:.c=.rel))

.PHONY: all clean

all : $(DISTDIR)/$(TARGET).com
	
# compile application
$(BUILDDIR)/%.rel: $(SRCDIR)/%.c
	@echo "Compiling: " $<
	$(CC) $(CCFLAGS) $(PLATFORM) $(INCLUDES) -c -o $@ $<
$(BUILDDIR)/%.rel: $(UIPDIR)/%.c
	@echo "Compiling: " $<
	$(CC) $(CCFLAGS) $(PLATFORM) $(INCLUDES) -c -o $@ $<

# link
$(BUILDDIR)/$(TARGET).ihx: $(RELS)
	@echo "Linking: " $@
	$(CC) $(CCFLAGS) $(LIBS) $(OBJECTS) $^ -o $@

# create executable
$(DISTDIR)/$(TARGET).com: $(BUILDDIR)/$(TARGET).ihx
	@echo "Packaging: " $@
	@$(HEXBIN) -e com $(BUILDDIR)/$(TARGET).ihx
	mv $(BUILDDIR)/$(TARGET).com $(DISTDIR)/$(TARGET).com

clean:
	@echo "Cleaning ...."
	rm -f $(BUILDDIR)/*
