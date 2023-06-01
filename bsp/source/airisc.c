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
// File             : airisc.c
// Author           : S. Nolting
// Last Modified    : 18.01.2023
// Abstract         : General core helpers and runtime environment functions.
//

#include "airisc.h"


/**********************************************************************//**
 * First level trap handler. Requires the 'interrupt' attribute to make
 * sure everything is saved to the stack and to enforce a 'mret' instruction
 * at the end of this function.
 *
 * @note The crt0 start-up code will initialize MTVEC with the address
 * of this function.
 **************************************************************************/
void __attribute__ ((__interrupt__, aligned(4))) __trap_entry(void)
{
	uint32_t mcause = cpu_csr_read(CSR_MCAUSE);
	uint32_t mepc   = cpu_csr_read(CSR_MEPC);
	uint32_t mtval  = cpu_csr_read(CSR_MTVAL);

	if (mcause & 0x80000000UL) { // is interrupt (async. exception)
		interrupt_handler(mcause, mepc);
	}
	else { // is (sync.) exception
		exception_handler(mcause, mepc, mtval);
	}
}


/**********************************************************************//**
 * Default DUMMY interrupt handler. This can be overriden by
 * defining a custom function using the same prototype.
 *
 * @note This is a "normal" function - so NO 'interrupt' attribute!
 *
 * @param[in] cause Exception identifier from mcause CSR.
 * @param[in] epc Exception program counter from epc CSR.
 **************************************************************************/
void __attribute__ ((weak)) interrupt_handler(uint32_t cause, uint32_t epc)
{
  // try to clear all pending interrupts
  cpu_csr_write(CSR_MIP, 0);

  return; // do nothing
}


/**********************************************************************//**
 * Default DUMMY interrupt handler. This can be overriden by
 * defining a custom function using the same prototype.
 *
 * @note This is a "normal" function - so NO 'interrupt' attribute!
 *
 * @param[in] cause Exception identifier from mcause CSR.
 * @param[in] epc Exception program counter from epc CSR.
 * @param[in] tval Trap value from mtval CSR.
 **************************************************************************/
void __attribute__ ((weak)) exception_handler(uint32_t cause, uint32_t epc, uint32_t tval)
{
  // compute return address (try to resume operation)
  cpu_csr_write(CSR_MEPC, epc+4);

  return; // do nothing
}


/**********************************************************************//**
 * Get number of implemented "AIRISC external interrupts"
 *
 * @warning Make sure this is executed in machine mode with mstatus.MIE = 0
 * to prevent accidential triggering of interrupts.
 *
 * @return Number of implemented external interrupt channels (0..16).
 **************************************************************************/
int get_num_xirq(void)
{
  cpu_csr_write(CSR_MIE, 0xffff0000U); // try to set all XIRQ enable bits
  uint32_t num = cpu_csr_read(CSR_MIE) >> IRQ_XIRQ0;

  // count set bits
  int cnt = 0;
  while (num) {
    cnt++;
    num >>= 1;
  }

  return cnt;
}


/**********************************************************************//**
 * Convert MISA CSR into human-readable string.
 *
 * @param[in,out] res Pointer to put the result string to (min 64 chars!).
 **************************************************************************/
void get_misa_string(char* res)
{
  int i = 0;
  uint32_t tmp = cpu_csr_read(CSR_MISA);

  // check MXL
  res[i++] = 'r';
  res[i++] = 'v';
  uint32_t mxl = (tmp >> 30) & 3;
  if (mxl == 3) {
    res[i++] = '1';
    res[i++] = '2';
    res[i++] = '8';
  }
  else if (mxl == 2) {
    res[i++] = '6';
    res[i++] = '4';
  }
  else if (mxl == 1) {
    res[i++] = '3';
    res[i++] = '2';
  }
  else {
    res[i++] = '?';
  }

  // check base integer ISA
  if (tmp & (1 << 8)) {
    res[i++] = 'i';
    tmp &= ~(1<<8); // clear bit so we do not print this again
  }
  else {
    res[i++] = 'e';
    tmp &= ~(1<<4); // clear bit so we do not print this again
  }
  
  if (tmp & 0x3ffffff) {
    res[i++] = ' ';
    res[i++] = '+';
    res[i++] = ' ';
  
    // check basic ISA extensions
    int j;
    for (j=0; j<26; j++) {
      if (tmp & (1 << j)) {
        res[i++] = (char)('A' + j);
        res[i++] = ' ';
      }
    }
  }

  // terminate string
  res[i++] = 0;
}
