//
// Copyright 2022 FRAUNHOFER INSTITUTE OF MICROELECTRONIC CIRCUITS AND SYSTEMS (IMS), DUISBURG, GERMANY.
// --- All rights reserved --- 
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
// Licensed under the Solderpad Hardware License v 2.1 (the “License”);
// you may not use this file except in compliance with the License, or, at your option, the Apache License version 2.0.
// You may obtain a copy of the License at
// https://solderpad.org/licenses/SHL-2.1/
// Unless required by applicable law or agreed to in writing, any work distributed under the License is distributed on an “AS IS” BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and limitations under the License.
//
//
// File             : airi5c_arch_options.vh
// Author           : A. Stanitzki, I. Hoyer 
// Creation Date    : 09.10.20
// Last Modified    : 15.02.21
// Version          : 1.0
// Abstract         : This is the central configuration file to select/deselect 
//                    features in the core and to set identification properties.
// Notes            : All fields are checked by the debugger, 
//                    so the expected values in the OpenOCD 
//                    target scripts have to match these ID codes.
//

//Supress dolphin warnings 
// Standard is defined, to avoid unneccessary warnings between ISA Tests. 
`ifdef CONFIG_DOLPHIN_SRAM
`define   SUPR_DOLPHIN
//`undef    SUPR_DOLPHIN
`endif

// System clock speed (in MHz)    - used to derive some timings, e.g. for UART

`define SYS_CLK_HZ 32'd32000000


// =======================
// = Core Identification =
// =======================

// official JEDEC vendor ID (if obtained)

`define VENDOR_ID 32'h00000000

// Implementation ID
// differentiates between versions of the same 
// architecture.

`define IMPL_ID   32'h00008000

// Hardware Threat (HART) ID
// only ID 0x00 is present in a single-core system. 
// For multi-core/multi-threads, the cores/threads are 
// enumerated by this field and the ID has to be set 
// for each HART/Core.

`define HART_ID   32'h00000000


// ===================================
// = Select supported ISA Extensions =
// ===================================

// ISA Extension "E" - reduced instruction set
// ===========================================
//
// This option enables the E extension, which reduces the number
// of GPRs to 16 and removes the rdcycle[h], rdtime[h] and rdinstret[h] 
// instructions and CSR registers.

// Default = undefined (full register set)

`undef ISA_EXT_E
//`define ISA_EXT_E

// ISA Extension "F" - single precision float
// ===========================================
//
// This option enables the F extension, which provides hardware 
// support for single precision floating point.

// Default = undefined (no hardware floats)

`undef ISA_EXT_F
//`define ISA_EXT_F

// ISA Extension "C" - compressed instructions
// ===========================================
//
// This option enables the C extension, which 
// adds support for 16 bit compressed instructions
// reduceing code size by ~30%.

// Default = defined (compressed instructions supported)

//`undef ISA_EXT_C
`define ISA_EXT_C

// ISA Extension "M" - hardware MUL/DIV/REM
// ========================================
//
// This option enables the M extension, which adds hardware
// support for MUL/DIV/REM 

// Default = defined (hardware MUL enabled)

//`undef ISA_EXT_M
`define ISA_EXT_M

// ISA Extension "P" - DSP/SIMD extension
// ========================================
//

// Default = undefined

`undef ISA_EXT_P
//`define ISA_EXT_P


// Performance options for M extension
// -----------------------------------
//
// You can choose between a smaller 6 cycle 
// hardware multiplier or a faster 2 cycle 
// multiplier implementation. Division and 
// REM are always performed in 32 cycles.
//
// Default = defined (2-cycle MUL)

// `undef ARCH_M_FAST
`define ARCH_M_FAST


// Arbitrary CUSTOM ISA extensions
// ========================================
//

// Default = defined (include example custom instruction)

 `undef ISA_EXT_CUSTOM
//`define ISA_EXT_CUSTOM

// Custom AI Functions 
// Sigmoid, Tanh, e-Function 
// ========================================
//
// Default = undefined
`undef ISA_EXT_AIACC
//`define ISA_EXT_AIACC



// EFPGA for CUSTOM ISA extensions
// ========================================
//

// Default = disabled (no EFPGA included)

 `undef ISA_EXT_EFPGA
//`define ISA_EXT_EFPGA


// =======================================
// = Architectural options / peripherals =
// =======================================

// enable safety options
// ====================
`undef WITH_SAFETY_FEATURES
//`define WITH_SAFETY_FEATURES

// Core / Debug options
// ====================

// Instruction prefetch buffer
`define IPB_DEPTH 4 // has to be a power of 2, min 4

// Entry point after reset
`define START_HANDLER `XPR_LEN'h80000000

// Entry point of debug park loop (e.g. location of debug ROM)
`define DEBUG_HANDLER `XPR_LEN'h00000000

// number of support external interrupt lines
`define N_EXT_INTS 24

// memory segments for debug ROM and main memory
`define ADDR_DEBUG_ROM       32'b0???????????????????????????????
`define ADDR_IMEM            32'b1???????????????????????????????

// memory mapped information in debug ROM
`define ADDR_HART0_STATUS   `XPR_LEN'h00000144
`define ADDR_HART0_STACK    `XPR_LEN'h00000140
`define ADDR_HART0_POSTEXEC `XPR_LEN'h00000148


// Memory Map
// ==========

// Define base addresses and address space of 
// memories and peripherals. 

`define MEMORY_BASE_ADDR        32'h80000000
`define MEMORY_ADDR_WIDTH       32'd30

// Memory mapped Peripherals
// =========================

`define SYSTEM_TIMER_BASE_ADDR  32'hC0000100
`define SYSTEM_TIMER_ADDR_WIDTH 32'd8

`define UART0_BASE_ADDR         32'hC0000200
`define UART0_ADDR_WIDTH        32'd8

`define UART1_BASE_ADDR         32'hC0000300
`define UART1_ADDR_WIDTH        32'd8

`define SPI0_BASE_ADDR          32'hC0000400
`define SPI0_ADDR_WIDTH         32'd8

`define SPI1_BASE_ADDR          32'hC0000500
`define SPI1_ADDR_WIDTH         32'd8

`define GPIO0_BASE_ADDR         32'hC0000600
`define GPIO0_ADDR_WIDTH        32'd8

`define ICAP_BASE_ADDR          32'hC0000700
`define ICAP_ADDR_WIDTH         32'd8


// ==============================================
// = Performance tweaks / architectural choices =
// ==============================================

// Enable hardware reset for internal memories (register
// file, FIFOs, ...); default = ENABLED
// FPGA-only: disabling this feature allows to auto-map
// certain memories to block/distributed RAM (leading to
// less logic & routing utilization)
// ====================

`define WITH_MEM_HW_RESET
//`undef WITH_MEM_HW_RESET
