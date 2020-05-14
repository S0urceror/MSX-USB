INFILE = msxusb.v
OUTFILE = msxusb.vvp

all: compile run

compile:
	iverilog -o $(OUTFILE) $(INFILE) test_mapper.v

run:
	vvp $(OUTFILE) -lxt2