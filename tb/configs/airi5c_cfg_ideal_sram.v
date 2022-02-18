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
// File              : airi5c_cfg_ideal_sram.v
// Author            : A. Stanitzki
// Creation Date     : 09.10.20
// Version           : 1.0         
// Abstract          : AIRI5C configuration with ideal SRAM
// Notes             : This configuration combines the AIRI5C core complex with
//                     an ideal SRAM model. It is used for verification purposes
//                     when the memory system doesn't need to be taken into account.
//                     This includes most of the work on the core complex itself, 
//                     the peripherals and custom instructions.
//
`timescale 1ns/1ns

`include "../src/airi5c_ctrl_constants.vh"
`include "../src/airi5c_csr_addr_map.vh"
`include "../src/airi5c_hasti_constants.vh"
`include "../src/airi5c_alu_ops.vh"
`include "../src/rv32_opcodes.vh"
`include "../src/airi5c_arch_options.vh"
`include "../src/airi5c_hasti_constants.vh"


module airi5c_cfg_ideal_sram(
   input                        VDD,
   input                        CLK,
   input                        nRESET,
   input                        EXT_INT, 

   // JTAG signals
   input                        tdi,
   input                        tms,
   input                        tck,
   output                       tdo,

   // default debug signals
   output [3:0]                 debug_state,
   output [7:0]                 debug_out,

   // scan chain interface
   input                        testmode,
   input                        sdi,
   output                       sdo,
   input                        sen,

   // additional, configuration specific 
   // signals. Might be unconnected in 
   // toplevel testbench.

   inout  [7:0]                 gpio,

   output                       uart_tx,
   input                        uart_rx,

   output                       spi_mosi,
   input                        spi_miso,
   output                       spi_sclk,
   output                       spi_nss
);


// ==========================================================
// ==   Core + Dual-Port-SRAM type memory     =
// ==========================================================
wire  [7:0]                     gpio_d, gpio_en;

wire  [`HASTI_ADDR_WIDTH-1:0]   imem_haddr;
wire                            imem_hwrite;
wire  [`HASTI_SIZE_WIDTH-1:0]   imem_hsize;
wire  [`HASTI_BURST_WIDTH-1:0]  imem_hburst;
wire                            imem_hmastlock;
wire  [`HASTI_PROT_WIDTH-1:0]   imem_hprot;
wire  [`HASTI_TRANS_WIDTH-1:0]  imem_htrans;
wire  [`HASTI_BUS_WIDTH-1:0]    imem_hwdata;
wire  [`HASTI_BUS_WIDTH-1:0]    imem_hrdata;
wire                            imem_hready;
wire                            imem_hresp;

wire  [`HASTI_ADDR_WIDTH-1:0]   dmem_haddr;
wire                            dmem_hwrite;
wire  [`HASTI_SIZE_WIDTH-1:0]   dmem_hsize;
wire  [`HASTI_BURST_WIDTH-1:0]  dmem_hburst;
wire                            dmem_hmastlock;
wire  [`HASTI_PROT_WIDTH-1:0]   dmem_hprot;
wire  [`HASTI_TRANS_WIDTH-1:0]  dmem_htrans;
wire  [`HASTI_BUS_WIDTH-1:0]    dmem_hwdata;
wire  [`HASTI_BUS_WIDTH-1:0]    dmem_hrdata;
wire                            dmem_hready;
wire                            dmem_hresp;

airi5c_dp_hasti_sram SRAM(
  .hclk(CLK),
  .hresetn(nRESET),
  .p0_haddr({14'h0,dmem_haddr[17:0]}),
  .p0_hwrite(dmem_hwrite & (dmem_haddr[31:30] == 2'b10)),
  .p0_hsize(dmem_hsize),
  .p0_hburst(dmem_hburst),
  .p0_hmastlock(dmem_hmastlock),
  .p0_hprot(dmem_hprot),
  .p0_htrans(dmem_htrans),
  .p0_hwdata(dmem_hwdata),
  .p0_hrdata(dmem_hrdata),
  .p0_hready(dmem_hready),
  .p0_hresp(dmem_hresp),

  .p1_haddr({14'h0,imem_haddr[17:0]}),
  .p1_hwrite(imem_hwrite),
  .p1_hsize(imem_hsize),
  .p1_hburst(imem_hburst),
  .p1_hmastlock(imem_hmastlock),
  .p1_hprot(imem_hprot),
  .p1_htrans(imem_htrans),
  .p1_hwdata(imem_hwdata),
  .p1_hrdata(imem_hrdata),
  .p1_hready(imem_hready),
  .p1_hresp(imem_hresp)
);

// generate tristate outputs for gpio 
genvar i;
generate
  for (i = 0; i < 8; i = i + 1) begin : GPIO_bufs
    bufif1(gpio[i],gpio_d[i],gpio_en[i]);
  end
endgenerate 


airi5c_top_asic DUT(
  .clk(CLK),
  .nreset(nRESET),
  .ext_interrupt(EXT_INT),
  .testmode(testmode),

  .imem_haddr(imem_haddr),
  .imem_hwrite(imem_hwrite),
  .imem_hsize(imem_hsize),
  .imem_hburst(imem_hburst),
  .imem_hmastlock(imem_hmastlock),
  .imem_hprot(imem_hprot),
  .imem_htrans(imem_htrans),
  .imem_hwdata(imem_hwdata),
  .imem_hrdata(imem_hrdata),
  .imem_hready(imem_hready),
  .imem_hresp(imem_hresp),

  .dmem_haddr(dmem_haddr),
  .dmem_hwrite(dmem_hwrite),
  .dmem_hsize(dmem_hsize),
  .dmem_hburst(dmem_hburst),
  .dmem_hmastlock(dmem_hmastlock),
  .dmem_hprot(dmem_hprot),
  .dmem_htrans(dmem_htrans),
  .dmem_hwdata(dmem_hwdata),
  .dmem_hrdata(dmem_hrdata),
  .dmem_hready(dmem_hready),
  .dmem_hresp(dmem_hresp),

  .oGPIO_D(gpio_d),
  .oGPIO_EN(gpio_e),
  .iGPIO_I(gpio),

  .oUART_TX(uart_tx),
  .iUART_RX(uart_rx),

  .oSPI1_MOSI(spi_mosi),
  .oSPI1_SCLK(spi_sclk),
  .oSPI1_NSS(spi_nss),
  .iSPI1_MISO(spi_miso),
  
  .tdi(tdi),
  .tdo(tdo),
  .tms(tms),
  .tck(tck),

  .debug_out(debug_out)  
);

endmodule
