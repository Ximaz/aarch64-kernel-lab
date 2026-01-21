.section .text

.extern __bss_start
.extern __bss_end
.extern __stack_top
.extern __stdin_buffer

_start:
    ADR X0, __stack_top
    MOV SP, X0

    BL _clear_bss_section

    // Setup mini UART
    BL _enable_mini_uart
    BL _disable_transmitter_and_receiver
    BL _disable_interrupt
    BL _set_uart_bit_mode
    BL _disable_auto_control_flow
    BL _set_baud_value
    BL _disable_fifo
    BL _enable_transmitter_receiver
    BL _interrupt_enable_register_1

    BL _shell

    B _start

// X0 = destination
// X1 = byte
// X2 = size
_memset:
    CMP X2, #0
    BEQ _memset.done
    STRB W1, [X0], #1
    SUB X2, X2, #1
    B _memset
_memset.done:
    RET

_clear_stdin_buffer:
    ADR X0, __stdin_buffer
    MOV X1, #0
    MOV X2, X0
    ADD X2, X2, 127
    B _memset

_clear_bss_section:
    ADR X0, __bss_start
    MOV X1, #0
    ADR X2, __bss_end
    SUB X2, X2, X0
    B _memset

_enable_mini_uart:
    LDR X0, =AUXENB
    MOV W1, #0b00000000000000000000000000000001
    STR W1, [X0]
    RET

_disable_transmitter_and_receiver:
    LDR X0, =AUX_MU_CNTL_REG
    MOV W1, #0
    STR W1, [X0]
    RET

_enable_transmitter_receiver:
    LDR X0, =AUX_MU_CNTL_REG
    MOV W1, #0b00000000000000000000000000000011
    STR W1, [X0]
    RET

_disable_interrupt:
    LDR X0, =AUX_MU_IER_REG
    MOV W1, #0
    STR W1, [X0]
    RET

_set_uart_bit_mode:
    LDR X0, =AUX_MU_LCR_REG
    MOV W1, #0b00000000000000000000000000000011
    STR W1, [X0]
    RET

_disable_auto_control_flow:
    LDR X0, =AUX_MU_MCR_REG
    MOV W1, #0
    STR W1, [X0]
    RET

_set_baud_value:
    LDR X0, =AUX_MU_BAUD
    MOV W1, #0b00000000000000000000000100001110
    STR W1, [X0]
    RET

_disable_fifo:
    LDR X0, =AUX_MU_IIR_REG
    MOV W1, #0b00000000000000000000000000000110
    STR W1, [X0]
    RET

// Wait for an interrupt to occur, then store the type of interrupt that happened
// into W1
_interrupt:
    LDR X0, =AUX_MU_IER_REG
    MOV W1, #0b00000000000000000000000000000011
    STR W1, [X0]

    LDR X0, =AUX_MU_IIR_REG
    LDR W1, [X0]
    AND W1, W1, #0b00000000000000000000000000000111

    RET

_interrupt_enable_register_1:
    LDR X0, =INT_REG_1
    MOV W1, #0x10000000
    STR W1, [X0]
    RET

// Read 32bits from AUX_MU_LSR_REG to check if data is writable
// Write 32bits to AUX_MU_IO_REG from W0, if doable
_write_char:
    MOV X1, X0
    LDR X0, =AUX_MU_LSR_REG
    LDR W2, [X0]
    TBZ W2, #5, _write_char.end

    LDR X0, =AUX_MU_IO_REG
    STRB W1, [X0]
_write_char.end:
    RET

// Read 32bits from AUX_MU_LSR_REG to cehck if data is available
// Read 32bits from AUX_MU_IO_REG to get the data, if available
// Return the 32bits read data, or zero, into W0
_read_char:
    LDR X0, =AUX_MU_LSR_REG
    LDR W1, [X0]
    TBZ W1, #0, _read_char.done

    LDR X0, =AUX_MU_IO_REG
    LDR W1, [X0]
    AND W1, W1, #0x7f
_read_char.done:
    MOV W0, W1
    RET

// Read stdin until EOF or max length is reached
// X0 = buffer
// X1 = max size
_read:
    STP X29, X30, [SP, #-16]! // Save frame pointer and return address onto the stack
    MOV X29, SP // Set the frame pointer to the stack pointer <=> base pointer
    MOV X3, #0 // Number of bytes read from the UART stdin
    CMP X1, #0 // Checks the max bytes to read is at least 1 byte
    BLE _read.done // If not, exit the procedure
    MOV X2, X0 // Saves the buffer address into X2 (X0 will be used later)
    MOV X4, X1 // Saves the max bytes to read into X4 (x1 will be used later)
    SUB X4, X4, #1 // Decrease by one to avoid out-of-bounds write
_read.wait_char:
    BL _read_char // Try to read a byte into W0
    CBZ W0, _read.wait_char // If W0 equals 0, keep trying to read a byte
    STRB W0, [X2]
    CMP W0, #'\r' // If EOF ('\r') equals W0
    BEQ _read.done // exit the procedure
    ADD X3, X3, #1 // Increase the total number of read bytes
    CMP X3, X4 // If the total number of read bytes is less than the max bytes to be read
    BEQ _read.done // keep reading from UART stdin
    ADD X2, X2, #1 // Store the read byte into the buffer and increase the address
    B _read.wait_char
_read.done:
    MOV W0, #0
    STRB W0, [X2] // null-terminate the buffer
    MOV X0, X3 // Restore the total number of bytes read into X0
    LDP X29, X30, [SP], #16 // restore frame pointer and return address
    RET // Exit the procedure and restore program counter


_shell:
    MOV X0, #'>'
    BL _write_char

    ADR X0, __stdin_buffer
    MOV X1, #127
    BL _read

    NOP

    B _shell


.section .data

.equ AUXENB, 0x3F215004
.equ AUX_MU_CNTL_REG, 0x3F215060
.equ AUX_MU_IER_REG, 0x3F215044
.equ AUX_MU_LCR_REG, 0x3F21504C
.equ AUX_MU_MCR_REG, 0x3F215050
.equ AUX_MU_BAUD, 0x3F215068
.equ AUX_MU_IIR_REG, 0x3F215048
.equ AUX_MU_LSR_REG, 0x3F215054
.equ AUX_MU_IO_REG, 0x3F215040
.equ INT_REG_1, 0x210
.equ EOF, 0xd

.section .bss
.equ STDIN_BUFFER_START, __bss_start
.equ STDIN_BUFFER_END, __bss_start+127
