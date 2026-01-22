.section .text

.global enable_interrupt

enable_interrupt:
    LDR X0, =AUX_MU_IER_REG
    MOV W1, #0b11
    STR W1, [X0]
    RET

.section .rodata
.equ AUX_MU_IER_REG, 0x3F215044
