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

`define FPU_OP_WIDTH    5
/*
// these instructions are not performed by the FPU
// they are only listed for completeness
// load/store RAM                           // original instruction
`define FPU_OP_SW       `FPU_OP_WIDTH'd2    // FSW
`define FPU_OP_LW       `FPU_OP_WIDTH'd1    // FLW

// load/store int register
`define FPU_OP_SR       `FPU_OP_WIDTH'd19   // FMV.X.W
`define FPU_OP_LR       `FPU_OP_WIDTH'd26   // FMV.W.X
*/

// multiply add/multiply sub
`define FPU_OP_MADD     `FPU_OP_WIDTH'd3    // FMADD.S
`define FPU_OP_MSUB     `FPU_OP_WIDTH'd4    // FMSUB.S
`define FPU_OP_NMSUB    `FPU_OP_WIDTH'd5    // FNMSUB.S
`define FPU_OP_NMADD    `FPU_OP_WIDTH'd6    // FNMADD.S

// standard functions
`define FPU_OP_ADD      `FPU_OP_WIDTH'd7    // FADD.S
`define FPU_OP_SUB      `FPU_OP_WIDTH'd8    // FSUB.S
`define FPU_OP_MUL      `FPU_OP_WIDTH'd9    // FMUL.S
`define FPU_OP_DIV      `FPU_OP_WIDTH'd10   // FDIV.S
`define FPU_OP_SQRT     `FPU_OP_WIDTH'd11   // FSQRT.S
`define FPU_OP_SGNJ     `FPU_OP_WIDTH'd12   // FSGNJ.S
`define FPU_OP_SGNJN    `FPU_OP_WIDTH'd13   // FSGNJN.S
`define FPU_OP_SGNJX    `FPU_OP_WIDTH'd14   // FSGNJX.S
`define FPU_OP_MIN      `FPU_OP_WIDTH'd15   // FMIN.S
`define FPU_OP_MAX      `FPU_OP_WIDTH'd16   // FMAX.S

// conversion
`define FPU_OP_CVTFI    `FPU_OP_WIDTH'd17   // FCVT.W.S
`define FPU_OP_CVTFU    `FPU_OP_WIDTH'd18   // FCVT.WU.S
`define FPU_OP_CVTIF    `FPU_OP_WIDTH'd24   // FCVT.S.W
`define FPU_OP_CVTUF    `FPU_OP_WIDTH'd25   // FCVT.S.WU

// compare
`define FPU_OP_EQ       `FPU_OP_WIDTH'd20   // FEQ.S
`define FPU_OP_LT       `FPU_OP_WIDTH'd21   // FLT.S
`define FPU_OP_LE       `FPU_OP_WIDTH'd22   // FLE.S
`define FPU_OP_CLASS    `FPU_OP_WIDTH'd23   // FCLASS.S

`define FPU_OP_NOP      `FPU_OP_WIDTH'd0

// rounding modes
`define FPU_RM_WIDTH    3

`define FPU_RM_RNE      `FPU_RM_WIDTH'b000  // round to nearest (tie to even)
`define FPU_RM_RTZ      `FPU_RM_WIDTH'b001  // round towards 0 (truncate)
`define FPU_RM_RDN      `FPU_RM_WIDTH'b010  // round down (towards -inf)
`define FPU_RM_RUP      `FPU_RM_WIDTH'b011  // round up (towards +inf)
`define FPU_RM_RMM      `FPU_RM_WIDTH'b100  // round to nearest (tie to max magnitude)
`define FPU_RM_DYN      `FPU_RM_WIDTH'b111  // use rounding mode from fcsr
