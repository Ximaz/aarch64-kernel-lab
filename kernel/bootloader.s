.section .text

.extern setup_uart
.extern uart_read_byte

.global bootloader
bootloader:
    STP X29, X30, [SP, #-32]!
    MOV X29, SP

    // Setup UART
    LDR X0, =UART_BAUDRATE
    BL setup_uart

    // Try to read a byte
    BL uart_read_byte

    LDP X29, X30, [SP], #32
    B bootloader

.section .rodata
.equ UART_BAUDRATE, 115200
