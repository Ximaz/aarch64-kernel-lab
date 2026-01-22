.section .text

// -----------------------------------------------------------------------------
// int8_t memcmp(
//    const char *buffer1 = X0,
//    const char *buffer2 = X1,
//    uint64_t size       = X2
// )
//
// Description
//   This procedure compares 'size' bytes of 'buffer1' against 'buffer2'.
//   The procedure returns the difference of the two last compared bytes.
//   The return value is stored in the least significant 8 bits of W0.
//
// Affected registers
//   X0, X1, X2, W3, W4
// -----------------------------------------------------------------------------
.global memcmp
memcmp:
    SUB X2, X2, #1
    // cmp
memcmp.loop:
    LDRB W3, [X0], #1
    LDRB W4, [X1], #1
    CBZ X2, memcmp.done
    SUB X2, X2, #1
    CMP W3, W4
    BEQ memcmp.loop
memcmp.done:
    MOV W0, W3
    SUB W0, W0, W4
    RET
