CC = gcc
CFLAGS = -Wall
LDFLAGS = -lm
INCLUDE = -I./include

MACRO_INCLUDE = -I macro_lib
MACRO_SRC = $(wildcard macro_lib/*.ml)
MACRO_OBJ = $(patsubst %.ml, %.cmxs, $(MACRO_SRC))

SRC = $(wildcard src/*.c)
OBJ = $(patsubst %.c, %.bcm.o, $(SRC))


.DEFAULT_GOAL := main


%.cmxs: %.ml
	ocamlfind ocamlopt -shared -package bcm.BCMMacros $< -o $@

%.bcm.o: %.c
	bcmc $(MACRO_INCLUDE) -- $(CC) $(CFLAGS) $(INCLUDE) -c $< -o $@


main: main.bcm.o $(OBJ)
	bcmc $(MACRO_INCLUDE) -- $(CC) $(CFLAGS) $(INCLUDE) $^ -o $@ $(LDFLAGS)

macros: $(MACRO_OBJ)

clean:
	rm -f $(OBJ) $(MACRO_OBJ) main.bcm.* main ./src/*.bcm.*
