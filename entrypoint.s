.section .text

.global __bss_start
.global __bss_end
.global __stack_top

_start:
    # (__stack_top - _start) < 1MB, ADR works here
    ADR X0, __stack_top
    MOV SP, X0

    # Prepare the .bss section, filling memory with zeroes

    # destination
    # (__bss_start - _start) < 1MB, ADR works here
    ADR X0, __bss_start
    # byte
    MOV X1, #0
    # size computation
    # (__bss_end - _start) < 1MB, ADR works here
    ADR X2, __bss_end
    SUB X2, X2, X0
    BL _memset

    WFE
    B _start

# X0 = destination
# X1 = byte
# X2 = size
_memset:
    CMP X2, #0
    BEQ _memset_done
    STRB W1, [X0], #1
    SUB X2, X2, #1
    B _memset

_memset_done:
    RET
