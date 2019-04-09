OS_NAME?=occamos

# User compilation configuration
CC?=gcc
CFLAGS?=-O2 -g
LDFLAGS?=
LIBS?=

# User target directory configuration
DESTDIR?=
PREFIX?=/usr/local
EXEC_PREFIX?=$(PREFIX)
BOOTDIR?=$(EXEC_PREFIX)/boot
INCLUDEDIR?=$(PREFIX)/include

# Mandatory kernel compilation flags
CFLAGS:=$(CFLAGS) -ffreestanding -Wall -Wextra -D__is_kernel -Iinclude
LDFLAGS:=$(LDFLAGS)
LIBS:=$(LIBS) -nostdlib -lgcc -lk

# Architecture dependent configuration
ARCHDIR=arch/i386
include $(ARCHDIR)/config.mk

CFLAGS:=$(CFLAGS) $(KERNEL_ARCH_CFLAGS)
LDFLAGS:=$(LDFLAGS) $(KERNEL_ARCH_LDFLAGS)
LIBS:=$(LIBS) $(KERNEL_ARCH_LIBS)

KERNEL_OBJS=\
$(KERNEL_ARCH_OBJS) \
kernel/kernel.o

OBJS=\
$(KERNEL_OBJS)

LINKER_OPTIONS=\
$(LDFLAGS) \
$(KERNEL_OBJS) \
$(LIBS)

.PHONY: all clean install install-headers install-kernel
.SUFFIXES: .o .libk.o .c .S

all: $(OS_NAME).kernel

$(OS_NAME).kernel: $(OBJS) $(ARCHDIR)/linker.ld
	$(CC) -T $(ARCHDIR)/linker.ld -o $@ $(CFLAGS) $(LINKER_OPTIONS)
	# grub-file --is-x86-multiboot $(OS_NAME).kernel # Check for valid Multiboot header

.c.o:
	$(CC) -MD -c $< -o $@ -std=gnu11 $(CFLAGS)

.S.o:
	$(CC) -MD -c $< -o $@ $(CFLAGS)

# TODO: but objects into dedicated directories and simply rm -rf those
clean:
	rm -f $(OS_NAME).kernel
	rm -f $(OBJS) *.o */*.o */*/*.o
	rm -f $(OBJS:.o=.d) *.d */*.d */*/*.d

install: install-headers install-kernel
install-headers:
	mkdir -p $(DESTDIR)$(INCLUDEDIR)
	cp -R -P include/. $(DESTDIR)$(INCLUDEDIR)/.

install-kernel: $(OS_NAME).kernel
	mkdir -p $(DESTDIR)$(BOOTDIR)
	cp $(OS_NAME).kernel $(DESTDIR)$(BOOTDIR)

-include $(OBJS:.o=.d)
