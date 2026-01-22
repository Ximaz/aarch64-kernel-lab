.section .text

.global set_baud_value

set_baud_value:
    LDR X0, =AUX_MU_BAUD
    MOV W1, #270
    STR W1, [X0]
    RET

.section .rodata
.equ AUX_MU_BAUD, 0x3F215068
