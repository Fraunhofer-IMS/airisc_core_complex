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
// File              : c_ext_tests.vh
// Author            : A. Stanitzki
// Creation Date     : 09.10.20
// Last Modified     : 15.02.21
// Version           : 1.0         
//

$write("\n");
$write("RV32C Test \n");
$write("---------- \n");

errorcount <= 0;

// =========================
// == 0 - C-ISA test       =
// =========================
$write("RVC  : ");
testtotal = testtotal + 1;
run_test_program_bulk(0,"./memfiles/rv32uc/rv32uc-p-rvc.mem",3030,result);
if(result != 0) errorcount = errorcount + 1;


$write("\n\n RV32C Instruction Tests completed with errorcount = ",errorcount);
$write("\n\n");
errortotal = errortotal + errorcount;
