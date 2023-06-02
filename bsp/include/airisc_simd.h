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
// File              : airisc_simd.h
// Author            : I. Hoyer
// Creation Date     : 13.12.22
// Last Modified     : 15.12.22
// Version           : 1.0
// Abstract          : Intrinsics for SIMD Operations as well as small test program#include <stdint.h>
// Note              : Please see SIMD.c for detailed description!
#ifndef AIRISC_SIMD_H_
#define AIRISC_SIMD_H_

#include <stdlib.h>
#include <stdio.h>

uint64_t __smul8(uint32_t a, uint32_t b);

uint64_t __smulx8(uint32_t a, uint32_t b); 


uint64_t __smul16(uint32_t a, uint32_t b);

uint64_t __smulx16(uint32_t a, uint32_t b); 

uint8_t simd_test();

void simd_test_uart();

#endif
