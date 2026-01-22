.section .text

// -----------------------------------------------------------------------------
// int8_t strncmp(
//    const char *str1 = X0,
//    const char *str2 = X1,
//    uint64_t size    = X2
// )
//
// Description
//   This procedure compares 'size' bytes of 'str1' against 'str2'.
//   'str1' and 'str2' are assumed to be null-terminated bytes buffers.
//   If either 'str1' or 'str2' is shorted than 'size' the procedure exits.
//   The procedure returns the difference of the two last compared bytes.
//   The return value is stored in the least significant 8 bits of W0.
//
// Affected registers
//   X0, X1, X2, W3, W4
// -----------------------------------------------------------------------------
.global strncmp
strncmp:
    SUB X2, X2, #1
.loop:
    LDRB W3, [X0], #1
    LDRB W4, [X1], #1
    CBZ W3, .done
    CBZ W4, .done
    CBZ X2, .done
    SUB X2, X2, #1
    CMP W3, W4
    BEQ .loop
.done:
    MOV W0, W3
    SUB W0, W0, W4
    RET
