CPP = c++
CPP_FLAGS = -stdlib=libc++ -g -c -D_VERBOSE_DEBUG
CPP_OUTPUT_DIR = 
LNK = c++
LNK_OUTPUT_DIR = ../dist
LNK_FLAGS = -g

spi: $(LNK_OUTPUT_DIR)/main_spi
parallel: $(LNK_OUTPUT_DIR)/main_parallel
device_mode: $(LNK_OUTPUT_DIR)/main_device_mode

.PHONY: all clean copy

$(LNK_OUTPUT_DIR)/main_spi: main.spi.cpp
	$(CPP) $(CPP_FLAGS) -o $@.o $< 
	$(LNK) $(LNK_FLAGS) -o $@ $@.o
	
$(LNK_OUTPUT_DIR)/main_parallel: main.parallel.cpp
	$(CPP) $(CPP_FLAGS) -o $@.o $< 
	$(LNK) $(LNK_FLAGS) -o $@ $@.o
	
$(LNK_OUTPUT_DIR)/main_device_mode: main.device.cpp
	$(CPP) $(CPP_FLAGS) -o $@.o $< 
	$(LNK) $(LNK_FLAGS) -o $@ $@.o
	

clean:
	-rm $(LNK_OUTPUT_DIR)/*

