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
// File             : rv32_opcodes.vh
// Author           : A. Stanitzki, I. Hoyer
// Creation Date    : 09.10.20
// Last Modified    : 156.12.21
// Version          : 1.1
// Abstract         : Definition of the opcodes
// History          : 05.03.18 - added dret command to return from debug mode (ASt)
//                    16.12.21 - Custom Opcodes 



// Width-related constants
`define INST_WIDTH          32 // o.k., V2.2, Instruction word is 32 Bits
`define REG_ADDR_WIDTH      5  // o.k., V2.2, There are 32 general purpose registers (GPR) x0 - x31
`define XPR_LEN             32 // o.k., V2.2, Instruction word is 32 Bits T
`define DOUBLE_XPR_LEN      64 // o.k., V2.2
`define LOG2_XPR_LEN        5  // o.k., V2.2, Instruction word is 32 Bits = 2^5
`define SHAMT_WIDTH         5  // o.k., V2.2, Bits [24:20] of Inst

`define RV_NOP              `INST_WIDTH'b0010011 // o.k., V2.2, == ADDI x0 + 0 -> x0 (does nothing)    

// Opcodes

`define RV32_LOAD           7'b0000011 // o.k., V2.2
`define RV32_STORE          7'b0100011 // o.k., V2.2
`define RV32_BRANCH         7'b1100011 // o.k., V2.2
// 7'b1101011 is reserved
`define RV32_JALR           7'b1100111 // o.k., V2.2

`define RV32_MISC_MEM       7'b0001111 // o.k., V2.2 - FENCE / FENCE.I
`define RV32_JAL            7'b1101111 // o.k., V2.2

`define RV32_OP_IMM         7'b0010011 // o.k., V2.2, REG/IMM ALU operations 
`define RV32_OP             7'b0110011 // o.k., V2.2, REG/REG ALU operations
`define RV32_SYSTEM         7'b1110011 // o.k., V2.2 -> ECALL, EBREAK, CSR (RW/RS/RC/RWI/RSI/RCI)
`define RV32_CUSTOM0         7'b0001011 //AI Accelerators use h0B 
`define RV32_CUSTOM1         7'h77 //Custom Module uses SIMD Opcode (h77) 1110111
//`define RV32_CUSTOM2         7'b1011011
//`define RV32_CUSTOM3         7'b1111011
//`define RV32_CUSTOM4         7'b1110111

`define RV32_AUIPC          7'b0010111 // o.k., V2.2
`define RV32_LUI            7'b0110111 // o.k., V2.2


// C - extension / compressed instructions

// opcodes
`define RV32_C_LOADSTORE    2'b00
`define RV32_C_OP           2'b01
`define RV32_C_MISC         2'b10

// compressed FUNCT3 encodings
`define RV32_FUNCT3_0       3'b000
`define RV32_FUNCT3_1       3'b000
`define RV32_FUNCT3_2       3'b000
`define RV32_FUNCT3_3       3'b000
`define RV32_FUNCT3_4       3'b000
`define RV32_FUNCT3_5       3'b000
`define RV32_FUNCT3_6       3'b000
`define RV32_FUNCT3_7       3'b000

// Arithmetic FUNCT3 encodings

`define RV32_FUNCT3_ADD_SUB 0 // o.k., V2.2
`define RV32_FUNCT3_SLL     1 // o.k., V2.2
`define RV32_FUNCT3_SLT     2 // o.k., V2.2
`define RV32_FUNCT3_SLTU    3 // o.k., V2.2
`define RV32_FUNCT3_XOR     4 // o.k., V2.2
`define RV32_FUNCT3_SRA_SRL 5 // o.k., V2.2
`define RV32_FUNCT3_OR      6 // o.k., V2.2
`define RV32_FUNCT3_AND     7 // o.k., V2.2

// Branch FUNCT3 encodings

`define RV32_FUNCT3_BEQ     0 // o.k., V2.2
`define RV32_FUNCT3_BNE     1 // o.k., V2.2
`define RV32_FUNCT3_BLT     4 // o.k., V2.2
`define RV32_FUNCT3_BGE     5 // o.k., V2.2
`define RV32_FUNCT3_BLTU    6 // o.k., V2.2
`define RV32_FUNCT3_BGEU    7 // o.k., V2.2

// MISC-MEM FUNCT3 encodings
`define RV32_FUNCT3_FENCE   0 // o.k., V2.2
`define RV32_FUNCT3_FENCE_I 1 // o.k., V2.2

// SYSTEM FUNCT3 encodings

`define RV32_FUNCT3_PRIV    0 // o.k., V2.2 - ECALL and EBREAK
`define RV32_FUNCT3_CSRRW   1 // o.k., V2.2
`define RV32_FUNCT3_CSRRS   2 // o.k., V2.2
`define RV32_FUNCT3_CSRRC   3 // o.k., V2.2
`define RV32_FUNCT3_CSRRWI  5 // o.k., V2.2
`define RV32_FUNCT3_CSRRSI  6 // o.k., V2.2
`define RV32_FUNCT3_CSRRCI  7 // o.k., V2.2

// PRIV FUNCT12 encodings

`define RV32_FUNCT12_ECALL  12'b000000000000 // o.k., V2.2
`define RV32_FUNCT12_EBREAK 12'b000000000001 // o.k., V2.2
`define RV32_FUNCT12_MRET   12'b001100000010    
`define RV32_FUNCT12_DRET   12'b011110110010 
`define RV32_FUNCT12_WFI    12'b000100000101 

// F - extension / floating point instructions
// opcode
`define RV32_F_LOAD         7'b0000111
`define RV32_F_STORE        7'b0100111
`define RV32_F_MADD         7'b1000011 
`define RV32_F_MSUB         7'b1000111
`define RV32_F_NMADD        7'b1001111
`define RV32_F_NMSUB        7'b1001011
`define RV32_F_OP           7'b1010011

// func3
`define RV32_F_FUNCT3_LOAD  3'b010
`define RV32_F_FUNCT3_STORE 3'b010
`define RV32_F_FUNCT3_MOV   3'b000
`define RV32_F_FUNCT3_J     3'b000
`define RV32_F_FUNCT3_JN    3'b001
`define RV32_F_FUNCT3_JX    3'b010
`define RV32_F_FUNCT3_MIN   3'b000
`define RV32_F_FUNCT3_MAX   3'b001
`define RV32_F_FUNCT3_EQ    3'b010
`define RV32_F_FUNCT3_LT    3'b001
`define RV32_F_FUNCT3_LE    3'b000
`define RV32_F_FUNCT3_CLASS 3'b001

// rs2
`define RV32_F_RS2_MOV      5'b00000
`define RV32_F_RS2_SQRT     5'b00000
`define RV32_F_RS2_FI       5'b00000
`define RV32_F_RS2_FU       5'b00001
`define RV32_F_RS2_IF       5'b00000
`define RV32_F_RS2_UF       5'b00001
`define RV32_F_RS2_CLASS    5'b00000

// funct7
`define RV32_F_FUNCT7_MFICL 7'b1110000  // move float to int or class
`define RV32_F_FUNCT7_MOVIF 7'b1111000
`define RV32_F_FUNCT7_ADD   7'b0000000
`define RV32_F_FUNCT7_SUB   7'b0000100
`define RV32_F_FUNCT7_MUL   7'b0001000
`define RV32_F_FUNCT7_DIV   7'b0001100
`define RV32_F_FUNCT7_SQRT  7'b0101100
`define RV32_F_FUNCT7_SGN   7'b0010000
`define RV32_F_FUNCT7_SEL   7'b0010100
`define RV32_F_FUNCT7_CVTFI 7'b1100000
`define RV32_F_FUNCT7_CVTIF 7'b1101000
`define RV32_F_FUNCT7_CMP   7'b1010000
`define RV32_F_FUNCT7_CLASS 7'b1110000 

// RV32M encodings
`define RV32_FUNCT7_MUL_DIV 7'd1    

`define RV32_FUNCT3_MUL     3'd0    
`define RV32_FUNCT3_MULH    3'd1    
`define RV32_FUNCT3_MULHSU  3'd2    
`define RV32_FUNCT3_MULHU   3'd3    
`define RV32_FUNCT3_DIV     3'd4    
`define RV32_FUNCT3_DIVU    3'd5    
`define RV32_FUNCT3_REM     3'd6    
`define RV32_FUNCT3_REMU    3'd7    
