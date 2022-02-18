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

`timescale 1ns / 1ps

`include "airi5c_hasti_constants.vh"
`include "airi5c_dmi_constants.vh"

module FPGA_Top
(
    input           nRESET,
    input           CLK,
        
    input           EXT_INT,
        
    input           tdi,
    input           tck,
    input           tms,
    output          tdo,

`ifdef SIM
    inout   [7:0]   gpio,
`else        
    input   [7:0]   gpio_i,
    output  [7:0]   gpio_d,
//  output  [7:0]   gpio_en,
`endif
        
    output          uart_tx,
    input           uart_rx,
  
//  output          sd_reset,

    output          spi_mosi,
`ifdef SIM
    output          spi_sclk,
`endif
    output          spi_nss,
    input           spi_miso
);

    reg             reset_sync;
    reg             interrupt_sync;

    wire            clkgen_locked;
    wire            clk32;
    wire            clktree_root;
    
    wire    [7:0]   debug_out;
`ifndef SIM
    wire            spi_sclk;
`endif

`ifdef SIM
    BUF     b1(.I(CLK), .O(clk32));
    BUF     b2(.I(1'b1), .O(clkgen_locked));

    wire [7:0] gpio_d, gpio_i, gpio_en;
    assign gpio_en = 8'hF; // gpio_en is not used by default.
    assign gpio_i  = gpio;
    genvar i;
    generate
      for (i = 0; i < 8; i = i + 1) begin : U
        bufif1(gpio[i],gpio_d[i],gpio_en[i]);
      end
    endgenerate  

`else
    clk_wiz_0 clkgen
    (
        .reset(!nRESET),
        .clk_in1(CLK),
        .clk_out1(clk32),
        .locked(clkgen_locked)
    );  

`endif

    // the spi interface in this toplevel 
    // is connected to the QSPI flash device 
    // via a STARTUPE2 instance. 
    // The spi_sclk port needs to be present, 
    // because the testbench assumes a constant 
    // toplevel interface to the chip/fpga. 
    // the easiest solution is to provide the 
    // toplevel port and have synthesis/p&r 
    // optimize it away.

    always @(posedge clk32 or negedge nRESET) begin
        if(!nRESET) begin
            reset_sync      <= 1'b1;
            interrupt_sync  <= 1'b0;
//          sd_reset_r      <= 1'b1;
        end
        
        else begin
            if(clkgen_locked) 
                reset_sync  <= !nRESET;
                
            interrupt_sync  <= EXT_INT;
//          sd_reset_r      <= 1'b0;
        end
    end
    
    	wire	[3:0]	su_nc;	// Startup primitive, no connect    	
    
    STARTUPE2 #(
		// Leave PROG_USR false to avoid activating the program
		// event security feature.  Notes state that such a feature
		// requires encrypted bitstreams.
		.PROG_USR("FALSE"),
		// Sets the configuration clock frequency (in ns) for
		// simulation.
		.SIM_CCLK_FREQ(0.0)
	) STARTUPE2_inst (
	// CFGCLK, 1'b output: Configuration main clock output -- no connect
	.CFGCLK(su_nc[0]),
	// CFGMCLK, 1'b output: Configuration internal oscillator clock output
	.CFGMCLK(su_nc[1]),
	// EOS, 1'b output: Active high output indicating the End Of Startup.
	.EOS(su_nc[2]),
	// PREQ, 1'b output: PROGRAM request to fabric output
	//	Only enabled if PROG_USR is set.  This lets the fabric know
	//	that a request has been made (either JTAG or pin pulled low)
	//	to program the device
	.PREQ(su_nc[3]),
	// CLK, 1'b input: User start-up clock input
	.CLK(1'b0),
	// GSR, 1'b input: Global Set/Reset input
	.GSR(1'b0),
	// GTS, 1'b input: Global 3-state input
	.GTS(1'b0),
	// KEYCLEARB, 1'b input: Clear AES Decrypter Key input from BBRAM
	.KEYCLEARB(1'b0),
	// PACK, 1-bit input: PROGRAM acknowledge input
	//	This pin is only enabled if PROG_USR is set.  This allows the
	//	FPGA to acknowledge a request for reprogram to allow the FPGA
	//	to get itself into a reprogrammable state first.
	.PACK(1'b0),
	// USRCLKO, 1-bit input: User CCLK input -- This is why I am using this
	// module at all.
	.USRCCLKO(spi_sclk),
	// USRCCLKTS, 1'b input: User CCLK 3-state enable input
	//	An active high here places the clock into a high impedence
	//	state.  Since we wish to use the clock as an active output
	//	always, we drive this pin low.
	.USRCCLKTS(1'b0),
	// USRDONEO, 1'b input: User DONE pin output control
	//	Set this to "high" to make sure that the DONE LED pin is
	//	high.
	.USRDONEO(1'b1),
	// USRDONETS, 1'b input: User DONE 3-state enable output
	//	This enables the FPGA DONE pin to be active.  Setting this
	//	active high sets the DONE pin to high impedence, setting it
	//	low allows the output of this pin to be as stated above.
	.USRDONETS(1'b1)
	);	

    BUFG    buf_clk(.I(clk32), .O(clktree_root));

    wire    [`HASTI_ADDR_WIDTH-1:0]     imem_haddr;
    wire                                imem_hwrite;
    wire    [`HASTI_SIZE_WIDTH-1:0]     imem_hsize;
    wire    [`HASTI_BURST_WIDTH-1:0]    imem_hburst;
    wire                                imem_hmastlock;
    wire    [`HASTI_PROT_WIDTH-1:0]     imem_hprot;
    wire    [`HASTI_TRANS_WIDTH-1:0]    imem_htrans;
    wire    [`HASTI_BUS_WIDTH-1:0]      imem_hwdata;
    wire    [`HASTI_BUS_WIDTH-1:0]      imem_hrdata;
    wire                                imem_hready;
    wire    [`HASTI_RESP_WIDTH-1:0]     imem_hresp;

    reg     [3:0]                       writeb; 
    reg     [31:0]                      dmem_haddr_r;

    wire    [`HASTI_ADDR_WIDTH-1:0]     dmem_haddr;
    wire                                dmem_hwrite;
    wire    [`HASTI_SIZE_WIDTH-1:0]     dmem_hsize;
    wire    [`HASTI_BURST_WIDTH-1:0]    dmem_hburst;
    wire                                dmem_hmastlock;
    wire    [`HASTI_PROT_WIDTH-1:0]     dmem_hprot;
    wire    [`HASTI_TRANS_WIDTH-1:0]    dmem_htrans;
    wire    [`HASTI_BUS_WIDTH-1:0]      dmem_hwdata;
    wire    [`HASTI_BUS_WIDTH-1:0]      dmem_hrdata;
    wire                                dmem_hready;
    wire    [`HASTI_RESP_WIDTH-1:0]     dmem_hresp; 

    wire    [`DMI_ADDR_WIDTH-1:0]       dmi_addr;
    wire    [`DMI_WIDTH-1:0]            dmi_rdata;
    wire    [`DMI_WIDTH-1:0]            dmi_wdata;
    wire                                dmi_en;
    wire                                dmi_wen;
    wire                                dmi_error;
    wire                                dmi_dm_busy;

    wire    [5:0]                       shiftval;   
    wire    [31:0]                      dmem_hrdata_shifted;    
    
    assign  dmem_hready                 = ~|writeb;
    assign  shiftval                    = dmem_haddr_r[1:0] << 3;
    assign  dmem_hrdata_shifted         = dmem_hrdata;//  >> shiftval; 

    airi5c_top_asic DUT
    (
        .clk(clktree_root),
        .nreset(~reset_sync),
        .testmode(1'b0),    
        .ext_interrupt(interrupt_sync),    
    
        .tck(tck),
        .tms(tms),
        .tdi(tdi),
        .tdo(tdo),

        .imem_haddr(imem_haddr),
        .imem_hwrite(imem_hwrite),
        .imem_hsize(imem_hsize),
        .imem_hburst(imem_hburst),
        .imem_hmastlock(imem_hmastlock),
        .imem_hprot(imem_hprot),
        .imem_htrans(imem_htrans),
        .imem_hwdata(imem_hwdata),
        .imem_hrdata(imem_hrdata),
        .imem_hready(1'b1),
        .imem_hresp(`HASTI_RESP_OKAY),
    
        .dmem_haddr(dmem_haddr),
        .dmem_hwrite(dmem_hwrite),
        .dmem_hsize(dmem_hsize),
        .dmem_hburst(dmem_hburst),
        .dmem_hmastlock(dmem_hmastlock),
        .dmem_hprot(dmem_hprot),
        .dmem_htrans(dmem_htrans),
        .dmem_hwdata(dmem_hwdata),
        .dmem_hrdata(dmem_hrdata_shifted),  
        .dmem_hready(dmem_hready),
        .dmem_hresp(`HASTI_RESP_OKAY),
       
    
        .oGPIO_D(gpio_d),
        .oGPIO_EN(),
        .iGPIO_I(gpio_i),

        .oUART_TX(uart_tx),
        .iUART_RX(uart_rx),

        .oSPI1_MOSI(spi_mosi),
        .oSPI1_SCLK(spi_sclk),
        .oSPI1_NSS(spi_nss),
        .iSPI1_MISO(spi_miso),
     
        .debug_out(debug_out)
    );

    always @(posedge clktree_root) begin
        if(reset_sync) begin
            writeb          <= 0;       
            dmem_haddr_r    <= 0;            
        end
        
        else begin                        
            if((dmem_haddr[31:30] == 2'b10) && dmem_hwrite && ~|writeb) begin
                dmem_haddr_r    <= dmem_haddr;
                writeb          <= (dmem_hsize == 2)   ? 4'b1111 :
                                   (dmem_hsize == 1)   ? (4'b0011 << dmem_haddr[1:0]) :
                                   (dmem_hsize == 0)   ? (4'b0001 << dmem_haddr[1:0]) :
                                   4'b0000;
            end else writeb <= 4'h0;
        end
    end

    blk_mem_gen_0 SRAM
    (
        .addra({11'h0000, imem_haddr[20:0]}),
        .clka(clktree_root),
        .dina(imem_hwdata),
        .douta(imem_hrdata),
        .wea(0),
    
        .addrb(|writeb ? {11'h0000, dmem_haddr_r[20:0]} : {11'h0000, dmem_haddr[20:0]}),
        .clkb(clktree_root),
        .dinb(dmem_hwdata),
        .doutb(dmem_hrdata),
        .web(writeb)
    );
    
endmodule
