SRCS		:=	$(shell find kernel -name '*.s')
OBJS		:=	$(SRCS:.s=.o)
KERNEL_MAP	:=	kernel8.map
KERNEL_ELF	:=	kernel8.elf
KERNEL_IMG	:=	kernel8.img
ASSEMBLER	:=	aarch64-elf-as
ASMFLAGS	:=	--fatal-warnings \
				--warn \
				--info \
				--gdwarf-4 \
				-mverbose-error \
				-march=armv8-a \
				-mcpu=cortex-a53+nosimd \
				--noexecstack
LINKER		:=	aarch64-elf-ld
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
OBJCOPY		:=	aarch64-elf-objcopy
OBJDUMP		:=	aarch64-elf-objdump
NM			:=	aarch64-elf-nm
READELF		:=	aarch64-elf-readelf
QEMU		:=	qemu-system-aarch64
QEMUFLAGS	:=	-serial null \
				-serial stdio \
				-display none \
				-cpu cortex-a53 \
				-M raspi3b
LD_SCRIPT	:=	./linker.ld

all: $(OBJS)
	$(MAKE) kernel8.img

%.o: %.s
	$(ASSEMBLER) $(ASMFLAGS) -c $< -o $@

all: $(KERNEL_IMG)

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

release: $(KERNEL_IMG)
	$(QEMU) $(QEMUFLAGS) -kernel $<

clean:
	rm -f $(OBJS) $(KERNEL_MAP)

fclean: clean
	rm -f $(KERNEL_IMG) $(KERNEL_ELF)

re: fclean $(KERNEL_IMG)
