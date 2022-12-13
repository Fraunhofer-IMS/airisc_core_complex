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

#include <airisc.h>


/**********************************************************************//**
 * First level trap handler. Requires the 'interrupt' attribute to make
 * sure everything is saved to the stack and to enforce a 'mret' instruction
 * at the end of this function.
 *
 * @note The crt0 start-up code will initialize MTVEC with the address
 * opf this function.
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
		// compute return address
		mepc += 4; // for upcoming C ISA extension: adjust by +2 if exception was caused by compressed instruction
		cpu_csr_write(CSR_MEPC, mepc);
	}
}


/**********************************************************************//**
 * Default DUMMY interrupt handler. This can be overriden by
 * defining a custom function with the same name and argument list.
 *
 * @note This is a "normal" function - so NO 'interrupt' attribute!
 *
 * @param[in] cause Exception identifier from mcause CSR.
 * @param[in] epc Exception program counter from epc CSR.
 **************************************************************************/
void __attribute__ ((weak)) interrupt_handler(uint32_t cause, uint32_t epc)
{
    return; // do nothing
}


/**********************************************************************//**
 * Default DUMMY interrupt handler. This can be overriden by
 * defining a custom function with the same name and argument list.
 *
 * @note This is a "normal" function - so NO 'interrupt' attribute!
 *
 * @param[in] cause Exception identifier from mcause CSR.
 * @param[in] epc Exception program counter from epc CSR.
 * @param[in] tval Trap value from mtval CSR.
 **************************************************************************/
void __attribute__ ((weak)) exception_handler(uint32_t cause, uint32_t epc, uint32_t tval)
{
    return; // do nothing
}
