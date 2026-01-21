ASSEMBLER	:=	aarch64-elf-gcc
LINKER		:=	aarch64-elf-ld
OBJCOPY		:=	aarch64-elf-objcopy
EMULATOR	:=	qemu-system-aarch64
LD_SCRIPT	:=	./linker.ld

entrypoint.o: entrypoint.s
	$(ASSEMBLER) -c $< -o $@


kernel8.elf: entrypoint.o
	$(LINKER) -T $(LD_SCRIPT) -o $@ $<

kernel8.img: kernel8.elf
	$(OBJCOPY) -O binary $< $@

get_asm: kernel8.img
	$(EMULATOR) -M raspi3b -kernel $< -display none -d in_asm

debug: kernel8.img
# This creates a QEMU gdb server session. To connect :
# $ lldb
# (lldb) file ./kernel8.elf
# (lldb) gdb-remote localhost:1234
	$(EMULATOR) -M raspi3b -kernel $< -display none -S -s