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
        stack_bottom = .;
        . += 0x4000;
        stack_top = .;
    } :data
}
