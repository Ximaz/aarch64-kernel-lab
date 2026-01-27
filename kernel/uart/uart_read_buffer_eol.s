.section .text

/* -----------------------------------------------------------------------------
uint64_t uart_read_buffer_eol(
    uint8_t *buffer   = X0,
    uint64_t max_size = X1
);

Description : Block the thread until either 'max_size' bytes have been read from
UART RX or EOL ('\r', 0xd) has been encountered once. If EOL is encountered, it
is not stored in the buffer, the procedure will exit before the insertion.
Return the number of bytes read into X0. 'buffer' is assumed to be allocated
with enough space to fit all 'max_size' bytes. X20 is assumed to contain the
PL011 base address.

Alias : uart_read_line

Affected registers : X0, X2, W3

----------------------------------------------------------------------------- */
.global uart_read_buffer_eol
.global uart_read_line
uart_read_buffer_eol:
uart_read_line:
    MOV X2, #0
uart_read_buffer_eol.loop:
    CMP X2, X1
    BEQ uart_read_buffer_eol.done
uart_read_buffer_eol.try_read:
    LDR W3, [X20, UARTFR]
    TBNZ W3, #4, uart_read_buffer_eol.try_read
    LDRB W3, [X20, UARTDR]
    CMP W3, #'\r'
    BEQ uart_read_buffer_eol.done
    STRB W3, [X0, X2]
    ADD X2, X2, #1
    B uart_read_buffer_eol.loop
uart_read_buffer_eol.done:
    MOV X0, X2
    RET

.section .rodata
.equ UARTFR, 0x018
.equ UARTDR, 0x000
