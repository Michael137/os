#!/bin/sh
set -e
. ./iso.sh

qemu-system-i386 -cdrom ${OS_NAME}.iso
