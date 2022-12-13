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

// In the event of publication, the following notice is applicable:
//
// (C) COPYRIGHT 2020 FRAUNHOFER INSTITUTE OF MICROELECTRONIC CIRCUITS
// AND SYSTEMS, DUISBURG, GERMANY.
// ALL RIGHTS RESERVED.
//
// The entire notice above must be reproduced on all authorized copies.
//
// File             : airi5c_fetch.v
// Author           : M. Richter, I. Hoyer, A. Stanitzki
// Creation Date    : 09.10.20?
// Last Modified    : 03.08.2022
// Version          : 1.1
// Abstract         : Airi5c Fetcher
// History          : 07.07.20 - rebranding to AIRI5C
//                    03.08.22 - Notice inserted, Fixing SlowRedirect functionality for ARTEMIS
`include "rv32_opcodes.vh"
`include "airi5c_arch_options.vh"
`include "airi5c_hasti_constants.vh"

`ifdef WITH_SAFETY_FEATURES
  `include "airisc_safety_options.vh"
`endif


module airi5c_fetch (     
// general I/O  
  input                  rst_ni,       
  input                  clk_i,
// core-side I/O  
  input   [`XPR_LEN-1:0] pc_pif_i,
  input                  kill_if_i,
  input                  de_ready_i,
  output wire [`XPR_LEN-1:0] pc_if_o,
  output wire [`XPR_LEN-1:0] inst_if_o,
  output wire                if_valid_o,

  output wire                compressed_o,
  output wire                predicted_branch_if_o,
  output wire [2:0]          error_in_if_o,
// memory-side I/O  
  input                           imem_hready_i, 
  output wire [`XPR_LEN-1:0]          imem_haddr_o,
  input   [`XPR_LEN-1:0]          imem_hrdata_i,
  input                           imem_badmem_i,
  output wire [`HASTI_TRANS_WIDTH-1:0] imem_htrans_o,
  output wire [`HASTI_BURST_WIDTH-1:0] imem_hburst_o,
  output wire                          imem_hmastlock_o,
  output wire [`HASTI_PROT_WIDTH-1:0]  imem_hprot_o

  `ifdef WITH_SAFETY_PREFETCH
  , input [7:0]           parity_i
  `endif
);

assign compressed_o = 1'b0;
assign predicted_branch_if_o = 1'b0;
assign error_in_if_o = 3'b0;

wire [`XPR_LEN-1:0] fetch_pc;
wire [`XPR_LEN-1:0] fetch_inst;
wire                fetch_valid;
wire                fetch_error;

reg [`XPR_LEN-1:0] pred_pc_r;
reg [`XPR_LEN-1:0] pred_inst_r;
reg                pred_valid_r;

// we assume the predictor is always able to 
// handle a new prediction in one cycle. So 
// we forward the "readyness" of the DE stage
// to stall the fetcher..

wire               pred_ready = de_ready_i;

assign pc_if_o    = pred_pc_r;
assign inst_if_o  = pred_inst_r;
assign if_valid_o = pred_valid_r;

airi5c_fetch_simple simple_fetcher(
 .rst_ni(rst_ni),
 .clk_i(clk_i),
 
 .pc_pif_i(pc_pif_i),
 .kill_if_i(kill_if_i),
 .de_ready_i(pred_ready),

 .pc_if_o(fetch_pc),
 .inst_if_o(fetch_inst),
 .if_valid_o(fetch_valid),
 
 .error_in_if_o(fetch_error),

 .imem_hready_i(imem_hready_i),
 .imem_haddr_o(imem_haddr_o),
 .imem_hrdata_i(imem_hrdata_i),
 .imem_badmem_i(imem_badmem_i),
 .imem_htrans_o(imem_htrans_o),
 .imem_hburst_o(imem_hburst_o),
 .imem_hmastlock_o(imem_hmastlock_o),
 .imem_hprot_o(imem_hprot_o)
);

always @(posedge clk_i or negedge rst_ni) begin
  if(~rst_ni) begin
    pred_valid_r <= 1'b0;
    pred_pc_r    <= 32'h80000000;
    pred_inst_r  <= 32'h00000013;
  end else begin
    if(kill_if_i) begin
      pred_valid_r <= 1'b0;
      pred_inst_r  <= 32'h00000013;
    end else begin
      if(de_ready_i) begin
        if(fetch_valid) begin
          pred_valid_r <= 1'b1;
          pred_pc_r    <= fetch_pc;
          pred_inst_r  <= fetch_inst;
        end else begin
          pred_inst_r  <= 32'h00000013;
          pred_valid_r <= 1'b0;       
        end
      end // if de_ready_i is 1'b0, we don't update anything.
    end
  end
end

endmodule
