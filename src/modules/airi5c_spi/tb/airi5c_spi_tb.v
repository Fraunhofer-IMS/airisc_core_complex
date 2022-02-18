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
// File              : airi5c_spi_tb.v
// Author            : A. Stanitzki    
// Date              : 11.11.2020
// Version           : 1.0         
// Abstract          : SPI testbench
// history           :
// Notes             :
`timescale 1ns/100ps


`include "airi5c_hasti_constants.vh"
module airi5c_spi_tb();

reg nreset, clk;

reg [`HASTI_ADDR_WIDTH-1:0]  haddr;
reg                          hwrite;
reg [`HASTI_SIZE_WIDTH-1:0]  hsize;
reg [`HASTI_BURST_WIDTH-1:0] hburst;
reg                          hmastlock;
reg [`HASTI_PROT_WIDTH-1:0]  hprot;
reg [`HASTI_TRANS_WIDTH-1:0] htrans;
reg [`HASTI_BUS_WIDTH-1:0]   hwdata;

wire [`HASTI_BUS_WIDTH-1:0]  hrdata_rx, hrdata_tx;
wire                         hready_rx, hready_tx;
wire [`HASTI_RESP_WIDTH-1:0] hresp_rx, hresp_tx;


airi5c_spi  #(
  .BASE_ADDR(32'hC0000020),
  .CLK_FREQ_KHZ(16000000),
  .DEFAULT_MASTER(1),
  .DEFAULT_SD(1)
) 
DUT_master (
  .n_reset(nreset),
  .clk(clk),

  .master_mosi(mosi),
  .master_miso(miso),
  .master_sclk(sclk),
  .master_nss(nss),

  .slave_mosi(1'b0),
  .slave_miso(),
  .slave_sclk(1'b0),
  .slave_nss(1'b1),
 
  .haddr(haddr),
  .hwrite(hwrite),
  .hsize(hsize),
  .hburst(hburst),
  .hmastlock(hmastlock),
  .hprot(hprot),
  .htrans(htrans),
  .hwdata(hwdata),
  .hrdata(hrdata_tx),
  .hready(hready_tx),
  .hresp(hresp_tx)
);

airi5c_spi  #(
  .BASE_ADDR(32'hC0000030),
  .CLK_FREQ_KHZ(16000000),
  .DEFAULT_MASTER(0),
  .DEFAULT_SD(1)
)
DUT_slave (
  .n_reset(nreset),
  .clk(clk),

  .master_mosi(),
  .master_miso(1'b0),
  .master_sclk(),
  .master_nss(),

  .slave_mosi(mosi),
  .slave_miso(miso),
  .slave_sclk(sclk),
  .slave_nss(nss),

  .haddr(haddr),
  .hwrite(hwrite),
  .hsize(hsize),
  .hburst(hburst),
  .hmastlock(hmastlock),
  .hprot(hprot),
  .htrans(htrans),
  .hwdata(hwdata),
  .hrdata(hrdata_tx),
  .hready(hready_tx),
  .hresp(hresp_tx)
);
always begin
  clk <= ~clk;
  #31;    // for 16MHz clock.
end


initial begin
  clk    <= 1'b0; nreset <= 1'b0; 
  haddr  <= 0;
  hwrite <= 0; hsize  <= 0; hburst <= 0; hmastlock <= 0;
  hprot  <= 0; htrans <= 0; hwdata <= 0;
    
  $display("tb started..\n");
  #50;
  nreset <= 1'b1;
  #50;
  @(posedge clk) hwrite <= 1'b1; haddr <= 32'hc0000028; htrans <= 1'b0;
  @(posedge clk) hwrite <= 1'b0; haddr <= 32'hdeadbeef; htrans <= 1'b0; hwdata <= 32'h00004000;
  @(posedge clk) hwrite <= 1'b1; haddr <= 32'hc0000024; htrans <= 1'b0;
  @(posedge clk) hwrite <= 1'b0; haddr <= 32'hdeadbeef; htrans <= 1'b0; hwdata <= 32'h00000001;
  @(posedge clk) hwdata <= 32'hdeadbeef;
  #400000;
  @(posedge clk) haddr  <= 32'hc0000038; htrans <= 1'b1;
  @(posedge clk) haddr  <= 32'hc0000034; htrans <= 1'b1;
  #100000;
  $finish();
end

endmodule