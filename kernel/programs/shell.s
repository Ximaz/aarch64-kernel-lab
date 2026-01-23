.section .text

.extern stdin_buffer

.extern uart_read_line
.extern uart_write
.extern uart_write_crlf
.extern memcmp
.extern strncmp
.extern system_off
.extern system_reset

.global shell
shell:
    STP X29, X30, [SP, #-16]!
    MOV X29, SP
    SUB SP, SP, #16

.loop:
    ADR X0, SHELL_PROMPT
    MOV X1, #2
    BL uart_write

    ADR X0, stdin_buffer
    MOV X1, #127
    BL uart_read_line
    STR X0, [X29] // Copy the number of read bytes on the stack

    // Look for the 'help' command
    MOV X2, X0
    ADR X0, stdin_buffer
    ADR X1, SHELL_CMD_HELP
    BL strncmp
    CBZ X0, .help

    // Look for the 'echo' command
    MOV X2, SHELL_CMD_ECHO_LEN
    ADR X0, stdin_buffer
    ADR X1, SHELL_CMD_ECHO
    BL strncmp
    CBZ X0, .echo

.invalid_cmd:
    ADR X0, SHELL_INVALID_CMD
    MOV X1, SHELL_INVALID_CMD_LEN
    BL uart_write
    BL uart_write_crlf
    ADR X0, SHELL_HELP
    MOV X1, SHELL_HELP_LEN
    BL uart_write
    BL uart_write_crlf
    B .continue

.help:
    ADR X0, SHELL_HELP
    MOV X1, SHELL_HELP_LEN
    BL uart_write
    BL uart_write_crlf
    B .continue

.echo:
    ADR X0, stdin_buffer
    ADD X0, X0, #5
    LDR X1, [X29]
    SUB X1, X1, #5
    CMP X1, #0
    BLE .echo.done
    BL uart_write
.echo.done:
    BL uart_write_crlf
    B .continue

.continue:
    WFE
    B .loop

.section .rodata
SHELL_PROMPT: .ascii "> "

SHELL_CMD_HELP: .ascii "help"
SHELL_CMD_HELP_LEN = . - SHELL_CMD_HELP

SHELL_CMD_ECHO: .ascii "echo"
SHELL_CMD_ECHO_LEN = . - SHELL_CMD_ECHO

SHELL_INVALID_CMD: .ascii "Invalid command"
SHELL_INVALID_CMD_LEN = . - SHELL_INVALID_CMD

SHELL_HELP: .ascii "help\r\necho [argument 1, [argument 2, ...]]"
SHELL_HELP_LEN = . - SHELL_HELP
