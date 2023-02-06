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

#ifndef AIRISC_TIMER_H_
#define AIRISC_TIMER_H_

#include "airisc_defines.h"

void     timer_set_time(volatile TIMER_t* const timer, uint64_t time);
uint64_t timer_get_time(volatile TIMER_t* const timer);
void     timer_set_timecmp(volatile TIMER_t* const timer, uint64_t timecmp);
uint64_t timer_get_timecmp(volatile TIMER_t* const timer);

#endif
