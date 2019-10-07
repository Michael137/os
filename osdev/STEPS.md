# Build Cross-copmiler
## What?

Build a cross compiler for a target triple (e.g. i686-elf)
## Requirements

* binutils
* gcc

## Installation
1. Get sources for gcc and binutils
2.
export PREFIX="$HOME/opt/cross" # this is where output binaries are built to
export TARGET=i686-elf # target triple
export PATH="$PREFIX/bin:$PATH"
3. (taken from osdev.org wiki on building cross-compiler for osdev [https://wiki.osdev.org/GCC_Cross-Compiler#Linux_Users_building_a_System_Compiler])
  * Download binutils src: https://www.gnu.org/software/binutils/
  * Download gcc src: 
3. Install binutils (on FreeBSD make sure you use gmake)
```
cd $HOME/src
 
 mkdir build-binutils
 cd build-binutils
 ../binutils-x.y.z/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
 make
 make install
```
4. Install gcc
```
cd $HOME/src
 
 # The $PREFIX/bin dir _must_ be in the PATH. We did that above.
 which -- $TARGET-as || echo $TARGET-as is not in the PATH
  
  mkdir build-gcc
  cd build-gcc
  ../gcc-x.y.z/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
  make all-gcc
  make all-target-libgcc
  make install-gcc
  make install-target-libgcc
```
5. export PATH="$HOME/opt/cross/bin:$PATH"

Next step involves creating a minimal kernel from: boot.s, kernel.c and linker.ld

# Booting OS

* Write multiboot header (boot.s)
** Assemble using: i686-elf-as boot.s -o boot.o

# Implement the Kernel
* Kernel is in kernel.c
* Compile using: i686-elf-gcc -c kernel.c -o kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

# Write linker script for bootloader
* Link together boot assembly and kernel
* In linker.ld
* i686-elf-gcc -T linker.ld -o <os_name>.bin -ffreestanding -O2 -nostdlib boot.o kernel.o -lgcc

# Building everything
* gmake all
* os image then now in bin/

# Check for valid multiboot (version 1) header
* grub-file --is-x86-multiboot bin/<os_name>.bin

# Making iso
* Needs xorriso, grub
* Create grub.cfg
* Create ISO:
mkdir -p isodir/boot/grub
cp occamos.bin isodir/boot/occamos.bin
cp grub.cfg isodir/boot/grub/grub.cfg
grub-mkrescue -o occamos.iso isodir

# Test OS
* On QEMU:
** gmake run
** or qemu-system-i386 -kernel bin/occamos.bin
* On real hardware

# Current installation (simply invoke build.sh, iso.sh or qemu.sh):
* config.sh->headers.sh->build.sh->iso.sh->qemu.sh
* TODO: use makefile instead of shell scripts?

# Common errors
* xorriso complaints when running grub2-mkcfg
  * Simply get latest xorriso using package manager (likely it is not even installed on the system yet, contrary to what the warning implies)
