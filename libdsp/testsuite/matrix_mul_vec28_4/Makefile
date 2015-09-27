topdir = ..
include $(topdir)/Makerules
PROGS = Verify28_4

all: $(PROGS)

Verify28_4: MatrixMulVec.o Verification.o 
	$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

clean:
	rm -f  *.o $(PROGS) *.gdb
