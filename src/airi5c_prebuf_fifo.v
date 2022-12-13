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
//
// File             : airi5c_prebuf_fifo.v
// Author           : M. Richter
// Creation Date    : 20.12.21
// Last Modified    : 20.12.21
// Version          : 0.1
// Abstract         : Prefetch Buffer FIFO with parameterizable data width
//                    and depth. Allows direct feedthrough of data as well
//                    as reading data with halfword-alignment (required for
//                    RISC-V C-Extension support).
// History          : 20.12.2021 - initial creation
// Notes            : The input index_i is twice as wide as the FIFO depth.
//                    This is because it indexes the FIFO at a halfword 
//                    granularity. The width parameters must both be 
//                    multiples of 2. `PREFETCH_INPUTWIDTH_MULTIPLIER must be 1 or 2. 
//                    The depth is the number of `PREFETCH_WIDTH-bit 
//                    data values that fit into the FIFO. `PREFETCH_DEPTH must be at 
//                    least as big as `PREFETCH_INPUTWIDTH_MULTIPLIER.
//
// 

`include "airi5c_arch_options.vh"

module airi5c_prebuf_fifo (
  input                             clk_i,
  input                             rst_ni,
  input                             enable_push_i,
  input  [`PREFETCH_INPUTWIDTH-1:0] data_i,
  input  [2:0]                      index_i,
  output [`PREFETCH_WIDTH-1:0]      data_o
);

reg   [`PREFETCH_WIDTH-1:0]       data_q, data_q2; 
wire  [3*`PREFETCH_WIDTH-1:0]     indexed_data;

integer i;
always @(posedge clk_i or negedge rst_ni) begin
  if (!rst_ni) begin
    data_q <= `PREFETCH_WIDTH'h0;
    data_q2 <= `PREFETCH_WIDTH'h0;
  end else if (enable_push_i) begin 
    data_q <= data_i;
    data_q2 <= data_q;
  end
end

assign indexed_data = {data_i, data_q, data_q2};

assign data_o = (index_i == 3'b000) ? {16'h0, indexed_data[95:80]} :
                (index_i == 3'b001) ? indexed_data[95:64] :
                (index_i == 3'b010) ? indexed_data[79:48] :
                (index_i == 3'b011) ? indexed_data[63:32] :
                (index_i == 3'b100) ? indexed_data[47:16] :
                indexed_data[31:0];
endmodule
