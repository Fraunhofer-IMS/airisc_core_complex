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
// File          : airisc_trng.h
// Author        : S. Nolting
// Creation Date : 05.04.2023
// Abstract      : HAL for the true random number generator (TRNG).
//

#ifndef AIRISC_TRNG_H_
#define AIRISC_TRNG_H_

#include "airisc_defines.h"

void    trng_enable(volatile TRNG_t* const handle);
void    trng_disable(volatile TRNG_t* const handle);
int     trng_is_enabled(volatile TRNG_t* const handle);
int     trng_is_sim(volatile TRNG_t* const handle);
uint8_t trng_get(volatile TRNG_t* const handle);

#endif
