.section .text

// -----------------------------------------------------------------------------
// uint8_t read_byte(void)
//
// Description
//   This procedure reads a byte from mini UART.
//   This procedure blocks until a byte is ready to be read.
//   If the read byte equals '\r', '\0' is returned and procedure exits.
//   The value is returned in the 8 least significant bits of W0 register.
//
// Affected registers
//   X0, W1
// -----------------------------------------------------------------------------
.global read_byte
read_byte:
    LDR X0, =AUX_MU_LSR_REG
    LDR W1, [X0]
    TBZ W1, #0, read_byte.sleep
    LDR X0, =AUX_MU_IO_REG
    LDR W0, [X0]
    AND W0, W0, #0xff
    CMP W0, #'\r'
    BEQ read_byte.done
    RET
read_byte.sleep:
    WFE
    B read_byte
read_byte.done:
    MOV W0, #0
    RET

.section .rodata
.equ AUX_MU_LSR_REG, 0x3F215054
.equ AUX_MU_IO_REG, 0x3F215040
