.section .text

.global enable_interrupt_request_1

enable_interrupt_request_1:
    LDR X0, =INT_REG_1
    MOV W1, #0x10000000
    STR W1, [X0]
    RET

.section .rodata
.equ INT_REG_1, 0x3F00B210
