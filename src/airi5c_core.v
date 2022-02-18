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
// File             : airi5c_core.v
// Author           : A. Stanitzki
// Creation Date    : 09.10.20
// Last Modified    : Thu 20 Jan 2022 09:00:22 AM CET
// Version          : 1.0
// Abstract         : Airi5c core
// History          : 07.07.20 - rebranding to AIRI5C
//                    22.08.19 - moved debug rom to its own module
//                             - removed legacy hacks and twirks
//                             - added more comments
//                             - fixed error in debug ROM code (wrong register stored to hw stack now fixed)
//                    10.12.18 - beautified and updated comments (ASt)
// Notes            : The core uses seperate instruction and data memory busses with an AHB-Lite 
//                    compatible interface (only basic AHB-Lite transfers are supported). Sometimes, 
//                    the two busses are combined into a single bus using an arbiter on the upper 
//                    hierachy level, because in order to load programs into the core via the debug 
//                    module, the core has to be able to write into instruction memory - which can 
//                    not be done using the "imem" bus.
//
`include "airi5c_arch_options.vh"

// definitions for the AHB-Lite type memory interface (called HASTI here for historic reasons)
`include "airi5c_hasti_constants.vh"

// constants from the control state machine, width of memory access, types of jump targets etc.
`include "airi5c_ctrl_constants.vh"

// address map for the control and status register file (CSR) as defined in the 
// RISC-V ISA. These include basic status information, timers, cycle counters, 
// interrupt handling etc. and are separate from the general purpose register file (GPR)
`include "airi5c_csr_addr_map.vh"

// debug module interface (DMI) definitions
`include "airi5c_dmi_constants.vh"

// RISC-V opcodes 
`include "rv32_opcodes.vh"

module airi5c_core(
  input                           nreset,            // asynchronous reset. low = reset, high = running
  input                           clk,               // main clock, positive edge logic
  input                           testmode, 

  input [`N_EXT_INTS-1:0]         ext_interrupts,    // external interrupt sources, active high 
  input                           system_timer_tick, // system timer interrupt (system timer is a mem-mapped periph)

  output                          ndmreset,

  // AHB-Lite style system busses

  // instruction memory bus    
  output [`HASTI_ADDR_WIDTH-1:0]  imem_haddr,      // I-Memory address
  output                          imem_hwrite,     // currently unused, as imem bus is read-only
  output [`HASTI_SIZE_WIDTH-1:0]  imem_hsize,      // width of memory access (1, 2 or 4 for byte, halfword and word access respectively)
  output [`HASTI_BURST_WIDTH-1:0] imem_hburst,     // burst mode (not implemented yet)
  output                          imem_hmastlock,  // "master lock" (not implemented yet)
  output [`HASTI_PROT_WIDTH-1:0]  imem_hprot,      
  output [`HASTI_TRANS_WIDTH-1:0] imem_htrans,     // transaction mode.!= 0 if transaction is active
  output [`HASTI_BUS_WIDTH-1:0]   imem_hwdata,     // unused, as imem bus is read-only
  input [`HASTI_BUS_WIDTH-1:0]    imem_hrdata,     // read data from instruction memory
  input                           imem_hready,     // busy/ready signaling (1 - ready, 0 - busy)
  input [`HASTI_RESP_WIDTH-1:0]   imem_hresp,      // error code / response from memory

  // data memory bus
  output [`HASTI_ADDR_WIDTH-1:0]  dmem_haddr,
  output                          dmem_hwrite,
  output [`HASTI_SIZE_WIDTH-1:0]  dmem_hsize,
  output [`HASTI_BURST_WIDTH-1:0] dmem_hburst,
  output                          dmem_hmastlock,
  output [`HASTI_PROT_WIDTH-1:0]  dmem_hprot,
  output [`HASTI_TRANS_WIDTH-1:0] dmem_htrans,
  output [`HASTI_BUS_WIDTH-1:0]   dmem_hwdata,     // data to be written into memory
  input [`HASTI_BUS_WIDTH-1:0]    dmem_hrdata,
  input                           dmem_hready,
  input [`HASTI_RESP_WIDTH-1:0]   dmem_hresp,

  input                           lock_custom,
  // Debug Module Interface (DMI) bus. 
  // 
  // This connects the Debug Module (DM) included in this core
  // to an external Debug Transport Module (DTM), which 
  // in our case is a JTAG-TAP.
  // 
  // The DTM uses the DMI to access registers in the DM,
  // thereby performing debug operations.
  // 
  // There can be other types of DTMs on the DMI bus, for example 
  // one could use an RS232 transceiver for debugging, the interface 
  // to the debug module would still be the same DMI.

  input [`DMI_ADDR_WIDTH-1:0]     dmi_addr,       // DM register address
  input                           dmi_en,       // DM (read/write) enable
  output [`DMI_WIDTH-1:0]         dmi_rdata,      // Data read from DM to the DTM
  input [`DMI_WIDTH-1:0]          dmi_wdata,      // Data from the DTM to the DM
  input                           dmi_wen,      // DM write enable (always together with dmi_en)
  output                          dmi_error,      // DM error signaling, should be 1'b0 if no error occured
  // DM busy signaling, if the DM needs more time, it can set 
  // this flag. Usually, the DM is clocked much faster (system clock)
  // than the DTM (external JTAG clock), so this is never required.
  output                          dmi_dm_busy
);

   wire                         dm_ndmreset;
   assign ndmreset = dm_ndmreset;

   wire                         nrst = nreset & ndmreset;

   // System bus signals (to core) translated from the AHB-Lite signals
   wire                         imem_wait_mem; // stall pipeline, memory is not yet ready (Imem side)
   reg                          imem_wait_muxed;
   wire [`HASTI_ADDR_WIDTH-1:0] imem_addr;   // imem address
   wire                         imem_badmem_e; // Signals access fault
   wire                         imem_stall;

   wire                         imem_compressed;
   wire                         imem_redirect; // signal branch-taken
   wire                         imem_exception_WB;

   wire                         dmem_wait_mem;
   reg                          dmem_wait_muxed;
   wire                         dmem_en;
   wire                         dmem_wen;
   
   // writes to dmem can target some address in the debug space or a 
   // regular d-memory address. The external write enable is only 
   // assigned when the target address within the "normal" memory 
   // space (see airi5c_platform_constants.vh for memory mapping)
   wire                         dmem_wen_extern; 
   wire [`HASTI_SIZE_WIDTH-1:0] dmem_size;
   wire [`HASTI_ADDR_WIDTH-1:0] dmem_addr;
   wire [`HASTI_BUS_WIDTH-1:0]  dmem_wdata_delayed;
   wire [`HASTI_BUS_WIDTH-1:0]  dmem_rdata_hasti;
   reg [`HASTI_BUS_WIDTH-1:0]   dmem_rdata;

   wire                         dmem_badmem_e;
  

   // register file access from debug module
   // the debug module can read/write registers in the 
   // general purpose register (GPR) file and in the 
   // control and status register (CSR) file directly using
   // a separate port.

   wire [`DMI_WIDTH-1:0]          dm_regfile_rd;
   wire [`DMI_WIDTH-1:0]          dm_regfile_wd;
   wire                           dm_regfile_wen;
   wire [`REG_ADDR_WIDTH-1:0]     dm_regfile_wara;
`ifdef ISA_EXT_F
   wire                           dm_sel_fpu_reg;
`endif

   wire [`CSR_ADDR_WIDTH-1:0]     dm_csr_addr;
   wire [`CSR_CMD_WIDTH-1:0]      dm_csr_cmd;
   wire [`XPR_LEN-1:0]            dm_csr_rdata;
   wire [`XPR_LEN-1:0]            dm_csr_wdata;

   // run control for individual harts
   // the debug module controls individual cores/harts 
   // using a set of request / status indiction lines.
   // within the debug module, there are mechanisms to 
   // select the group of targeted cores. On this hierarchy level, 
   // a set of control lines needs to be provided for each hart.
   //
   // the current implementation is single-core, so only one set 
   // of control lines is provided.

   wire                dm_hart0_haltreq; // requests the hart to halt and enter debug loop
   wire                dm_hart0_resumereq; // requests the hart to resume opertion at last PC
   wire                dm_hart0_resumeack; // acknowledges the hart has resumed.
  
   wire [`XPR_LEN-1:0] dm_hart0_progbuf0;  // two-instruction-program-buffer that can be filled
   wire [`XPR_LEN-1:0] dm_hart0_progbuf1;  // by the debugger with arbitrary commands. 
                  // thereby the main pipeline is used to execute functions
                  // like memory access in debug mode.

   wire                dm_hart0_postexecreq; // requests the hart to execute the programm buffer.
   wire                dm_hart0_halted;  // signals the hart has sucessfully entered debug loop


   reg [`XPR_LEN-1:0] imem_rdata_muxed;
   reg [`XPR_LEN-1:0] dmem_rdata_muxed;
  
// ============================================================================================================================


   wire [`XPR_LEN-1:0] imem_addr_mem;
   wire [`XPR_LEN-1:0] imem_rdata_mem;
   wire                imem_badmem_e_mem;

// bus translation between pipeline-internal signals 
// and AHB-Lite compatible naming / encoding.

// ============================================================================================================================
// signals for the additional pipeline stage in decompressor (DC)
//
   wire [`XPR_LEN-1:0] PC_DC;
   wire                stall_DC;
   wire                kill_DC;


// ============================================================================================================================

airi5c_hasti_bridge imem_bridge(
  .clk(clk),
  .nreset(nrst),
  .haddr(imem_haddr),
  .hwrite(imem_hwrite),
  .hsize(imem_hsize),
  .hburst(imem_hburst),
  .hmastlock(imem_hmastlock),
  .hprot(imem_hprot),
  .htrans(imem_htrans),
  .hwdata(imem_hwdata),
  .hrdata(imem_hrdata),
  .hready(imem_hready),
  .hresp(imem_hresp),
  .core_mem_en(~imem_stall & |imem_addr_mem[31:28]),
  .core_mem_wen(1'b0),
  .core_mem_size(`HASTI_SIZE_WORD),
  .core_mem_addr(imem_addr_mem),
  .core_mem_wdata_delayed(32'b0),
  .core_mem_rdata(imem_rdata_mem),
  .core_mem_wait(imem_wait_mem),
  .core_badmem_e(imem_badmem_e_mem)
);
                        
airi5c_hasti_bridge dmem_bridge(
  .clk(clk),
  .nreset(nrst),
  .haddr(dmem_haddr),
  .hwrite(dmem_hwrite),
  .hsize(dmem_hsize),
  .hburst(dmem_hburst),
  .hmastlock(dmem_hmastlock),
  .hprot(dmem_hprot),
  .htrans(dmem_htrans),
  .hwdata(dmem_hwdata),
  .hrdata(dmem_hrdata),
  .hready(dmem_hready),
  .hresp(dmem_hresp),
  .core_mem_en(dmem_en & |dmem_addr[31:28]),
  .core_mem_wen(dmem_wen_extern),
  .core_mem_size(dmem_size),
  .core_mem_addr(dmem_addr),
  .core_mem_wdata_delayed(dmem_wdata_delayed),
  .core_mem_rdata(dmem_rdata_hasti),
  .core_mem_wait(dmem_wait_mem),
  .core_badmem_e(dmem_badmem_e)
);

airi5c_debug_module debug_module( 
  .nreset(nreset),
  .clk(clk),
  .testmode(testmode),

  .dmi_addr(dmi_addr),
  .dmi_en(dmi_en),
  .dmi_error(dmi_error),
  .dmi_rdata(dmi_rdata),
  .dmi_wdata(dmi_wdata),
  .dmi_wen(dmi_wen),
  .dmi_dm_busy(dmi_dm_busy),

  .dm_regfile_wen(dm_regfile_wen),
  .dm_regfile_wara(dm_regfile_wara),
`ifdef ISA_EXT_F
  .dm_sel_fpu_reg(dm_sel_fpu_reg),
`endif
  .dm_regfile_rd(dm_regfile_rd),
  .dm_regfile_wd(dm_regfile_wd),

  .dm_hart0_haltreq(dm_hart0_haltreq),
  .dm_hart0_resumereq(dm_hart0_resumereq),
  .dm_hart0_halted(dm_hart0_halted),
  .dm_hart0_postexecreq(dm_hart0_postexecreq),
  .dm_hart0_resumeack(dm_hart0_resumeack),
  .dm_hart0_ndmreset(dm_ndmreset),

  .dm_hart0_progbuf0(dm_hart0_progbuf0),
  .dm_hart0_progbuf1(dm_hart0_progbuf1),

  .dm_illegal_csr_access(dm_illegal_csr_access),
  .dm_csr_addr(dm_csr_addr),
  .dm_csr_cmd(dm_csr_cmd),
  .dm_csr_rdata(dm_csr_rdata),
  .dm_csr_wdata(dm_csr_wdata),
  .dm_state_out()         
);

// =============================================================
// = Memory mapped debug registers, Debug-ROM + Program Buffer =
// =============================================================

reg [`HASTI_ADDR_WIDTH-1:0] dmem_addr_r;  // addr hold register
reg                         dmem_wen_r; // write enable hold register

always @(posedge clk or negedge nrst) begin
  if(~nrst) begin
    dmem_addr_r <= 0;
    dmem_wen_r <= 0;
  end else begin
    dmem_addr_r <= dmem_addr;     // sample addr
    dmem_wen_r <= dmem_wen;
  end
end

assign  dmem_wen_extern = dmem_wen; // (dmem_wen & dmem_addr[`HASTI_ADDR_WIDTH-1]);


// ===========================================
// = Debug-ROM + Debug Program Buffer        =
// ===========================================

reg [`HASTI_ADDR_WIDTH-1:0] imem_addr_mem_r;         // addr hold register

wire  [`XPR_LEN-1:0]        imem_rdata_debug; 
wire  [`XPR_LEN-1:0]        dmem_rdata_debug;

airi5c_debug_rom debug_rom(
  .nreset(nrst),
  .clk(clk),
  .postexec_req(dm_hart0_postexecreq),
  .resume_req(dm_hart0_resumereq),
  .halted(dm_hart0_halted),
  .resume_ack(dm_hart0_resumeack),
  .rom_addra(imem_addr_mem_r),
  .rom_rdataa(imem_rdata_debug),
  .progbuf0(dm_hart0_progbuf0),
  .progbuf1(dm_hart0_progbuf1),
  .rom_addrb(dmem_addr_r),
  .rom_writeb(dmem_wen_r),
  .rom_rdatab(dmem_rdata_debug),
  .rom_wdatab(dmem_wdata_delayed)
);

// Memory Access to Debug ROM
// ==========================

// AHB-Lite provide the data in the clock cycle after the address has been 
// sampled. To mimic this behaviour, the multiplexer samples the address and 
// muxes output from debug rom or real memory based on the address stored in the hold register.

always @(posedge clk or negedge nrst) begin
  if(~nrst) begin 
    imem_addr_mem_r <= 32'h80000000;
  end else begin
    imem_addr_mem_r <= imem_addr_mem;             // sample addr from core
  end
end

// Instruction MUX between debug ROM and regular memory
always @* begin
  casez(imem_addr_mem_r)
    `ADDR_DEBUG_ROM   : begin
                          imem_rdata_muxed = imem_rdata_debug;
                          imem_wait_muxed  = 1'b0;
                        end
    `ADDR_IMEM        : begin 
                          imem_rdata_muxed = imem_rdata_mem;    
                          imem_wait_muxed  = imem_wait_mem;
                        end
  endcase
end


// Data MUX between debug ROM and regular memory (and special places within debug rom)

always @* begin
  casez(dmem_addr_r)
    `ADDR_DEBUG_ROM : begin
                        dmem_rdata = dmem_rdata_debug;
                        dmem_wait_muxed = 1'b0;
                      end
    `ADDR_IMEM      : begin 
                        dmem_rdata = dmem_rdata_hasti;
                        dmem_wait_muxed = dmem_wait_mem;
                      end
  endcase
end


// ===================================================
// = Coprocessors            =
// ===================================================

wire                 pcpi_valid;
wire  [`XPR_LEN-1:0] pcpi_insn;
wire  [`XPR_LEN-1:0] pcpi_rs1;
wire  [`XPR_LEN-1:0] pcpi_rs2;
wire  [`XPR_LEN-1:0] pcpi_rs3;
wire                 pcpi_wr;      // unused - assumes to always write a result. 
wire  [`XPR_LEN-1:0] pcpi_rd;
wire  [`XPR_LEN-1:0] pcpi_rd2;
wire                 pcpi_use_rd64;
wire                 pcpi_wait;      // unused
wire                 pcpi_ready;


// =====================================
// = M-Extension (Hardware MUL/DIV/REM =
// =====================================

`ifdef ISA_EXT_M
`ifndef ISA_EXT_P
wire                 pcpi_wr_mul_div;
wire  [`XPR_LEN-1:0] pcpi_rd_mul_div;
wire  [`XPR_LEN-1:0] pcpi_rd2_mul_div;
wire                 pcpi_use_rd64_mul_div;
wire                 pcpi_wait_mul_div;
wire                 pcpi_ready_mul_div;

airi5c_mul_div  mul_div(
  .nreset(nrst),
  .clk(clk),

  .pcpi_valid(pcpi_valid),
  .pcpi_insn(pcpi_insn),
  .pcpi_rs1(pcpi_rs1),
  .pcpi_rs2(pcpi_rs2),
//  .pcpi_rs3(pcpi_rs3),
  .pcpi_wr(pcpi_wr_mul_div),
  .pcpi_rd(pcpi_rd_mul_div),
//  .pcpi_rd2(pcpi_rd2_mul_div),
//  .pcpi_use_rd64(pcpi_use_rd64_mul_div),
  .pcpi_wait(pcpi_wait_mul_div),
  .pcpi_ready(pcpi_ready_mul_div)
);
`endif
`endif

// =====================================
// = Custom Arithmetics                =
// =====================================

`ifdef ISA_EXT_CUSTOM
wire                 pcpi_wr_custom;
wire  [`XPR_LEN-1:0] pcpi_rd_custom;
wire  [`XPR_LEN-1:0] pcpi_rd2_custom;
wire                 pcpi_use_rd64_custom;
wire                 pcpi_wait_custom;
wire                 pcpi_ready_custom;

airi5c_custom custom(
  .nreset(nrst),
  .clk(clk),

  .pcpi_valid(pcpi_valid),
  .pcpi_insn(pcpi_insn),
  .pcpi_rs1(pcpi_rs1),
  .pcpi_rs2(pcpi_rs2),
  .pcpi_rs3(pcpi_rs3),
  .pcpi_wr(pcpi_wr_custom),
  .pcpi_rd(pcpi_rd_custom),
  .pcpi_rd2(pcpi_rd2_custom),
  .pcpi_use_rd64(pcpi_use_rd64_custom),
  .pcpi_wait(pcpi_wait_custom),
  .pcpi_ready(pcpi_ready_custom)
);
`endif

// =====================================
// = DSP Extension                     =
// =====================================

`ifdef ISA_EXT_P
wire                 pcpi_wr_dsp;
wire  [`XPR_LEN-1:0] pcpi_rd_dsp;
wire  [`XPR_LEN-1:0] pcpi_rd2_dsp;
wire                 pcpi_use_rd64_dsp;
wire                 pcpi_wait_dsp;
wire                 pcpi_ready_dsp;

wire                 pcpi_wr_mul_div;
wire  [`XPR_LEN-1:0] pcpi_rd_mul_div;
wire  [`XPR_LEN-1:0] pcpi_rd2_mul_div;
wire                 pcpi_use_rd64_mul_div;
wire                 pcpi_wait_mul_div;
wire                 pcpi_ready_mul_div;

airi5c_mul_div_simd  mul_div(
  .nreset(nrst),
  .clk(clk),

  .pcpi_valid(pcpi_valid),
  .pcpi_insn(pcpi_insn),
  .pcpi_rs1(pcpi_rs1),
  .pcpi_rs2(pcpi_rs2),
  .pcpi_rs3(pcpi_rs3),
  .pcpi_wr(pcpi_wr_mul_div),
  .pcpi_rd(pcpi_rd_mul_div),
  .pcpi_rd2(pcpi_rd2_mul_div),
  .pcpi_use_rd64(pcpi_use_rd64_mul_div),
  .pcpi_wait(pcpi_wait_mul_div),
  .pcpi_ready(pcpi_ready_mul_div)
);

airi5c_alu_simd dsp(
  .nreset(nrst),
  .clk(clk),

  .pcpi_valid(pcpi_valid),
  .pcpi_insn(pcpi_insn),
  .pcpi_rs1(pcpi_rs1),
  .pcpi_rs2(pcpi_rs2),
  .pcpi_rs3(pcpi_rs3),
  .pcpi_wr(pcpi_wr_dsp),
  .pcpi_rd(pcpi_rd_dsp),
  .pcpi_rd2(pcpi_rd2_dsp),
  .pcpi_use_rd64(pcpi_use_rd64_dsp),
  .pcpi_wait(pcpi_wait_dsp),
  .pcpi_ready(pcpi_ready_dsp)
);
`endif

// =====================================
// = eFPGA Extension                     =
// =====================================


`ifdef ISA_EXT_EFPGA
wire                 pcpi_wr_efpga;
wire  [`XPR_LEN-1:0] pcpi_rd_efpga;
wire  [`XPR_LEN-1:0] pcpi_rd2_efpga;
wire                 pcpi_use_rd64_efpga;
wire                 pcpi_wait_efpga;
wire                 pcpi_ready_efpga;

airi5c_efpga efpga(
  .nreset(nrst),
  .clk(clk),

  .pcpi_valid(pcpi_valid),
  .pcpi_insn(pcpi_insn),
  .pcpi_rs1(pcpi_rs1),
  .pcpi_rs2(pcpi_rs2),
  .pcpi_rs3(pcpi_rs3),
  .pcpi_wr(pcpi_wr_efpga),
  .pcpi_rd(pcpi_rd_efpga),
  .pcpi_rd2(pcpi_rd2_efpga),
  .pcpi_use_rd64(pcpi_use_rd64_efpga),
  .pcpi_wait(pcpi_wait_efpga),
  .pcpi_ready(pcpi_ready_efpga)
);
`endif

// Multiplex the various coprocessor results here

assign  pcpi_wr = 1'b0
`ifdef ISA_EXT_M
  | pcpi_wr_mul_div  
`endif
`ifdef ISA_EXT_CUSTOM
  | (pcpi_wr_custom & ~lock_custom)
`endif
`ifdef ISA_EXT_EFPGA
  | pcpi_wr_efpga
`endif
`ifdef ISA_EXT_P
  | pcpi_wr_dsp
`endif;

assign  pcpi_rd = 1'b0
`ifdef ISA_EXT_M 
  | pcpi_rd_mul_div  
`endif
`ifdef ISA_EXT_CUSTOM
  | pcpi_rd_custom 
`endif
`ifdef ISA_EXT_EFPGA
  | pcpi_rd_efpga
`endif
`ifdef ISA_EXT_P
  | pcpi_rd_dsp
`endif;

assign  pcpi_rd2 = 1'b0
`ifdef ISA_EXT_M 
  | pcpi_rd2_mul_div  
`endif
`ifdef ISA_EXT_CUSTOM
  | pcpi_rd2_custom
`endif
`ifdef ISA_EXT_EFPGA
  | pcpi_rd2_efpga
`endif
`ifdef ISA_EXT_P
  | pcpi_rd2_dsp
`endif;

assign  pcpi_use_rd64 = 1'b0
`ifdef ISA_EXT_M 
  | pcpi_use_rd64_mul_div  
`endif
`ifdef ISA_EXT_CUSTOM
  | (pcpi_use_rd64_custom & ~lock_custom) 
`endif
`ifdef ISA_EXT_EFPGA
  | pcpi_use_rd64_efpga
`endif
`ifdef ISA_EXT_P
  | pcpi_use_rd64_dsp
`endif;

assign  pcpi_wait = 1'b0
`ifdef ISA_EXT_M 
  | pcpi_wait_mul_div 
`endif
`ifdef ISA_EXT_CUSTOM
  | (pcpi_wait_custom & ~lock_custom)
`endif
`ifdef ISA_EXT_EFPGA
  | pcpi_wait_efpga
`endif
`ifdef ISA_EXT_P
  | pcpi_wait_dsp
`endif;

assign  pcpi_ready =  1'b0
`ifdef ISA_EXT_M
  | pcpi_ready_mul_div 
`endif
`ifdef ISA_EXT_CUSTOM
  | (pcpi_ready_custom & ~lock_custom)
`endif
`ifdef ISA_EXT_EFPGA
  | pcpi_ready_efpga
`endif
`ifdef ISA_EXT_P
  | pcpi_ready_dsp
`endif;


// ===================================================
// == 
// ===================================================



// ===================================================
// = Core Pipeline             =
// ===================================================
//
// The pipeline module includes the computational core. 
// It consists of IF/DE, EX, WB stages, control logic, 
// general purpose register file, control/status register 
// file and exception handling.



airi5c_pipeline pipeline(
  .clk(clk),
  .ext_interrupts(ext_interrupts),            // External interrrupt sources, active high
  .system_timer_tick(system_timer_tick),      // system_timer_tick is a special interrupt source
  .debug_haltreq(dm_hart0_haltreq),           // haltreq is a special interrupt which 
  // causes a jump into debug ROM on the next 
  // cycle.
  .nreset(nrst),

  // Instruction memory interface to 
  // IF stage
  .imem_wait(imem_wait_muxed),
  .imem_addr(imem_addr_mem),
  .imem_rdata(imem_rdata_muxed),
  .imem_stall(imem_stall),
  .imem_badmem_e(1'b0),

  // Data memory interface from/to 
  // WB stage
  .dmem_wait(dmem_wait_muxed),
  .dmem_en(dmem_en),
  .dmem_wen(dmem_wen),
  .dmem_size(dmem_size),
  .dmem_addr(dmem_addr),
  .dmem_wdata_delayed(dmem_wdata_delayed),
  .dmem_rdata(dmem_rdata),
  .dmem_badmem_e(1'b0),          

  // Debug Module Register File Access
  // The Debug Module (DM) can access the 
  // register file via a separate port. 
  // It has priority over core accesses to 
  // the regfile.
  .dm_wen(dm_regfile_wen),        // write enable, active high
  .dm_wara(dm_regfile_wara),      // write/read address
`ifdef ISA_EXT_F
  .dm_sel_fpu_reg(dm_sel_fpu_reg),
`endif
  .dm_rd(dm_regfile_rd),          // data regfile -> DM
  .dm_wd(dm_regfile_wd),          // data DM -> regfile


  // Debug Module CSR access
  .dm_csr_cmd(dm_csr_cmd),        // command. read = 0, write = >0
  .dm_csr_addr(dm_csr_addr),      // register address
  .dm_csr_rdata(dm_csr_rdata),    // data CSR -> DM
  .dm_csr_wdata(dm_csr_wdata),    // data DM -> CSR

  .dm_illegal_csr_access(dm_illegal_csr_access),    // signal illegal address to DM
  // This is actually used by debuggers to differentiate 
  // e.g. between 32/64 Bit implementations

  // PCPI coprocessor interface
  .pcpi_valid(pcpi_valid),
  .pcpi_insn(pcpi_insn),
  .pcpi_rs1(pcpi_rs1),
  .pcpi_rs2(pcpi_rs2),
  .pcpi_rs3(pcpi_rs3),
  .pcpi_wr(pcpi_wr),      // unused - assumes to always write a result. 
  .pcpi_rd(pcpi_rd),
  .pcpi_rd2(pcpi_rd2),
  .pcpi_use_rd64(pcpi_use_rd64),
  .pcpi_wait(pcpi_wait),  // unused
  .pcpi_ready(pcpi_ready)
);

endmodule
