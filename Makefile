include Makerules

CROSS?=$(CROSS_COMPILE)
AR=$(CROSS)ar
AS=$(CROSS)as
CC=$(CROSS)gcc
CXX=$(CROSS)g++
STRIP=$(CROSS)strip
INSTALL=install
INSTALL_DATA = $(INSTALL) -m 644
TAR=tar

ARFLAGS = cr

FLAGS_TO_PASS = \
	'AR=$(AR)' \
	'AS=$(AS)' \
	'CC=$(CC)' \
	'CXX=$(CXX)' \
	'INSTALL=$(INSTALL)' \
	'INSTALL_DATA=$(INSTALL_DATA)' \
	'LIBC_HAS_NO_CMATH=$(LIBC_HAS_NO_CMATH)' \
	'MULTILIB_FLAGS=$(MULTILIB_FLAGS)' \
	'MULTILIB=$(MULTILIB)' \
	'DESTDIR=$(DESTDIR)' \
	'STRIP=$(STRIP)' \
	'SUFFIX=$(SUFFIX)' \
	'TAR=$(TAR)' \
	'USR=$(USR)'

headers := \
	complex_bf.h complex_typedef.h cycle_count.h cycle_count_bf.h \
	filter.h float16.h flt2fr.h \
	fr2x16_base.h fr2x16.h fr2x16_math.h fr2x16_typedef.h \
	fract2float_conv.h fract_base.h fract_complex.h fract.h \
	fract_math.h fract_typedef.h gcc.h \
	i2x16_base.h i2x16.h i2x16_math.h i2x16_typedef.h \
	math_bf.h math_const.h matrix.h means.h \
	r2x16_base.h r2x16_typedef.h r4x16_typedef.h raw_typedef.h \
	stats.h util.h vector.h video.h window.h xcycle_count.h

ifneq ($(LIBC_HAS_NO_CMATH),)
headers += complex_fns.h
endif

all: all-libdsp

all-libdsp:
	cd libdsp && $(MAKE) $(FLAGS_TO_PASS) all

install: install-headers install-libdsp

install-headers: $(addprefix $(inst_includedir)/,$(headers))

$(addprefix $(inst_includedir)/,$(headers)): $(inst_includedir)/%: include/%
	$(do-install)

install-libdsp:
	cd libdsp && $(MAKE) $(FLAGS_TO_PASS) install

clean: clean-libdsp

clean-libdsp:
	cd libdsp && $(MAKE) $(FLAGS_TO_PASS) clean
