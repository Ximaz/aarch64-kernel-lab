.section .text

.global enable_mini_uart

enable_mini_uart:
    LDR X0, =AUXENB
    MOV W1, #1
    STR W1, [X0]
    RET

.section .rodata
.equ AUXENB, 0x3F215004
