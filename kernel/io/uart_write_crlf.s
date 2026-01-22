.section .text
.extern uart_write

// -----------------------------------------------------------------------------
// void uart_write_crlf(void)
//
// Description
//   This procedure writes a carriage-return-line-feed to mini UART.
//   This procedure blocks until the bytes are written.
//
// Affected registers
//   X0, X1
// -----------------------------------------------------------------------------
.global uart_write_crlf
uart_write_crlf:
    ADR X0, CRLF
    MOV X1, #2
    B uart_write

.section .rodata
CRLF: .ascii "\r\n"
