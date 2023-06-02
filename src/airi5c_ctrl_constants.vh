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
// File             : airi5c_ctrl_constants.vh
// Author           : A. Stanitzki
// Creation Date    : 09.10.20
// Last Modified    : 15.02.21
// Version          : 1.0
// Abstract         : Constants for the control logic 
// History          : 05.02.18 - HTIF removed (ASt)
//


`define SRC_A_SEL_WIDTH  2
`define SRC_A_RS1        `SRC_A_SEL_WIDTH'd0
`define SRC_A_PC         `SRC_A_SEL_WIDTH'd1
`define SRC_A_ZERO       `SRC_A_SEL_WIDTH'd2

`define SRC_B_SEL_WIDTH  2
`define SRC_B_RS2        `SRC_B_SEL_WIDTH'd0
`define SRC_B_IMM        `SRC_B_SEL_WIDTH'd1
`define SRC_B_FOUR       `SRC_B_SEL_WIDTH'd2
`define SRC_B_ZERO       `SRC_B_SEL_WIDTH'd3

`define SRC_C_SEL_WIDTH  2
`define SRC_C_RS3        `SRC_C_SEL_WIDTH'd0
`define SRC_C_ZERO       `SRC_C_SEL_WIDTH'd3

`define PC_SRC_SEL_WIDTH 4
`define PC_PLUS_FOUR      `PC_SRC_SEL_WIDTH'd0
`define PC_BRANCH_TARGET  `PC_SRC_SEL_WIDTH'd1
`define PC_JAL_TARGET     `PC_SRC_SEL_WIDTH'd2
`define PC_JALR_TARGET    `PC_SRC_SEL_WIDTH'd3
`define PC_REPLAY         `PC_SRC_SEL_WIDTH'd4
`define PC_HANDLER        `PC_SRC_SEL_WIDTH'd5
`define PC_EPC            `PC_SRC_SEL_WIDTH'd6
`define PC_DPC            `PC_SRC_SEL_WIDTH'd7
`define PC_MISSED_PREDICT `PC_SRC_SEL_WIDTH'd8

`define IMM_TYPE_WIDTH   2
`define IMM_I            `IMM_TYPE_WIDTH'd0
`define IMM_S            `IMM_TYPE_WIDTH'd1
`define IMM_U            `IMM_TYPE_WIDTH'd2
`define IMM_J            `IMM_TYPE_WIDTH'd3

`define WB_SRC_SEL_WIDTH 3
`define WB_SRC_ALU       `WB_SRC_SEL_WIDTH'd0
`define WB_SRC_MEM       `WB_SRC_SEL_WIDTH'd1
`define WB_SRC_CSR       `WB_SRC_SEL_WIDTH'd2
`define WB_SRC_PCPI      `WB_SRC_SEL_WIDTH'd3
`define WB_SRC_FPU       `WB_SRC_SEL_WIDTH'd4
`define WB_SRC_REG       `WB_SRC_SEL_WIDTH'd5

`define MEM_TYPE_WIDTH    3
`define MEM_TYPE_LB      `MEM_TYPE_WIDTH'd0
`define MEM_TYPE_LH      `MEM_TYPE_WIDTH'd1
`define MEM_TYPE_LW      `MEM_TYPE_WIDTH'd2
`define MEM_TYPE_LD      `MEM_TYPE_WIDTH'd3
`define MEM_TYPE_LBU     `MEM_TYPE_WIDTH'd4
`define MEM_TYPE_LHU     `MEM_TYPE_WIDTH'd5
`define MEM_TYPE_LWU     `MEM_TYPE_WIDTH'd6

`define MEM_TYPE_WIDTH   3
`define MEM_TYPE_SB      `MEM_TYPE_WIDTH'd0
`define MEM_TYPE_SH      `MEM_TYPE_WIDTH'd1
`define MEM_TYPE_SW      `MEM_TYPE_WIDTH'd2
`define MEM_TYPE_SD      `MEM_TYPE_WIDTH'd3
