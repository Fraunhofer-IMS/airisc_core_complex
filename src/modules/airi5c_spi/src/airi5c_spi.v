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
// File              : airi5c_spi.v
// Author            : A. Stanitzki    
// Creation Date     : 11.11.20
// Last Modified     : 15.02.21
// Version           : 1.0         
// Abstract          : SPI Master/Slave module with AHB-Lite interface

`include "airi5c_hasti_constants.vh"
//`include "rv32_opcodes.vh"

module airi5c_spi
  #(
  parameter BASE_ADDR   = 32'hC0000030, 
  parameter CLK_FREQ_HZ = 16000000,
  parameter DEFAULT_SD  = 1'b0,
  parameter DEFAULT_MASTER = 1'b1)
  (
  // system clk and reset
  input                              n_reset,  // active low async reset
  input                              clk,    // clock
  // Toggle Pad Drivers
  output                             enable_master,  // 1 = drive enable for mosi, sclk and nss
                                                     //     drive disable for miso
                                                     // 0 = vice versa.
  // SPI Master Port
  input                              master_miso,  
  output  reg                        master_mosi,
//  output  reg                        master_sclk,
  output                             master_sclk,
  output  reg                        master_nss,

  // SPI Slave Port
  output  reg                        slave_miso,
  input                              slave_mosi,
  input                              slave_sclk,
  input                              slave_nss,

  // AHB-Lite interface
  input   [`HASTI_ADDR_WIDTH-1:0]    haddr,    
  input                              hwrite,   
  input   [`HASTI_SIZE_WIDTH-1:0]    hsize,
  input   [`HASTI_BURST_WIDTH-1:0]   hburst,
  input                              hmastlock,
  input   [`HASTI_PROT_WIDTH-1:0]    hprot,
  input   [`HASTI_TRANS_WIDTH-1:0]   htrans,
  input   [`HASTI_BUS_WIDTH-1:0]     hwdata,
  output  reg [`HASTI_BUS_WIDTH-1:0] hrdata,
  output                             hready,
  output    [`HASTI_RESP_WIDTH-1:0]  hresp
);

assign hready = 1'b1;

`define SPI_MAX_LEN 64
`define SPI_REG_ADDR_CTRL BASE_ADDR + 32'h0
`define SPI_REG_ADDR_DIO  BASE_ADDR + 32'h4
`define SPI_REG_ADDR_DIO_H  BASE_ADDR + 32'h8

// default: slave, 100kHz from 32MHz, 8 bit, no int, SD mode.
`define SPI_REG_DEFAULT_CTRL_SLAVE  32'h00708000
`define SPI_REG_DEFAULT_CTRL_MASTER 32'h00708008
`define SPI_REG_DEFAULT_CTRL_SD_SLAVE 32'h00730000
`define SPI_REG_DEFAULT_CTRL_SD_MASTER  32'h00730008

reg [`HASTI_ADDR_WIDTH-1:0] haddr_r;
reg                         hwrite_r;

reg [`XPR_LEN-1:0]          spi_ctrl_r;
reg [`XPR_LEN-1:0]          spi_dio_r;
reg [`XPR_LEN-1:0]          spi_dio_h_r;


wire        spi_ready;   //= spi_ctrl_r[31];  // byte in rx buffer (slave mode) or ready to send (master mode)
// 30:28 unused
wire  [7:0] spi_clkdiv  = spi_ctrl_r[27:20];  // f_sclk = (fclk >> spi_clkdiv[7:0])
// 19 unused
wire  [6:0] spi_datalen = spi_ctrl_r[18:12];  // 0 - 64 bit transactions
// 11:10 unused
wire  [1:0] spi_mode    = spi_ctrl_r[9:8];
// 7:5 unused
wire        spi_rxint   = spi_ctrl_r[4];    // generate an interrupt if a byte has been received (slave mode)
wire        spi_master  = spi_ctrl_r[3];    // 0 - slave, 1 - master
wire        spi_sdmode  = spi_ctrl_r[2];    // spi master in SD card mode (sends CMD0 after reset)
wire        spi_testgen = spi_ctrl_r[1];    // continuously send test byte A5..
wire        spi_forcess = spi_ctrl_r[0];    // 1 - force nss LOW, 0 - nss set by transaction


reg         tx_start_r;
wire        running;
reg         master_running, slave_running;
assign      running = spi_master ? master_running : slave_running;
assign      enable_master = master_running;

reg         master_ready, slave_ready;
assign      spi_ready = spi_master ? master_ready : slave_ready;

reg [31:0]  clkdiv_r, next_clkdiv;
reg         bit_done;

reg [`SPI_MAX_LEN-1:0]  shiftreg_r, next_master_shiftreg, next_slave_shiftreg;


always @(posedge clk or negedge n_reset) begin
  if(~n_reset) begin
    haddr_r  <= `HASTI_ADDR_WIDTH'h0;
    hwrite_r <= 1'b0;
  end else begin 
    haddr_r  <= haddr;
    hwrite_r <= hwrite;
  end
end

always @(posedge clk or negedge n_reset) begin
  if(~n_reset) begin
    hrdata      <= `HASTI_BUS_WIDTH'h0;
    if((DEFAULT_SD == 1) && (DEFAULT_MASTER == 1)) 
      spi_ctrl_r <= `SPI_REG_DEFAULT_CTRL_SD_MASTER;
    else if(DEFAULT_SD) 
      spi_ctrl_r  <= `SPI_REG_DEFAULT_CTRL_SD_SLAVE;
    else if(DEFAULT_MASTER)
      spi_ctrl_r  <= `SPI_REG_DEFAULT_CTRL_MASTER;
    else
      spi_ctrl_r <= `SPI_REG_DEFAULT_CTRL_SLAVE;
    spi_dio_r <= 32'h0;
    spi_dio_h_r <= 32'h0;
    tx_start_r  <= 1'b0;
  end else begin
    if(hwrite_r) begin
      if(haddr_r == `SPI_REG_ADDR_CTRL) begin 
        spi_ctrl_r[23:0] <= hwdata[23:0];
      end

      if(haddr_r == `SPI_REG_ADDR_DIO) begin 
        spi_dio_r <= hwdata[31:0];               
        tx_start_r <= 1'b1;
      end

      if(haddr_r == `SPI_REG_ADDR_DIO_H) begin
        spi_dio_h_r <= hwdata[31:0];
      end
    end else tx_start_r <= 1'b0;

    if(|htrans) begin
      case(haddr)
        (`SPI_REG_ADDR_CTRL) :  begin hrdata <= {spi_ready,spi_ctrl_r[30:0]}; end
        (`SPI_REG_ADDR_DIO)  :  begin 
          if(spi_ready)  
            hrdata <= shiftreg_r[`XPR_LEN-1:0]; 
          else 
            hrdata <= `XPR_LEN'hdeadbee1;       
          end
        (`SPI_REG_ADDR_DIO_H) : begin 
          if(spi_ready)  
            hrdata <= shiftreg_r[`SPI_MAX_LEN-1:`XPR_LEN]; 
          else 
            hrdata <= `XPR_LEN'hdeadbee2;       
          end
        default: ;
      endcase
    end
  end
end

assign hresp = `HASTI_RESP_OKAY;

// SPI clock generation

wire  [31:0]  cycles_per_symbol; assign cycles_per_symbol = (1 << spi_clkdiv[7:0]);

always @(posedge clk or negedge n_reset) begin
  if(~n_reset) begin
    clkdiv_r <= 32'h0;
  end else begin
    if(running) 
      clkdiv_r <= next_clkdiv;
    else
      clkdiv_r <= 0;
  end
end



always @* begin
  if(running) begin
    next_clkdiv = (clkdiv_r == cycles_per_symbol) ? 32'h0 : (clkdiv_r + 32'h1);
  end else
    next_clkdiv = 0;

  bit_done = (clkdiv_r == cycles_per_symbol) ? 1'b1 : 1'b0;  //always counts up to one clk cycle
end

// Master FSM
`define MASTER_FSM_IDLE     3'h0
`define MASTER_FSM_GETDATA  3'h1
`define MASTER_FSM_SEND     3'h2
`define MASTER_FSM_STORE    3'h3

reg [2:0] master_state_r, next_master_state;
reg [6:0] master_bitcnt_r, next_master_bitcnt;

reg master_sclk_pa0;
reg master_sclk_pa1;
wire master_sclk_l;
assign master_sclk_l = (spi_mode[1] == 0)? master_sclk_pa0 : master_sclk_pa1;
assign master_sclk = (spi_mode[0] == 0)? master_sclk_l : ~master_sclk_l;

always @(posedge clk or negedge n_reset) begin
  if(~n_reset) begin
    master_state_r <= `MASTER_FSM_IDLE;
    shiftreg_r <= `SPI_MAX_LEN'h0;
    master_bitcnt_r <= 7'h8;
  end else begin 
    master_state_r <= next_master_state;
    shiftreg_r <= spi_master ? next_master_shiftreg : next_slave_shiftreg;
    master_bitcnt_r <= next_master_bitcnt;
  end
end

always @* begin
  next_master_state = `MASTER_FSM_IDLE;
  master_running    = 1'b0;
  next_master_bitcnt= spi_datalen;
  master_ready    = 1'b0;
  master_mosi   = 1'b0;
  master_nss    = 1'b1;
  master_sclk_pa0   = 1'b0;
  master_sclk_pa1   = 1'b0;
  next_master_shiftreg  = shiftreg_r;

  case(master_state_r) 
    `MASTER_FSM_IDLE   : begin 
      next_master_state = (spi_master & tx_start_r) ? `MASTER_FSM_GETDATA : `MASTER_FSM_IDLE;
      master_ready = 1'b1 & ~tx_start_r;
     end
    `MASTER_FSM_GETDATA : begin         
      master_running = 1'b1;
      master_nss = 1'b0;
      next_master_shiftreg = ({spi_dio_h_r,spi_dio_r} << (`SPI_MAX_LEN-spi_datalen)); // load data to MSB of shift reg.
      next_master_state = bit_done ? `MASTER_FSM_SEND : `MASTER_FSM_GETDATA;
    end
    `MASTER_FSM_SEND : begin
      master_running = 1'b1;
      master_nss = 1'b0;
      master_mosi = shiftreg_r[`SPI_MAX_LEN-1];
	  if(master_bitcnt_r == 0) next_master_state = `MASTER_FSM_STORE;
	  else begin 
      master_sclk_pa0 = (clkdiv_r > (cycles_per_symbol >> 1)) ? 1'b1 : 1'b0;
      master_sclk_pa1 = (clkdiv_r > (cycles_per_symbol >> 1)) ? 1'b0 : 1'b1;
      next_master_shiftreg = bit_done ? {shiftreg_r[`SPI_MAX_LEN-2:0],master_miso} : shiftreg_r;          
      next_master_bitcnt = bit_done ? (master_bitcnt_r - 4'h1) : master_bitcnt_r;
	  next_master_state = `MASTER_FSM_SEND;
	  end
//      master_sclk_r = (clkdiv_r > (cycles_per_symbol >> 1)) ? 1'b1 : 1'b0;
//      next_master_shiftreg = bit_done ? {shiftreg_r[`SPI_MAX_LEN-2:0],master_miso} : shiftreg_r;          
//      next_master_bitcnt = bit_done ? (master_bitcnt_r - 4'h1) : master_bitcnt_r;
//      next_master_state = (master_bitcnt_r == 0) ? `MASTER_FSM_STORE : `MASTER_FSM_SEND;   //put this in a if clause 
    end
    `MASTER_FSM_STORE : begin
      master_running = 1'b1;
      master_nss = 1'b0;
      next_master_state = bit_done ? `MASTER_FSM_IDLE : `MASTER_FSM_STORE;
    end
  endcase
end

// Slave FSM

`define SLAVE_FSM_IDLE     3'h0
`define SLAVE_FSM_GETDATA  3'h1
`define SLAVE_FSM_SEND     3'h2
`define SLAVE_FSM_STORE    3'h3

reg [2:0] slave_state_r, next_slave_state;
reg [6:0] slave_bitcnt_r, next_slave_bitcnt;
reg   slave_sclk_r;

always @(posedge clk or negedge n_reset) begin
  if(~n_reset) begin
    slave_state_r <= `SLAVE_FSM_IDLE;
    slave_bitcnt_r <= 7'h8;
    slave_sclk_r <= 1'b0;
  end else begin 
    slave_state_r <= next_slave_state;
    slave_bitcnt_r <= next_slave_bitcnt;
    slave_sclk_r <= slave_sclk;
  end
end


wire  slave_sclk_posedge; assign slave_sclk_posedge = slave_sclk & ~slave_sclk_r;

always @* begin
  next_slave_state= `SLAVE_FSM_IDLE;
  slave_running   = 1'b0;
  next_slave_bitcnt = spi_datalen;
  slave_ready   = 1'b0;
  slave_miso    = 1'b0;
  next_slave_shiftreg   = shiftreg_r;

  case(slave_state_r) 
    `SLAVE_FSM_IDLE   : begin 
      next_slave_state = (~spi_master & ~slave_nss) ? `SLAVE_FSM_SEND : `SLAVE_FSM_IDLE;
      next_slave_shiftreg = (spi_dio_r << (`SPI_MAX_LEN-spi_datalen));
      slave_miso = shiftreg_r[`SPI_MAX_LEN-1];
    end
    `SLAVE_FSM_SEND : begin
      slave_running = 1'b1;
      slave_miso = shiftreg_r[`SPI_MAX_LEN-1];
      next_slave_shiftreg = slave_sclk_posedge ? {shiftreg_r[`SPI_MAX_LEN-2:0],slave_mosi} : shiftreg_r;          
      next_slave_bitcnt = slave_sclk_posedge ? (slave_bitcnt_r - 4'h1) : slave_bitcnt_r;
      next_slave_state = (slave_bitcnt_r == 0) ? `SLAVE_FSM_STORE : `SLAVE_FSM_SEND;
    end
    `SLAVE_FSM_STORE : begin
      slave_ready = 1'b1;
      next_slave_state = `SLAVE_FSM_IDLE;
    end
  endcase
end
endmodule
