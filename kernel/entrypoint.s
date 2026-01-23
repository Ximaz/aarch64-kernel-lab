.section .text
.extern boot

.global _start
_start:
    MRS X0, MPIDR_EL1
    TBNZ X0, #30, boot // Unique processor system
    AND X0, X0, #0xFF // Get Affinity 0
    CBZ X0, boot // If core ID is zero, continue to boot

    LDR X0, =PSCI_CPU_OFF
    SMC #0

.wait:
    WFI
    B .

.section .rodata
PSCI_CPU_OFF = 0x84000002
