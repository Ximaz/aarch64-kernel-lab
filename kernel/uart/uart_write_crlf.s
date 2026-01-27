.section .text

/* -----------------------------------------------------------------------------
void uart_write_crlf(void);

Description : Block the thread until CRLF bytes have been written to UART TX.
X20 is assumed to contain the PL011 base address.

Affected registers : X0, X1, W2

----------------------------------------------------------------------------- */
.global uart_write_crlf
uart_write_crlf:
    LDR X0, =CRLF
    MOV X1, #0
uart_write_crlf.loop:
    CMP X1, CRLF_LEN
    BEQ uart_write_crlf.done
uart_write_crlf.try_write:
    LDR W2, [X20, UARTFR]
    TBNZ W2, #5, uart_write_crlf.try_write
    LDRB W2, [X0, X1]
    STRB W2, [X20, UARTDR]
    ADD X1, X1, #1
    B uart_write_crlf.loop
uart_write_crlf.done:
    RET

.section .rodata
.equ UARTFR, 0x018
.equ UARTDR, 0x000

CRLF: .ascii "\r\n"
.equ CRLF_LEN, . - CRLF
