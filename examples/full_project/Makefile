CC = gcc
CFLAGS = -Wall
LDFLAGS = -lm
INCLUDE = -I./include

BUILD_DIR = .build

MACRO_INCLUDE = -I./macro_lib
MACRO_SRC = $(wildcard macro_lib/*.ml)
MACRO_OBJ = $(patsubst %.ml, $(BUILD_DIR)/%.cmxs, $(MACRO_SRC))

SRC = $(wildcard src/*.c)
OBJ = $(patsubst %.c, $(BUILD_DIR)/%.bcm.o, $(SRC))

.PHONY: macros clean
.DEFAULT_GOAL := main

$(BUILD_DIR)/%.cmxs: %.ml
	mkdir -p $(dir $@)
	ocamlfind ocamlopt -shared -package bcm.BCMMacros $< -o $@
	@mv ${<:.ml=.cmi} ${<:.ml=.cmx} ${<:.ml=.o} $(dir $@)

macros: $(MACRO_OBJ)

$(BUILD_DIR)/%.bcm.o: %.c | macros
	bcmc $(MACRO_INCLUDE) -- $(CC) $(CFLAGS) $(INCLUDE) -c $< -o $@

main: $(BUILD_DIR)/main.bcm.o $(OBJ)
	bcmc $(MACRO_INCLUDE) -- $(CC) $(CFLAGS) $(INCLUDE) $^ -o $@ $(LDFLAGS)

clean:
	rm -f $(OBJ) $(MACRO_OBJ) main
	rm -rf $(BUILD_DIR)
