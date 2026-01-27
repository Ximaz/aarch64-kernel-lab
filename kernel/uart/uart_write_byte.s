.section .text

/* -----------------------------------------------------------------------------
void uart_write_byte(
  uint8_t char = X0
);

Description : Block the thread until a byte can be written to UART TX. X20 is
assumed to contain the PL011 base address.

Affected registers : X1

----------------------------------------------------------------------------- */
.global uart_write_byte
uart_write_byte:
    LDR W1, [X20, UARTFR]
    TBNZ W1, #5, uart_write_byte
    STRB W0, [X20, UARTDR]
    RET

.section .rodata
.equ UARTFR, 0x018
.equ UARTDR, 0x000
