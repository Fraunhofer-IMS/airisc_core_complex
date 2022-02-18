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
// File              : benchmark_tests.vh
// Author            : A. Stanitzki
// Creation Date     : 09.10.20
// Last Modified     : 15.02.21
// Version           : 1.0         
//

errorcount <= 0;
$write("===================\n");
$write("= Benchmarks      =\n");
$write("===================\n");

// ========================
// == Coremark            =
// ========================;
$write("Coremark:\n");

$write("\nremove $finish command from tb before running this! \n");
$write("Coremark takes ~30min. real time to finish\n");
$write("Beware to disable all probes during simulation!\n\n");

`define VPI_MODE
testtotal = testtotal + 1;
run_test_program(1,"./memfiles/coremark.mem",5500,result);
`undef VPI_MODE
$write("loaded. Running");
$write("\n\n");