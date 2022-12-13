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
// File              : privileged_tests.vh
// Author            : A. Stanitzki
// Creation Date     : 09.10.20
// Last Modified     : 15.02.21
// Version           : 1.0         

//
errorcount <= 0;
$write("\n");
$write("Priviledged U/M-Mode Inst Tests\n");
$write("-------------------------------\n");

// ===============================
// == 1 - PRIV test - BREAKPOINT =
// ===============================;

$write("BREAK   : ");
testtotal = testtotal + 1;
run_test_program_bulk(1,"./memfiles/rv32mi/rv32mi-p-breakpoint.mem",220,result);
if(result != 0) errorcount = errorcount + 1;

// ===============================
// == 2 - PRIV test - CSR ACCESS =
// ===============================;

$write("CSR     : ");
testtotal = testtotal + 1;
run_test_program_bulk(2,"./memfiles/rv32mi/rv32mi-p-csr.mem",2054,result);
if(result != 0) errorcount = errorcount + 1;

// ========================================
// == 3 - PRIV test - Illegal Instruction =
// ========================================;

$write("ILLEGAL : ");
testtotal = testtotal + 1;
run_test_program_bulk(3,"./memfiles/rv32mi/rv32mi-p-illegal.mem",290,result);
if(result != 0) errorcount = errorcount + 1;

// ==========================
// == Testbench-Selbsttest  =
// ==========================
$write("TB-BIST : ");
testtotal = testtotal + 1;
run_test_program_bulk(35,"./memfiles/nop.mem",100,result);	// Speicher mit NOPs gefüllt.
if(result == 0) errorcount = errorcount + 1; // check for expected error!


// ====================================
// == 4 - PRIV test - MISALIGNED ADDR =
// ====================================;

$write("MA_ADDR : ");
testtotal = testtotal + 1;
run_test_program_bulk(4,"./memfiles/rv32mi/rv32mi-p-ma_addr.mem",610,result);
if(result != 0) errorcount = errorcount + 1;

// =====================================
// == 5 - PRIV test - MISALIGNED FETCH =
// =====================================;

$write("MA_FETCH: ");
testtotal = testtotal + 1;
run_test_program_bulk(5,"./memfiles/rv32mi/rv32mi-p-ma_fetch.mem",240,result);
if(result != 0) errorcount = errorcount + 1;

// =========================
// == 6 - PRIV test - MCSR =
// =========================;

$write("MCSR    : ");
testtotal = testtotal + 1;
run_test_program_bulk(6,"./memfiles/rv32mi/rv32mi-p-mcsr.mem",150,result);
if(result != 0) errorcount = errorcount + 1;

// ===========================
// == 7 - PRIV test - SBREAK =
// ===========================;

$write("SBREAK  : ");
testtotal = testtotal + 1;
run_test_program_bulk(7,"./memfiles/rv32mi/rv32mi-p-sbreak.mem",150,result);
if(result != 0) errorcount = errorcount + 1;

// ===========================
// == 8 - PRIV test - SCALL  =
// ===========================;

$write("SCALL   : ");
testtotal = testtotal + 1;
run_test_program_bulk(8,"./memfiles/rv32mi/rv32mi-p-scall.mem",170,result);
if(result != 0) errorcount = errorcount + 1;

// ===========================
// == 9 - PRIV test - SHAMT  =
// ===========================;

$write("SHAMT   : ");
testtotal = testtotal + 1;
run_test_program_bulk(9,"./memfiles/rv32mi/rv32mi-p-shamt.mem",150,result);
if(result != 0) errorcount = errorcount + 1;

// ==========================
// == Testbench-Selbsttest  =
// ==========================
$write("TB-BIST : ");
testtotal = testtotal + 1;
run_test_program_bulk(95,"./memfiles/nop.mem",100,result);	// Speicher mit NOPs gefüllt.
if(result == 0) errorcount = errorcount + 1; // check for expected error!


$write("\n\n M/U-Priviledged Instruction Tests completed with errorcount = ",errorcount);
$write("\n\n");
errortotal = errortotal + errorcount;
