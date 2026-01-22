.section .text

.global disable_auto_control_flow

disable_auto_control_flow:
    LDR X0, =AUX_MU_MCR_REG
    MOV W1, #0
    STR W1, [X0]
    RET

.section .rodata
AUX_MU_MCR_REG = 0x3F215050
