UNIFDEF = unifdef
UFLAGS-kernel = -D__KERNEL__ -U__LIBC__ -U__UBOOT__
UFLAGS-libc   = -U__KERNEL__ -D__LIBC__ -U__UBOOT__
UFLAGS-uboot  = -U__KERNEL__ -U__LIBC__ -D__UBOOT__

TARGETS = kernel libc uboot

all: $(TARGETS)

$(TARGETS):
	rm -rf $@
	mkdir $@
	for f in *.S ; do $(UNIFDEF) $(UFLAGS-$@) $$f > $@/$$f || : ; done
	sed -i \
		-e 's:@WARNING@:Please do not edit.  The master copy is in blackfin.uclinux.org toolchain scm repo.:' \
		-e "s:@HEADERS@:`sed -e '$$q' -e 's:$$:\\\\:' headers-asm-$@`:" \
		$@/*.S

clean:
	rm -rf $(TARGETS)

.PHONY: all clean $(TARGETS)
