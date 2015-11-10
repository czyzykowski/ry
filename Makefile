CSC=csc
OBJ = term.o display.o ry.o

all: ry

%.o: %.scm
	  $(CSC) -c -o $@ $<

ry: $(OBJ)
	  $(CSC) -o $@ $^

clean:
	rm *.o
	rm ry

run:
	DEBUG=1 chicken-install && ry ry.meta

repl:
	@csi -s support/repl.scm
