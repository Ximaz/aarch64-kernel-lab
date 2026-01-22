.section .text

.global disable_transmitter_receiver

disable_transmitter_receiver:
    LDR X0, =AUX_MU_CNTL_REG
    MOV W1, #0
    STR W1, [X0]
    RET

.section .rodata
AUX_MU_CNTL_REG = 0x3F215060
