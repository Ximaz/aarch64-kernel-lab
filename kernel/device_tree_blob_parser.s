.section .text

.extern dtb_start
.extern strncmp
.extern strcmp

.global dtb_parse_header_magic_number
.global dtb_parse_header_total_size
.global dtb_parse_header_off_dt_struct
.global dtb_parse_header_off_dt_strings
.global dtb_parse_header_off_mem_rsvmap
.global dtb_parse_header_version
.global dtb_parse_header_last_comp_version
.global dtb_parse_header_boot_cpuid_phys
.global dtb_parse_header_size_dt_strings
.global dtb_parse_header_size_dt_struct

.global dtb_parse_offset_dt_struct
.global dtb_parse_dt_struct_node
.global dtb_parse_dt_struct_node_next
.global dtb_parse_dt_struct_node_prop
.global dtb_parse_dt_struct_node_prop_next

.global dtb_find_dt_struct_node
.global dtb_find_dt_struct_node_prop
.global dtb_find_dt_struct_node_by_phandle

/* -----------------------------------------------------------------------------
uint32_t dtb_parse_header_magic_number(void);

Description : Return the magic number of the devicetree blob into W0. The magic
number should match 0xD00DFEED.

Affected registers : X0

----------------------------------------------------------------------------- */
dtb_parse_header_magic_number:
    LDR W0, dtb_start
    B __reverse_endianness

/* -----------------------------------------------------------------------------
uint32_t dtb_parse_header_total_size(void);

Description : Return the total size of the devicetree blob in bytes into W0.

Affected registers : X0

----------------------------------------------------------------------------- */
dtb_parse_header_total_size:
    ADR X0, dtb_start
    LDR W0, [X0, 4]
    B __reverse_endianness

/* -----------------------------------------------------------------------------
uint32_t dtb_parse_header_off_dt_struct(void);

Description : Return the offset from dtb_start to the devicetree struct into W0.

Affected registers : X0

----------------------------------------------------------------------------- */
dtb_parse_header_off_dt_struct:
    ADR X0, dtb_start
    LDR W0, [X0, 8]
    B __reverse_endianness

/* -----------------------------------------------------------------------------
uint32_t dtb_parse_header_off_dt_strings(void);

Description : Return the offset from dtb_start to the devicetree strings into
W0.

Affected registers : X0

----------------------------------------------------------------------------- */
dtb_parse_header_off_dt_strings:
    ADR X0, dtb_start
    LDR W0, [X0, 12]
    B __reverse_endianness

/* -----------------------------------------------------------------------------
uint32_t dtb_parse_header_off_mem_rsvmap(void);

Description : Return the offset from dtb_start to the memory reservation block
into W0.

Affected registers : X0

----------------------------------------------------------------------------- */
dtb_parse_header_off_mem_rsvmap:
    ADR X0, dtb_start
    LDR W0, [X0, 16]
    B __reverse_endianness

/* -----------------------------------------------------------------------------
uint32_t dtb_parse_header_version(void);

Description : Return the version of the devicetree data structure into W0. The
current parser is implemented for version = 17.

Affected registers : X0

----------------------------------------------------------------------------- */
dtb_parse_header_version:
    ADR X0, dtb_start
    LDR W0, [X0, 20]
    B __reverse_endianness

/* -----------------------------------------------------------------------------
uint32_t dtb_parse_header_last_comp_version(void);

Description : Return the lowest version of the devicetree data structure with
which the current version used is backwards compatible into W0.

Affected registers : X0

----------------------------------------------------------------------------- */
dtb_parse_header_last_comp_version:
    ADR X0, dtb_start
    LDR W0, [X0, 24]
    B __reverse_endianness

/* -----------------------------------------------------------------------------
uint32_t dtb_parse_header_boot_cpuid_phys(void);

Description : Return the physical ID of the system's boot CPU into W0.

Affected registers : X0

----------------------------------------------------------------------------- */
dtb_parse_header_boot_cpuid_phys:
    ADR X0, dtb_start
    LDR W0, [X0, 28]
    B __reverse_endianness

/* -----------------------------------------------------------------------------
uint32_t dtb_parse_header_size_dt_strings(void);

Description : Return the length in bytes of the strings block section of the
devicetree blob into W0.

Affected registers : X0

----------------------------------------------------------------------------- */
dtb_parse_header_size_dt_strings:
    ADR X0, dtb_start
    LDR W0, [X0, 32]
    B __reverse_endianness

/* -----------------------------------------------------------------------------
uint32_t dtb_parse_header_size_dt_struct(void);

Description : Return the length in bytes of the structure block section of the
devicetree blob into W0.

Affected registers : X0

----------------------------------------------------------------------------- */
dtb_parse_header_size_dt_struct:
    ADR X0, dtb_start
    LDR W0, [X0, 36]
    B __reverse_endianness

__reverse_endianness:
    REV W0, W0
    UXTW X0, W0
    RET

/* -----------------------------------------------------------------------------
uint64_t dtb_parse_offset_dt_struct(void);

Description : Return the absolute address of the devicetree struct into X0.

Affected registers : X0, X1

----------------------------------------------------------------------------- */
dtb_parse_offset_dt_struct:
    STP X29, X30, [SP, #-16]!
    MOV X29, SP

    BL dtb_parse_header_off_dt_struct

    ADR X1, dtb_start
    ADD X0, X1, X0

    LDP X29, X30, [SP], #16
    RET

/* -----------------------------------------------------------------------------
uint64_t dtb_parse_offset_dt_struct_next_node(
    uint64_t cursor = X0
);

Description : Find the beginning of a node using the FDT_BEGIN_NODE token as a
reference. Return the new cursor into X0, pointing to the FDT_BEGIN_NODE.

Affected registers : X0, X1

----------------------------------------------------------------------------- */
dtb_parse_offset_dt_struct_next_node:
    STP X29, X30, [SP, #-16]!
    MOV X29, SP
    MOV X1, X0
dtb_parse_offset_dt_struct_next_node.loop:
    LDR W0, [X1]
    BL __reverse_endianness
    CMP W0, FDT_BEGIN_NODE
    BEQ dtb_parse_offset_dt_struct_next_node.done
    ADD X1, X1, #4
    B dtb_parse_offset_dt_struct_next_node.loop
dtb_parse_offset_dt_struct_next_node.done:
    MOV X0, X1
    LDP X29, X30, [SP], #16
    RET

/* -----------------------------------------------------------------------------
uint64_t dtb_parse_dt_struct_node(
    uint64_t cursor           = X0,
    uint8_t  **node_unit_name = X1,
    uint8_t  *has_property    = W2
);

Description : Start to process the devicetree node pointed by 'cursor'. 'cursor'
is expected to point to a FDT_BEGIN_NODE node token. Return the new cursor,
which is the address to the first FDT_PROP token of the node, into X0. Return
the node unit name absolute address, which is a null-terminated byte string,
into X1. Return whether there is a new node property to be parsed into W2.

Affected registers : X0, X1, X2, X3

----------------------------------------------------------------------------- */
dtb_parse_dt_struct_node:
    STP X29, X30, [SP, #-16]!
    MOV X29, SP

    // read the node unit name
    ADD X0, X0, #4 // skip the FDT_BEGIN_TOKEN
    MOV X1, X0 // X1 = absolute address of the node unit name string
    MOV X3, #0
dtb_parse_dt_struct_node.read_node_unit_name:
    LDRB W3, [X0], #1
    CBNZ W3, dtb_parse_dt_struct_node.read_node_unit_name
    // compute the next aligned address following this formula :
    // (X0+3)&~3 where X0 is the current address, including the null-terminator
    ADD X0, X0, #3
    BIC X0, X0, #3

    MOV X3, X0
    LDR W0, [X0]
    BL __reverse_endianness
    CMP W0, FDT_PROP
    BNE dtb_parse_dt_struct_node.stop

    MOV W2, #1
dtb_parse_dt_struct_node.done:
    MOV X0, X3
    LDP X29, X30, [SP], #16
    RET
dtb_parse_dt_struct_node.stop:
    MOV W2, #0
    B dtb_parse_dt_struct_node.done

/* -----------------------------------------------------------------------------
uint64_t dtb_parse_dt_struct_node_next(
    uint64_t cursor           = X0,
    uint8_t *continue         = W1
);

Description : Seek the 'cursor' until it finds either a FDT_BEGIN_NODE token or
a FDT_END token. If the encountered token is FDT_END, that means all nodes have
been iterated through and none is remaining. Return the new cursor into X0.
Return whether a new node was found into W1.

Affected registers : X0, X1

----------------------------------------------------------------------------- */
dtb_parse_dt_struct_node_next:
    STP X29, X30, [SP, #-16]!
    MOV X29, SP
    MOV X1, X0
dtb_parse_dt_struct_node_next.loop:
    LDR W0, [X1]
    BL __reverse_endianness
    CMP W0, FDT_BEGIN_NODE
    BEQ dtb_parse_dt_struct_node_next.found_new_node
    CMP W0, FDT_END
    BEQ dtb_parse_dt_struct_node_next.no_new_node
    ADD X1, X1, #4
    B dtb_parse_dt_struct_node_next.loop
dtb_parse_dt_struct_node_next.found_new_node:
    CMP W0, FDT_BEGIN_NODE
    BNE dtb_parse_dt_struct_node_next.done
    LDR W0, [X1, #4]!
    BL __reverse_endianness
    B dtb_parse_dt_struct_node_next.found_new_node
dtb_parse_dt_struct_node_next.no_new_node:
    MOV W1, #0
    LDP X29, X30, [SP], #16
    RET
dtb_parse_dt_struct_node_next.done:
    SUB X0, X1, #4
    MOV W1, #1
    LDP X29, X30, [SP], #16
    RET


/* -----------------------------------------------------------------------------
uint64_t dtb_parse_dt_struct_node_prop(
    uint64_t cursor           = X0,
    uint32_t *prop_value_size = W1,
    uint64_t *prop_name_addr  = X2,
    uint8_t **prop_value_addr = X3
);

Description : Start to process the devicetree node pointed by 'cursor' It is
expected that the 'cursor' points to a FDT_PROP token. Return the new cursor
into X0. Return the property value size in bytes into W1. Return the property
name absolute address into X2. Return the absolute address of the property value
into X3 (as a byte string array).

Affected registers : X0, W1, X2, X3

----------------------------------------------------------------------------- */
dtb_parse_dt_struct_node_prop:
    STP X29, X30, [SP, #-32]!
    MOV X29, SP

    ADD X0, X0, #4 // skip the FDT_PROP token
    STR X0, [X29, #16]

    // read property value size in bytes
    LDR W0, [X0]
    BL __reverse_endianness
    MOV X1, #0
    MOV W1, W0 // W1 = property value size in bytes
    LDR X0, [x29, #16]
    ADD X0, X0, #4
    STR X0, [x29, #16]

    LDR W0, [X0]
    BL __reverse_endianness
    MOV X2, #0
    MOV W2, W0 // W2 = property name offset
    LDR X0, [x29, #16]
    ADD X0, X0, #4
    STR X0, [x29, #16]

    MOV X3, X0 // X3 = property value absolute address
    ADD X0, X0, X1 // seek to the end of the property value
    // compute the next aligned address following this formula :
    // (X0+3)&~3 where X0 is the end of the property value address
    ADD X0, X0, #3
    BIC X0, X0, #3
    STR X0, [x29, #16]

    BL dtb_parse_header_off_dt_strings // X0 = offset devicetree strings
    ADD X2, X2, X0 // X2 = property name offset + devicetree strings offset
    ADR X0, dtb_start
    ADD X2, X2, X0 // X2 = absolute address of property name value

    LDR X0, [X29, #16] // Restore cursor
    LDP X29, X30, [SP], #32
    RET


/* -----------------------------------------------------------------------------
uint64_t dtb_parse_dt_struct_node_prop_next(
    uint64_t cursor   = X0,
    uint8_t *continue = W1
);

Description : Seek the 'cursor' until it finds either a FDT_PROP, FDT_END_NODE,
FDT_BEGIN_NODE or FDT_END token. If the encountered token is FDT_END_NODE, that
means all properties for this node have been discovered. If the encountered
token is FDT_BEGIN_NODE, this means the cursor points to a sub-node of this node
and the dtb_parse_dt_struct_node should be use dtb_parse_dt_struct_node_prop. If
the encountered token is FDT_END, this means all nodes have been discovered.
Return the new cursor into X0. Return whether a new node property was found into
W1.

Affected registers : X0, X1, X2

----------------------------------------------------------------------------- */
dtb_parse_dt_struct_node_prop_next:
    STP X29, X30, [SP, #-16]!
    MOV X29, SP
    MOV X1, X0
dtb_parse_dt_struct_node_prop_next.loop:
    LDR W0, [X1]
    BL __reverse_endianness
    CMP W0, FDT_PROP
    BEQ dtb_parse_dt_struct_node_prop_next.found_new_node_prop
    CMP W0, FDT_END_NODE
    BEQ dtb_parse_dt_struct_node_prop_next.no_new_node_prop
    CMP W0, FDT_END
    BEQ dtb_parse_dt_struct_node_prop_next.no_new_node_prop
    CMP W0, FDT_BEGIN_NODE
    BEQ dtb_parse_dt_struct_node_prop_next.no_new_node_prop
    ADD X1, X1, #4
    B dtb_parse_dt_struct_node_prop_next.loop
dtb_parse_dt_struct_node_prop_next.found_new_node_prop:
    MOV X0, X1
    MOV W1, #1
    B dtb_parse_dt_struct_node_prop_next.done
dtb_parse_dt_struct_node_prop_next.no_new_node_prop:
    MOV X0, X1
    MOV W1, #0
dtb_parse_dt_struct_node_prop_next.done:
    LDP X29, X30, [SP], #16
    RET

/* -----------------------------------------------------------------------------
uint64_t dtb_find_dt_struct_node(
    uint8_t *node_unit_name    = X0,
    uint8_t node_unit_name_len = X1
);

Description : Parse the whole devicetree blob to find the node by its name. The
'node_unit_name' value shall not include the address of the unit as only the
names will be matched. 'node_unit_name_len' shall not exceed 32, as per the
standard. If no node matching the name was found, #0 is returned. Return the
pointer to the beginning of the node into X0.

Affected registers : X0, X1, X2, X3, W4, X5

----------------------------------------------------------------------------- */
dtb_find_dt_struct_node:
    STP X29, X30, [SP, #-48]!
    MOV X29, SP
    STR X0, [X29, #16]  // node_unit_name
    STR X1, [X29, #24]  // node_unit_name_len
    BL dtb_parse_offset_dt_struct

dtb_find_dt_struct_node.iterate_through_node:
    STR X0, [X29, #40]  // cursor to the beginning of the node
    BL dtb_parse_dt_struct_node
    MOV W5, W2 // whether there is a node property to parse
    STR X0, [X29, #32]  // cursor to the first property of the node
    LDR X0, [X29, #16]  // node_unit_name
    LDR X2, [X29, #24]  // node_unit_name_len
    BL strncmp
    CBZ W0, dtb_find_dt_struct_node.node_found
    LDR X0, [X29, #32]  // cursor to the first property of the node
    CBNZ W5, dtb_find_dt_struct_node.iterate_through_prop
dtb_find_dt_struct_node.continue:
    BL dtb_parse_dt_struct_node_next
    CBNZ W1, dtb_find_dt_struct_node.iterate_through_node
dtb_find_dt_struct_node.node_not_found:
    MOV X0, #0
    B dtb_find_dt_struct_node.done
dtb_find_dt_struct_node.node_found:
    LDR X0, [X29, #40]  // cursor to the beginning of the node
dtb_find_dt_struct_node.done:
    LDP X29, X30, [SP], #48
    RET
dtb_find_dt_struct_node.iterate_through_prop:
    BL dtb_parse_dt_struct_node_prop
    BL dtb_parse_dt_struct_node_prop_next
    CBNZ W1, dtb_find_dt_struct_node.iterate_through_prop
    B dtb_find_dt_struct_node.continue

/* -----------------------------------------------------------------------------
uint64_t dtb_find_dt_struct_node_prop(
    uint64_t cursor               = X0,
    uint8_t *property_name        = X1,
    uint8_t *property_found       = W2,
    uint32_t *property_value_size = W3,
    uint8_t **property_value      = X4
);

Description : Parse the whole devicetree blob node to find the matching property
'property_name' (null-terminated string). The 'cursor' is expected to point to
the FDT_BEGIN_NODE token of the node to explore. If the FDT_END_NODE token is
found, the function returns. When the function returns, the 'cursor' is restored
to its original base, which is the FDT_BEGIN_NODE token. 'property_found' is a
boolean value which is set to 1 if the property is found, 0 otherwise. The
'property_name' (X1) will be overwritten. Return the original 'cursor' into X0.
Return whether the property was found into W2. Return the found property value
size into W3. Return the absolute address of property value into X4.

Affected registers : X0, X1, X2, X3, W4, X5

----------------------------------------------------------------------------- */
dtb_find_dt_struct_node_prop:
    STP X29, X30, [SP, #-64]!
    MOV X29, SP
    STR X0, [X29, #16]  // initial cursor, points to the beginning of the node
    STR X0, [X29, #24]  // current cursor, used to iterate through properties
    STR X1, [X29, #32]  // property name to retrieve

    BL dtb_parse_dt_struct_node
    CBZ W2, dtb_find_dt_struct_node_prop.prop_not_found
dtb_find_dt_struct_node_prop.iterate_through_prop:
    BL dtb_parse_dt_struct_node_prop
    STR X0, [X29, #24] // seeked cursor, points to the next FDT_PROP token
    STR W1, [X29, #40] // property value size
    STR X3, [X29, #48] // property value absolute address
    MOV X0, X2
    LDR X1, [X29, #32] // property name to find
    BL strcmp
    CBZ W0, dtb_find_dt_struct_node_prop.prop_found
    LDR X0, [X29, #24] // restore new cursor to iterate more
    BL dtb_parse_dt_struct_node_prop_next
    CBNZ W1, dtb_find_dt_struct_node_prop.iterate_through_prop
dtb_find_dt_struct_node_prop.prop_not_found:
    MOV W2, #0
    LDR X1, [X29, #32] // property_name
    MOV W3, #0
    MOV X4, #0
    B dtb_find_dt_struct_node_prop.done
dtb_find_dt_struct_node_prop.prop_found:
    MOV W2, #1
    LDR X1, [X29, #32] // property_name
    LDR W3, [X29, #40] // property value size
    LDR X4, [X29, #48] // property value absolute address
dtb_find_dt_struct_node_prop.done:
    LDR X0, [X29, #16]  // original cursor
    LDP X29, X30, [SP], #64
    RET


/* -----------------------------------------------------------------------------
uint64_t dtb_find_dt_struct_node_by_phandle(
    uint32_t phandle = W0,
    uint8_t *found   = W1
);

Description : Parse the whole devicetree blob to find the node by its phandle.
Return the pointer to the beginning of the node into X0. Return whether a node
matching the given phandle has been found into W1.

Affected registers : X0, X1, X2, X3, W4, X5

----------------------------------------------------------------------------- */
dtb_find_dt_struct_node_by_phandle:
    STP X29, X30, [SP, #-48]!
    MOV X29, SP
    STR W0, [X29, #16]  // phandle
    BL dtb_parse_offset_dt_struct

dtb_find_dt_struct_node_by_phandle.iterate_through_node:
    STR X0, [X29, #24]  // cursor to the beginning of the node
    BL dtb_parse_dt_struct_node
    CBNZ W2, dtb_find_dt_struct_node_by_phandle.iterate_through_prop
dtb_find_dt_struct_node_by_phandle.continue:
    BL dtb_parse_dt_struct_node_next
    CBNZ W1, dtb_find_dt_struct_node_by_phandle.iterate_through_node
dtb_find_dt_struct_node_by_phandle.done:
    LDP X29, X30, [SP], #48
    RET
dtb_find_dt_struct_node_by_phandle.node_found:
    LDR X0, [X29, #24]  // cursor to the beginning of the node
    MOV W1, #1
    B dtb_find_dt_struct_node_by_phandle.done
dtb_find_dt_struct_node_by_phandle.iterate_through_prop:
    BL dtb_parse_dt_struct_node_prop
    STR X0, [X29, #32] // save cursor to the end of the property
    STR X3, [X29, #40] // save pointer to the property value
    MOV X0, X2
    ADR X1, PROP_PHANDLE_NAME
    BL strcmp
    CBZ W0, dtb_find_dt_struct_node_by_phandle.compare_phandle_value
dtb_find_dt_struct_node_by_phandle.phandle_no_match:
    LDR X0, [X29, #32] // restore cursor to the end of the property
    BL dtb_parse_dt_struct_node_prop_next
    CBNZ W1, dtb_find_dt_struct_node_by_phandle.iterate_through_prop
    B dtb_find_dt_struct_node_by_phandle.continue
dtb_find_dt_struct_node_by_phandle.compare_phandle_value:
    LDR X3, [X29, #40] // restore the pointer ot the property value
    LDR W0, [X29, #16] // retore the expected value for phandle
    LDR W3, [X3] // read the value from the pointed address
    CMP W0, W3
    BEQ dtb_find_dt_struct_node_by_phandle.node_found
    B dtb_find_dt_struct_node_by_phandle.phandle_no_match

.section .rodata
.equ FDT_BEGIN_NODE, 0x00000001
.equ FDT_END_NODE, 0x00000002
.equ FDT_PROP, 0x00000003
.equ FDT_NOP, 0x00000004
.equ FDT_END, 0x00000009
PROP_PHANDLE_NAME: .asciz "phandle"
