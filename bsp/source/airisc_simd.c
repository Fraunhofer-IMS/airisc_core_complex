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
// File              : airisc_simd.c
// Author            : I. Hoyer
// Creation Date     : 13.12.22
// Last Modified     : 15.12.22
// Version           : 1.0
// Abstract          : Intrinsics for SIMD Operations as well as small test program

#include <stdint.h>
#include <stdlib.h>
#include <inttypes.h>
#include <stdio.h>
#include "airisc_simd.h"
#include "airisc_custom.h"

/*
// Intrinsics for SIMD Operations
// The operations are implemented with respect to this P-Ext. proposal, v.09.3
// https://github.com/riscv/riscv-p-spec/blob/master/P-ext-proposal.adoc
*/

// SMUL8: Signed 8-Bit Int. Multiplikation 
__inline__ __attribute__((always_inline))
uint64_t __smul8(uint32_t a, uint32_t b) {
	   uint64_t result;
	   asm(".insn r 0x77, 0, 0x54, %0, %1, %2"
	        :"=r"(result)
	        :"r"(a),"r"(b)
	        :);
	   return(result);
	}
// SMULX8: Crossed Signed 8-Bit Int. Multiplication 
__inline__ __attribute__((always_inline))
uint64_t __smulx8(uint32_t a, uint32_t b) {
   uint64_t result;
   asm(".insn r 0x77, 0, 0x55, %0, %1, %2"
        :"=r"(result)
        :"r"(a),"r"(b)
        :);
   return(result);
}

//SMUL16: Signed 16-Bit Int. Multiplication
__inline__ __attribute__((always_inline))
uint64_t  __smul16(uint32_t a, uint32_t b) {
   uint64_t result;
   asm(".insn r 0x77, 0, 0x50, %0, %1, %2"
        :"=r"(result)
        :"r"(a),"r"(b)
        :);
   return(result);
}

// SMULX16: Crossed Signed 16-Bit Int. Multiplication 
__inline__ __attribute__((always_inline))
uint64_t __smulx16(uint32_t a, uint32_t b) {
   uint64_t result;
   asm(".insn r 0x77, 0, 0x51, %0, %1, %2"
        :"=r"(result)
        :"r"(a),"r"(b)
        :);
   return(result);
}

/*
// simd_test: The actual test with example values
*/
uint8_t simd_test(){
	//first operand
	uint32_t opa;
  //second operand
	uint32_t opb;
  //result register
	uint64_t res;
  //Signals to evaluate the test
  uint8_t fail = 0;
  uint8_t pass = 0;
  //Initializing result register to check for write hazards 
	res = 0x01010101010101;
  //First test operands for 8-Bit Multiplications
	opa = 0x01020304;
	opb = 0x05060708;
  //Using the SMUL8 intrinsic and saving the result to "res" 
	res = __smul8(opa, opb);
  //Checking result
	if (res != 0x0005000C00150020ULL) {
	  //If the result is wrong, leave the test as "failed"
    fail = 1;
	  return(pass);
	}
  //Using smulx8
	res = __smulx8(opa, opb);
	if (res != 0x0006000A0018001CULL) {
	  fail = 1;
	  return(pass);
	}
  //Initializing result register to check for write hazards 
	res = 0x11111111111111;
  //Operands for 16-Bit Multiplications
	opa = 0x00010002;
	opb = 0x00030004;
  //Using smul16
	res = __smul16(opa, opb);
	if (res != 0x0000000300000008ULL) {
		fail = 1;
		return(pass);
		}
  //Using smulx16
	res = __smulx16(opa, opb);
	if (res != 0x0000000400000006ULL) {
		fail = 1;
		return(pass);
		}
  //Final Check
	if(fail == 0){
		pass = 1;
	}
	return(pass);

}

/*
// Test programm, writing the findings to UART. 
*/
void simd_test_uart(){
	printf("SIMD Test started... \r\n "); fflush(stdout);
	uint8_t pass;
  //Starting the actual test
	pass = simd_test();
	if (pass != 1){
		printf("fail. \r\n"); fflush(stdout);
	}
	else {
		printf("success. \r\n"); fflush(stdout);
	}
		return;
}

