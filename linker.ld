ENTRY(_start)
EXTERN(_start)

PHDRS
{
    text PT_LOAD FLAGS (PF_R | PF_X);
    rodata PT_LOAD FLAGS (PF_R);
    data PT_LOAD FLAGS (PF_R | PF_W);
    debug PT_LOAD FLAGS (PF_NOTE);
}

SECTIONS
{
    . = 0x40080000;

    .text :
    {
        . = ALIGN(16);
        kernel/_start.o(.text)
        *(.text)
    } :text

    .rodata :
    {
        . = ALIGN(16);
        *(.rodata)
        *(.note.gnu.build-id)
    } :rodata

    .bss :
    {
        . = ALIGN(16);

        bss_start = .;

        stdin_buffer_start = .;
        . += 128;
        stdin_buffer_end = .;

        . = bss_start + 0x4000;
        bss_end = .;
    } :data

    .stack :
    {
        . = ALIGN(16);

        stack_bottom = .;
        . += 0x4100;
        stack_top = .;
    } :data

    .debug :
    {
        . = ALIGN(16);
        KEEP(*(.note.GNU-stack))
        KEEP(*(.debug*))
        KEEP(*(.rela*))
        KEEP(*(.iplt))
        KEEP(*(.igot.plt))
    } :debug

    .dtb :
    {
        . = ALIGN(16);
        dtb_start = .;     /* symbol for assembly to access DTB */
        KEEP(*(.data))
        dtb_end = .;
    } :data
}
