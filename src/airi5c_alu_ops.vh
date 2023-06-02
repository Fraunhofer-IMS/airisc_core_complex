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
// File             : airi5c_alu_ops.vh
// Author           : A. Stanitzki
// Creation Date    : 09.10.20
// Last Modified    : 15.02.21
// Version          : 1.0
// Abstract         : Constants for the ALU
//


`define ALU_OP_WIDTH 4

`define ALU_OP_ADD  `ALU_OP_WIDTH'd0
`define ALU_OP_SLL  `ALU_OP_WIDTH'd1
`define ALU_OP_XOR  `ALU_OP_WIDTH'd4
`define ALU_OP_OR   `ALU_OP_WIDTH'd6
`define ALU_OP_AND  `ALU_OP_WIDTH'd7
`define ALU_OP_SRL  `ALU_OP_WIDTH'd5
`define ALU_OP_SEQ  `ALU_OP_WIDTH'd8
`define ALU_OP_SNE  `ALU_OP_WIDTH'd9
`define ALU_OP_SUB  `ALU_OP_WIDTH'd10
`define ALU_OP_SRA  `ALU_OP_WIDTH'd11
`define ALU_OP_SLT  `ALU_OP_WIDTH'd12
`define ALU_OP_SGE  `ALU_OP_WIDTH'd13
`define ALU_OP_SLTU `ALU_OP_WIDTH'd14
`define ALU_OP_SGEU `ALU_OP_WIDTH'd15