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

repl:
	@csi -s support/repl.scm
