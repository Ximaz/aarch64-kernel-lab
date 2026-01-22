.section .text

.extern __stdin_buffer
.extern memset

.global clear_stdin_buffer

clear_stdin_buffer:
    ADR X0, __stdin_buffer
    MOV W1, #0
    MOV X2, X0
    ADD X2, X2, 127
    B memset
