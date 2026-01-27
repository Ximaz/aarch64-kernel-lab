.section .text

.extern stdin_buffer_start
.extern stdin_buffer_end
.extern memset

.global clear_stdin_buffer

clear_stdin_buffer:
    ADR X0, stdin_buffer_start
    MOV W1, #0
    ADR X2, stdin_buffer_end
    SUB X2, X2, X0
    B memset
