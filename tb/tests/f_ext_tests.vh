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
// File              : f_ext_tests.vh
// Author            : A. Stanitzki
// Creation Date     : 09.10.20
// Last Modified     : 15.02.21
// Version           : 1.0
//

$write("\n");
$write("RV32F Test \n");
$write("---------- \n");

errorcount <= 0;

// =========================
// == 0 - FADD test        =
// =========================
$write("FADD     : ");
testtotal = testtotal + 1;
run_test_program_bulk(0,"./memfiles/rv32uf/rv32uf-p-fadd.mem",2090,result);
if(result != 0) errorcount = errorcount + 1;

// =========================
// == 1 - FCLASS test      =
// =========================
$write("FCLASS   : ");
testtotal = testtotal + 1;
run_test_program_bulk(1,"./memfiles/rv32uf/rv32uf-p-fclass.mem",210,result);
if(result != 0) errorcount = errorcount + 1;

// =========================
// == 2 - FCMP test      =
// =========================
$write("FCMP     : ");
testtotal = testtotal + 1;
run_test_program_bulk(2,"./memfiles/rv32uf/rv32uf-p-fcmp.mem",2110,result);
if(result != 0) errorcount = errorcount + 1;

// =========================
// == 3 - FCVT test      =
// =========================
$write("FCVT     : ");
testtotal = testtotal + 1;
run_test_program_bulk(3,"./memfiles/rv32uf/rv32uf-p-fcvt.mem",2090,result);
if(result != 0) errorcount = errorcount + 1;

// =========================
// == 4 - FCVT_W test      =
// =========================
$write("FCVT_W   : ");
testtotal = testtotal + 1;
run_test_program_bulk(4,"./memfiles/rv32uf/rv32uf-p-fcvt_w.mem",2125,result);
if(result != 0) errorcount = errorcount + 1;

// =========================
// == 5 - FDIV test      =
// =========================
$write("FDIV     : ");
testtotal = testtotal + 1;
run_test_program_bulk(5,"./memfiles/rv32uf/rv32uf-p-fdiv.mem",2090,result);
if(result != 0) errorcount = errorcount + 1;

// =========================
// == 6 - FMADD test      =
// =========================
$write("FMADD    : ");
testtotal = testtotal + 1;
run_test_program_bulk(6,"./memfiles/rv32uf/rv32uf-p-fmadd.mem",2130,result);
if(result != 0) errorcount = errorcount + 1;

// =========================
// == 7 - FMIN test      =
// =========================
$write("FMIN     : ");
testtotal = testtotal + 1;
run_test_program_bulk(7,"./memfiles/rv32uf/rv32uf-p-fmin.mem",2130,result);
if(result != 0) errorcount = errorcount + 1;

// =========================
// == 8 - LDST test      =
// =========================
$write("LDST     : ");
testtotal = testtotal + 1;
run_test_program_bulk(8,"./memfiles/rv32uf/rv32uf-p-ldst.mem",2090,result);
if(result != 0) errorcount = errorcount + 1;

// =========================
// == 9 - MOVE test      =
// =========================
$write("MOVE     : ");
testtotal = testtotal + 1;
run_test_program_bulk(9,"./memfiles/rv32uf/rv32uf-p-move.mem",338,result);
if(result != 0) errorcount = errorcount + 1;

// =========================
// == 10 - RECODING test      =
// =========================
$write("RECODING : ");
testtotal = testtotal + 1;
run_test_program_bulk(10,"./memfiles/rv32uf/rv32uf-p-recoding.mem",2090,result);
if(result != 0) errorcount = errorcount + 1;

$write("\n\n RV32F Tests completed with errorcount = ",errorcount);
$write("\n\n");
errortotal = errortotal + errorcount;
