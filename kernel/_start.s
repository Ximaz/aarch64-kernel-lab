.section .text

.extern bootloader

.extern bss_start
.extern bss_end

.extern stack_bottom
.extern stack_top

.extern memset

.global _start
_start:
    MRS X0, MPIDR_EL1
    TBNZ X0, #30, _start.preboot // Unique processor system
    AND X0, X0, #0xFF            // Get Affinity 0
    CBZ X0, _start.preboot       // If core ID is zero, continue to boot

    LDR X0, =PSCI_CPU_OFF
    SMC #0
_start.wait:
    WFI
    B _start.wait
_start.preboot:
    // Clear stack
    LDR X0, =stack_bottom
    LDR X2, =stack_top
    SUB X2, X2, X0
    MOV W1, #0
    BL memset
    LDR X0, =stack_top
    MOV SP, X0

    // Clear bss section
    LDR X0, =bss_start
    LDR X2, =bss_end
    SUB X2, X2, X0
    MOV W1, #0
    BL memset

    B bootloader

.section .rodata

.equ PSCI_CPU_OFF, 0x84000002
