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
`timescale 1ns/100ps


`include "airi5c_ctrl_constants.vh"
`include "airi5c_alu_ops.vh"
`include "rv32_opcodes.vh"

module airi5c_WB_pregs(
input                           clk,
input                           nreset,

input                           stall_WB,

input                           killed_EX,
input                           ex_EX,
//input                           wr_reg_unkilled_EX,
/*input [`WB_SRC_SEL_WIDTH-1:0]   wb_src_sel_EX,
input  [`MCAUSE_WIDTH-1:0]      ex_code_EX,
input                           ex_int_EX,
input  [`REG_ADDR_WIDTH-1:0]    reg_to_wr_EX,
input                           dmem_wen_EX,
input                           dmem_en_EX,
input                           wfi_EX,
input                           uses_pcpi_EX,
input                           killed_EX,
input                           bubble_in_EX,
input  [`XPR_LEN-1:0]           branch_target_EX,
input                           redirect_EX,*/

output                           prev_killed_WB,
output                           had_ex_WB
//output                           wr_reg_unkilled_WB,
/*output  [`WB_SRC_SEL_WIDTH-1:0]  wb_src_sel_WB,
output  [`MCAUSE_WIDTH-1:0]      prev_ex_code_WB,
output                           prev_ex_int_WB,
output  [`REG_ADDR_WIDTH-1:0]    reg_to_wr_WB,
output                           store_in_WB,
output                           dmem_en_WB,
output                           wfi_unkilled_WB,
output                           uses_pcpi_WB,
output                           bubble_in_WB,
output  [`XPR_LEN-1:0]           branch_target_WB,
output                           redirect_WB*/
);

reg                              prev_killed_WB_r;
reg                              had_ex_WB_r;
//reg                              wr_reg_unkilled_WB_r;
/*reg  [`WB_SRC_SEL_WIDTH-1:0]     wb_src_sel_WB_r;
reg  [`MCAUSE_WIDTH-1:0]         prev_ex_code_WB_r;
reg                              prev_ex_int_WB_r;
reg  [`REG_ADDR_WIDTH-1:0]       reg_to_wr_WB_r;
reg                              store_in_WB_r;
reg                              dmem_en_WB_r;
reg                              wfi_unkilled_WB_r;
reg                              uses_pcpi_WB_r;
reg                              bubble_in_WB_r;
reg  [`XPR_LEN-1:0]              branch_target_WB_r;
reg                              redirect_WB_r;*/

assign prev_killed_WB      =  prev_killed_WB_r;
assign had_ex_WB           =  had_ex_WB_r;
//assign wr_reg_unkilled_WB  =  wr_reg_unkilled_WB_r;
/*assign wb_src_sel_WB       =  wb_src_sel_WB_r;
assign prev_ex_code_WB     =  prev_ex_code_WB_r;
assign prev_ex_int_WB      =  prev_ex_int_WB_r;
assign reg_to_wr_WB        =  reg_to_wr_WB_r;
assign store_in_WB         =  store_in_WB_r;
assign dmem_en_WB          =  dmem_en_WB_r;
assign wfi_unkilled_WB     =  wfi_unkilled_WB_r;
assign uses_pcpi_WB        =  uses_pcpi_WB_r;assign 
assign bubble_in_WB        =  bubble_in_WB_r;
assign branch_target_WB    =  branch_target_WB_r;
assign redirect_WB         =  redirect_WB_r;*/

always @(posedge clk or negedge nreset) begin
  if (~nreset) begin
    prev_killed_WB_r      <= 0;
    had_ex_WB_r           <= 0;
//    wr_reg_unkilled_WB_r  <= 0;
/*    wb_src_sel_WB_r       <= 0;
    prev_ex_code_WB_r     <= 0;
    reg_to_wr_WB_r        <= 0;
    store_in_WB_r         <= 0;
    dmem_en_WB_r          <= 0;
    wfi_unkilled_WB_r     <= 0;
    uses_pcpi_WB_r        <= 0;
    bubble_in_WB_r        <= 1;
    branch_target_WB_r  <= 0;
    redirect_WB_r       <= 0;    */
  end else if (!stall_WB) begin
    prev_killed_WB_r      <= killed_EX;
    had_ex_WB_r           <= ex_EX;
//    wr_reg_unkilled_WB_r  <= wr_reg_EX || (uses_pcpi && pcpi_wr);
/*    wb_src_sel_WB_r       <= wb_src_sel_EX;
    prev_ex_code_WB_r     <= ex_code_EX;
    prev_ex_int_WB_r      <= ex_int_DX;
    reg_to_wr_WB_r        <= reg_to_wr_EX;
    store_in_WB_r         <= dmem_wen_EX;
    dmem_en_WB_r          <= dmem_en_EX;
    wfi_unkilled_WB_r     <= wfi_EX;
    uses_pcpi_WB_r        <= uses_pcpi;
    bubble_in_WB_r        <= killed_EX ? 1'b1 : bubble_in_EX;
    if(!bubble_in_EX) 
      branch_target_WB_r   <= branch_target;
    if(!bubble_in_EX) 
      redirect_WB_r        <= redirect;*/
  end
end
endmodule

