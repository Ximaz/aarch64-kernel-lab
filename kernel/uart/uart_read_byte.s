.section .text

.extern uart_read_byte

/* -----------------------------------------------------------------------------
uint8_t uart_read_byte(void);

Description : Block the thread until a byte can be read from UART RX. Return the
byte into W0. X20 is assumed to contain the PL011 base address

Affected registers : X0

----------------------------------------------------------------------------- */
.global uart_read_byte
uart_read_byte:
    LDR W0, [X20, UARTFR]
    TBNZ W0, #4, uart_read_byte
    LDRB W0, [X20, UARTDR]
    RET

.section .rodata
.equ UARTFR, 0x018
.equ UARTDR, 0x000
