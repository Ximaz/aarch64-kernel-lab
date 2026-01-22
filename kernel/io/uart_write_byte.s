.section .text

// -----------------------------------------------------------------------------
// void uart_write_byte(
//    uint8_t byte = W0
// )
//
// Description
//   This procedure writes a byte to mini UART.
//   This procedure blocks until the byte is written.
//   The byte to write must be stored in the 8 least significant bits of W0.
//
// Affected registers
//   X0, W1, W2
// -----------------------------------------------------------------------------
.global uart_write_byte
uart_write_byte:
    MOV W1, W0
    LDR X0, =AUX_MU_LSR_REG
uart_write_byte.wait:
    LDR W2, [X0]
    TBZ W2, #5, uart_write_byte.wait
    LDR X0, =AUX_MU_IO_REG
    STRB W1, [X0]
    RET

.section .rodata
.equ AUX_MU_LSR_REG, 0x3F215054
.equ AUX_MU_IO_REG, 0x3F215040
