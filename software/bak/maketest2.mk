CC = sdcc
ASM = sdasz80
PLATFORM = -mz80
HEXBIN = hex2bin

INCLUDES = -I../../Libraries/asmlib
LIBS = ../../Libraries/asmlib/asm.lib
OBJECTSDIR = ../../Libraries/fusion-c/include
SRCDIR = src
BINDIR = dist

# See startup files for the correct ADDR_CODE and ADDR_DATA
ADDR_CODE = 0x0180
ADDR_DATA = 0

VERBOSE = --verbose
CCFLAGS = $(VERBOSE) $(PLATFORM) --code-loc $(ADDR_CODE) --data-loc $(ADDR_DATA) --no-std-crt0 --opt-code-size --out-fmt-ihx
OBJECTS = $(OBJECTSDIR)/crt0_msxdos_advanced.rel $(OBJECTSDIR)/putchar_msxdos.rel $(OBJECTSDIR)/printf.rel
SOURCES = test2.c
OUTFILE = nd.com

.PHONY: all compile link package clean

all: clean compile link package

compile: $(SOURCES)

%.c:
		@echo "Compiling $@"
		@[ -f $(SRCDIR)/$@ ] && $(CC) $(CCFLAGS) $(PLATFORM) $(INCLUDES) -c -o $(BINDIR)/$(notdir $(@:.c=.rel)) $(SRCDIR)/$@ || true

link:
		@echo "Linking"
		$(CC) $(CCFLAGS) $(LIBS) $(OBJECTS) \
			$(addprefix $(BINDIR)/,$(SOURCES:.c=.rel)) \
			-o $(BINDIR)/$(basename $(OUTFILE)).ihx

package: 
		@echo "Building $(OUTFILE)..."
		@$(HEXBIN) -e com $(BINDIR)/$(basename $(OUTFILE)).ihx
		mv $(BINDIR)/nd.com ../drivers/UsbEthernet/dist
		@echo "Done."

clean:
		@echo "Cleaning ...."
		rm -f $(BINDIR)/*.asm $(BINDIR)/*.bin $(BINDIR)/*.cdb $(BINDIR)/*.ihx $(BINDIR)/*.lk $(BINDIR)/*.lst \
			$(BINDIR)/*.map $(BINDIR)/*.mem $(BINDIR)/*.omf $(BINDIR)/*.rst $(BINDIR)/*.rel $(BINDIR)/*.sym \
			$(BINDIR)/*.noi $(BINDIR)/*.hex $(BINDIR)/*.lnk $(BINDIR)/*.dep
		rm -f $(BINDIR)/$(OUTFILE)

test:
	@echo $(BINDIR)/$(basename $(OUTFILE)).ihx
