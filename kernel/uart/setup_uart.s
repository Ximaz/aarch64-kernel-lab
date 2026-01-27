.section .text

.extern setup_uart_baud_rate
.extern get_uartclk_config

/* -----------------------------------------------------------------------------
void setup_uart(
    uint32_t uart_baud_rate      = W0,
    uint64_t *pl011_base_address = X20
);

Description : Configure and enable UART on a given Baud rate. The PL011 base
address will be computed and stored in the external label called 'pl011'. Return
the PL011 base address into X20.

Affected registers : X0, X1, X2, X3, X4

----------------------------------------------------------------------------- */
.global setup_uart
setup_uart:
    STP X29, X30, [SP, #-32]!
    MOV X29, SP
    STR X0, [X29, #16]

    BL get_uartclk_config
    // X0 = store the uart clock frequency (in Hz)
    MOV X20, X1 // X20 = PL011 base address

    // Disable UART while configuring
    MOV W2, #0
    STR W2, [X1, UARTCR]

    LDR X1, [X29, #16]
    BL setup_uart_baud_rate

    LDR X1, [X29, #24] // load the PL011 base address
    // Enable : FIFO and 8-bit word length
    MOV W2, #0b1110000
    STR W2, [X1, UARTLCR_H]
    // Enabled : UART, TX and RX
    MOV W2, #0b1100000001
    STR W2, [X1, UARTCR]

    LDP X29, X30, [SP], #32
    RET

.section .rodata
.equ UARTLCR_H, 0x02C
.equ UARTCR, 0x030
.equ UARTFR, 0x018
.equ UARTDR, 0x000
