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

#ifndef AIRISC_H_
#define AIRISC_H_

#include <stdint.h>

#include "airisc_csr.h"
#include "airisc_defines.h"
#include "airisc_syscalls.h"
#include "airisc_uart.h"
#include "airisc_spi.h"


/**********************************************************************//**
 * Memory-mapped primtives.
 **************************************************************************/
#define MMREG8  (volatile uint8_t*)
#define MMREG16 (volatile uint16_t*)
#define MMREG32 (volatile uint32_t*)

#define MMROM8  (const volatile uint8_t*)
#define MMROM16 (const volatile uint16_t*)
#define MMROM32 (const volatile uint32_t*)


/**********************************************************************//**
 * Debug output primitive.
 **************************************************************************/
#define DEBUG_OUT (*(MMRAM32 0x80010000UL)) // write-only, simulation-only


/**********************************************************************//**
 * Prototypes.
 **************************************************************************/
void __attribute__((__interrupt__, aligned(4))) __trap_entry(void);
void interrupt_handler(uint32_t cause, uint32_t epc);
void exception_handler(uint32_t cause, uint32_t epc, uint32_t tval);

#endif
