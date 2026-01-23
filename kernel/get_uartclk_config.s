.section .text

.extern dtb_find_dt_struct_node
.extern dtb_find_dt_struct_node_prop
.extern dtb_find_dt_struct_node_by_phandle

/* -----------------------------------------------------------------------------
uint32_t get_uartclk_config(
    uint64_t *pl011_base_addr = X1
);

Description : If the clock frequency is not found, #0 is returned. If the pl011
base address is not found, #0 is returned. Return the uart clock frequency into
W0. Return the pl011 base address into X1.

Affected registers : X0, X1, X2, X3, X4, X5

----------------------------------------------------------------------------- */
.global get_uartclk_config
get_uartclk_config:
    STP X29, X30, [SP, #-48]!
    MOV X29, SP

    // --- try to find the 'pl011@...' device tree node
    ADR X0, PL011_NODE_UNIT_NAME
    MOV X1, PL011_NODE_UNIT_NAME_LEN
    BL dtb_find_dt_struct_node
    // unable to find the pl011 node
    CBZ X0, get_uartclk_config.error
    STR X0, [X29, #16] // store the pointer to the beginning of the node

    // parse the pl011 base address
    // --- try to find the base address from the 'reg' property
    ADR X1, PL011_REG_PROP
    BL dtb_find_dt_struct_node_prop
    // unable to find the 'reg' property
    CBZ W2, get_uartclk_config.error

    LDR W0, [X4]
    REV W0, W0
    ROR X0, X0, #16
    LDR W0, [X4, #4]
    REV W0, W0
    STR X0, [X29, #32] // the parsed pl011 base address

    LDR X0, [X29, #16]

    // --- try to find the uartclk phandle from the 'clock' property
    ADR X1, PL011_CLOCKS_PROP
    BL dtb_find_dt_struct_node_prop
    // unable to find the 'clocks' property
    CBZ W2, get_uartclk_config.error
    LDR W0, [X4] // W0 now contains the value of the phandle to find

    // --- try to find the node containing the uartclk frequency value based on
    //     the phandle value
    BL dtb_find_dt_struct_node_by_phandle
    // unable to find the uartclk phandle
    CBZ W1, get_uartclk_config.error

    // --- try to read the 'clock-frequency' property value, containing the uart
    //     clock frequency in Hz
    ADR X1, CLOCK_FREQUENCY_PROP
    BL dtb_find_dt_struct_node_prop
    // unable to find the 'clock-frequency' property given the found phandle
    CBZ W2, get_uartclk_config.error

    LDR W0, [X4]
    REV W0, W0 // convert from big to little endian

    LDR X1, [X29, #32] // restore the pl011 base address
    B get_uartclk_config.done

get_uartclk_config.error:
    MOV W0, #0
    MOV X1, #0
get_uartclk_config.done:
    LDP X29, X30, [SP], #48
    RET

.section .rodata

PL011_NODE_UNIT_NAME: .ascii "pl011@"
.equ PL011_NODE_UNIT_NAME_LEN, . - PL011_NODE_UNIT_NAME

PL011_CLOCKS_PROP: .asciz "clocks"
PL011_REG_PROP: .asciz "reg"
// stored in 'apb-pclk' node, found via phandle value
CLOCK_FREQUENCY_PROP: .asciz "clock-frequency"
