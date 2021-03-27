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
CCFLAGS = $(VERBOSE) $(PLATFORM) --code-loc $(ADDR_CODE) --data-loc $(ADDR_DATA) --no-std-crt0 --out-fmt-ihx --opt-code-size #--max-allocs-per-node 200000

# Directories
INCLUDES = -I../../../Libraries/fusion-c/header -I../../../Libraries/fusion-c/include -I../../../Libraries/asmlib -I./src -I./uip
FUSIONLIB = ../../../Libraries/fusion-c/include
LIBS = ../../../Libraries/asmlib/asm.lib ../../../Libraries/fusion-c/lib/fusion.lib
OBJECTS = $(FUSIONLIB)/putchar_msxdos.rel $(FUSIONLIB)/printf.rel
SRCDIR = src
UIPDIR = uip
BUILDDIR = build
DISTDIR = dist

# Target
TARGET = wget

# Sources
UIP_SOURCES = uip.c uip_arp.c uiplib.c psock.c timer.c uip-neighbor.c
SOURCES = main.c msxusbecm.c clock-arch.c uip_arch.c webclient.c webclient-strings.c resolv.c dhcpc.c appregister.c
ASSEMBLY = crt0_msxdos_advanced.s uip_arch-asm.s
RELS = $(addprefix $(BUILDDIR)/,$(SOURCES:.c=.rel) $(UIP_SOURCES:.c=.rel) $(ASSEMBLY:.s=.rel))

.PHONY: all clean

all : $(DISTDIR)/$(TARGET).com
	
# compile application
$(BUILDDIR)/%.rel: $(SRCDIR)/%.c
	@echo "Compiling: " $<
	$(CC) $(CCFLAGS) $(PLATFORM) $(INCLUDES) -c -o $@ $<

# compile uip
$(BUILDDIR)/%.rel: $(UIPDIR)/%.c
	@echo "Compiling: " $<
	$(CC) $(CCFLAGS) $(PLATFORM) $(INCLUDES) -c -o $@ $<

# assemble sources
$(BUILDDIR)/%.rel: $(SRCDIR)/%.s
	@echo "Assemble: " $<
	$(ASM) -l -s -o $@ $<

# link
$(BUILDDIR)/$(TARGET).ihx: $(RELS)
	@echo "Linking: " $@
	$(CC) $(CCFLAGS) $(OBJECTS) $(LIBS) $^ -o $@

# create executable
$(DISTDIR)/$(TARGET).com: $(BUILDDIR)/$(TARGET).ihx
	@echo "Packaging: " $@
	@$(HEXBIN) -e com $(BUILDDIR)/$(TARGET).ihx
	mv $(BUILDDIR)/$(TARGET).com $(DISTDIR)/$(TARGET).com

clean:
	@echo "Cleaning ...."
	rm -f $(BUILDDIR)/*
	rm -f $(DISTDIR)/*
