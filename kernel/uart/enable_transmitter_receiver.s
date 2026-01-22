.section .text

.global enable_transmitter_receiver

enable_transmitter_receiver:
    LDR X0, =AUX_MU_CNTL_REG
    MOV W1, #0b11
    STR W1, [X0]
    RET

.section .rodata
.equ AUX_MU_CNTL_REG, 0x3F215060
