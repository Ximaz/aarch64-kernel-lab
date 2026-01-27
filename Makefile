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
				-mcpu=cortex-a57 \
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
QEMU_MACHINE	:=	virt-10.1
QEMU_DTB	:=	$(QEMU_MACHINE).dtb
QEMU_DTB_OBJ := $(QEMU_DTB:.dtb=.dtb.o)
QEMUFLAGS	:=	-M $(QEMU_MACHINE) \
				-cpu cortex-a57 \
				-smp 1 \
				-nographic
# 				-chardev socket,id=tty0,path=$(QEMU_COM_SOCK),server=on,wait=off \
#   				-serial chardev:tty0
LD_SCRIPT	:=	./linker.ld
LLDB_PROFILE	:=	./remote.lldb

%.o: %.s
	$(ASSEMBLER) $(ASMFLAGS) -c $< -o $@

all: $(KERNEL_IMG)

$(KERNEL_IMG): $(KERNEL_ELF)
	$(OBJCOPY) -O binary $< $@

$(KERNEL_ELF): $(OBJS) $(QEMU_DTB_OBJ)
	$(LINKER) $(LDFLAGS) -T $(LD_SCRIPT) -o $@ $(OBJS) $(QEMU_DTB_OBJ)

asm: $(KERNEL_IMG) $(QEMU_DTB)
	$(QEMU) $(QEMUFLAGS) -d in_asm -kernel $<

$(QEMU_DTB):
	$(QEMU) -M $(QEMU_MACHINE),dumpdtb=$(QEMU_DTB) -nographic

$(QEMU_DTB_OBJ): $(QEMU_DTB)
	$(OBJCOPY) -I binary -O elf64-littleaarch64 -B aarch64 $< $@

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

lldb: $(LLDB_PROFILE) $(KERNEL_ELF)
	lldb $(KERNEL_ELF) -s $(LLDB_PROFILE)

clean:
	rm -f $(OBJS) $(QEMU_DTB_OBJ) $(KERNEL_MAP)

fclean: clean
	rm -f $(KERNEL_IMG) $(KERNEL_ELF) bootloader_communication

re: fclean all

.PHONY: all asm elf_headers debug release bootloader_communication clean fclean re
