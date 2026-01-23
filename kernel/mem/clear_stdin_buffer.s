.section .text

.extern stdin_buffer
.extern stdin_buffer_size
.extern memset

.global clear_stdin_buffer

clear_stdin_buffer:
    ADR X0, stdin_buffer
    MOV W1, #0
    ADR X2, stdin_buffer_size
    B memset
