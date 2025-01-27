CC = gcc
CFLAGS = -Wall

MACRO_INCLUDE = -I macro_lib
MACRO_SRC = $(wildcard macro_lib/*.ml)
MACRO_OBJ = $(patsubst %.ml, %.cmxs, $(MACRO_SRC))

.DEFAULT_GOAL := main


%.cmxs: %.ml
	ocamlfind ocamlopt -shared -package bcm.BCMMacros $< -o $@

%.bcm.o: %.c
	bcmc $(MACRO_INCLUDE) -- $(CC) $(CFLAGS) -c $< -o $@


main: main.bcm.o
	bcmc $(MACRO_INCLUDE) -- $(CC) $(CFLAGS) $^ -o $@


macros: $(MACRO_OBJ)


clean:
	rm -f $(MACRO_OBJ) main.bcm.* main
