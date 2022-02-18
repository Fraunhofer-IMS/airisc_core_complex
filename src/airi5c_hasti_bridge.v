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
// File             : airi5c_hasti_bridge.v
// Author           : A. Stanitzki
// Creation Date    : 09.10.20
// Last Modified    : 15.02.21
// Version          : 1.0
// Abstract         : AHB-Lite signal generation
// Notes            : The core communicates in a AHB-Lite fashion, with separate address and data cycle. 
//                    This module adds some logic to generate the AHB-Lite control signals.
//                    This is purely combinational, in contrast to the "airi5c_sync_to_hasti_bridge.v" 
//                    which interfaces single-cycle devices to the AHB-Lite bus.
//

`include "airi5c_hasti_constants.vh"

module airi5c_hasti_bridge(
  input                           clk,
  input                           nreset,
  output [`HASTI_ADDR_WIDTH-1:0]  haddr,
  output                          hwrite,
  output [`HASTI_SIZE_WIDTH-1:0]  hsize,
  output [`HASTI_BURST_WIDTH-1:0] hburst,
  output                          hmastlock,
  output [`HASTI_PROT_WIDTH-1:0]  hprot,
  output [`HASTI_TRANS_WIDTH-1:0] htrans,
  output [`HASTI_BUS_WIDTH-1:0]   hwdata,
  input [`HASTI_BUS_WIDTH-1:0]    hrdata,
  input                           hready,
  input [`HASTI_RESP_WIDTH-1:0]   hresp,
  input                           core_mem_en,
  input                           core_mem_wen,
  input [`HASTI_SIZE_WIDTH-1:0]   core_mem_size,
  input [`HASTI_ADDR_WIDTH-1:0]   core_mem_addr,
  input [`HASTI_BUS_WIDTH-1:0]    core_mem_wdata_delayed,
  output [`HASTI_BUS_WIDTH-1:0]   core_mem_rdata,
  output                          core_mem_wait,
  output                          core_badmem_e
);


assign haddr     = core_mem_addr;
assign hwrite    = core_mem_wen;
assign hsize     = core_mem_size;
assign hburst    = `HASTI_BURST_SINGLE;
assign hmastlock = `HASTI_MASTER_NO_LOCK;
assign hrpot     = `HASTI_NO_PROT;
assign htrans    = core_mem_en ? `HASTI_TRANS_NONSEQ : `HASTI_TRANS_IDLE;
assign hwdata    = core_mem_wdata_delayed;

assign core_mem_rdata = hrdata;
assign core_mem_wait  = ~hready;
assign core_badmem_e  = (hresp == `HASTI_RESP_ERROR) ? 1'b1 : 1'b0;

/*
reg [1:0] state, state_next;

reg [`HASTI_ADDR_WIDTH-1:0]  haddr_r;     assign haddr     = haddr_r;
reg                          hwrite_r;    assign hwrite    = hwrite_r;
reg [`HASTI_SIZE_WIDTH-1:0]  hsize_r;     assign hsize     = hsize_r;
reg [`HASTI_BURST_WIDTH-1:0] hburst_r;    assign hburst    = hburst_r;
reg                          hmastlock_r; assign hmastlock = hmastlock_r; 
reg [`HASTI_PROT_WIDTH-1:0]  hprot_r;     assign hprot     = hprot_r;
reg [`HASTI_TRANS_WIDTH-1:0] htrans_r;    assign htrans    = htrans_r;
reg [`HASTI_BUS_WIDTH-1:0]   hwdata_r;    assign hwdata    = hwdata_r;

reg [`HASTI_BUS_WIDTH-1:0]   core_mem_rdata_r;    assign core_mem_rdata = core_mem_rdata_r;
reg                          core_mem_wait_r;     assign core_mem_wait  = core_mem_wait_r;
reg                          core_badmem_e_r;     assign core_badmem_e  = core_badmem_e_r;


reg [`HASTI_ADDR_WIDTH-1:0]  stored_addr_r;

localparam [1:0] IDLE    = 2'h0,
                 RUNNING = 2'h1,
                 REPLAY  = 2'h2,
                 WAIT    = 2'h3;

always @(posedge clk or negedge nreset) begin
   if(~nreset) begin
      state <= IDLE;
      stored_addr_r <= 0;
   end else begin
      state <= state_next;
      if((state == RUNNING) || (state == WAIT) && (core_mem_en & ~hready)) begin
         stored_addr_r <= core_mem_addr;
      end
   end
end

always @(*) begin
   haddr_r          = core_mem_addr;
   hwrite_r         = core_mem_wen; // core_mem_en && core_mem_wen;
   hsize_r          = core_mem_size;
   hburst_r         = `HASTI_BURST_SINGLE;
   hmastlock_r      = `HASTI_MASTER_NO_LOCK;
   hprot_r          = `HASTI_NO_PROT;
   htrans_r         = core_mem_en ? `HASTI_TRANS_NONSEQ : `HASTI_TRANS_IDLE;
   hwdata_r         = core_mem_wdata_delayed;
   core_mem_rdata_r = hrdata;
   core_mem_wait_r  = ~hready;
   core_badmem_e_r  = (hresp == `HASTI_RESP_ERROR) ? 1'b1 : 1'b0;
   state_next       = IDLE;

   case(state) 
      IDLE    : begin 
                   state_next = core_mem_en ? RUNNING : IDLE;
                 end
      RUNNING : begin
                   htrans_r   = (core_mem_en & hready) ? `HASTI_TRANS_NONSEQ : `HASTI_TRANS_IDLE;
                   state_next = (core_mem_en & hready) ? RUNNING : 
                                (core_mem_en & ~hready) ? WAIT : 
                                (~core_mem_en & hready) ? IDLE : RUNNING;
                 end
      WAIT   : begin
                   state_next      = hready ? REPLAY : WAIT;
                   core_mem_wait_r = 1'b1;
                   core_mem_rdata_r = 32'h13;
                   haddr_r         = stored_addr_r;
                   htrans_r        = hready ? `HASTI_TRANS_NONSEQ : `HASTI_TRANS_IDLE;
                 end
      REPLAY : begin
                   state_next      = hready ? (core_mem_en ? RUNNING : IDLE) : REPLAY;
                   core_mem_wait_r = ~hready;
                   core_mem_rdata_r = hready ? hrdata : 32'h13;
                   htrans_r        = core_mem_en ? `HASTI_TRANS_NONSEQ : `HASTI_TRANS_IDLE;
                 end
   endcase
end

*/
endmodule

