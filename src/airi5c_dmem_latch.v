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
`include "airi5c_alu_ops.vh"
`include "rv32_opcodes.vh"
`include "airi5c_csr_addr_map.vh"
`include "airi5c_arch_options.vh"

module dmem_latch(
  input                  clk,
  input                  nreset,
  input  [`XPR_LEN-1:0]  alu_out,
  input                  loadstore_EX,
  output [`XPR_LEN-1:0]  dmem_addr
);

reg  [`XPR_LEN-1:0]  dmem_addr_r;

always @(posedge clk or negedge nreset) begin
  if(~nreset)
    dmem_addr_r <= 0;
  else begin
    dmem_addr_r <= loadstore_EX ? alu_out : dmem_addr_r;
  end
end

assign dmem_addr = loadstore_EX ? alu_out : dmem_addr_r;

endmodule
