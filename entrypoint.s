.section .text

_start:
    LDR X0, =stack_top
    MOV SP, X0
    wfe
    b _start
