//
// Copyright 2022 FRAUNHOFER INSTITUTE OF MICROELECTRONIC CIRCUITS AND SYSTEMS (IMS), DUISBURG, GERMANY.
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
// File             : airisc_csr.h
// Author           : S. Nolting
// Last Modified    : 23.01.2023
// Abstract         : CSR access helpers.
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
  asm volatile ("csrr %[rd], %[addr]" : [rd] "=r" (rdata) : [addr] "i" (csr_address));
  return rdata;
}


/**********************************************************************//**
 * Write data to CPU control and status register (CSR).
 *
 * @param[in] csr_address Address of CSR to write. See #airisc_csr_enum.
 * @param[in] data Data word to write (32-bit).
 **************************************************************************/
inline void cpu_csr_write(const int csr_address, uint32_t wdata) {

  asm volatile ("csrw %[addr], %[rs]" :  : [addr] "i" (csr_address), [rs] "r" (wdata));
}


/**********************************************************************//**
 * Set bit(s) in CPU control and status register (CSR).
 *
 * @param[in] set_mask Bit mask, each set bit will be set in the CSR (32-bit).
 **************************************************************************/
inline void cpu_csr_set(const int csr_address, uint32_t set_mask) {

  asm volatile ("csrs %[addr], %[mask]" :  : [addr] "i" (csr_address), [mask] "r" (set_mask));
}


/**********************************************************************//**
 * Clear bit(s) in CPU control and status register (CSR).
 *
 * @param[in] clr_mask Bit mask, each set bit will be cleared in the CSR (32-bit).
 **************************************************************************/
inline void cpu_csr_clr(const int csr_address, uint32_t clr_mask) {

  asm volatile ("csrc %[addr], %[mask]" :  : [addr] "i" (csr_address), [mask] "r" (clr_mask));
}


/**********************************************************************//**
 * AIRISC CSR (control and status register) address list
 **************************************************************************/
enum airisc_csr_enum {

  /* floating-point unit control and status */
  CSR_FFLAGS         = 0x001, /**< 0x001 - fflags (r/w): Floating-point accrued exception flags */
  CSR_FRM            = 0x002, /**< 0x002 - frm    (r/w): Floating-point dynamic rounding mode */
  CSR_FCSR           = 0x003, /**< 0x003 - fcsr   (r/w): Floating-point control/status register (frm + fflags) */

  /* machine control and status */
  CSR_MSTATUS        = 0x300, /**< 0x300 - mstatus (r/w): Machine status register */
  CSR_MISA           = 0x301, /**< 0x301 - misa    (r/-): CPU ISA and extensions */
  CSR_MIE            = 0x304, /**< 0x304 - mie     (r/w): Machine interrupt enable registe */
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

  /* machine counter setup */
  CSR_MCOUNTINHIBIT  = 0x320, /**< 0x320 - mcountinhibit (r/w): Machine counter-inhibit register */

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


/**********************************************************************//**
 * MCAUSE trap identifiers
 **************************************************************************/
enum airisc_mcause_enum {

  MCAUSE_SOFTWARE_INT_M            = 0x80000003, /**< Machine software interrupt */
  MCAUSE_TIMER_INT_M               = 0x80000007, /**< Machine time interrupt */
  MCAUSE_EXT_INT_M                 = 0x8000000b, /**< Machine external interrupt */

  MCAUSE_XIRQ0_INT                 = 0x80000010, /**< AIRISC external interrupt channel 0 */
  MCAUSE_XIRQ1_INT                 = 0x80000011, /**< AIRISC external interrupt channel 1 */
  MCAUSE_XIRQ2_INT                 = 0x80000012, /**< AIRISC external interrupt channel 2 */
  MCAUSE_XIRQ3_INT                 = 0x80000013, /**< AIRISC external interrupt channel 3 */
  MCAUSE_XIRQ4_INT                 = 0x80000014, /**< AIRISC external interrupt channel 4 */
  MCAUSE_XIRQ5_INT                 = 0x80000015, /**< AIRISC external interrupt channel 5 */
  MCAUSE_XIRQ6_INT                 = 0x80000016, /**< AIRISC external interrupt channel 6 */
  MCAUSE_XIRQ7_INT                 = 0x80000017, /**< AIRISC external interrupt channel 7 */
  MCAUSE_XIRQ8_INT                 = 0x80000018, /**< AIRISC external interrupt channel 8 */
  MCAUSE_XIRQ9_INT                 = 0x80000019, /**< AIRISC external interrupt channel 9 */
  MCAUSE_XIRQ10_INT                = 0x8000001a, /**< AIRISC external interrupt channel 10 */
  MCAUSE_XIRQ11_INT                = 0x8000001b, /**< AIRISC external interrupt channel 11 */
  MCAUSE_XIRQ12_INT                = 0x8000001c, /**< AIRISC external interrupt channel 12 */
  MCAUSE_XIRQ13_INT                = 0x8000001d, /**< AIRISC external interrupt channel 13 */
  MCAUSE_XIRQ14_INT                = 0x8000001e, /**< AIRISC external interrupt channel 14 */
  MCAUSE_XIRQ15_INT                = 0x8000001f, /**< AIRISC external interrupt channel 15 */
  
  MCAUSE_INST_ADDR_MISALIGNED      = 0x00000000,
  MCAUSE_INST_ACCESS_FAULT         = 0x00000001,
  MCAUSE_ILLEGAL_INST              = 0x00000002,
  MCAUSE_BREAKPOINT                = 0x00000003,
  MCAUSE_LOAD_ADDR_MISALIGNED      = 0x00000004,
  MCAUSE_LOAD_ACCESS_FAULT         = 0x00000005,
  MCAUSE_STORE_AMO_ADDR_MISALIGNED = 0x00000006,
  MCAUSE_STORE_AMO_ACCESS_FAULT    = 0x00000007,
  MCAUSE_ECALL_FROM_U              = 0x00000008,
  MCAUSE_ECALL_FROM_S              = 0x00000009,
  MCAUSE_ECALL_FROM_M              = 0x0000000b,
  MCAUSE_INST_PAGE_FAULT           = 0x0000000c,
  MCAUSE_LOAD_PAGE_FAULT           = 0x0000000d,
  MCAUSE_RESERVED_14               = 0x0000000e,
  MCAUSE_STORE_AMO_PAGE_FAULT      = 0x0000000f

};


/**********************************************************************//**
 * MIP / MIE interrupt identifiers
 **************************************************************************/
enum AIRISC_IRQ_enum {
  IRQ_MSI    =  3, /**< MSIP - Machine software interrupt pending */
  IRQ_MTI    =  7, /**< MTIP - Machine timer interrupt pending */
  IRQ_MEI    = 11, /**< MEIP - Machine external interrupt pending */

  /* AIRISC-specific interrupts */
  IRQ_XIRQ0  = 16, /**< AIRISC external interrupt channel 0 */
  IRQ_XIRQ1  = 17, /**< AIRISC external interrupt channel 1 */
  IRQ_XIRQ2  = 18, /**< AIRISC external interrupt channel 2 */
  IRQ_XIRQ3  = 19, /**< AIRISC external interrupt channel 3 */
  IRQ_XIRQ4  = 20, /**< AIRISC external interrupt channel 4 */
  IRQ_XIRQ5  = 21, /**< AIRISC external interrupt channel 5 */
  IRQ_XIRQ6  = 22, /**< AIRISC external interrupt channel 6 */
  IRQ_XIRQ7  = 23, /**< AIRISC external interrupt channel 7 */
  IRQ_XIRQ8  = 24, /**< AIRISC external interrupt channel 8 */
  IRQ_XIRQ9  = 25, /**< AIRISC external interrupt channel 9 */
  IRQ_XIRQ10 = 26, /**< AIRISC external interrupt channel 10 */
  IRQ_XIRQ11 = 27, /**< AIRISC external interrupt channel 11 */
  IRQ_XIRQ12 = 28, /**< AIRISC external interrupt channel 12 */
  IRQ_XIRQ13 = 29, /**< AIRISC external interrupt channel 13 */
  IRQ_XIRQ14 = 30, /**< AIRISC external interrupt channel 14 */
  IRQ_XIRQ15 = 31  /**< AIRISC external interrupt channel 15 */
};


/**********************************************************************//**
 * Machine status register bits
 **************************************************************************/
enum CSR_MSTATUS_enum {
  MSTATUS_MIE   =  3, /**< MIE - Machine interrupt enable bit */
  MSTATUS_MPIE  =  7, /**< MPIE - Machine previous interrupt enable bit */
  MSTATUS_MPP_L = 11, /**< MPP_L - Machine previous privilege mode bit low  */
  MSTATUS_MPP_H = 12  /**< MPP_H - Machine previous privilege mode bit high */
};


#endif
