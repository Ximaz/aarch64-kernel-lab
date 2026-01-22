.section .text

.global disable_fifo

disable_fifo:
    LDR X0, =AUX_MU_IIR_REG
    MOV W1, #0b110
    STR W1, [X0]
    RET

.section .rodata
AUX_MU_IIR_REG = 0x3F215048
