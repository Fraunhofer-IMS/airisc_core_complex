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
// File              : base_isa_tests.vh
// Author            : A. Stanitzki
// Creation Date     : 09.10.20
// Last Modified     : 15.02.21
// Version           : 1.0
//

errorcount <= 0;
$write("\n");
$write("RV32I instructions \n");
$write("------------------ \n");

// ========================
// == 1 - ISA test - ADDI =
// ========================;
testtotal = testtotal + 1;
$write("ADDI   : ");
run_test_program_bulk(1,"./memfiles/rv32ui/rv32ui-p-addi.mem",338,result);

if(result != 0) errorcount = errorcount + 1;

// =======================
// == 2- ISA test - ADD  =
// =======================
testtotal = testtotal + 1;
$write("ADD    : ");
run_test_program_bulk(2,"./memfiles/rv32ui/rv32ui-p-add.mem",466,result);

if(result != 0) errorcount = errorcount + 1;

// ========================
// == 3 - ISA test - ANDI =
// ========================
testtotal = testtotal + 1;
$write("ANDI   : ");
run_test_program_bulk(3,"./memfiles/rv32ui/rv32ui-p-andi.mem",274,result);

if(result != 0) errorcount = errorcount + 1;


// =====================
// == Testbench-Selbsttest  =
// =====================
testtotal = testtotal + 1;
$write("TB-BIST: ");
run_test_program_bulk(35,"./memfiles/nop.mem",100,result);  // Speicher mit NOPs gefüllt.

if(result == 0) errorcount = errorcount + 1; // check for expected error!


// ========================
// == 4 - ISA test - AND  =
// ========================
testtotal = testtotal + 1;
$write("AND    : ");
run_test_program_bulk(4,"./memfiles/rv32ui/rv32ui-p-and.mem",466,result);

if(result != 0) errorcount = errorcount + 1;


// ==========================
// == 5 - ISA test - AUIPC  =
// ==========================
testtotal = testtotal + 1;
$write("AUIPC  : ");
run_test_program_bulk(5,"./memfiles/rv32ui/rv32ui-p-auipc.mem",146,result);

if(result != 0) errorcount = errorcount + 1;


// ========================
// == 6 - ISA test - BEQ  =
// ========================
testtotal = testtotal + 1;
$write("BEQ    : ");
run_test_program_bulk(6,"./memfiles/rv32ui/rv32ui-p-beq.mem",338,result);

if(result != 0) errorcount = errorcount + 1;


// ========================
// == 7 - ISA test - BGE  =
// ========================
testtotal = testtotal + 1;
$write("BGE    : ");
run_test_program_bulk(7,"./memfiles/rv32ui/rv32ui-p-bge.mem",338,result);

if(result != 0) errorcount = errorcount + 1;

// ========================
// == 8 - ISA test - BGEU  =
// ========================
testtotal = testtotal + 1;
$write("BGEU   : ");
run_test_program_bulk(8,"./memfiles/rv32ui/rv32ui-p-bgeu.mem",348,result);

if(result != 0) errorcount = errorcount + 1;


// ====================
// == 9 - ISA test - BLT  =
// ====================
testtotal = testtotal + 1;
$write("BLT    : ");
run_test_program_bulk(9,"./memfiles/rv32ui/rv32ui-p-blt.mem",338,result);

if(result != 0) errorcount = errorcount + 1;


// =====================
// == 10 - ISA test - BLTU  =
// =====================
testtotal = testtotal + 1;
$write("BLTU   : ");
run_test_program_bulk(10,"./memfiles/rv32ui/rv32ui-p-bltu.mem",338,result);

if(result != 0) errorcount = errorcount + 1;


// =====================
// == 11 - ISA test - BNE  =
// =====================
testtotal = testtotal + 1;
$write("BNE    : ");
run_test_program_bulk(11,"./memfiles/rv32ui/rv32ui-p-bne.mem",338,result);

if(result != 0) errorcount = errorcount + 1;


// ========================
// == 12 - ISA test - FENCE_I  =
// ========================
testtotal = testtotal + 1;
$write("FENCE_I: ");
run_test_program_bulk(12,"./memfiles/rv32ui/rv32ui-p-fence_i.mem",264,result);

if(result != 0) errorcount = errorcount + 1;


// =====================
// == 13 - ISA test - JAL   =
// =====================
testtotal = testtotal + 1;
$write("JAL    : ");
run_test_program_bulk(13,"./memfiles/rv32ui/rv32ui-p-jal.mem",146,result);

if(result != 0) errorcount = errorcount + 1;

// =====================
// == 14 - ISA test - JALR  =
// =====================
testtotal = testtotal + 1;
$write("JALR   : ");
run_test_program_bulk(14,"./memfiles/rv32ui/rv32ui-p-jalr.mem",210,result);

if(result != 0) errorcount = errorcount + 1;

// =====================
// == 15 - ISA test - LB    =
// =====================
testtotal = testtotal + 1;
$write("LB     : ");
run_test_program_bulk(15,"./memfiles/rv32ui/rv32ui-p-lb.mem",324,result);

if(result != 0) errorcount = errorcount + 1;

// =====================
// == 16 - ISA test - LBU  =
// =====================
testtotal = testtotal + 1;
$write("LBU    : ");
run_test_program_bulk(16,"./memfiles/rv32ui/rv32ui-p-lbu.mem",324,result);

if(result != 0) errorcount = errorcount + 1;

// =====================
// == 17 - ISA test - LH    =
// =====================
testtotal = testtotal + 1;
$write("LH     : ");
run_test_program_bulk(17,"./memfiles/rv32ui/rv32ui-p-lh.mem",388,result);

if(result != 0) errorcount = errorcount + 1;

// =====================
// == 18 - ISA test - LHU   =
// =====================
testtotal = testtotal + 1;
$write("LHU    : ");
run_test_program_bulk(18,"./memfiles/rv32ui/rv32ui-p-lhu.mem",388,result);

if(result != 0) errorcount = errorcount + 1;

// =====================
// == 19 - ISA test - LUI   =
// =====================
testtotal = testtotal + 1;
$write("LUI    : ");
run_test_program_bulk(19,"./memfiles/rv32ui/rv32ui-p-lui.mem",210,result);

if(result != 0) errorcount = errorcount + 1;

// =====================
// == 20 - ISA test - LW   =
// =====================
testtotal = testtotal + 1;
$write("LW     : ");
run_test_program_bulk(20,"./memfiles/rv32ui/rv32ui-p-lw.mem",388,result);

if(result != 0) errorcount = errorcount + 1;

// =====================
// == 21 - ISA test - OR  =
// =====================
testtotal = testtotal + 1;
$write("OR     : ");
run_test_program_bulk(21,"./memfiles/rv32ui/rv32ui-p-or.mem",466,result);

if(result != 0) errorcount = errorcount + 1;

// =====================
// == 22 - ISA test - ORI   =
// =====================
testtotal = testtotal + 1;
$write("ORI    : ");
run_test_program_bulk(22,"./memfiles/rv32ui/rv32ui-p-ori.mem",274,result);

if(result != 0) errorcount = errorcount + 1;

// =====================
// == 23 - ISA test - SB   =
// =====================
testtotal = testtotal + 1;
$write("SB     : ");
run_test_program_bulk(23,"./memfiles/rv32ui/rv32ui-p-sb.mem",452,result);

if(result != 0) errorcount = errorcount + 1;

// =====================
// == 24 - ISA test - SH  =
// =====================
testtotal = testtotal + 1;
$write("SH     : ");
run_test_program_bulk(24,"./memfiles/rv32ui/rv32ui-p-sh.mem",520,result);

if(result != 0) errorcount = errorcount + 1;


// =====================
// == 25 - ISA test - SLLI  =
// =====================
testtotal = testtotal + 1;
$write("SLLI   : ");
run_test_program_bulk(25,"./memfiles/rv32ui/rv32ui-p-slli.mem",338,result);

if(result != 0) errorcount = errorcount + 1;

// =====================
// == 26 - ISA test - SLL  =
// =====================
testtotal = testtotal + 1;
$write("SLL    : ");
run_test_program_bulk(26,"./memfiles/rv32ui/rv32ui-p-sll.mem",466,result);

if(result != 0) errorcount = errorcount + 1;

// =====================
// == 27 - ISA test - SLTI  =
// =====================
testtotal = testtotal + 1;
$write("SLTI   : ");
run_test_program_bulk(27,"./memfiles/rv32ui/rv32ui-p-slti.mem",338,result);

if(result != 0) errorcount = errorcount + 1;


// =====================
// == 28 - ISA test - SLTIU  =
// =====================
testtotal = testtotal + 1;
$write("SLTIU  : ");
run_test_program_bulk(28,"./memfiles/rv32ui/rv32ui-p-sltiu.mem",338,result);

if(result != 0) errorcount = errorcount + 1;


// =====================
// == 29 - ISA test - SLT  =
// =====================
testtotal = testtotal + 1;
$write("SLT    : ");
run_test_program_bulk(29,"./memfiles/rv32ui/rv32ui-p-slt.mem",466,result);

if(result != 0) errorcount = errorcount + 1;

// =====================
// == 30 - ISA test - SLTU  =
// =====================
testtotal = testtotal + 1;
$write("SLTU   : ");
run_test_program_bulk(30,"./memfiles/rv32ui/rv32ui-p-sltu.mem",466,result);

if(result != 0) errorcount = errorcount + 1;

// =====================
// == 31 - ISA test - SRAI  =
// =====================
testtotal = testtotal + 1;
$write("SRAI   : ");
run_test_program_bulk(31,"./memfiles/rv32ui/rv32ui-p-srai.mem",338,result);

if(result != 0) errorcount = errorcount + 1;

// =====================
// == 32 - ISA test - SRA  =
// =====================
testtotal = testtotal + 1;
$write("SRA    : ");
run_test_program_bulk(32,"./memfiles/rv32ui/rv32ui-p-sra.mem",530,result);

if(result != 0) errorcount = errorcount + 1;

// =====================
// == 33 - ISA test - SRLI  =
// =====================
testtotal = testtotal + 1;
$write("SRLI   : ");
run_test_program_bulk(33,"./memfiles/rv32ui/rv32ui-p-srli.mem",338,result);

if(result != 0) errorcount = errorcount + 1;

// =====================
// == 34 - ISA test - SRL  =
// =====================
testtotal = testtotal + 1;
$write("SRL    : ");
run_test_program_bulk(34,"./memfiles/rv32ui/rv32ui-p-srl.mem",530,result);

if(result != 0) errorcount = errorcount + 1;

// =====================
// == 35 - ISA test - SUB  =
// =====================
testtotal = testtotal + 1;
$write("SUB    : ");
run_test_program_bulk(35,"./memfiles/rv32ui/rv32ui-p-sub.mem",466,result);

if(result != 0) errorcount = errorcount + 1;

// =========================
// == 36 - ISA test - SW   =
// =========================
testtotal = testtotal + 1;
$write("SW     : ");
run_test_program_bulk(36,"./memfiles/rv32ui/rv32ui-p-sw.mem",524,result);

if(result != 0) errorcount = errorcount + 1;

// =====================
// == 37 - ISA test - XORI  =
// =====================
testtotal = testtotal + 1;
$write("XORI   : ");
run_test_program_bulk(37,"./memfiles/rv32ui/rv32ui-p-xori.mem",274,result);

if(result != 0) errorcount = errorcount + 1;

// =====================
// == 38 - ISA test - XOR  =
// =====================
testtotal = testtotal + 1;
$write("XOR    : ");
run_test_program_bulk(38,"./memfiles/rv32ui/rv32ui-p-xor.mem",466,result);

if(result != 0) errorcount = errorcount + 1;

// =====================
// == Testbench-Selbsttest  =
// =====================
testtotal = testtotal + 1;
$write("TB-BIST: ");
run_test_program_bulk(39,"./memfiles/nop.mem",100,result);  // Speicher mit NOPs gefüllt.

if(result == 0) errorcount = errorcount + 1; // check for expected error!

$write("\n\n RV32I Instruction Tests completed with errorcount = ",errorcount);
$write("\n\n");
errortotal = errortotal + errorcount;
