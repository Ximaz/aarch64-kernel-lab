.section .text
.extern uart_write_byte

// -----------------------------------------------------------------------------
// uint64_t uart_read_line(
//    char *dest    = X0,
//    uint64_t size = X1
// )
//
// Description
//   This procedure reads a chunk of bytes from mini UART.
//   If '\r' (0xd, null-terminator) is encountered, the procedure returns.
//   If backspace (0x7f) is encountered, '\b' is printed, cursor gets seek.
//   If '\t' (0x9) is encountered, it is replaced by four ' ' (0x20).
//   If the number of bytes read reaches 'size', the procedure returns.
//   Each byte is stored sequentially in the 'dest' buffer.
//   The procedure returns the total number of bytes read.
//   The return value is stored in X0.
//
// Affected registers
//   X0, X1, X3, X4, X5, X6, X29, X30, SP
// -----------------------------------------------------------------------------
.global uart_read_line
uart_read_line:
    STP X29, X30, [SP, #-16]!
    MOV X29, SP
    MOV X2, X0
    MOV X3, #0
    MOV X4, X1
    SUB X4, X4, #1
.loop:
    CMP X3, X4
    BEQ .done
.wait:
    LDR X0, =AUX_MU_LSR_REG
    LDR W0, [X0]
    TBNZ W0, #0, .get_byte
    WFE
    B .wait
.get_byte:
    LDR X0, =AUX_MU_IO_REG
    LDR W0, [X0]
    AND W0, W0, #0xff
    CMP W0, #'\r'
    BEQ .done
    CMP W0, #0x7f
    BEQ .seek_cursor_left
    CMP W0, #'\t'
    BEQ .tab_to_space
    STRB W0, [X2], #1
    ADD X3, X3, #1
    BL uart_write_byte
    B .loop
.seek_cursor_left:
    SUB X3, X3, #1
    SUB X2, X2, #1
    MOV W0, #'\b'
    BL uart_write_byte
    MOV W0, #' '
    BL uart_write_byte
    MOV W0, #'\b'
    BL uart_write_byte
    B .loop
.tab_to_space:
    STRB W0, [X2]
    STRB W0, [X2]
    STRB W0, [X2]
    STRB W0, [X2]
    ADD X2, X2, #4
    ADD X3, X3, #4
    MOV W0, #' '
    BL uart_write_byte
    MOV W0, #' '
    BL uart_write_byte
    MOV W0, #' '
    BL uart_write_byte
    MOV W0, #' '
    BL uart_write_byte
    B .loop
.done:
    MOV X6, X3
    BL uart_write_crlf
    MOV X0, X6
    LDP X29, X30, [SP], #16
    RET

.section .rodata
AUX_MU_LSR_REG = 0x3F215054
AUX_MU_IO_REG = 0x3F215040
