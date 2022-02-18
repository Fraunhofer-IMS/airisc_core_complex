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
//
// File              : airi5c_hasti_constants.v 
// Author            : A. Stanitzki
// Creation Date     : 09.10.20
// Last Modified     : 15.02.21
// Version           : 1.0
// Abstract         : constants for the hasti bus



`define HASTI_BUS_WIDTH      32
`define HASTI_BUS_NBYTES     4
`define HASTI_ADDR_WIDTH     32

`define HASTI_TRANS_WIDTH    2
`define HASTI_TRANS_IDLE     `HASTI_TRANS_WIDTH'd0
`define HASTI_TRANS_BUSY     `HASTI_TRANS_WIDTH'd1
`define HASTI_TRANS_NONSEQ   `HASTI_TRANS_WIDTH'd2
`define HASTI_TRANS_SEQ      `HASTI_TRANS_WIDTH'd3

`define HASTI_PROT_WIDTH     4 
`define HASTI_NO_PROT        `HASTI_PROT_WIDTH'd0

`define HASTI_BURST_WIDTH    3
`define HASTI_BURST_SINGLE   `HASTI_BURST_WIDTH'd0

`define HASTI_MASTER_NO_LOCK 1'b0

`define HASTI_RESP_WIDTH     1
`define HASTI_RESP_OKAY      `HASTI_RESP_WIDTH'd0
`define HASTI_RESP_ERROR     `HASTI_RESP_WIDTH'd1

`define HASTI_SIZE_WIDTH     3
`define HASTI_SIZE_BYTE      `HASTI_SIZE_WIDTH'd0
`define HASTI_SIZE_HALFWORD  `HASTI_SIZE_WIDTH'd1
`define HASTI_SIZE_WORD      `HASTI_SIZE_WIDTH'd2
