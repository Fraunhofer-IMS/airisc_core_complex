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
// File              : airi5c_top_tb.v
// Author            : A. Stanitzki
// Creation Date     : 09.10.20
// Last Modified     : 15.02.21
// Version           : 1.0
// Abstract          : TOP testbench          
//
`timescale 1ns/1ns
`include "../src/airi5c_ctrl_constants.vh"
`include "../src/airi5c_csr_addr_map.vh"
`include "../src/airi5c_hasti_constants.vh"
`include "../src/airi5c_alu_ops.vh"
`include "../src/rv32_opcodes.vh"
`include "../src/airi5c_arch_options.vh"
`include "../src/airi5c_hasti_constants.vh"
// `include "../src/modules/airi5c_dtm/src/airi5c_dmi_constants.vh"

`timescale 1ns/1ns

module airi5c_top_tb();

// Interface declarations for DUT interface
// ========================================

// global signals driven by testbench
reg VDD;
reg CLK, CLKQSPI, RESET;
reg EXT_INT;

wire  [3:0]     debug_state;
wire  [7:0]     debug_out;

// Scan Interface to DUT
reg SDI, SEN;
wire  SDO;

// peripherals typically integrated in DUT, which 
// may or may not be present in the configuration.

// GPIO pull-up/-down
wire  [7:0] GPIO;
buf (weak0, weak1) gpio_buf[7:0] (GPIO, 8'b10100101);


// UART (RX is set by host, i.e. testbench)
wire    UART_TX;
reg     UART_RX;

// SPI (DUT is master)
reg     SPI_MASTER_MISO;
wire    SPI_MASTER_MOSI, SPI_MASTER_SCLK, SPI_MASTER_NSS;


// Signal declarations for testbench internal use
// ==============================================

// select between normal simulation (with jtag signals
// set by the testbench) or VPI mode (with jtag signals
// set by externally connected OpenOCD-Process via VPI
// interface module).

`ifndef VPIMODE
reg tck, tms, tdi;
wire  tdo;
`else 
wire  tck, tms, tdi, tdo;
`endif

// include virtual JTAG controller if VPI mode is enabled.
// this can be used to run a virtual prototype and connect 
// to it via openocd/gdb.
`ifdef VPIMODE
// Clock half period (Clock period = 100 ns => 10 MHz)
reg init_done;
jtag_vpi #(.DEBUG_INFO(0), .TP(1), .TCK_HALF_PERIOD(3000), .CMD_DELAY(3000)) 
jtag
  (
    .tms(tms),
    .tck(tck),
    .tdi(tdi),
    .tdo(tdo),
    .enable(1'b1),
    .init_done(init_done)
  );
`endif

// ======================== DUT instance ======================================
// =              uncomment appropriate configuration                         =
// ============================================================================

// configurations are now placed in the /configs subfolder. 
// A configuration consists of the base core, memories, peripherals and all 
// glue logic for bus access etc. 
// The constant interface between the configuration and the testbench is 
// defined by the signal declarations at the top of this file.



// Config: AIRI5C with internal ideal SRAM (mainly for core verification)
// ----------------------------------------------------------------------
`ifdef CONFIG_IDEAL_SRAM_1
`define ASIC 1
// number of testcases expect to fail, so the overall TB still passes
integer expectederror=5;
airi5c_cfg_ideal_sram DUT(
`elsif CONFIG_XH018_QSPI_1
`define ASIC 1
// number of testcases expect to fail, so the overall TB still passes
integer expectederror=8;
airi5c_cfg_xh018_4x8SRAM DUT(
`elsif CONFIG_XH018_QSPI_SICHEL
`define ASIC 1
// number of testcases expect to fail, so the overall TB still passes
integer expectederror=6;
airi5c_cfg_xh018_NVSRAM DUT(
`elsif CONFIG_IDEAL_SRAM_N65
`define ASIC 1
// number of testcases expect to fail, so the overall TB still passes
integer expectederror=5;
airi5c_cfg_ideal_sram_N65_padframe DUT(
`else 
`undef ASIC
// number of testcases expect to fail, so the overall TB still passes
integer expectederror=5;
FPGA_Top DUT(
`endif
   .CLK(CLK),
   .nRESET(~RESET),
   .EXT_INT(EXT_INT),

   .tdi(tdi),
   .tdo(tdo),
   .tck(tck),
   .tms(tms),

`ifdef ASIC
   .VDD(VDD),
   .debug_state(debug_state),
   .debug_out(debug_out),

   .testmode(1'b0),
   .sdi(SDI),
   .sdo(SDO),
   .sen(SEN),
`endif

   .gpio(GPIO),

   .uart_tx(UART_TX),
   .uart_rx(UART_RX),

   .spi_mosi(SPI_MASTER_MOSI),
   .spi_miso(SPI_MASTER_MISO),
   .spi_sclk(SPI_MASTER_SCLK),
   .spi_nss(SPI_MASTER_NSS)
);

`ifndef ASIC
assign debug_out = DUT.debug_out;
`endif

// ==============================================================================================================
// ===============       Main Testbench     =====================================================================
// ==============================================================================================================

`ifdef ASIC
`define CLK_PERIOD 20        // ASIC sysclk is 50 MHz
`define CORE_CLK_PERIOD 20   // .. no divider
`define JTAG_CLK_PERIOD 128  // JTAG TCK is     8 MHz
`else 
`define CLK_PERIOD 10        // FPGA clock is 100 MHz, ..
`define CORE_CLK_PERIOD 31   // ..  32 Mhz are generated internally.
`define JTAG_CLK_PERIOD 256  // JTAG TCK is     4 MHz
`endif

always begin
  #(`CLK_PERIOD/2)
  CLK = ~CLK;
end


// current testcase and number of failed
// tests. useful for waveform inspection.
integer testcase;
integer i;

// testbench counters
reg [31:0] result;                // tb writes exit code to magic address, which is read into "result".
reg [31:0] memimg[256000000-1:0]; // tb reads memfile into memimg array before writing it to imem using jtag
reg [31:0] errorcount;            // tb collects exit codes from test steps and reports total fail count
reg [31:0] errortotal;            // tb sum of testcase errors
integer testtotal=0;              // tb sum of executed testcases

`ifndef VPIMODE 

// either we are in virtual prototype mode or 
// we run the following testbenches.

`include "jtag_tasks.vh"    // definition of jtag commands
`include "test_tasks.vh"    // includes tasks to load and execute memfiles


initial begin
  $write("==================================\n");
  $write("==== FLAVOR TESTBENCH STARTET ====\n");
  $write("==================================\n");
  
  `ifdef CONFIG_IDEAL_SRAM_1 
  $write("DUT: CONFIG_IDEAL_SRAM_1 \n");
  `elsif CONFIG_XH018_QSPI_1 
  $write("DUT: CONFIG_XH018_QSPI_1 \n");
  `elsif CONFIG_XH018_QSPI_SICHEL
  $write("DUT: CONFIG_XH018_QSPI_SICHEL \n");
  `elsif CONFIG_IDEAL_SRAM_N65
  $write("DUT: CONFIG_IDEAL_SRAM_N65 \n");
  `else
  $write("DUT: CONFIG_IDEAL_SRAM_1 \n");
  `endif
  

  `include "tests/init_tests.vh"
  `include "tests/debug_tests.vh"

  $write("===================== \n");
  $write("= Instruction Tests = \n");
  $write("===================== \n");


//  `include "tests/torture_tests.vh"
  `include "tests/base_isa_tests.vh"
  `include "tests/privileged_tests.vh"
///*
  `ifdef ISA_EXT_M 
    `include "tests/m_ext_tests.vh"
  `elsif ISA_EXT_P 
    `include "tests/m_ext_tests.vh"
  `endif

  `ifdef ISA_EXT_E 
    `include "tests/e_ext_tests.vh"
  `endif

  `ifdef ISA_EXT_C
    `include "tests/c_ext_tests.vh"
  `endif

  `ifdef ISA_EXT_F
    `include "tests/f_ext_tests.vh"
  `endif

/*
  $write("===================== \n");
  $write("= Platform Tests    = \n");
  $write("===================== \n");

  `include "tests/platform_tests.vh"
*/

`ifdef CONFIG_XH018_QSPI_SICHEL
  `include "tests/qspi_sichel_tests.vh"
`endif

/*  $write("===================== \n");
  $write("= Benchmark Tests   = \n");
  $write("===================== \n");

  `include "tests/benchmark_tests.vh"*/

  $write("cumulative errors / number of tests: ", errortotal, " / ", testtotal);
  $write("\n");
  $write("expected errors: ", expectederror);
  $write("\n\n");
  if(errortotal == expectederror) 
     $write("TB PASSED");
    else
     $write("TB FAILED");
  $write("\n\n");
  
  $finish();
end

`else

// we are in VPI mode. Only do initialization
// and keep running the simulation.


initial begin
  $write("==== VPI MODE ===\n");
  $write("\n");
  $write("Core configuration: RV32I");
  `ifdef ISA_EXT_E $write("E"); `endif
  `ifdef ISA_EXT_M $write("M"); `endif
  `ifdef ISA_EXT_F $write("F"); `endif
  `ifdef ISA_EXT_C $write("C"); `endif
  `ifdef ISA_EXT_XCRYPTO $write("Xcrypto"); `endif
  $write("\n");
  init_done = 1'b0;
  $write("VDD: 0, RESET: 1, CLK: 0, CLKQSPI: 0, EXT_INT: 0, tms: 0, tdi: 0, tck: 0, SDI = 0, SEN = 0\n");
  VDD <= 1'b1; RESET <= 1'b1;
  CLK <= 1'b0; CLKQSPI <= 1'b0; 
  EXT_INT <= 1'b0;
  SEN <= 0; SDI <= 0;
  #(56*`CLK_PERIOD); 
  $write("waiting 2ms for NVRAM startup..\n");
  #2000000;
  #(5*`CLK_PERIOD); 
  $write("VDD: 1, RESET: 0, CLK: taktet, CLKQSPI: taktet, EXT_INT: 0, tms: 0, tdi: 0, tck: 0\n");
  @(negedge CLK) RESET <= 1'b0;
  #(5*`CLK_PERIOD); 
  init_done <= 1'b1;
end
`endif
endmodule
