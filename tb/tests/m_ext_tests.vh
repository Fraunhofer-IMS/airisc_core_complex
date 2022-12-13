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
// File              : m_ext_tests.vh
// Author            : A. Stanitzki
// Creation Date     : 09.10.20
// Last Modified     : 15.02.21
// Version           : 1.0
//

$write("\n");
$write("RV32M instructions \n");
$write("------------------ \n");

errorcount <= 0;

// =========================
// == 0 - M-ISA test - DIV =
// =========================
$write("DIV    : ");
testtotal = testtotal + 1;
run_test_program_bulk(0,"./memfiles/rv32um/rv32um-p-div.mem",210,result);
if(result != 0) errorcount = errorcount + 1;

// ==========================
// == 1 - M-ISA test - DIVU =
// ==========================
$write("DIVU   : ");
testtotal = testtotal + 1;
run_test_program_bulk(1,"./memfiles/rv32um/rv32um-p-divu.mem",210,result);
if(result != 0) errorcount = errorcount + 1;

// ===========================
// == 2 - M-ISA test - MULH  =
// ===========================
$write("MULH   : ");
testtotal = testtotal + 1;
run_test_program_bulk(2,"./memfiles/rv32um/rv32um-p-mulh.mem",1261,result);
if(result != 0) errorcount = errorcount + 1;

// =============================
// == 3 - M-ISA test - MULHSU  =
// =============================
$write("MULHSU : ");
testtotal = testtotal + 1;
run_test_program_bulk(3,"./memfiles/rv32um/rv32um-p-mulhsu.mem",1261,result);
if(result != 0) errorcount = errorcount + 1;

// ============================
// == 4 - M-ISA test - MULHU  =
// ============================
$write("MULHU  : ");
testtotal = testtotal + 1;
run_test_program_bulk(4,"./memfiles/rv32um/rv32um-p-mulhu.mem",1261,result);
if(result != 0) errorcount = errorcount + 1;


// ==========================
// == 5 - M-ISA test - MUL  =
// ==========================
$write("MUL    : ");
testtotal = testtotal + 1;
run_test_program_bulk(5,"./memfiles/rv32um/rv32um-p-mul.mem",466,result);
if(result != 0) errorcount = errorcount + 1;

// ==========================
// == 6 - M-ISA test - REM  =
// ==========================
$write("REM    : ");
testtotal = testtotal + 1;
run_test_program_bulk(6,"./memfiles/rv32um/rv32um-p-rem.mem",1010,result);
if(result != 0) errorcount = errorcount + 1;

// ==========================
// == 7 - M-ISA test - REMU  =
// ==========================
$write("REMU   : ");
testtotal = testtotal + 1;
run_test_program_bulk(7,"./memfiles/rv32um/rv32um-p-remu.mem",1010,result);
if(result != 0) errorcount = errorcount + 1;



$write("\n\n RV32M Instruction Tests completed with errorcount = ",errorcount);
$write("\n\n");
errortotal = errortotal + errorcount;
