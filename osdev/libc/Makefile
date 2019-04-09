# libk: kernel libc
# libc: C library
# freestanding: libc features that does not require kernel/OS e.g. memmove, memcpy, etc.
# hosted: libc features that require help from kernel/OS

OS_NAME:=occamos

# User compilation configuration
CC?=gcc
CFLAGS?=-O2 -g
LDFLAGS?=
LIBS?=

# User target directory configuration
DESTDIR?=
PREFIX?=/usr/local
EXEC_PREFIX?=$(PREFIX)
INCLUDEDIR?=$(PREFIX)/include
LIBDIR?=$(EXEC_PREFIX)/lib

# Mandatory kernel compilation flags
CFLAGS:=$(CFLAGS) -ffreestanding -Wall -Wextra -D__is_libc -Iinclude
LIBK_CFLAGS:=$(CFLAGS) -D__is_libk

# Architecture dependent configuration
ARCHDIR=arch/i386
include $(ARCHDIR)/config.mk

CFLAGS:=$(CLFAGS) $(ARCH_CFLAGS)
LIBK_CFLAGS:=$(LIBK_CFLAGS) $(KERNEL_ARCH_CFLAGS)

FREEOBJS=\
	$(ARCH_FREEOBJS) \
	stdlib/abort.o \
	string/memcmp.o \
	string/memcpy.o \
	string/memmove.o \
	string/strlen.o \
	string/memset.o \
	string/stoi.o \
	stdio/putchar.o \
	stdio/printf.o \
	stdio/puts.o

HOSTEDOBJS=\
$(ARCH_HOSTEDOBJS)

OBJS=\
$(FREEOBJS) \
$(HOSTEDOBJS)

LIBK_OBJS=$(FREEOBJS:.o=.libk.o)

BINARIES=libk.a

.PHONY: all clean install install-headers install-libs
.SUFFIXES: .o .libk.o .c .S

all: $(BINARIES)

libc.a: $(OBJS)
	$(AR) rcs $@ $(OBJS)

libk.a: $(LIBK_OBJS)
	$(AR) rcs $@ $(LIBK_OBJS)

.c.o:
	$(CC) -MD -c $< -o $@ -std=gnu11 $(CFLAGS)

.S.o:
	$(CC) -MD -c $< -o $@ $(CFLAGS)

.c.libk.o:
	$(CC) -MD -c $< -o $@ -std=gnu11 $(LIBK_CFLAGS)

.S.libk.o:
	$(CC) -MD -c $< -o $@ $(LIBK_CFLAGS)

# TODO: but objects into dedicated directories and simply rm -rf those
clean:
	rm -f $(BINARIES) *.a
	rm -f $(OBJS) $(LIBK_OBJS) *.o */*.o */*/*.o
	rm -f $(OBJS:.o=.d) $(LIBK_OBJS:.o=.d) *.d */*.d */*/*.d

install: install-headers install-libs
install-headers:
	mkdir -p $(DESTDIR)$(INCLUDEDIR)
	cp -R -P include/. $(DESTDIR)$(INCLUDEDIR)/.

install-libs: $(BINARIES)
	mkdir -p $(DESTDIR)$(LIBDIR)
	cp $(BINARIES) $(DESTDIR)$(LIBDIR)

-include $(OBJS:.o=.d)
-include $(LIBK_OBJS:.o=.d)
