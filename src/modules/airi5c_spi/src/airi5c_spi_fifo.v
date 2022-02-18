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
// File              : airi5c_uart_fifo.v
// Author            : A. Stanitzki    
// Creation Date     : 28.10.20
// Last Modified     : 15.02.21
// Version           : 1.0         
// Abstract          : FIFO for UART buffering
//
`timescale 1ns/100ps

`include "airi5c_hasti_constants.vh"
// `define XPR_LEN 32

module airi5c_uart_fifo
  #(
  parameter FIFO_DEPTH     = 16,
  parameter FIFO_WIDTH     = 8)
  (
  // system clk and reset
  input                       n_reset,    // active high async reset
  input                       clk,        // clock

  // write portS
  input      [FIFO_WIDTH-1:0] din,
  input                       wen,

  // read port
  output reg [FIFO_WIDTH-1:0] dout,
  output reg                  dvalid,
  output reg                  fifo_full, 
  output reg                  fifo_half, 
  output reg                  fifo_empty, 
  input                       dready
);

reg [FIFO_WIDTH-1:0] fifo_mem_r[FIFO_DEPTH-1:0];
reg [`XPR_LEN-1:0]   wpt_r, rpt_r;

reg [`XPR_LEN-1:0]   next_wpt, next_rpt;
reg [FIFO_WIDTH-1:0] next_dout;
reg                  next_dvalid, next_fifo_full, next_fifo_half, next_fifo_empty;
reg [`XPR_LEN-1:0]   fcnt_r, next_fcnt;

integer    index;

always @(posedge clk or negedge n_reset) begin
  if (~n_reset) begin
    for (index=0; index<=(FIFO_DEPTH-1); index=index+1) begin
          fifo_mem_r[index] <= {FIFO_WIDTH{1'b0}};
    end
    dvalid      <= 1'b0;
    fifo_full   <= 1'b0;
    fifo_empty  <= 1'b1;
    fifo_half   <= 1'b1;
    wpt_r       <= `XPR_LEN'h0;
    rpt_r       <= `XPR_LEN'h0;
    fcnt_r      <= `XPR_LEN'h0;
  end else begin
    dvalid     <= next_dvalid;
    fifo_full  <= next_fifo_full;
    fifo_half  <= next_fifo_half;
    fifo_empty <= next_fifo_empty;
    wpt_r      <= next_wpt;
    rpt_r      <= next_rpt; 
    fcnt_r     <= next_fcnt;

    if (wen & ~fifo_full) fifo_mem_r[wpt_r] <= din;

  end
end

always @* begin
  next_wpt        = wpt_r; //`XPR_LEN'h0;
  next_rpt        = rpt_r; //`XPR_LEN'h0;
  next_dout       = dout;
  next_dvalid     = 1'b0;
  next_fifo_full  = fifo_full;
  next_fifo_half  = fifo_half;
  next_fifo_empty = fifo_empty;  
  next_fcnt       = fcnt_r;

  if (dready & dvalid) begin
    next_rpt = ((rpt_r + `XPR_LEN'h1) > (FIFO_DEPTH-1)) ? `XPR_LEN'h0 : rpt_r + `XPR_LEN'h1;        
  end

  if (wen & ~fifo_full) begin
    next_wpt = ((wpt_r + `XPR_LEN'h1) > (FIFO_DEPTH-1)) ? `XPR_LEN'h0 : wpt_r + `XPR_LEN'h1;
  end

  if (wen == dready) begin
    next_fifo_full = fifo_full;
    next_fifo_empty = fifo_empty;
  end else begin
    if (wen) begin
      next_fifo_empty = 1'b0;
      next_fcnt = fifo_full ? fcnt_r : fcnt_r + `XPR_LEN'h1;
      if (next_fcnt == FIFO_DEPTH) next_fifo_full = 1'b1;
    end else
    if (dready) begin 
      next_fifo_full = 1'b0;
      next_fcnt = fifo_empty ? fcnt_r : fcnt_r - `XPR_LEN'h1;
      if (next_fcnt == 0) next_fifo_empty = 1'b1;
    end
  end    

  next_dvalid = ~next_fifo_empty;
  dout = fifo_mem_r[rpt_r];
  next_fifo_half = (next_fcnt >= ((FIFO_DEPTH-1)>>1)) ? 1'b1 : 1'b0;
end

endmodule