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

`include "rv32_opcodes.vh"
`include "airi5c_arch_options.vh"

module airi5c_fetch_simple (     
// general I/O  
  input                  rst_ni,       
  input                  clk_i,
// core-side I/O  
  input   [`XPR_LEN-1:0] pc_pif_i,
  input                  kill_if_i,
  input                  de_ready_i,
  output  [`XPR_LEN-1:0] pc_if_o,
  output  [`XPR_LEN-1:0] inst_if_o,
  output                 if_valid_o,

  output                 error_in_if_o,

// memory-side I/O  
  input                           imem_hready_i, 
  output  [`XPR_LEN-1:0]          imem_haddr_o,
  input   [`XPR_LEN-1:0]          imem_hrdata_i,
  input                           imem_badmem_i,
  output [`HASTI_TRANS_WIDTH-1:0] imem_htrans_o,
  output [`HASTI_BURST_WIDTH-1:0] imem_hburst_o,
  output                          imem_hmastlock_o,
  output [`HASTI_PROT_WIDTH-1:0]  imem_hprot_o

);

reg [`XPR_LEN-1:0] imem_haddr_r;
reg [`XPR_LEN-1:0] pc_if_r;
reg [`XPR_LEN-1:0] inst_if_r;
reg                if_valid_r;
reg [`HASTI_TRANS_WIDTH-1:0] imem_htrans_r;

assign imem_haddr_o     = imem_haddr_r;
assign imem_hburst_o    = `HASTI_BURST_SINGLE;
assign imem_hmastlock_o = `HASTI_MASTER_NO_LOCK;
assign imem_hprot_o     = `HASTI_NO_PROT;
assign imem_htrans_o    = imem_htrans_r;

assign pc_if_o    = pc_if_r;
assign inst_if_o  = inst_if_r;
assign if_valid_o = if_valid_r;
assign error_in_if_o = 1'b0; // Implement me.


localparam [2:0] StRestart = 3'h1,
                 StFetch = 3'h3;


reg [2:0] state, next_state;
reg [`XPR_LEN-1:0] last_addr_r;
reg [`XPR_LEN-1:0] last_data_r;

always @(posedge clk_i or negedge rst_ni) begin
  if(~rst_ni) begin
    state <= StRestart;
    pc_if_r <= 32'h80000000;
    inst_if_r <= 0;
    if_valid_r <= 0;
    imem_haddr_r <= 32'h80000000;
    last_addr_r <= 32'hdeadbeef;
  end else begin
    state <= next_state;

    // in StRestart, output the addr to be 
    // fetched (already in imem_haddr_r), 
    // and wait for the next memory_ready.
    // then we are sure, the memory has 
    // sampled the address an can return to StFetch, 
    // incrementing the address.
    if(state == StRestart) begin
      if(kill_if_i) begin
        imem_haddr_r <= pc_pif_i;
        pc_if_r      <= pc_pif_i;
        inst_if_r    <= `RV_NOP;
        if_valid_r   <= 1'b0;
      end else begin
        if(imem_hready_i) begin
          imem_haddr_r <= imem_haddr_r + 32'h4;
          last_addr_r  <= imem_haddr_r;
        end        
      end
    end

    if(state == StFetch) begin
      if(kill_if_i) begin
        imem_haddr_r <= pc_pif_i;
        pc_if_r      <= pc_pif_i;
        inst_if_r    <= `RV_NOP;
        if_valid_r   <= 1'b0;
      end else begin
      // various combinations of the memory (not) being 
      // ready, the pipeline (not) being stalled and 
      // previously fetched instructions (not) being available.

        // memory finishes access, there is a previously 
        // fetched instruction in the hold register and 
        // the decode stage is able to take it now.
        // -> store the new fetched instruction, while decode 
        // takes the previously fetched. Increment address.
        if(imem_hready_i & de_ready_i & if_valid_r) begin 
          imem_haddr_r <= imem_haddr_r + 32'h4;
          last_addr_r  <= imem_haddr_r;
          pc_if_r      <= last_addr_r;
          inst_if_r    <= imem_hrdata_i;
          if_valid_r   <= 1'b1;
        // memory is still working, de can take an instruction 
        // and there is a previously fetched instruction in the 
        // hold register.
        // -> de takes the previously fetched instruction
        // and the output of the IF stage becomes invalid afterwards
        // (because there is no instruction left for DE).
        // Meanwhile we leave the memory working.. 
        end else if(~imem_hready_i & de_ready_i & if_valid_r) begin
          if_valid_r   <= 1'b0;
        // memory just finished an access, and there is a previously 
        // fetched instruction in the hold register, but the de stage 
        // cannot take it now. So we cannot store the new fetched 
        // instruction (would overwrite the one not yet taken by DE).
        // instead, we reset the address to the one of the inst the 
        // de could not take and restart the fetch.
        end else if(imem_hready_i & ~de_ready_i & if_valid_r) begin
          imem_haddr_r <= pc_if_r;
          last_addr_r  <= pc_if_r;
          pc_if_r      <= pc_if_r;
          inst_if_r    <= inst_if_r;
          if_valid_r   <= 1'b0;
        end else if(imem_hready_i & ~de_ready_i & ~if_valid_r) begin
//          imem_haddr_r <= pc_if_r;
//          last_addr_r  <= pc_if_r;
//          pc_if_r      <= pc_if_r;
//          inst_if_r    <= inst_if_r;
          imem_haddr_r <= imem_haddr_r + 32'h4;
          last_addr_r  <= imem_haddr_r;
          pc_if_r      <= last_addr_r;
          inst_if_r    <= imem_hrdata_i;
          if_valid_r   <= 1'b1;
        // memory just finished an access and will store the instruction 
        // in the buffer at the ende of this cycle. The DE stage could 
        // take an instrution, but currently, there is none (the new one 
        // will be in the buffer only at the *end* of this cycle).
        // -> Its fine. We just continue to fetch the next inst and 
        // set the output of the IF stage to valid (so DE will take it 
        // in the next cycle).
        end else if(imem_hready_i & de_ready_i & ~if_valid_r) begin
          imem_haddr_r <= imem_haddr_r + 32'h4;
          last_addr_r  <= imem_haddr_r;
          pc_if_r      <= last_addr_r;
          inst_if_r    <= imem_hrdata_i;
          if_valid_r   <= 1'b1;
        // memory is working, de is also not ready to take anything in 
        // this cycle, but there is a not-yet-taken instruction in the 
        // hold register.
        // -> we reset the addr to the one of the instruction in the hold 
        // register and restart, hoping that next time we finish, the de 
        // stage will be able to take the inst. 
        // *this is likely not very optimal and should be improved*
        // (but it is fail-safe ;))
        end else if(~imem_hready_i & ~de_ready_i & if_valid_r) begin
          imem_haddr_r <= pc_if_r;
          last_addr_r  <= pc_if_r;
          pc_if_r      <= pc_if_r;
          inst_if_r    <= inst_if_r;
          if_valid_r   <= 1'b0;  
        end
      end
    end
  end
end

always @(*) begin
  next_state = state;
  imem_htrans_r = `HASTI_TRANS_IDLE;
  case (state) 
    StRestart: begin 
                 next_state =  kill_if_i ? StRestart : (imem_hready_i ? StFetch : StRestart);
                 imem_htrans_r = `HASTI_TRANS_NONSEQ;
               end
    StFetch:   begin 
                 next_state    = kill_if_i ?  StRestart : (if_valid_r & ~de_ready_i) ? StRestart : StFetch;
                 imem_htrans_r = `HASTI_TRANS_NONSEQ;
               end
    default: ;
  endcase
end

endmodule
