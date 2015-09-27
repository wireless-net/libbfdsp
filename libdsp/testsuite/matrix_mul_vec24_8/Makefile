topdir = ..
include $(topdir)/Makerules
PROGS = Verify24_8

all: $(PROGS)

Verify24_8: MatrixMulVec.o Verification.o
	$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

clean:
	rm -f  *.o $(PROGS) *.gdb
