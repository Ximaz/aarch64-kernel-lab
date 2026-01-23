.section .text

.extern __stack_top
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

.extern shell

.global boot
boot:
    ADR X0, __stack_top
    MOV SP, X0

    BL clear_bss_section
    BL clear_stdin_buffer

    // Configure UART
    BL enable_mini_uart
    BL disable_transmitter_receiver
    BL disable_interrupt
    BL set_uart_bit_mode
    BL disable_auto_control_flow
    BL set_baud_value
    BL disable_fifo
    BL enable_transmitter_receiver
    BL enable_interrupt_request_1

    B shell
