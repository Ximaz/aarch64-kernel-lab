# AArch64 Kernel Lab

Through this project, I'm learning what is kernel development as well as the
ARMv8 instruction set architecture.

## Toolchain

To build this project, you will need a few tools. I'm working on MacOS, so I
only know the tooling for my workflow, but here is what is being used :

```bash
brew install qemu # for kernel emulation
brew install llvm # for kernel building
brew install aarch64-elf-gcc aarch64-elf-binutils # cross toolchain
brew install lldb # gdb but for MacOS, avoids Code Signature errors
```

## Building

You may build the kernel using the following command :

```bash
make kernel8.img
```

And you should be able to debug the image using the next command :
```bash
make debug
```

This will cause QEMU to run the kernel. On another terminal, you then can start
`lldb` as following :

```bash
$ lldb
(lldb) file ./kernel8.elf # target the kernel for debugging
(lldb) gdb-remote localhost:1234 # connect to the QEMU gdb server
(lldb) breakpoint _start
(lldb) continue
```

## Credits

Here is the list of resources I'm learning from to build this project :
- hands-on lab : https://grasslab.github.io/osdi/en/labs/lab0.html
- hands-on lab (remake ?) : https://oscapstone.github.io/labs/lab1.html
- ARMv8 Base Instructions : https://developer.arm.com/documentation/ddi0602/2025-12/Base-Instructions
- ARMv8 System Registers : https://developer.arm.com/documentation/102374/0103/Registers-in-AArch64---system-registers
- mini UART setup on RasPI3b : https://oscapstone.github.io/labs/hardware/uart.html

I will try to keep this list as updated as possible.
