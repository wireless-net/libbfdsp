topdir = ..
include $(topdir)/Makerules
PROGS = cfft 

CPPFLAGS += -D__USE_FFT_REL45__ -DDO_CYCLE_COUNTS

all: $(PROGS)

clean:
	rm -f  *.o $(PROGS) *.gdb
