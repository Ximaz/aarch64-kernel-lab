.section .text
.extern uart_read_byte

// -----------------------------------------------------------------------------
// uint64_t uart_read(
//    char *dest    = X0,
//    uint64_t size = X1
// )
//
// Description
//   This procedure reads a chunk of bytes from mini UART.
//   If '\0' (0x0, null-terminator) is encountered, the procedure returns.
//   If the number of bytes read reaches 'size', the procedure returns.
//   Each byte is stored sequentially in the 'dest' buffer.
//   The procedure returns the total number of bytes read.
//   The return value is stored in X0.
//
// Affected registers
//   X0, X1, X3, X4, X29, X30, SP
// -----------------------------------------------------------------------------
.global uart_read
uart_read:
    STP X29, X30, [SP, #-16]!
    MOV X29, SP
    MOV X2, X0
    MOV X3, #0
    MOV X4, X1
    SUB X4, X4, #1
.loop:
    CMP X3, X4
    BEQ .done
    BL uart_read_byte
    STRB W0, [X2], #1
    CBZ W0, .done
    ADD X3, X3, #1
    B .loop
.done:
    MOV X0, X3
    LDP X29, X30, [SP], #16
    RET
