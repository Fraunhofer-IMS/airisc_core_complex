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
// File             : airi5c_mem_arbiter.v
// Author           : A. Stanitzki
// Creation Date    : 09.10.20
// Last Modified    : 15.02.21
// Version          : 1.0
// Abstract         : Memory Arbiter to differentiate between internal 
//                    memory access (to SRAM) and external going to the 
//                    quad-spi nvSRAM
//
`include "airi5c_hasti_constants.vh"
`include "airi5c_arch_options.vh"

module airi5c_mem_arbiter(
input                                nreset,
input                                clk,

output  reg [`HASTI_ADDR_WIDTH-1:0]  mem_haddr,
output  reg                          mem_hwrite,
output  reg [`HASTI_SIZE_WIDTH-1:0]  mem_hsize,
output  reg [`HASTI_BURST_WIDTH-1:0] mem_hburst,
output  reg                          mem_hmastlock,
output  reg [`HASTI_PROT_WIDTH-1:0]  mem_hprot,
output  reg [`HASTI_TRANS_WIDTH-1:0] mem_htrans,
output  reg [`HASTI_BUS_WIDTH-1:0]   mem_hwdata,
input       [`HASTI_BUS_WIDTH-1:0]   mem_hrdata,
input                                mem_hready,
input       [`HASTI_RESP_WIDTH-1:0]  mem_hresp,

input       [`HASTI_ADDR_WIDTH-1:0]  imem_haddr,
input                                imem_hwrite,      // unused, as imem is read-only (typically)
input       [`HASTI_SIZE_WIDTH-1:0]  imem_hsize,
input       [`HASTI_BURST_WIDTH-1:0] imem_hburst,
input                                imem_hmastlock,
input       [`HASTI_PROT_WIDTH-1:0]  imem_hprot,
input       [`HASTI_TRANS_WIDTH-1:0] imem_htrans,
input       [`HASTI_BUS_WIDTH-1:0]   imem_hwdata,     // unused, as imem is read-only (typically)
output      [`HASTI_BUS_WIDTH-1:0]   imem_hrdata,
output                               imem_hready,
output      [`HASTI_RESP_WIDTH-1:0]  imem_hresp,

input       [`HASTI_ADDR_WIDTH-1:0]  dmem_haddr,
input                                dmem_hwrite,      // unused, as imem is read-only (typically)
input       [`HASTI_SIZE_WIDTH-1:0]  dmem_hsize,
input       [`HASTI_BURST_WIDTH-1:0] dmem_hburst,
input                                dmem_hmastlock,
input       [`HASTI_PROT_WIDTH-1:0]  dmem_hprot,
input       [`HASTI_TRANS_WIDTH-1:0] dmem_htrans,
input       [`HASTI_BUS_WIDTH-1:0]   dmem_hwdata,      // unused, as imem is read-only (typically)
output      [`HASTI_BUS_WIDTH-1:0]   dmem_hrdata,
output                               dmem_hready,
output      [`HASTI_RESP_WIDTH-1:0]  dmem_hresp
);


`define RESET        4'hf
`define IDLE         4'h0
`define IMEM_START   4'h1
`define IMEM_WAITMEM 4'h2
`define DMEM_START   4'h3
`define DMEM_WAITMEM 4'h4
`define DMEM_WDATA   4'h5
`define IMEM_WDATA   4'h6
`define DMEM_READY   4'h7
`define IMEM_READY   4'h8

reg [3:0]   state, next_state;

reg [31:0]  pending_imem_addr;
reg [31:0]  pending_imem_wdata;
reg         pending_imem_write;
reg [2:0]   pending_imem_size;
reg         pending_imem;
reg         got_dmem_htrans;

reg [31:0]  pending_dmem_addr;
reg [31:0]  pending_dmem_wdata;
reg         pending_dmem_write;
reg [2:0]   pending_dmem_size;
reg         pending_dmem;
reg         got_imem_htrans;

reg [`HASTI_BUS_WIDTH-1:0]  imem_hrdata_r;  assign imem_hrdata = imem_hrdata_r;
reg [`HASTI_RESP_WIDTH-1:0] imem_hresp_r;   assign imem_hresp  = imem_hresp_r;
reg                         imem_hready_r;  assign imem_hready = imem_hready_r;

reg [`HASTI_BUS_WIDTH-1:0]  dmem_hrdata_r;  assign dmem_hrdata = dmem_hrdata_r;
reg [`HASTI_RESP_WIDTH-1:0] dmem_hresp_r;   assign dmem_hresp  = dmem_hresp_r;
reg dmem_hready_r;                          assign dmem_hready = dmem_hready_r;

wire  [`HASTI_BUS_WIDTH-1:0]  memory_response; assign memory_response = mem_hrdata;
wire  [`HASTI_RESP_WIDTH-1:0] memory_hresp;    assign memory_hresp = mem_hresp;

// if there is a dmem access, the pending 
// imem access will be performed afterwards.
// Thus we need to remember the pending imem request..

always @(posedge clk or negedge nreset) begin
  if(~nreset) begin
    state              <= `RESET;
    pending_dmem       <= 1'b0;
    pending_imem       <= 1'b0;
    got_dmem_htrans    <= 1'b0;
    got_imem_htrans    <= 1'b0;
    imem_hrdata_r      <= 32'hdeadbeef;
    dmem_hrdata_r      <= 32'hdeadbeef;
    pending_dmem_write <= 1'b0;
    pending_imem_write <= 1'b0;
    pending_imem_addr  <= 32'hdeadbeef;
    pending_dmem_addr  <= 32'hdeadbeef;
  end else begin
    if(|dmem_htrans && (dmem_haddr[31:28] == 4'h8)) begin
      pending_dmem_addr      <= dmem_haddr;
      pending_dmem_write     <= dmem_hwrite;
      pending_dmem_size      <= dmem_hsize;
      pending_dmem           <= 1'b1;
      got_dmem_htrans        <= 1'b1;
    end else got_dmem_htrans <= 1'b0;
    if(|imem_htrans && (imem_haddr[31:28] == 4'h8)) begin
      pending_imem_addr      <= imem_haddr;
      pending_imem_write     <= imem_hwrite;
      pending_imem_size      <= imem_hsize;
      pending_imem           <= 1'b1;
      got_imem_htrans        <= 1'b1;
    end else got_imem_htrans <= 1'b0;
    if(state == `DMEM_WAITMEM) begin
      if(mem_hready) begin  
        dmem_hrdata_r <= memory_response; // mem_hrdata;
        dmem_hresp_r  <= memory_hresp; //mem_hresp;
        pending_dmem  <= 1'b0;
      end   
    end
    if(state == `IMEM_WAITMEM) begin
      if(mem_hready) begin
        imem_hrdata_r <= mem_hrdata;
        imem_hresp_r  <= mem_hresp;
        pending_imem  <= 1'b0;
      end   
    end
    if(got_imem_htrans) pending_imem_wdata <= imem_hwdata;
    if(got_dmem_htrans) pending_dmem_wdata <= dmem_hwdata;

    state <= next_state;
  end
end



always @(*) begin
  imem_hready_r = 1'b0;
  dmem_hready_r = 1'b0;
  mem_haddr     = 0;
  mem_hwrite    = 0;
  mem_hsize     = 0;
  mem_hburst    = 0;
  mem_hmastlock = 1'h0;
  mem_hprot     = 4'h0;
  mem_htrans    = 2'h0;
  mem_hwdata    = 0;
  next_state    = `RESET;

  case (state) 
  `RESET  : begin 
        next_state = `IMEM_START;
      end
  `IDLE   : begin
        imem_hready_r = 1'b1;
        dmem_hready_r = 1'b1;
        if(|dmem_htrans && (dmem_haddr[31:28] == 4'h8)) begin
          next_state = dmem_hwrite ? `DMEM_WDATA : `DMEM_START;
        end else 
        if(|imem_htrans && (imem_haddr[31:28] == 4'h8)) begin
          next_state = imem_hwrite ? `IMEM_WDATA : `IMEM_START;
        end else next_state = `IDLE;
      end
  `IMEM_WDATA : begin 
        next_state = `IMEM_START;
      end
  `IMEM_START : begin   
        next_state = `IMEM_WAITMEM;
        mem_haddr  = pending_imem_addr;
        mem_hwrite = pending_imem_write;
        mem_hsize  = pending_imem_size;
        mem_hburst = 0;
        mem_hmastlock = 0;
        mem_hprot  = 0;
        mem_htrans = 2'b11;
        mem_hwdata = pending_imem_wdata;  
      end
  `IMEM_WAITMEM : begin 
        mem_haddr  = pending_imem_addr;
        mem_hwrite = pending_imem_write;
        mem_hsize  = pending_imem_size;
        mem_hburst = 0;
        mem_hmastlock = 0;
        mem_hprot  = 0;
        mem_htrans = 2'b00;
        mem_hwdata = pending_imem_wdata;  
        next_state = mem_hready ? (pending_dmem ? `DMEM_START : `IDLE) : `IMEM_WAITMEM;
      end
  `DMEM_WDATA : begin 
        next_state = `DMEM_START;
    end
  `DMEM_START : begin
        next_state = `DMEM_WAITMEM;
        mem_haddr  = pending_dmem_addr;
        mem_hwrite = pending_dmem_write;
        mem_hsize  = pending_dmem_size;
        mem_hburst = 0;
        mem_hmastlock = 0;
        mem_hprot  = 0;
        mem_htrans = 2'b11;
        mem_hwdata = pending_dmem_wdata;  
      end
  `DMEM_WAITMEM : begin
        mem_haddr  = pending_dmem_addr;
        mem_hwrite = pending_dmem_write;
        mem_hsize  = pending_dmem_size;
        mem_hburst = 0;
        mem_hmastlock = 0;
        mem_hprot  = 0;
        mem_htrans = 2'b00;
        mem_hwdata = pending_dmem_wdata;  
        next_state = mem_hready ? (pending_imem ? `IMEM_START : `IDLE) : `DMEM_WAITMEM; // always read IMEM after DMEM
      end 
  endcase
end

endmodule 
