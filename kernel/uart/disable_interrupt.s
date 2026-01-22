.section .text

.global disable_interrupt

disable_interrupt:
    LDR X0, =AUX_MU_IER_REG
    MOV W1, #0
    STR W1, [X0]
    RET

.section .rodata
AUX_MU_IER_REG = 0x3F215044
