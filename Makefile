ASSEMBLER	:=	aarch64-elf-gcc
LINKER		:=	aarch64-elf-ld
OBJCOPY		:=	aarch64-elf-objcopy
READELF		:=	aarch64-elf-readelf
EMULATOR	:=	qemu-system-aarch64
LD_SCRIPT	:=	./linker.ld

entrypoint.o: entrypoint.s
	$(ASSEMBLER) -c $< -o $@

kernel8.elf: entrypoint.o
	$(LINKER) -T $(LD_SCRIPT) -o $@ $<

kernel8.img: kernel8.elf
	$(OBJCOPY) -O binary $< $@

get_asm: kernel8.img
	$(EMULATOR) -serial null -serial stdio -M raspi3b -kernel $< -display none -d in_asm

get_elf_headers: kernel8.elf
	$(READELF) -l $<

debug: kernel8.img
# This creates a QEMU gdb server session. To connect :
# $ lldb
# (lldb) file ./kernel8.elf
# (lldb) gdb-remote localhost:1234
	$(EMULATOR) -serial null -serial stdio -M raspi3b -kernel $< -display none -S -s

clean:
	rm -f entrypoint.o

fclean: clean
	rm -f kernel8.img kernel8.elf

re: fclean kernel8.img
