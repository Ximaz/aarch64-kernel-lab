.section .text

.extern __bss_start
.extern __bss_size
.extern memset

.global clear_bss_section

clear_bss_section:
    ADR X0, __bss_start
    MOV W1, #0
    ADR X2, __bss_size
    B memset
