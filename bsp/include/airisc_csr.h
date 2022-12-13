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

#ifndef AIRISC_CSR_H_
#define AIRISC_CSR_H_

/**********************************************************************//**
 * Read data from CPU control and status register (CSR).
 *
 * @param[in] csr_address Address of CSR to read. See #airisc_csr_enum.
 * @return Read data word (32-bit).
 **************************************************************************/
inline uint32_t cpu_csr_read(const int csr_address) {

  uint32_t rdata;
  asm volatile ("csrr %[rd], %[addr]"
                : [rd] "=r" (rdata)
                : [addr] "i" (csr_address));
  return rdata;
}


/**********************************************************************//**
 * Write data to CPU control and status register (CSR).
 *
 * @param[in] csr_address Address of CSR to write. See #airisc_csr_enum.
 * @param[in] data Data word to write (32-bit).
 **************************************************************************/
inline void cpu_csr_write(const int csr_address, uint32_t wdata) {

  asm volatile ("csrw %[addr], %[rs]"
                : 
                : [addr] "i" (csr_address),
                  [rs] "r" (wdata));
}


// AIRISC CSR (control and status register) address list
enum airisc_csr_enum {

  /* floating-point unit control and status */
  CSR_FFLAGS         = 0x001, /**< 0x001 - fflags (r/w): Floating-point accrued exception flags */
  CSR_FRM            = 0x002, /**< 0x002 - frm    (r/w): Floating-point dynamic rounding mode */
  CSR_FCSR           = 0x003, /**< 0x003 - fcsr   (r/w): Floating-point control/status register (frm + fflags) */

  /* machine control and status */
  CSR_MSTATUS        = 0x300, /**< 0x300 - mstatus (r/w): Machine status register */
  CSR_MISA           = 0x301, /**< 0x301 - misa    (r/-): CPU ISA and extensions */
  CSR_MTVEC          = 0x305, /**< 0x305 - mtvec   (r/w): Machine trap-handler base address (for ALL traps) */

  /* machine trap control */
  CSR_MSCRATCH       = 0x340, /**< 0x340 - mscratch (r/w): Machine scratch register */
  CSR_MEPC           = 0x341, /**< 0x341 - mepc     (r/w): Machine exception program counter */
  CSR_MCAUSE         = 0x342, /**< 0x342 - mcause   (r/w): Machine trap cause */
  CSR_MTVAL          = 0x343, /**< 0x343 - mtval    (r/-): Machine trap value register */
  CSR_MIP            = 0x344, /**< 0x344 - mip      (r/?): Machine interrupt pending register */

  /* not accessible by m-mode software */
  CSR_DCSR           = 0x7b0, /**< 0x7b0 - dcsr     (-/-): Debug status and control register */
  CSR_DPC            = 0x7b1, /**< 0x7b1 - dpc      (-/-): Debug program counter */
  CSR_DSCRATCH       = 0x7b2, /**< 0x7b2 - dscratch (-/-): Debug scratch register */

  /* machine counterd and timers */
  CSR_MCYCLE         = 0xb00, /**< 0xb00 - mcycle    (r/w): Machine cycle counter low word */
  CSR_MINSTRET       = 0xb02, /**< 0xb02 - minstret  (r/w): Machine instructions-retired counter low word */
  CSR_MCYCLEH        = 0xb80, /**< 0xb80 - mcycleh   (r/w): Machine cycle counter high word */
  CSR_MINSTRETH      = 0xb82, /**< 0xb82 - minstreth (r/w): Machine instructions-retired counter high word */

  /* user counterd and timers */
  CSR_CYCLE          = 0xc00, /**< 0xc00 - cycle    (r/-): Cycle counter low word (from MCYCLE) */
  CSR_TIME           = 0xc01, /**< 0xc01 - time     (r/-): Timer low word (from MTIME.TIME_LO) */
  CSR_INSTRET        = 0xc02, /**< 0xc02 - instret  (r/-): Instructions-retired counter low word (from MINSTRET) */
  CSR_CYCLEH         = 0xc80, /**< 0xc80 - cycleh   (r/-): Cycle counter high word (from MCYCLEH) */
  CSR_TIMEH          = 0xc81, /**< 0xc81 - timeh    (r/-): Timer high word (from MTIME.TIME_HI) */
  CSR_INSTRETH       = 0xc82, /**< 0xc82 - instreth (r/-): Instructions-retired counter high word (from MINSTRETH) */


  /* machine information registers */
  CSR_MVENDORID      = 0xf11, /**< 0xf11 - mvendorid (r/-): Vendor ID */
  CSR_MARCHID        = 0xf12, /**< 0xf12 - marchid   (r/-): Architecture ID */
  CSR_MIMPID         = 0xf13, /**< 0xf13 - mimpid    (r/-): Implementation ID/version */
  CSR_MHARTID        = 0xf14  /**< 0xf14 - mhartid   (r/-): Hardware thread ID (always 0) */

};


#endif
