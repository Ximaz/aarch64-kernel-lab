SRCS		:=	$(shell find kernel -name '*.s')
OBJS		:=	$(SRCS:.s=.o)
KERNEL_MAP	:=	kernel8.map
KERNEL_ELF	:=	kernel8.elf
KERNEL_IMG	:=	kernel8.img

AARCH_ELF_	:=	aarch64-elf-

ASSEMBLER	:=	$(AARCH_ELF_)as
ASMFLAGS	:=	--fatal-warnings \
				--warn \
				--info \
				--gdwarf-4 \
				-mverbose-error \
				-march=armv8-a \
				-mcpu=cortex-a53+nosimd \
				--noexecstack

LINKER		:=	$(AARCH_ELF_)ld
LDFLAGS		:=	--warn-execstack-objects \
				--error-execstack \
				--warn-execstack \
				--error-rwx-segments \
				--warn-rwx-segments \
				--error-unresolved-symbols \
				--warn-unresolved-symbols \
				--warn-multiple-gp \
				--warn-once \
				--warn-section-align \
				--warn-textrel \
				--warn-alternate-em \
				--check-sections \
				--gc-sections \
				--print-gc-sections \
				--orphan-handling=error \
				-Map=$(KERNEL_MAP) \
				--build-id=sha1

OBJCOPY		:=	$(AARCH_ELF_)objcopy

OBJDUMP		:=	$(AARCH_ELF_)objdump

NM			:=	$(AARCH_ELF_)nm

READELF		:=	$(AARCH_ELF_)readelf

GCC			:=	clang

QEMU		:=	qemu-system-aarch64
QEMU_COM_SOCK	:= /tmp/rpi-tty.sock
QEMUFLAGS	:=	-serial null \
				-display none \
				-cpu cortex-a53 \
				-M raspi3b \
				-serial stdio
# 				-chardev socket,id=tty0,path=$(QEMU_COM_SOCK),server=on,wait=off \
  				-serial chardev:tty0
LD_SCRIPT	:=	./linker.ld

%.o: %.s
	$(ASSEMBLER) $(ASMFLAGS) -c $< -o $@

all: $(KERNEL_IMG) bootloader_communication

$(KERNEL_IMG): $(KERNEL_ELF)
	$(OBJCOPY) -O binary $< $@

$(KERNEL_ELF): $(OBJS)
	$(LINKER) $(LDFLAGS) -T $(LD_SCRIPT) -o $@ $(OBJS)

asm: $(KERNEL_IMG)
	$(QEMU) $(QEMUFLAGS) -d in_asm -kernel $<

elf_headers: $(KERNEL_ELF)
	$(READELF) -a $<
# 	$(OBJDUMP) -d -W $<
# 	$(NM) $<

debug: $(KERNEL_IMG)
# This creates a QEMU gdb server session. To connect :
# $ lldb
# (lldb) file ./kernel8.elf
# (lldb) gdb-remote localhost:1234
	$(QEMU) $(QEMUFLAGS) -S -s -kernel $<

release: $(KERNEL_IMG) bootloader_communication
	$(QEMU) $(QEMUFLAGS) -kernel $<

bootloader_communication: bootloader_communication.c
	$(GCC) $< -o $@

clean:
	rm -f $(OBJS) $(KERNEL_MAP)

fclean: clean
	rm -f $(KERNEL_IMG) $(KERNEL_ELF)

re: fclean all

.PHONY: all asm elf_headers debug release bootloader_communication clean fclean re