INFILE = msxusb.v
OUTFILE = msxusb.vvp

all: compile run program

compile:
	iverilog -o $(OUTFILE) $(INFILE) test_mapper.v

run:
	vvp $(OUTFILE) -lxt2

program:
	openocd -f altera-usb-blaster.cfg -c init -c "svf quiet MSXUSB.svf" -c shutdown