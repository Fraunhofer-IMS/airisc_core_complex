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

/* System Timer */

#include <airisc_timer.h>
#include <stdint.h>


/**********************************************************************//**
 * Set current system time.
 *
 * @param[in] timer Pointer to timer hardware handle (TIMER_t*)
 * @param[in] time New system time (uint64_t)
 **************************************************************************/
void timer_set_time(volatile TIMER_t* const timer, uint64_t time) {

  union {
    uint64_t u64;
    uint32_t u32[sizeof(uint64_t)/sizeof(uint32_t)];
  } cycles;

  cycles.u64 = time;

  timer->TIMEL = 0;
  timer->TIMEH = cycles.u32[1];
  timer->TIMEL = cycles.u32[0];
}


/**********************************************************************//**
 * Get current system time.
 *
 * @param[in] timer Pointer to timer hardware handle (TIMER_t*)
 * @return Current system time (uint64_t)
 **************************************************************************/
uint64_t timer_get_time(volatile TIMER_t* const timer) {

  union {
    uint64_t u64;
    uint32_t u32[sizeof(uint64_t)/sizeof(uint32_t)];
  } cycles;

  uint32_t tmp1, tmp2, tmp3;
  while(1) {
    tmp1 = timer->TIMEH;
    tmp2 = timer->TIMEL;
    tmp3 = timer->TIMEH;
    if (tmp1 == tmp3) {
      break;
    }
  }

  cycles.u32[0] = tmp2;
  cycles.u32[1] = tmp3;

  return cycles.u64;
}


/**********************************************************************//**
 * Set compare time register (MTIMECMP) for generating interrupts.
 *
 * @param[in] timer Pointer to timer hardware handle (TIMER_t*)
 * @param[in] timecmp System time for interrupt (uint64_t)
 **************************************************************************/
void timer_set_timecmp(volatile TIMER_t* const timer, uint64_t timecmp) {

  union {
    uint64_t u64;
    uint32_t u32[sizeof(uint64_t)/sizeof(uint32_t)];
  } cycles;

  cycles.u64 = timecmp;

  timer->TIMECMPL = -1; // prevent MTIMECMP from temporarily becoming smaller than the lesser of the old and new values
  timer->TIMECMPH = cycles.u32[1];
  timer->TIMECMPL = cycles.u32[0];
}


/**********************************************************************//**
 * Get compare time register (MTIMECMP).
 *
 * @param[in] timer Pointer to timer hardware handle (TIMER_t*)
 * @return Current MTIMECMP value.
 **************************************************************************/
uint64_t timer_get_timecmp(volatile TIMER_t* const timer) {

  union {
    uint64_t u64;
    uint32_t u32[sizeof(uint64_t)/sizeof(uint32_t)];
  } cycles;

  cycles.u32[0] = timer->TIMECMPL;
  cycles.u32[1] = timer->TIMECMPH;

  return cycles.u64;
}
