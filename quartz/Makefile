K=kernel
U=user

OBJS = $K/entry.o $K/start.o $K/main.o

TOOLPREFIX=riscv64-unknown-elf-
QEMU=qemu-system-riscv64

CC=$(TOOLPREFIX)gcc
AS=$(TOOLPREFIX)gas
LD=$(TOOLPREFIX)ld
OBJCOPY=$(TOOLPREFIX)objcopy
OBJDUMP=$(TOOLPREFIX)objdump

CFLAGS = -Wall -Werror -Wpedantic -O -fno-omit-frame-pointer -ggdb
CFLAGS += -MD
CFLAGS += -mcmodel=medany
CFLAGS += -ffreestanding -fno-common -nostdlib -mno-relax
CFLAGS += -I.
CFLAGS += -fno-stack-protector

LDFLAGS = -z max-page-size=4096

$K/kernel: $(OBJS) $K/kernel.ld
	$(LD) $(LDFLAGS) -T $K/kernel.ld -o $K/kernel $(OBJS)

.PRECIOUS: %.o

-include kernel/*.d

clean:
	rm -f *.tex *.dvi *.idx *.aux *.log *.ind *.ilg */*.o */*.d */*.asm */*.sym
	rm -f $K/kernel

ifndef CPUS
  CPUS := 3
endif

QEMUOPTS = -machine virt -bios none -kernel $K/kernel -m 128M -smp $(CPUS) -nographic
#QEMUOPTS += -drive if=none,format=raw,id=x0
#QEMUOPTS += -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0

qemu: $K/kernel
	$(QEMU) $(QEMUOPTS)
