.section .text

/* -----------------------------------------------------------------------------
uint8_t *uart_read_buffer(
    uint8_t *buffer = X0,
    uint64_t size   = X1
);

Description : Block the thread until all bytes have been read from UART RX.
Return the pointer to the start of the buffer in X0. 'buffer' is assumed to be
allocated with enough space to fit all bytes. X20 is assumed to contain the
PL011 base address.

Affected registers : X0, X2, W3

----------------------------------------------------------------------------- */
.global uart_read_buffer
uart_read_buffer:
    MOV X2, #0
uart_read_buffer.loop:
    CMP X2, X1
    BEQ uart_read_buffer.done
uart_read_buffer.try_read:
    LDR W3, [X20, UARTFR]
    TBNZ W3, #4, uart_read_buffer.try_read
    LDRB W3, [X20, UARTDR]
    STRB W3, [X0, X2]
    ADD X2, X2, #1
    B uart_read_buffer.loop
uart_read_buffer.done:
    RET

.section .rodata
.equ UARTFR, 0x018
.equ UARTDR, 0x000
