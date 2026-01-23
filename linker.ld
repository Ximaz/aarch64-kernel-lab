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
    . = 0x80000;

    .text :
    {
        . = ALIGN(16);
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

        __stdin_buffer = .;
        . += 128;
        __stdin_buffer_size = . - __stdin_buffer;

        __bss_start = .;
        . += 0x4000;
        __bss_size = . - __bss_start;
    } :data

    .stack :
    {
        . = ALIGN(16);

        __stack_bottom = .;
        . += 0x4000;
        __stack_top = .;
        __stack_size = __stack_top - __stack_bottom;
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
}
