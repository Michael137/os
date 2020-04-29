#!/bin/sh
set -e
. ./build.sh

mkdir -p isodir
mkdir -p isodir/boot
mkdir -p isodir/boot/grub

cp sysroot/boot/${OS_NAME}.kernel isodir/boot/${OS_NAME}.kernel
cat > isodir/boot/grub/grub.cfg << EOF
menuentry "${OS_NAME}" {
	multiboot /boot/${OS_NAME}.kernel
}
EOF

OS_=`uname`
if [ "${OS_}" == "Darwin" ]
then
	# On MacOS install using: brew install i386-elf-grub
	i386-elf-grub-mkrescue -o ${OS_NAME}.iso isodir
else
	grub-mkrescue -o ${OS_NAME}.iso isodir
fi
