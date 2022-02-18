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
$write("Torture tests      \n");
$write("------------------ \n");

errorcount <= 0;

// ===================================
// == 0 - HelloWorld test - I/O      =
// ===================================
$write("HELLO       : ");
testtotal = testtotal + 1;
run_test_program_bulk(0,"./memfiles/torture/helloworld.mem",9490,result);
if(result != 0) errorcount = errorcount + 1;
$finish();


// ===================================
// == 0 - Torture test - Interrupts  =
// ===================================
$write("INT         : ");
testtotal = testtotal + 1;
run_test_program_bulk(0,"./memfiles/torture/interrupt.mem",60,result);
if(result != 0) errorcount = errorcount + 1;
$finish();
// =================================
// == 0 - Torture test - AXI       =
// =================================
$write("AXI         : ");
testtotal = testtotal + 1;
run_test_program_bulk(0,"./memfiles/torture/axitest.mem",2400,result);
if(result != 0) errorcount = errorcount + 1;
$finish();
// =================================
// == 1 - Torture test - WB stalls =
// =================================
$write("WB stalls   : ");
testtotal = testtotal + 1;
run_test_program_bulk(1,"./memfiles/torture/wbstalls.mem",60,result);
if(result != 0) errorcount = errorcount + 1;
// =================================
// == 2 - Torture test - PCPI RAW  =
// =================================
$write("PCPI RAW    : ");
testtotal = testtotal + 1;
run_test_program_bulk(2,"./memfiles/torture/pcpiraw.mem",40,result);
if(result != 0) errorcount = errorcount + 1;
// =================================
// == 3 - Torture test - CUSTOM    =
// =================================
$write("CUSTOM      : ");
testtotal = testtotal + 1;
run_test_program_bulk(3,"./memfiles/torture/custom.mem",15,result);
if(result != 0) errorcount = errorcount + 1;
// ===================================
// == 4 - Torture test - Breakpoints =
// ===================================
$write("Breakpoints  : ");
testtotal = testtotal + 1;
run_test_program_resume(4,"./memfiles/torture/breakpoint.mem",64,result);
if(result != 0) errorcount = errorcount + 1;
$finish();
// =================================
// == 5 - Torture test - Coremark  =
// =================================
$write("COREMARK    : ");
testtotal = testtotal + 1;
run_test_program_step(5,"./memfiles/torture/coremark.mem",4070,result);
if(result != 0) errorcount = errorcount + 1;

$write("\n\n Torture Tests completed with errorcount = ",errorcount);
$write("\n\n");
errortotal = errortotal + errorcount;
