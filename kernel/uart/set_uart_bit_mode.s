.section .text

.global set_uart_bit_mode

set_uart_bit_mode:
    LDR X0, =AUX_MU_LCR_REG
    MOV W1, #0b11
    STR W1, [X0]
    RET

.section .rodata
AUX_MU_LCR_REG = 0x3F21504C
