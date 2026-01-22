.section .text

// -----------------------------------------------------------------------------
// void *memset(
//    void *dest    = X0,
//    uint8_t byte  = W1,
//    uint64_t size = X2)
//
// Description
//   This procedure sets the 'byte' to the 'dest' buffer over 'size' bytes.
//   The copied byte must be stored in the least significate 8 bits of W1.
//   The return value is the address of the beginning of the 'dest' buffer.
//
// Affected registers
//   X0, W1, X2, X3
// -----------------------------------------------------------------------------
.global memset
memset:
    MOV X3, X0
memset.loop:
    CBZ X2, memset.done
    STRB W1, [X0], #1
    SUB X2, X2, #1
    B memset
memset.done:
    MOV X0, X3
    RET
