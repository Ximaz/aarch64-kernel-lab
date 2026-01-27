.section .text

.extern stdin_buffer_start
.extern stdin_buffer_end

.extern setup_uart
.extern uart_read_line
.extern uart_write_buffer
.extern uart_write_crlf

.global bootloader
bootloader:
    STP X29, X30, [SP, #-32]!
    MOV X29, SP

    // Setup UART
    LDR X0, =UART_BAUDRATE
    BL setup_uart

    // Print hello world
    ADR X0, BUFFER
    LDR X1, =BUFFER_LEN
    BL uart_write_buffer
    BL uart_write_crlf

    // Try to read a byte
    ADR X0, stdin_buffer_start
    ADR X1, stdin_buffer_end
    SUB X1, X1, X0 // end - start = buffer max size
    BL uart_read_line

    MOV X1, X0
    ADR X0, stdin_buffer_start
    BL uart_write_buffer
    BL uart_write_crlf

    LDP X29, X30, [SP], #32
    B bootloader

.section .rodata
.equ UART_BAUDRATE, 115200

BUFFER: .asciz "Hello, World !"
.equ BUFFER_LEN, . - BUFFER
