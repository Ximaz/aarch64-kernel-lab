.section .text

.extern __stdin_buffer

.extern uart_read_line
.extern uart_write
.extern uart_write_crlf
.extern memcmp
.extern system_off
.extern system_reset

.global shell
shell:
    ADR X0, SHELL_PROMPT
    MOV X1, #2
    BL uart_write

    ADR X0, __stdin_buffer
    MOV X1, #127
    BL uart_read_line
    MOV X5, X0 // Copy the number of read bytes

    // Look for the 'help' command
    MOV X2, X5
    ADR X0, __stdin_buffer
    ADR X1, SHELL_CMD_HELP
    BL memcmp
    CBZ X0, .help

.invalid_cmd:
    ADR X0, SHELL_INVALID_CMD
    MOV X1, SHELL_INVALID_CMD_LEN
    BL uart_write
    BL uart_write_crlf
    B shell

.help:
    ADR X0, SHELL_HELP
    MOV X1, SHELL_HELP_LEN
    BL uart_write
    BL uart_write_crlf
    B shell

.section .rodata
SHELL_PROMPT: .ascii "> "
SHELL_CMD_HELP: .ascii "help"

SHELL_INVALID_CMD: .ascii "Invalid command"
SHELL_INVALID_CMD_LEN = . - SHELL_INVALID_CMD

SHELL_HELP: .ascii "help"
SHELL_HELP_LEN = . - SHELL_HELP
