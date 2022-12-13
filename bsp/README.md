# AIRISC Board Support Package (BSP)

This folder includes everything you need to convert a high-level C/C++ program into
an AIRISC executable.

- [Folder Structure](#Folder-Structure)
- [How to Use](#How-to-Use)
- [CPU Boot](#CPU-Boot)
- [Executable Layout](#Executable-Layout)


## Folder Structure

- `.gitignore`: ignore build artifacts (like object files)
- `common`: linker script, start-up code, main application makefile
- `debugger`: on-chip-debugger: openOCD configuration scripts, GDB helper scripts
- `example`: simple example SW project including a Makefile
- `include`: CPU core and peripheral headers (HAL)
- `source`: CPU core and peripheral sources (HAL)


## Example Program

The `example` folder provides a simple demo program. Run `make` to see the help menu of the
Makefile. This will show all available targets as well as all variables that can be customized.

To generate an ELF file (ready for upload via GDB) run:

```bash
airi5c-base-core/bsp/example$ make clean_all elf
Memory utilization:
   text	   data	    bss	    dec	    hex	filename
  13756	   2108	     64	  15928	   3e38	main.elf
```

This is what the example project directory looks like after compilation:

```bash
airi5c-base-core/bsp/example$ ll
total 256
-rwxrwxrwx. 1 nolting r_1842684567   3517 Nov  9 13:00 main.c
-rwxrwxrwx. 1 nolting r_1842684567 127020 Nov  9 15:29 main.c.o
-rwxrwxrwx. 1 nolting r_1842684567 116416 Nov  9 15:29 main.elf
-rwxrwxrwx. 1 nolting r_1842684567     64 Nov  8 13:52 Makefile
```

## How to Use

Include this repository (the AIRISC base core) as submodule into your software-only
project. :warning: Make sure to keep this submodule updated as the board support package
is maintained (only!) in the AIRISC core repository!

In your main source file (and in other files if needed) you just need to include the main AIRISC
library header, which will automatically include all further AIRISC header files:

```c
#include <airisc.h>
```

### Using Makefile

Copy and rename the `example` folder and use _that_ for your project. Adjust the default
project-local `Makefile` to include additional source files and headers.

Show help screen and list makefile variables:

```bash
airi5c-base-core/bsp/example$ make help
AIRISC Software Application Makefile

=== Targets ===
 help      - Show this text
 check     - Check RISC-V GCC toolchain

...
```

Check the installed RISC-V GCC toolchain:

```bash
airi5c-base-core/bsp/example$ make check
---------------- Check: Shell ----------------
/bin/sh
/usr/bin/bash
---------------- Check: riscv32-unknown-elf-gcc ----------------
Using built-in specs.
COLLECT_GCC=riscv32-unknown-elf-gcc
COLLECT_LTO_WRAPPER=/sw/lx_sw/lxcad/xgcc/rv32multi/bin/../libexec/gcc/riscv32-unknown-elf/10.2.0/lto-wrapper
Target: riscv32-unknown-elf

...
```

Check the makefile configuration (flags and variables):

```bash
airi5c-base-core/bsp/example$ make info
---------------- Info: Project ----------------
Project folder:        example
Source files:          ./main.c
Include folder(s):     -I .
ASM include folder(s): -I .
---------------- Info: AIRISC ----------------
AIRISC home folder (AIRISC_HOME): ../..

...
```

:bulb: **TIP** You can override the Makefile variables during invokation of _make_. Example: `make EFFORT=-O3 clean_all elf`

### Using an IDE

Add the submodule's `include`, `source` and `common` folder to your project. Copy the
GCC toolchain configuration (i.e. compiler flags) from the central makefile (`common/common.mk`).


## CPU Boot

The CPU start-up code `common/crt0.S` is responsible for initializing the CPU itself and for
preparing the C runtime environment.

* setup stack pointer and global pointer according to linker script smybols
* initialize all relevant CSRs 
  * setup trap vector (first-level trap handler defined in `airisc.c`)
  * disable interrupts globally
  * reset cycle counter `mcycle` and instructions-retired counter `minstret`
* clear all MTIME timer registers (reset system time)
* initialize all integer registers to zero (only register 1..15 if `E` ISA extension is enabled)
* clear `.bss` section (defined by linker script)
* call applications's `main` function; `argc` = `argv` = 0
* if `main` function returns:
  * disable interrupts globally
  * copy `main`'s return value to `mscratch` (for inspection via debugger)
  * (try to) enter sleep mode executing `wfi`
  * stall in an endless loop

## Executable Layout

Coming soon.
