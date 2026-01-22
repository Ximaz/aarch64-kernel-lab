.section .text
.extern uart_write_byte

// -----------------------------------------------------------------------------
// void uart_write(
//    char *src     = X0,
//    uint64_t size = X1
// )
//
// Description
//   This procedure writes a chunk of bytes to mini UART.
//   If the mini UART buffer is full, this procedure blocks until it's flushed.
//
// Affected registers
//   X0, X1, X3, X4, X5, X29, X30, SP
// -----------------------------------------------------------------------------
.global uart_write
uart_write:
    STP X29, X30, [SP, #-16]!
    MOV X29, SP
    MOV X5, X0
    MOV X3, #0
    MOV X4, X1
uart_write.loop:
    CMP X3, X4
    BEQ uart_write.done
    LDRB W0, [X5], #1
    BL uart_write_byte
    ADD X3, X3, #1
    B uart_write.loop
uart_write.done:
    LDP X29, X30, [SP], #16
    RET
