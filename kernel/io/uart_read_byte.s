.section .text

// -----------------------------------------------------------------------------
// uint8_t uart_read_byte(void)
//
// Description
//   This procedure reads a byte from mini UART.
//   This procedure blocks until a byte is ready to be read.
//   If the read byte equals '\r', '\0' is returned and procedure exits.
//   The value is returned in the 8 least significant bits of W0 register.
//
// Affected registers
//   X0, W1
// -----------------------------------------------------------------------------
.global uart_read_byte
uart_read_byte:
    LDR X0, =AUX_MU_LSR_REG
    LDR W1, [X0]
    TBZ W1, #0, .sleep
    LDR X0, =AUX_MU_IO_REG
    LDR W0, [X0]
    AND W0, W0, #0xff
    RET
.sleep:
    WFE
    B uart_read_byte

.section .rodata
AUX_MU_LSR_REG = 0x3F215054
AUX_MU_IO_REG = 0x3F215040
