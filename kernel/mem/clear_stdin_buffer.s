.section .text

.extern __stdin_buffer
.extern __stdin_buffer_size
.extern memset

.global clear_stdin_buffer

clear_stdin_buffer:
    ADR X0, __stdin_buffer
    MOV W1, #0
    ADR X2, __stdin_buffer_size
    B memset
