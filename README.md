# AIRISC Base Core
Fraunhofer IMS processor core. RISC-V ISA (RV32IM) with additional periperals. FPGA implementation for [Digilent Nexys Video](https://digilent.com/reference/programmable-logic/nexys-video/start).

## Table of Contents
- [Overview](#overview)
  - [Releases](#releases)
  - [Contact](#contact)
  - [License](#license)
  - [Exploitation](#exploitation)
- [User Guide](#user-guide)
- [Feedback](#feedback)
- [Development](#development)

## Overview
The AIRISC Core Complex implements the [RISC-V specification](https://riscv.org/technical/specifications/) in a 32-bit Harvard architecture with an four-level pipeline and separate AHB-Lite interface for the instruction and data bus. RV32I is used as the base ISA. Extensions to the ISA can be added via a coprocessor interface (PCPI). Standard extensions available are a hardware MUL/DIV/REM (RV32M).

In addition to the core the AIRISC Core Complex includes basic peripheral units to build a basic system on chip: MTIME-compatible timer, UART, SPI, GPIO as well as JTAG debug transport module according to the External Debug Support Specification

### Releases
- New releases with more features and improvements will be uploaded in this repository under the Solderpad license.  
Support for the F and C extensions will be added soon.
- Releases include an pre-compiled hardware as bitfile and a hello world program.

### Contact
- Maintainer: [Carsten Rolfes - Fraunhofer IMS](mailto:carsten.rolfes@ims.fraunhofer.de) 
- Contact for questions regarding license and exploitation: [AIRISC-support](mailto:airisc@ims.fraunhofer.de)

### License
- Solderpad Hardware License v2.1 maintained by [FOSSi Foundation](http://solderpad.org/)

### Exploitation
- Files for ASIC synthesis, more periperals and performance improvements can be obtained from Fraunhofer IMS under a less permissive license.

### Additional Modules and ISA extensions
- C-extension 
- F-Extension
- AI extensions based on SIMD-support (P-extension) and coprocessors for the calculation of activation functions
- QSPI
- On-Chip Physical Unclonable Function
- AXI Bus Interface
- A safety version of the AIRISC prepared for ISO 26262 ASIL-D certification extended with multiple additional safety features
- A security version of the AIRISC equipped with hardware features for encryption and decryption, secure boot and -update mechanisms


## User Guide
- Quickstart for Vivado and the Digilent Nexys Video FPGA board

Please see the [Quickstart.txt](./doc/Quickstart.txt) in the /doc directory.

For more details see the UserGuide in the /doc directory.

Online documentation: _**tdb. Link to pages**_

-------------------------------------------------------------

If you want to build the hardware design
- Xilinx Vivado: [2020.2 WebPack](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive.html)

If you want to run the precompiled hardware bitstream and hello world program 
- Xilinx Vivado: [2020.2 LabEdition](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive.html)
- OpenOCD: [risc-v openocd](https://github.com/riscv/riscv-openocd) 0.10.0+dev-01259-gfb477376d
- GDB: [risc32-unknown-elf-gdb](https://github.com/riscv/riscv-gnu-toolchain) 9.1
- Terminal:  e.g. [Picocom](https://github.com/npat-efault/picocom) v3.2a 

## Feedback
- We are happy if you share your expirience and provide feedback. Please send a mail to the maintainer listed in the [contact](#contact) section
- You can also request new features for the open source version or report problems by using the Gitlab issues feature.

## Development
- The project is primarily developed in a private Fraunhofer IMS repository to take advantage of all CI stages that need licensed EDA tools.
