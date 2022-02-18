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
//`include "rv32_opcodes.vh"
`include "airi5c_arch_options.vh"

module airi5c_fetch (      
  input                  nreset,       
  input                  clk,
  output                 imem_wait_c, 
  input   [`XPR_LEN-1:0] imem_addr_c,
  output  [`XPR_LEN-1:0] PC_IF,
  input                  stall_IF,
  input                  kill_IF,
  output  [`XPR_LEN-1:0] imem_rdata_c,
  output                 imem_badmem_e_c,
  input                  imem_stall_c,
  output                 imem_compressed_c,
  output                 predicted_branch_IF,

  input                  imem_wait, 
  output  [`XPR_LEN-1:0] imem_addr,
  input   [`XPR_LEN-1:0] imem_rdata,
  input                  imem_badmem_e,
  output                 imem_stall
);

reg [`XPR_LEN-1:0] imem_addr_r;         assign imem_addr = imem_addr_r;
reg                imem_stall_r;        assign imem_stall = imem_stall_r;
reg                imem_wait_c_r;       assign imem_wait_c = imem_wait_c_r;
reg                imem_badmem_e_c_r;   assign imem_badmem_e_c = imem_badmem_e_c_r;
reg                imem_compressed_c_r; assign imem_compressed_c = imem_compressed_c_r;



reg [`XPR_LEN-1:0] addr_DC, prev_addr_DC, rdata_DC;
reg [`XPR_LEN-1:0] decoded_insn, PC_IF_r;
reg                had_restart;

wire  [31:0]  insn  = rdata_DC;


// 
// Simple branch prediction
// ------------------------
// Prediction: Forward branches are never taken, backward branches
//             are always taken.

// partially decode insn to find branches/jmps
wire        branch           = (insn[6:0] == 7'b1100011);
wire        jump             = (insn[6:0] == 7'b1101111);

// calculate the branch target (register indirect branches are not predicted!)
wire        predicted_branch = (branch & insn[31]) || jump;
wire [12:0] branch_offset    = {insn[31],insn[7],insn[30:25],insn[11:8],1'b0};
wire [20:0] jump_offset      = {insn[31],insn[19:12],insn[20],insn[30:21],1'b0};

wire [31:0] sign_ext_offset  = branch ? {{19{branch_offset[12]}},branch_offset} :
                               jump   ? {{11{jump_offset[20]}},jump_offset} : 32'h0;

wire [31:0] branch_target    = PC_IF + sign_ext_offset;


assign imem_rdata_c = decoded_insn;
assign PC_IF        = PC_IF_r;

localparam [3:0] s_reset = 0,
                 s_fetch = 3,
                 s_restart = 5;


reg [3:0] state, next_state;
wire      restart = kill_IF;

always @(posedge clk or negedge nreset) begin
  if(~nreset) begin 
    state        <= s_reset;
    addr_DC      <= `START_HANDLER;
    prev_addr_DC <= 32'hdeadbeef;
    PC_IF_r      <= 32'h80000000;
    had_restart  <= 1'b1;
  end else begin
    state        <= next_state;
    had_restart  <= restart;
    if(state == s_fetch) begin
      if(restart) begin
        addr_DC      <= imem_addr_c;
        prev_addr_DC <= addr_DC;
        PC_IF_r      <= imem_addr_c;
      end else if(~imem_wait & ~imem_stall_c) begin 
        addr_DC      <= predicted_branch ? branch_target + 4 : addr_DC + 4;
        prev_addr_DC <= predicted_branch ? branch_target : addr_DC;
        PC_IF_r      <= predicted_branch ? branch_target : addr_DC;
      end 
    end else if(state == s_restart) begin 
      if(restart) begin
        addr_DC      <= imem_addr_c;
        prev_addr_DC <= addr_DC;
        PC_IF_r      <= imem_addr_c;
      end else if(~imem_wait & ~imem_stall_c) begin 
        addr_DC      <= addr_DC + 4;
        PC_IF_r      <= addr_DC;
        prev_addr_DC <= addr_DC;
      end
    end
  end 
end

assign predicted_branch_IF = ~(state == s_restart) & predicted_branch;


always @(*) begin 
  imem_addr_r         = imem_stall_c ? prev_addr_DC : (predicted_branch ? branch_target : addr_DC);
  imem_stall_r        = 0;
  imem_wait_c_r       = 0;
  imem_badmem_e_c_r   = 0;
  imem_compressed_c_r = 0; //((state == s_reset) || &imem_rdata[1:0]) ? 1'b0 : 1'b1; // give compressed info to core;
  rdata_DC            = (imem_wait || had_restart) ? 32'h00000013 : imem_rdata;
  next_state          = s_fetch;

  case(state)
    s_reset      : begin
                       next_state    = s_fetch;
                     imem_wait_c_r = 1'b1;
                   end
    s_restart    : begin
                     next_state    = (restart | imem_wait) ? s_restart : s_fetch;
                     imem_addr_r   = imem_stall_c ? prev_addr_DC : addr_DC; 
                     imem_wait_c_r = 1'b1;
                     imem_stall_r  = 1'b0;
                     rdata_DC      = 32'h00000013; 
                   end
    s_fetch      : begin
                     next_state = restart ? s_restart : s_fetch;
                     imem_wait_c_r = imem_wait;
                     imem_stall_r = imem_wait;
                   end
  endcase
end

/*
reg	[`XPR_LEN-1:0]	imem_rdata_r, imem_addr_r;
reg	had_reset, had_redirect;

reg	[`XPR_LEN-1:0]	decoded_insn;
reg	[`XPR_LEN-1:0]	PC_DC_r;


assign  imem_wait_c = imem_wait || ~nreset || had_reset || imem_exception_WB_c; //moved imem_wait_r into airi5c_ctrl
assign  imem_badmem_e_c = 1'b0;


reg kill_reset_DC; // this register defines if the instruction data in IF stage (i.e. imem_rdata_c) is overwritten with a NOP 
assign  imem_stall = imem_wait  && ~had_redirect && ~imem_exception_WB_c; //when an exception is in WB, the PC will already hold the exception address
assign  imem_rdata_c = kill_reset_DC ? `RV_NOP : decoded_insn;
assign  imem_addr = imem_addr_c;
assign  PC_DC = PC_DC_r;

// pipeline register PC_DC (aka imem_addr_r) and inst_IF (aka imem_rdata_c output)
always @(posedge clk or negedge nreset) begin
  if (~nreset) begin
    imem_addr_r <= `START_HANDLER;
    kill_reset_DC <= 1'b1;
  end else begin
    if (~stall_DC) begin
      imem_addr_r <= imem_addr_c;
    end //(~stall_DC) begin
    kill_reset_DC <= (kill_DC & ~stall_DC) ? 1'b1 : 1'b0;
  end //(reset) begin ... end else begin
end
 

always @(posedge clk or negedge nreset) begin
  if(~nreset) begin 
    had_reset <= 1'b1;
    imem_rdata_r <= 0;
    had_redirect <= 1'b0;
  end else begin
    if (imem_stall_c && ~imem_wait_c) begin // imem_stall_c is actually stall_IF
      imem_rdata_r <= imem_rdata_r;
    end else if (kill_DC) begin
      imem_rdata_r <= `RV_NOP;
    end else begin  
      imem_rdata_r <= imem_rdata;
      PC_DC_r <= imem_addr_r;
    end
    had_reset <= 1'b0;
    had_redirect <= imem_redirect_c; 
  end
end
*/

// Decoding part 
// =============

`ifdef ISA_EXT_C
wire  [4:0] func  = {insn[15:13],insn[1:0]};

// decode instructions

wire    c_addi4spn	=	(func == 5'b00000) && (insn[12:5] != 0);
wire    c_fld		=	(func == 5'b00100);
wire    c_lw		=	(func == 5'b01000);
wire    c_flw		=	(func == 5'b01100);
wire	c_fsd		=	(func == 5'b10100);
wire	c_sw		=	(func == 5'b11000);
wire	c_fsw		=	(func == 5'b11100);

wire	c_nop		=	(func == 5'b00001) && (insn[11:7] == 0);
wire	c_addi		=	(func == 5'b00001) && ~(insn[11:7] == 0) && ~({insn[12],insn[6:2]} == 0);
wire	c_jal		=	(func == 5'b00101);
wire	c_li		=	(func == 5'b01001);
wire	c_addi16sp	=	(func == 5'b01101) && (insn[11:7] == 2);
wire	c_lui		=	(func == 5'b01101) && ~((insn[11:7] == 2) || (insn[11:7] == 0));
wire	c_srli		=	(func == 5'b10001) && (insn[11:10] == 2'b00);
wire	c_srai		=	(func == 5'b10001) && (insn[11:10] == 2'b01);
wire	c_andi		=	(func == 5'b10001) && (insn[11:10] == 2'b10);

wire	c_sub		=	(func == 5'b10001) && (insn[12] == 1'b0) && (insn[11:10] == 2'b11) && (insn[6:5] == 2'b00);
wire	c_xor		=	(func == 5'b10001) && (insn[12] == 1'b0) && (insn[11:10] == 2'b11) && (insn[6:5] == 2'b01);
wire	c_or		=	(func == 5'b10001) && (insn[12] == 1'b0) && (insn[11:10] == 2'b11) && (insn[6:5] == 2'b10);
wire	c_and		=	(func == 5'b10001) && (insn[12] == 1'b0) && (insn[11:10] == 2'b11) && (insn[6:5] == 2'b11);

wire	c_subw		=	(func == 5'b10001) && (insn[12] == 1'b1) && (insn[11:10] == 2'b11) && (insn[6:5] == 2'b00);
wire	c_addw		=	(func == 5'b10001) && (insn[12] == 1'b1) && (insn[11:10] == 2'b11) && (insn[6:5] == 2'b01);

wire	c_j		=	(func == 5'b10101);

wire	c_beqz		=	(func == 5'b11001);
wire	c_bnez		=	(func == 5'b11101);

wire	c_slli		=	(func == 5'b00010) && ~(insn[11:7] == 0);
wire	c_fldsp		=	(func == 5'b00110);
wire	c_lwsp		=	(func == 5'b01010) && ~(insn[11:7] == 0);
wire	c_flwsp		=	(func == 5'b01110);
wire	c_jr		=	(func == 5'b10010) && (insn[12] == 1'b0) && ~(insn[11:7] == 0) && (insn[6:2] == 0);
wire	c_mv		=	(func == 5'b10010) && (insn[12] == 1'b0) && ~(insn[11:7] == 0) && ~(insn[6:2] == 0);
wire	c_ebreak	=	(insn[15:0] == 16'b1001000000000010);
wire	c_jalr		=	(func == 5'b10010) && (insn[12] == 1'b1) && ~(insn[11:7] == 0) && (insn[6:2] == 0);
wire	c_add		=	(func == 5'b10010) && (insn[12] == 1'b1) && ~(insn[11:7] == 0) && ~(insn[6:2] == 0);
wire	c_fsdsp		=	(func == 5'b10110);
wire	c_swsp		=	(func == 5'b11010);
wire	c_fswsp		=	(func == 5'b11110);

wire	[11:0]	fld_imm	=	{4'b0000,insn[6:5],insn[12:10],3'b000};
wire	[19:0]	jal_imm =	{insn[12],insn[8],insn[10:9],insn[6],insn[7],insn[2],insn[11],insn[5:3],insn[12],{8{insn[12]}}};
wire	[11:0]	fldsp_imm =	{3'b000,insn[4:2],insn[12],insn[6:5],3'b000};
wire	[11:0]	lw_imm =	{5'b00000,insn[5],insn[12:10],insn[6],2'b00};
wire	[11:0]	li_imm =	{{7{insn[12]}},insn[6:2]};

wire	[11:0]	lwsp_imm =	{4'b0000,insn[3:2],insn[12],insn[6:4],2'b00};
wire	[11:0]	flwsp_imm =	{4'b0000,insn[3:2],insn[12],insn[6:4],2'b00};

wire	[11:0]	flw_imm	=	{5'b00000,insn[5],insn[12:10],insn[6],2'b00};
wire    [11:0]  addi_imm =  {{7{insn[12]}},insn[6:2]};
wire    [11:0]  addi4spn_imm = {2'b00,insn[10:7],insn[12:11],insn[5],insn[6],2'b00};
wire	[11:0]	addi16sp_imm =	{{2{insn[12]}},insn[12],insn[4:3],insn[5],insn[2],insn[6],4'b0000};
wire	[31:12]	lui_imm	=	{{14{insn[12]}},insn[12],insn[6:2]};
wire	[11:0]	andi_imm = 	{{7{insn[12]}},insn[6:2]};
wire	[11:0]	fsd_imm = 	{4'b0000,insn[6:5],insn[12:10],3'b000};
wire	[19:0]	j_imm = 	{insn[12],insn[8],insn[10:9],insn[6],insn[7],insn[2],insn[11],insn[5:3],insn[12],{8{insn[12]}}};
wire	[11:0]	fsdsp_imm = 	{3'b000,insn[9:7],insn[12:10],3'b000};

wire	[11:0]	sw_imm = 	{5'b00000,insn[5],insn[12:10],insn[6],2'b00};
wire	[11:0]	fsw_imm = 	{5'b00000,insn[5],insn[12:10],insn[6],2'b00};

wire	[12:0]	beqz_imm = 	{{4{insn[12]}},insn[12],insn[6:5],insn[2],insn[11:10],insn[4:3],1'b0};
wire	[12:0]	bnez_imm = 	{{4{insn[12]}},insn[12],insn[6:5],insn[2],insn[11:10],insn[4:3],1'b0};

wire	[11:0]	swsp_imm =	{4'b0000,insn[8:7],insn[12:9],2'b00};
wire	[11:0]	fswsp_imm =	{4'b0000,insn[8:7],insn[12:9],2'b00};

always @(*) begin
	decoded_insn = 32'hdeadbeef;
	if(&insn[1:0]) begin	// if regular instruction
		decoded_insn = insn;
	end else begin		// else if compressed instruction
		case(func)
			5'b00000	:	decoded_insn = c_addi4spn ? {addi4spn_imm,5'b00010,3'b000,2'b01,insn[4:2],7'b0010011} : 32'h0;	// addi4spn or illegal
			5'b00001	:	decoded_insn = c_nop ? 32'h00000013 : c_addi ? {addi_imm ,insn[11:7],3'b000,insn[11:7],7'b0010011} : 32'h00000013; // nop or addi or reserved for hint (--> do a nop)
			5'b00010	:	decoded_insn = c_slli ? {7'b0000000, insn[6:2],insn[11:7],3'b001,insn[11:7],7'b0010011} : 32'h0; // slli or illegal
//			5'b00011	:	decoded_insn = 
			5'b00100	:	decoded_insn = c_fld ? {fld_imm,2'b01,insn[9:7],3'b011,2'b01,insn[4:2],7'b0000111} : 32'h0; // fld or illegal
			5'b00101	:	decoded_insn = c_jal ? {jal_imm,5'b00001,7'b1101111} : 32'h0; // jal or illegal
			5'b00110	:	decoded_insn = c_fldsp ? {fldsp_imm,5'b00010,3'b011,insn[11:7],7'b0000111} : 32'h0; // fldsp or illegal
//			5'b00111	:	decoded_insn = 
			5'b01000	:	decoded_insn = c_lw ? {lw_imm,2'b01,insn[9:7],3'b010,2'b01,insn[4:2],7'b0000011} : 32'h0; // lw or illegal
			5'b01001	:	decoded_insn = c_li ? {li_imm,5'b00000,3'b000,insn[11:7],7'b0010011} : 32'h0; // li or illegal
			5'b01010	:	decoded_insn = c_lwsp ? {lwsp_imm,5'b00010,3'b010,insn[11:7],7'b0000011} : 32'h0; // lw or illegal
//			5'b01011	:	decoded_insn = 
			5'b01100	:	decoded_insn = c_flw ? {flw_imm,2'b01,insn[9:7],3'b010,2'b01,insn[4:2],7'b0000111} : 32'h0; // flw or illegal
			5'b01101	:	decoded_insn = 	c_addi16sp ? {addi16sp_imm, 5'b00010,3'b000,5'b00010,7'b0010011} : 
								c_lui ? {lui_imm,insn[11:7],7'b0110111} : 32'h0; // addi16sp or lui or illegal
			5'b01110	:	decoded_insn = c_flwsp ? {flwsp_imm,5'b00010,3'b010,insn[11:7],7'b0000111} : 32'h0; // flwsp or illegal
//			5'b01111	:	decoded_insn = 
			5'b10000	:	decoded_insn = 32'h0; // reserved
			5'b10001	:	decoded_insn = 	c_srli ? { 7'b0000000,insn[6:2],2'b01,insn[9:7],3'b101,2'b01,insn[9:7],7'b0010011} :
								c_srai ? { 7'b0100000,insn[6:2],2'b01,insn[9:7],3'b101,2'b01,insn[9:7],7'b0010011} :
								c_andi ? { andi_imm,2'b01,insn[9:7],3'b111,2'b01,insn[9:7],7'b0010011} :
								c_sub ? { 7'b0100000,2'b01,insn[4:2],2'b01,insn[9:7],3'b000,2'b01,insn[9:7],7'b0110011} :
								c_xor ? { 7'b0000000,2'b01,insn[4:2],2'b01,insn[9:7],3'b100,2'b01,insn[9:7],7'b0110011} :
								c_or  ? { 7'b0000000,2'b01,insn[4:2],2'b01,insn[9:7],3'b110,2'b01,insn[9:7],7'b0110011} :
								c_and ? { 7'b0000000,2'b01,insn[4:2],2'b01,insn[9:7],3'b111,2'b01,insn[9:7],7'b0110011} : 32'h0;
			5'b10010	:	decoded_insn = 	c_jr ? { 12'h0, insn[11:7],3'b000,5'h0,7'b1100111} : 
								c_mv ? { 7'b0000000,insn[6:2],5'b00000,3'b000,insn[11:7],7'b0110011} :        //C.MV expands into add rd, x0, rs2
								c_ebreak ? { 12'h1,13'h0,7'b1110011} :
								c_jalr ? { 12'h0,insn[11:7],3'b000,5'b00001,7'b1100111 } :
								c_add ? { 7'h0,insn[6:2],insn[11:7],3'b000,insn[11:7],7'b0110011 } : 32'h0;
//			5'b10011	:	decoded_insn = 
			5'b10100	:	decoded_insn = c_fsd ? { fsd_imm[11:5],2'b01,insn[4:2],2'b01,insn[9:7],3'b011,fsd_imm[4:0],7'b0100111} : 32'h0; // fsd or illegal
			5'b10101	:	decoded_insn = c_j ? { j_imm,5'b00000,7'b1101111} : 32'h0; // j or illegal
			5'b10110	:	decoded_insn = c_fsdsp ? { fsdsp_imm[11:5], insn[6:2],5'b00010,3'b011,fsdsp_imm[4:0],7'b0100111} : 32'h0; // fsdsp or illegal
//			5'b10111	:	decoded_insn = 
			5'b11000	:	decoded_insn = c_sw ? { sw_imm[11:5],2'b01,insn[4:2],2'b01,insn[9:7],3'b010,sw_imm[4:0],7'b0100011} : 32'h0; // sw or illegal
			5'b11001	:	decoded_insn = c_beqz ? { beqz_imm[12],beqz_imm[10:5],5'b00000,2'b01,insn[9:7],3'b000,beqz_imm[4:1],beqz_imm[11],7'b1100011} : 32'h0; // beqz or illegal
			5'b11010	:	decoded_insn = c_swsp ? { swsp_imm[11:5],insn[6:2],5'b00010,3'b010,swsp_imm[4:0],7'b0100011} : 32'h0; // swsp or illegal
//			5'b11011	:	decoded_insn = 
			5'b11100	:	decoded_insn = c_fsw ? { fsw_imm[11:5],2'b01,insn[4:2],2'b01,insn[9:7],3'b010,fsw_imm[4:0],7'b0100111} : 32'h0; // fsw or illegal
			5'b11101	:	decoded_insn = c_bnez ? { bnez_imm[12],bnez_imm[10:5],5'b00000,2'b01,insn[9:7],3'b001,bnez_imm[4:1],bnez_imm[11],7'b1100011} : 32'h0; // bnez or illegal
			5'b11110	:	decoded_insn = c_fswsp ? { fswsp_imm[11:5],insn[6:2],5'b00010,3'b010,fswsp_imm[4:0],7'b0100111} : 32'h0; // fswsp or illegal
//			5'b11111	:	decoded_insn = 

		endcase
	end	
		
end
`else
//if C-ext is not defined, compression will never happen and decoded_insn is
//always insn.
assign imem_compressed_c = 1'b0; 

always @(*) begin
    decoded_insn <= insn;
end
`endif
endmodule
