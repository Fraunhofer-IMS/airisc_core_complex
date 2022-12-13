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
// File             : airi5c_prebuf.v
// Author           : M. Richter
// Creation Date    : 11.01.22
// Last Modified    : 11.01.22
// Version          : 0.1
// Abstract         : Prefetch Buffer for the AIRISC.
// History          : 11.01.2022 - initial creation
// Notes            : 
//
// 

`include "airi5c_arch_options.vh"

module airi5c_prebuf (
  input                       clk_i,
  input                       rst_ni,
  input                       enable_push_i,
  input   [`PREFETCH_INPUTWIDTH-1:0]    data_i,
  input   [2:0]       index_i,
  output  [`PREFETCH_WIDTH-1:0]         data_o
);

`ifndef prebuf_shortcut
reg       [`PREFETCH_INPUTWIDTH-1:0]    data_q;

always @ (posedge clk_i or negedge rst_ni) begin
  if (!rst_ni) begin
    data_q <= `PREFETCH_INPUTWIDTH'h0;
  end else begin
    if (enable_push_i) begin
      data_q <= data_i;
    end
  end
end

airi5c_prebuf_fifo prebuf_fifo ( 
  .clk_i(clk_i),
  .rst_ni(rst_ni),
  .enable_push_i(enable_push_i),
  .data_i(data_q),
  .index_i(index_i),
  .data_o(data_o)
);
`else
assign data_o = data_i; 

`endif



endmodule
