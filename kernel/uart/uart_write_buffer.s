.section .text

/* -----------------------------------------------------------------------------
void uart_write_buffer(
    uint8_t *buffer = X0,
    uint64_t size   = X1
);

Description : Block the thread until all bytes have been written to UART TX. X20
is assumed to contain the PL011 base address.

Affected registers : X0, X2, W3

----------------------------------------------------------------------------- */
.global uart_write_buffer
uart_write_buffer:
    MOV X2, #0
uart_write_buffer.loop:
    CMP X2, X1
    BEQ uart_write_buffer.done
uart_write_buffer.try_write:
    LDR W3, [X20, UARTFR]
    TBNZ W3, #5, uart_write_buffer.try_write
    LDRB W3, [X0, X2]
    STRB W3, [X20, UARTDR]
    ADD X2, X2, #1
    B uart_write_buffer.loop
uart_write_buffer.done:
    RET

.section .rodata
.equ UARTFR, 0x018
.equ UARTDR, 0x000
