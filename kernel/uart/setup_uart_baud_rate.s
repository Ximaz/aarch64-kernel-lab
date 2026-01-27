.section .text

.extern get_uartclk_config

/* -----------------------------------------------------------------------------
void setup_uart_baud_rate(
    uint64_t uart_clock_frequency = X0,
    uint32_t uart_baud_rate       = W1
);

Description : Setup the UARTIBRD and UARTFBRD registers for a given Baud rate
value. X20 is assumed to contain the PL011 base address

Affected registers : X0, X1, X2, X3, X4

----------------------------------------------------------------------------- */
.global setup_uart_baud_rate
setup_uart_baud_rate:
    STP X29, X30, [SP, #-16]!
    MOV X29, SP

    // X1 = 16 * baudrate (aka D for divider)
    LSL X1, X1, #4

    // X2 = UARTCLK / D (aka IBRD)
    UDIV X2, X0, X1

    // X3 = UARTCLK % D (aka ratio)
    MSUB X3, X2, X1, X0 // UARTCLK (X0) - IBRD (X2) * D (X1)

    // X4 = round((R * 64) / D) (aka FBRD)
    LSL X3, X3, #6         // ratio (X3) *= 64
    ADD X3, X3, X1, LSR #1 // ratio (X3) += D (X1) / 2 (rounding)
    UDIV X4, X3, X1        // X4 = FBRD

    // X2 = IBRD, X4 = FBRD
    CMP X4, #64
    BLO setup_uart_baud_rate.no_carry
    ADD X2, X2, #1     // carry into IBRD
    MOV X4, #0

setup_uart_baud_rate.no_carry:
    STR W2, [X20, UARTIBRD]
    STR W4, [X20, UARTFBRD]
    LDP X29, X30, [SP], #16
    RET

.section .rodata
.equ UARTIBRD, 0x024
.equ UARTFBRD, 0x028
