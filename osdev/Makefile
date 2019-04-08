CROSS_PATH=$(HOME)/opt/cross
CROSS_BIN=$(CROSS_PATH)/bin
BIN_DIR=bin
OBJ_DIR=obj
OS_BIN_NAME=myos.bin
OS_BIN_PATH=$(BIN_DIR)/$(OS_BIN_NAME)
ISO_NAME=myos.iso
ISO_PATH=$(BIN_DIR)/$(ISO_NAME)

OBJECTS := $(OBJ_DIR)/boot.o $(OBJ_DIR)/kernel.o $(OS_BIN_PATH)

all: clean $(OBJECTS) make_iso

.PHONY:
clean:
	rm -f bin/*
	rm -f obj/*
	rm -rf isodir

$(OBJ_DIR)/boot.o: boot.s
	$(CROSS_BIN)/i686-elf-as $^ -o $@

$(OBJ_DIR)/kernel.o: kernel.c
	$(CROSS_BIN)/i686-elf-gcc -c $^ -o $@ -std=gnu99 -ffreestanding -O2 -Wall -Wextra

$(OS_BIN_PATH): $(OBJ_DIR)/kernel.o $(OBJ_DIR)/boot.o
	$(CROSS_BIN)/i686-elf-gcc -T linker.ld -o $@ -ffreestanding -O2 -nostdlib $^ -lgcc

.PHONY:
make_iso: grub.cfg $(OS_BIN_PATH)
	mkdir -p isodir/boot/grub
	cp $(OS_BIN_PATH) isodir/boot/$(OS_BIN_NAME)
	cp grub.cfg isodir/boot/grub/grub.cfg
	sudo grub-mkrescue -o $(ISO_PATH) isodir

.PHONY:
run:
	qemu-system-i386 -cdrom $(ISO_PATH)
