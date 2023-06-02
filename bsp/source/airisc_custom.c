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
// File              : airisc_custom.c
// Author            : I. Hoyer
// Creation Date     : 13.12.22
// Last Modified     : 15.12.22
// Version           : 1.0
// Abstract          : Intrinsics for custom operations, such as accelerators for activation functions, and test program
// Note              : 8-Bit Fixed-Point, divide by 32 for decimal value!
#include "airisc_custom.h"
#include "airisc_simd.h"


/*
// Intrinsics for activation functions
*/
// Hyperbolic tangent function 
__inline__ int8_t hw_tanH(int8_t a) {
	int8_t result;
   asm(".insn r 0x0B, 1, 0, %0, %1, %1"
        :"=r"(result)
        :"r"(a)
        :);
   return(result);
}

// Sigmoid function 
__inline__ int8_t hw_sigmoid(int8_t a) {
   uint8_t result;
   asm(".insn r 0x0B, 2, 0, %0, %1, %1"
        :"=r"(result)
        :"r"(a)
        :);
   return(result);
}


// e function 
__inline__ int8_t hw_e_fkt(int8_t a) {
   uint32_t result;
   asm(".insn r 0x0B, 4, 0, %0, %1, %1"
        :"=r"(result)
        :"r"(a)
        :);
   return(result);
}


void ai_acc_test() {
	printf("AI Accelerator Test started... \r\n "); fflush(stdout);
	int8_t input;
	int8_t output;
	int8_t expected;
	int8_t fail = 0;
	input = 61;
	expected = 31;
	output = 	hw_tanH(input);
	if (output != expected){
		fail = 1;
	}
	input = 0;
	expected = 36;
	output = hw_e_fkt(input);
	if (output != expected){
		fail = 1;
	}
	input = 112;
	expected = 31;
	output = hw_sigmoid(input);
	if (output != expected){
		fail = 1;
	}
	if (fail == 1){
		printf("fail. \r\n"); fflush(stdout);
		}
	else {
		printf("success. \r\n"); fflush(stdout);
	}
	printf("Goodbye!\r\n\r\n\r\n"); fflush(stdout);
	return;
}
