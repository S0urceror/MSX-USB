SDCC =
CC = $(SDCC)/sdcc
ASM = $(SDCC)/sdasz80
PLATFORM = -mz80
HEXBIN = hex2bin

FUSION =
INCLUDES = $(FUSION)/include
HEADERS = $(FUSION)/header
LIBS = $(FUSION)/lib
#FUSIONLIB = $(FUSIONLIBDIR)/fusion_min_printf.lib
FUSIONLIB = $(LIBS)/fusion.lib
SRCDIR = src
BINDIR = dist

# See startup files for the correct ADDR_CODE and ADDR_DATA
CRT0 = $(INCLUDES)/crt0_msxdos_advanced.rel
ADDR_CODE = 0x0180
ADDR_DATA = 0x0

#VERBOSE = --verbose 
CCFLAGS = $(VERBOSE) --code-loc $(ADDR_CODE) --data-loc $(ADDR_DATA) --disable-warning 196 --disable-warning 112 --disable-warning 84 --no-std-crt0 --opt-code-size
SOURCES = flash.c
OUTFILE = flash.com

.PHONY: all compile package clean

all: clean compile package

compile: $(SOURCES)

%.c:
		@echo "Compiling $@"
		$(CC) $(CCFLAGS) $(PLATFORM) $(FUSIONLIB) ${CRT0} -L $(LIBS) -I $(HEADERS) -I $(INCLUDES) $(SRCDIR)/$@ -o $(BINDIR)/$(notdir $(@:.c=.ihx))

package: 
		@echo "Building $(OUTFILE)..."
		@$(HEXBIN) -e com $(BINDIR)/$(basename $(OUTFILE)).ihx
		@echo "Done."

clean:
		@echo "Cleaning ...."
		rm -f $(BINDIR)/*.asm $(BINDIR)/*.bin $(BINDIR)/*.cdb $(BINDIR)/*.ihx $(BINDIR)/*.lk $(BINDIR)/*.lst \
      $(BINDIR)/*.map $(BINDIR)/*.mem $(BINDIR)/*.omf $(BINDIR)/*.rst $(BINDIR)/*.rel $(BINDIR)/*.sym \
      $(BINDIR)/*.noi $(BINDIR)/*.hex $(BINDIR)/*.lnk $(BINDIR)/*.dep
		rm -f $(BINDIR)/$(OUTFILE)

test:
	@echo $(BINDIR)\$(basename $(OUTFILE)).ihx