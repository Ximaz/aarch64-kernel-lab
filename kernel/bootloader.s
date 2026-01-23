.section .text

.extern get_uartclk_config

.global bootloader
bootloader:
    STP X29, X30, [SP, #-32]!
    MOV X29, SP

    BL get_uartclk_config
    STR X0, [X29, #16] // store the uart clock frequency (in Hz)
    STR X1, [X29, #24] // store the pl011 base address

    LDP X29, X30, [SP], #32
    B bootloader
