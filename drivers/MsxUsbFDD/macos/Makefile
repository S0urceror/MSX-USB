COMPILER = clang
COMPILER_FLAGS = -g -c -DDEBUG
COMPILER_OUTPUT_DIR = 
LNK = clang
LNK_OUTPUT_DIR = ./build
LNK_FLAGS = -g
OBJS := $(LNK_OUTPUT_DIR)/main.o $(LNK_OUTPUT_DIR)/hal.o $(LNK_OUTPUT_DIR)/ch376s.o $(LNK_OUTPUT_DIR)/usbdisk.o
BIN := $(LNK_OUTPUT_DIR)/main

all: $(LNK_OUTPUT_DIR)/main

$(LNK_OUTPUT_DIR)/main.o: main.c
	$(COMPILER) $(COMPILER_FLAGS) -o $@ $< 
$(LNK_OUTPUT_DIR)/hal.o: hal.c
	$(COMPILER) $(COMPILER_FLAGS) -o $@ $< 
$(LNK_OUTPUT_DIR)/ch376s.o: ../generic/ch376s.c
	$(COMPILER) $(COMPILER_FLAGS) -o $@ $< 
$(LNK_OUTPUT_DIR)/usbdisk.o: ../generic/usbdisk.c
	$(COMPILER) $(COMPILER_FLAGS) -o $@ $< 

$(BIN): $(OBJS)
	$(LNK) $(LNK_FLAGS) -o $@ $^ 

clean:
	-rm $(OUTPUT_DIR)/*.*