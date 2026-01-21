PHDRS
{
    text PT_LOAD FLAGS (PF_R | PF_X);
    data PT_LOAD FLAGS (PF_R | PF_W);
}

SECTIONS
{
    . = 0x80000;

    .text :
    {
        *(.text)
    } :text


    .bss :
    {
        . = ALIGN(16);
        __bss_start = .;
        . += 0x4000; /* 16kb */
        __bss_end = .;
    } :data

    .stack :
    {
        . = ALIGN(16);
        __stack_bottom = .;
        . += 0x4000; /* 16kb */
        __stack_top = .;
    } :data
}
