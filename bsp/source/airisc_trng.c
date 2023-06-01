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
// File          : airisc_trng.c
// Author        : S. Nolting
// Creation Date : 05.04.2023
// Abstract      : HAL for the true random number generator (TRNG).
//

#include <airisc_trng.h>
#include <stdint.h>


/**********************************************************************//**
 * Enable true-random number generator.
 *
 * @param[in] handle Pointer to TRNG hardware handle (TRNG_t*)
 **************************************************************************/
void trng_enable(volatile TRNG_t* const handle) {

  int i;

  handle->CTRL = 0; // reset and disable

  // "cool-down" time
  for(i=0; i<128; i++) {
    asm volatile ("nop");
  }

  handle->CTRL = 1 << 30; // set enable bit

  // "warm-up" time
  for(i=0; i<128; i++) {
    asm volatile ("nop");
  }
}


/**********************************************************************//**
 * Disable true-random number generator.
 *
 * @param[in] handle Pointer to TRNG hardware handle (TRNG_t*)
 **************************************************************************/
void trng_disable(volatile TRNG_t* const handle) {

  handle->CTRL = 0;
}


/**********************************************************************//**
 * Check if TRNG is enabled
 *
 * @param[in] handle Pointer to TRNG hardware handle (TRNG_t*)
 * @return 1 if TRNG is enabled, 0 if TRNG is disabled
 **************************************************************************/
int trng_is_enabled(volatile TRNG_t* const handle) {

  if (handle->CTRL & (1 << 30)) { // enable bit set?
    return 1;
  }
  else {
    return 0;
  }
}


/**********************************************************************//**
 * Check if TRNG is in SIMULATION mode
 *
 * @param[in] handle Pointer to TRNG hardware handle (TRNG_t*)
 * @return 1 if TRNG is in simulation mode, 0 if TRNG is not in simulation mode
 **************************************************************************/
int trng_is_sim(volatile TRNG_t* const handle) {

  if (handle->CTRL & (1 << 29)) { // enable bit set?
    return 1;
  }
  else {
    return 0;
  }
}


/**********************************************************************//**
 * Get random byte.
 *
 * @warning This function is blocking (stalls until random data is obtained).
 *
 * @param[in] handle Pointer to TRNG hardware handle (TRNG_t*)
 * @return Random data byte (uint8_t)
 **************************************************************************/
uint8_t trng_get(volatile TRNG_t* const handle) {

  uint32_t tmp;

  while(1) {
    tmp = handle->CTRL;
    if (tmp & (1 << 31)) { // data valid?
      return (uint8_t)tmp;
    }
  }
}

