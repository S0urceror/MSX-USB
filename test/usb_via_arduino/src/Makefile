CPP = c++
CPP_FLAGS = -stdlib=libc++ -g -c
CPP_OUTPUT_DIR = 
LNK = c++
LNK_OUTPUT_DIR = ../dist
LNK_FLAGS = -g

spi: $(LNK_OUTPUT_DIR)/main
parallel: $(LNK_OUTPUT_DIR)/main_parallel

.PHONY: all clean copy

$(LNK_OUTPUT_DIR)/main: main.cpp
	$(CPP) $(CPP_FLAGS) -o $@.o $< 
	$(LNK) $(LNK_FLAGS) -o $@ $@.o
	
$(LNK_OUTPUT_DIR)/main_parallel: main.parallel.cpp
	$(CPP) $(CPP_FLAGS) -o $@.o $< 
	$(LNK) $(LNK_FLAGS) -o $@ $@.o
	
clean:
	-rm $(OUTPUT_DIR)/*.*

