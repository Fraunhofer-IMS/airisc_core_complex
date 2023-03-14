[![AIRISC](https://raw.githubusercontent.com/Fraunhofer-IMS/airisc_core_complex/main/doc/gfx/logo-airisc.png)](https://github.com/Fraunhofer-IMS/airisc_core_complex)

# AIRISC - The RISC-V Processor for Embedded AI

[![Fraunhofer_IMS](https://img.shields.io/badge/Fraunhofer-IMS-179c7d.svg?longCache=true&style=flat-square&logo=fraunhofergesellschaft&logoColor=179c7d)](https://www.ims.fraunhofer.de/en.html)
[![GitHub Pages](https://img.shields.io/website.svg?label=Documentation%20@%20GitHub%20Pages&longCache=true&style=flat-square&url=http%3A%2F%2Ffraunhofer-ims.github.io%2Fairisc_core_complex%2Findex.html&logo=GitHub)](https://fraunhofer-ims.github.io/airisc_core_complex/index.html)
[![airisc-sim_check](https://img.shields.io/github/actions/workflow/status/Fraunhofer-IMS/airisc_core_complex/main.yml?branch=main&longCache=true&style=flat-square&label=airisc-sim&logo=Github%20Actions&logoColor=fff)](https://github.com/Fraunhofer-IMS/airisc_core_complex/actions/workflows/main.yml)
[![sw_build](https://img.shields.io/github/actions/workflow/status/Fraunhofer-IMS/airisc_core_complex/sw_build.yml?branch=main&longCache=true&style=flat-square&label=SW-Build&logo=Github%20Actions&logoColor=fff)](https://github.com/Fraunhofer-IMS/airisc_core_complex/actions/workflows/sw_build.yml)

The Fraunhofer IMS **AIRISC** is a RISC-V-powered ASIC- and FPGA-proven processor core optimized for embedded AI
applications. It comes with a set of common peripherals together with a wide variety of optional extensions to build
a customizable yet powerful system on chip (SoC).

- [Overview](#Overview)
  - [Development](#Development)
  - [Additional Modules and Extensions](#Additional-Modules-and-Extensions)
  - [AIfES Integration](#AIfES-Integration)
- [**Quickstart**](#Quickstart)
- [Contact](#Contact)
- [External Dependencies](#External-Dependencies)


## Overview

[![RISC-V](https://raw.githubusercontent.com/Fraunhofer-IMS/airisc_core_complex/main/doc/gfx/riscv_logo_small.png)](https://riscv.org/)

[![MARCHID](https://img.shields.io/badge/RISC--V%20Architecture%20ID-31-000000.svg?longCache=true&style=flat-square&colorA=273274&colorB=fbb517)](https://github.com/riscv/riscv-isa-manual/blob/master/marchid.md)

The AIRISC Core Complex is based on a 32-bit RISC-V CPU compatible to the
[RISC-V unprivileged and privileged specifications](https://riscv.org/technical/specifications/) also supporting
the [RISC-V External Debug specification](https://riscv.org/wp-content/uploads/2019/03/riscv-debug-release.pdf).
The CPU implements a Harvard architecture with a four-level pipeline and separate AHB-Lite interfaces for instruction fetch
and data access. The core's `RV32I_Zicsr` base ISA can be further extended via a unified co-processor interface (PCPI).
The default setup already includes a co-processor for integer multiplication and division operations implementing
the RISC-V `M` ISA extension.

In addition to the CPU core itself, the AIRISC Core Complex includes common peripherals to build a complete SoC.
These include a RISC-V-compatible system timer (**MTIME**), a serial **UART** interface with optional FIFO buffers,
a **SPI** controller also with configurable FIFO buffers and acting either as host device or as peripheral,
general-purpose IO ports (**GPIO**) and a RISC-V-compatible
**on-chip debugger** that provides a JTAG interface to debug the core online and _in-system_.

The provided SoC is ready for an implementation on a
[Digilent Nexys Video](https://digilent.com/reference/programmable-logic/nexys-video/start)
FPGA board and can be easily ported to other boards, platforms and technologies as the core itself is written in
vendor-agnostic plain **Verilog**. The Fraunhofer IMS AIRISC is also part of
[Intel Pathfinder for RISC-V](https://pathfinder.intel.com/) providing a full-scale RISC-V
evaluation platform.

:bulb: For more information check out the
[AIRISC fact sheet (PDF)](https://www.ims.fraunhofer.de/content/dam/ims/en/documents/2022-10-20%20Info%20Sheet_AIRISC%20-%20Family%20of%20RISC-V%20Cores_DINA4_Digtale%20Version.pdf)
or have a look at the [online documentation](https://fraunhofer-ims.github.io/airisc_core_complex/index.html).

### Development

The project is developed primarily in a closed-source organization-internal repository to take advantage of
sophisticated continuous integration stages that require licensed EDA tools. New releases with novel features and overall
improvements will be uploaded frequently to this repository under the permissive
[Solderpad license](https://github.com/Fraunhofer-IMS/airisc_core_complex/blob/main/LICENSE).
All releases include a pre-compiled FPGA [bitstream](https://github.com/Fraunhofer-IMS/airisc_core_complex/tree/main/fpga/sdcard)
as well as a pre-compiled _"hello world!"_ [application program](https://github.com/Fraunhofer-IMS/airisc_core_complex/tree/main/sw)
to get started immediately.

:loudspeaker: **Feedback from the community is always highly appreciated!** Feel free to open a new
[issue](https://github.com/Fraunhofer-IMS/airisc_core_complex/issues)
or get in [contact](#Contact) directly if you have questions, requests, ideas or any kind of problems with the provided project.

### Additional Modules and Extensions

Files for ASIC synthesis, additional and advanced peripherals as well as area/energy/performance-optimized core configurations can
be obtained from Fraunhofer IMS under a _less permissive license_. See the [Contact](#Contact)
section for more information how to get in touch. Some of the additional features are listed below:

- RISC-V `C` extension - 16-bit compressed instructions for improved code density
- RISC-V `F` extension - IEEE754 single-precision floating-point unit
- Fraunhofer IMS **_AI_** extensions based on SIMD processor module (RISC-V `P` extension) and co-processors for computing activation functions
- QSPI interface; also providing _Execute-In-Place_ (XIP)
- On-chip _Physical Unclonable Function_ ("PUF") for advanced security functions
- AXI-compatible bus interface to interface with off-the-shelve IP components
- A **safety** version of the AIRISC prepared for ISO 26262 ASIL-D certification extended with multiple additional safety features
- A **security** version of the AIRISC equipped with hardware features for encryption and decryption, secure boot and update mechanisms
- _more to come!_ :rocket:

### AIfES Integration

[![AIfES](https://raw.githubusercontent.com/Fraunhofer-IMS/airisc_core_complex/main/doc/gfx/logo_aifes.png)](https://www.ims.fraunhofer.de/en/Business-Unit/Industry/Industrial-AI/Artificial-Intelligence-for-Embedded-Systems-AIfES.html)

The Fraunhofer **AIfES** machine learning library integrates seamlessly into the AIRISC processor, which allows
fast and easy development of on-the-edge AI applications such as inference of neuronal networks. In additions to
the software-only AIfES libraries, Fraunhofer IMS also provides additional ISA extensions and dedicated co-processors
to improve throughput resulting in optimized performance at a minimal energy budget. Hence, the combination of the
AIfES libraries and the dedicated hardware accelerators (some examples are shown in section
[Additional Modules and Extensions](#Additional-Modules-and-Extensions)) make the AIRISC a well-suited platform for
embedded AI applications.


## Quickstart

This section provides instructions to get you started:

- Synthesize the core complex for a specific FPGA board.
- Run the pre-compiled example application program using openOCD and GDB.
- Run a simulation using the default testbench, which checks the ISA for RISC-V-compatibility as well as the general core functionality.

:bulb: See the project's [**Quickstart Guide**](https://github.com/Fraunhofer-IMS/airisc_core_complex/blob/main/doc/Quickstart.txt)
for step-by-step instructions on how to program the FPGA board and how to run a GDB session executing the provided
example application program.

### Synthesis

Requirements for (re-)building the hardware and programming the (pre-build) bitstream:

- Xilinx Vivado: [2020.2 WebPack](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive.html) (for generating and programming the bitstream)
- Xilinx Vivado: [2020.2 LabEdition](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive.html) (for programming the pre-compiled bitstream only)
- FPGA board: [Digilent Nexys Video](https://digilent.com/reference/programmable-logic/nexys-video/start) or
[Digilent Arty A7](https://digilent.com/reference/programmable-logic/arty-a7/start)

The [`fpga`](https://github.com/Fraunhofer-IMS/airisc_core_complex/tree/main/fpga) folder provides pre-configured TCL scripts
to automatically generate a Xilinx Vivado project and to program the bitstream to the FPGA. See the project's
[online documentation](https://fraunhofer-ims.github.io/airisc_core_complex/index.html) for more information on how to setup a
AIRISC Xilinx Vivado project from scratch.

:bulb: Prebuilt bitstreams for the supported boards can be found in
[`fpga/sdcard`](https://github.com/Fraunhofer-IMS/airisc_core_complex/tree/main/fpga/sdcard).

#### Exemplary Synthesis Results

* FPGA: Xilinx Artix-7 `xc7a200tsbg484-1`
* Board: Digilent Nexys Video
* Results generated on Dec. 19th, 2022

| Name | Slice LUTs | Slice Registers | DSPs |
|:-----|-----------:|----------------:|-----:|
| FPGA_Top                                | 8476 | 4236 | 4 |
| > clkgen (clk_wiz_0)                    |    0 |    0 | 0 |
| > DUT (airi5c_top_asic)                 | 6650 | 4167 | 4 |
| >> airi5c (airi5c_core)                 | 4351 | 2612 | 4 |
| >>> debug_module (airi5c_debug_module)  |  168 |  214 | 0 |
| >>> debug_rom (airi5c_debug_rom)        |   20 |   75 | 0 |
| >>> mul_div (airi5c_mul_div)            |  581 |  337 | 4 |
| >>> pipeline (airi5c_pipeline)          | 2963 | 1984 | 0 |
| >>>> csr (airi5c_csr_file)              |  394 |  425 | 0 |
| >>>> ctrl (airi5c_ctrl)                 |  114 |   24 | 0 |
| >>>> decoder (airi5c_decode)            |   52 |   65 | 0 |
| >>>> EX_pipeline_regs (airi5c_EX_pregs) | 1049 |  107 | 0 |
| >>>> fetcher (airi5c_fetch)             |  283 |  119 | 0 |
| >>>> imm_gen (airi5c_imm_gen)           |    3 |    0 | 0 |
| >>>> regfile (airi5c_regfile)           |  834 | 1024 | 0 |
| >>>> src_a_mux (airi5c_src_a_mux)       |   64 |    0 | 0 |
| >>>> the_dmem_latch (airi5c_dmem_latch) |   16 |   32 | 0 |
| >>>> WB_pipeline_regs (airi5c_WB_pregs) |  155 |  188 | 0 |
| >> dtm (airi5c_dtm)                     |   86 |  178 | 0 |
| >> gpio0 (airi5c_gpio)                  |   43 |   33 | 0 |
| >> icap1 (airi5c_icap)                  |    0 |    2 | 0 |
| >> peripheral_mux (airi5c_periph_mux)   |  110 |   24 | 0 |
| >> spi0 (airi5c_spi)                    |  267 |  336 | 0 |
| >> system_timer (airi5c_timer)          |  131 |  163 | 0 |
| >> uart0 (airi5c_uart)                  | 1664 |  819 | 0 |
| > SRAM (blk_mem_gen_0)                  | 1819 |   44 | 0 |

#### CoreMark Benchmark

Coremark result @32 MHz on the NexysVideo FPGA Dev Board with local BlockRAM as instruction memory:

```
2K performance run parameters for coremark.
  CoreMark Size    : 666
  Total ticks      : 7794
  Total time (secs): 15
  Iterations/Sec   : 80
  Iterations       : 1200
  Compiler version : GCC10.1.0
  Compiler flags   : -o3 
  Memory location  : STACK
  seedcrc          : 0xe9f5
  [0]crclist       : 0xe714
  [0]crcmatrix     : 0x1fd7
  [0]crcstate      : 0x8e3a
  [0]crcfinal      : 0x988c
  Correct operation validated. See README.md for run and reporting rules.
```

### Application

Requirements for running the _hello world_ example program:

- OpenOCD: [risc-v openOCD](https://github.com/riscv/riscv-openocd) (upstream version)
- GDB: [risc32-unknown-elf-gdb](https://github.com/riscv/riscv-gnu-toolchain) 9.1
- Serial terminal like [Picocom](https://github.com/npat-efault/picocom)

Requirements for (re-)building the software example (_optional_):

- [RISC-V GCC Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)

:bulb: A pre-compiled version (`*.elf`; including debug symbols) of the example/demo program can be found in
[`bsp/example`](https://github.com/Fraunhofer-IMS/airisc_core_complex/tree/main/bsp/example).

### Simulation / CI

The [`.ci`](https://github.com/Fraunhofer-IMS/airisc_core_complex/tree/main/.ci) ("continuous integration") folder is used
to check the core's functionality when modifying project sources. A [GitHub workflow](https://github.com/Fraunhofer-IMS/airisc_core_complex/actions/workflows/main.yml)
is configured to run a simulation of the [default testbench](https://github.com/Fraunhofer-IMS/airisc_core_complex/blob/main/tb/airi5c_top_tb.v)
using the _free and open-source_ [Icarus Verilog](https://github.com/steveicarus/iverilog) simulator.

Requirements for running the (CI) simulation:

- [Icarus Verilog](http://iverilog.icarus.com/)

You can run the simulation by yourself using the provided script:

```bash
airisc_core_complex/.ci$ sh iverilog_sim.sh
```


## Contact

Fraunhofer Institute for Microelectronic Circuits and Systems, Duisburg, Germany

- Homepage: [ims.fraunhofer.de/en.html](https://www.ims.fraunhofer.de/en.html)
- Project maintainer: [Alexander Utz](mailto:alexander.utz@ims.fraunhofer.de)
- Contact for questions regarding license and exploitation: [AIRISC-support](mailto:airisc@ims.fraunhofer.de)


## External Dependencies

The `*.mem` files in `tb/memfiles` are used to test/verify the core for RISC-V ISA compliance were pre-compiled by us.
The source files were obtained from the official RISC-V
[riscv-software-src/riscv-tests](https://github.com/riscv-software-src/riscv-tests) GitHub repository (see the
repository's [license](https://github.com/riscv-software-src/riscv-tests/blob/master/LICENSE)).
