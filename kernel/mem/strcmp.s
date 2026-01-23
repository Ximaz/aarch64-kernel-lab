.section .text

// -----------------------------------------------------------------------------
// int8_t strcmp(
//    const char *str1 = X0,
//    const char *str2 = X1
// )
//
// Description
//   This procedure compares all possible bytes of 'str1' against 'str2'.
//   'str1' and 'str2' are assumed to be null-terminated bytes buffers.
//   If either 'str1' or 'str2' is shorted than the other the procedure exits.
//   The procedure returns the difference of the two last compared bytes.
//   The return value is stored in the least significant 8 bits of W0.
//
// Affected registers
//   X0, X1, X2, W3
// -----------------------------------------------------------------------------
.global strcmp
strcmp:
strcmp.loop:
    LDRB W2, [X0], #1
    LDRB W3, [X1], #1
    CBZ W2, strcmp.done
    CBZ W3, strcmp.done
    CMP W2, W3
    BEQ strcmp.loop
strcmp.done:
    MOV W0, W2
    SUB W0, W0, W3
    RET
