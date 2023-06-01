//
// Copyright 2023 FRAUNHOFER INSTITUTE OF MICROELECTRONIC CIRCUITS AND SYSTEMS (IMS), DUISBURG, GERMANY.
// --- All rights reserved --- 
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
// Licensed under the Solderpad Hardware License v 2.1 (the "License");
// you may not use this file except in compliance with the License, or, at your option, the Apache License version 2.0.
// You may obtain a copy of the License at
// https://solderpad.org/licenses/SHL-2.1/
// Unless required by applicable law or agreed to in writing, any work distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and limitations under the License.
//
//
// File             : crt0.S
// Author           : S. Nolting
// Last Modified    : 18.01.2023
// Abstract         : AIRISC start-up code.
//

.file "crt0.S"
.section .init, "ax"
.align 1
.global _reset_entry
.global _trap_entry
.global main
.type _reset_entry, @function

_reset_entry:
.cfi_startproc

// ****************************************************************************
// Setup pointers using linker script symbols
// ****************************************************************************
crt0_begin:
  .cfi_undefined ra
  .option push
  .option norelax
  la gp, __global_pointer$
  la sp, __stack
  .option pop


// ****************************************************************************
// Initialize core CSRs
// ****************************************************************************
crt0_init_csrs:
  la   x10,    __trap_entry // function defined in airisc.c
  csrw mie,    zero
  csrw mip,    zero
  csrw mcause, zero
  csrw mtval,  zero
  csrw mtvec,  x10
  csrw mepc,   x10


// ****************************************************************************
// Reset MTIME machine system timer
// ****************************************************************************
crt0_init_mtime:
  la  x10,   _timer_base // linker script symbol
  sw  zero,  0(x10)
  sw  zero,  4(x10)
  sw  zero,  8(x10)
  sw  zero, 16(x10)


// ****************************************************************************
// Initialize/clear integer register file
// ****************************************************************************
crt0_init_rf:
  mv  x1, x0
  mv  x4, x1
  mv  x5, x1
  mv  x6, x1
  mv  x7, x1
  mv  x8, x1
  mv  x9, x1
  mv x10, x1
  mv x11, x1
  mv x12, x1
  mv x13, x1
  mv x14, x1
  mv x15, x1
#ifndef __riscv_32_e // initialize upper half only if E ISA extension not enabled
  mv x16, x1
  mv x17, x1
  mv x18, x1
  mv x19, x1
  mv x20, x1
  mv x21, x1
  mv x22, x1
  mv x23, x1
  mv x24, x1
  mv x25, x1
  mv x26, x1
  mv x27, x1
  mv x28, x1
  mv x29, x1
  mv x30, x1
  mv x31, x1
#endif


// ****************************************************************************
// Clear .bss section (word-wise as section begins/end on word boundary)
// ****************************************************************************
crt0_bss:
  la  x10, _bss_start
  la  x11, _bss_end
  bge x10, x11, crt0_bss_loop_end

crt0_bss_loop:
  sw   zero, 0(x10)
  addi x10,  x10, 4
  ble  x10,  x11, crt0_bss_loop
crt0_bss_loop_end:


// ****************************************************************************
// Call main function
// ****************************************************************************
crt0_call_main:
  addi x10, zero, 0 // x10 = a0 = argc = 0
  addi x11, zero, 0 // x11 = a1 = argv = 0
  call main      


// ****************************************************************************
// Go to endless sleep mode if main returns
// ****************************************************************************
crt0_end:
  csrw mie, zero     // disable all interrupt source
  csrw mscratch, x10 // copy main's return value (for debugger)
  wfi                // go to sleep mode
  j .                // endless loop

.cfi_endproc
