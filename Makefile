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
	chicken-install && DEBUG=1 ry ry.scm

repl:
	@csi -s support/repl.scm
