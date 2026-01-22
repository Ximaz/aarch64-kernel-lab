.section .text

.global _start

.extern __stack_top
.extern __stdin_buffer

.extern clear_bss_section
.extern clear_stdin_buffer

.extern enable_interrupt
.extern disable_interrupt
.extern enable_interrupt_request_1
.extern disable_fifo
.extern set_baud_value
.extern disable_transmitter_receiver
.extern enable_transmitter_receiver
.extern enable_mini_uart
.extern set_uart_bit_mode
.extern disable_auto_control_flow

.extern uart_read
.extern uart_write


_start:
    ADR X0, __stack_top
    MOV SP, X0

    BL clear_bss_section
    BL clear_stdin_buffer

    BL _configure_uart

    BL _shell

    B _start

_configure_uart:
    STP X29, X30, [SP, #-16]!
    MOV X29, SP
    BL enable_mini_uart
    BL disable_transmitter_receiver
    BL disable_interrupt
    BL set_uart_bit_mode
    BL disable_auto_control_flow
    BL set_baud_value
    BL disable_fifo
    BL enable_transmitter_receiver
    BL enable_interrupt_request_1
    LDP X29, X30, [SP], #16
    RET

_shell:
    ADR X0, SHELL_PROMPT
    MOV X1, #2
    BL uart_write

    ADR X0, __stdin_buffer
    MOV X1, #127
    BL uart_read

    MOV X1, X0
    ADR X0, __stdin_buffer
    BL uart_write

    ADR X0, CRLF
    MOV X1, #2
    BL uart_write

    B _shell

.section .rodata
SHELL_PROMPT: .ascii "> "
CRLF: .ascii "\r\n"
