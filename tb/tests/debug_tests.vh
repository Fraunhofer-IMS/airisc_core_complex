//
// Copyright 2022 FRAUNHOFER INSTITUTE OF MICROELECTRONIC CIRCUITS AND SYSTEMS (IMS), DUISBURG, GERMANY.
// --- All rights reserved --- 
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
// Licensed under the Solderpad Hardware License v 2.1 (the "License");
// you may not use this file except in compliance with the License, or, at your option, the Apache License version 2.0.
// You may obtain a copy of the License at
// https://solderpad.org/licenses/SHL-2.1/
// Unless required by applicable law or agreed to in writing, any work distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and limitations under the License.
//
//
// File              : debug_tests.vh
// Author            : A. Stanitzki
// Creation Date     : 09.10.20
// Last Modified     : 15.02.21
// Version           : 1.0         
//

$write("\n");
$write("==========================\n");
$write("= Debug tests            =\n");
$write("==========================\n");
$write("Info: JTAG TAP: reset..\n"); jtag_tap_reset;
$write("Info: JTAG TAP: halt and resume core several times without program loaded..\n");
//$write("Info: JTAG TAP: send core halt request.\n");
jtag_dmi_write(5'h10,32'h80000000,2'h2,result);
//$write("Info: JTAG TAP: wait some cycles.\n"); 
jtag_wait8;
//$write("Info: JTAG TAP: resume hart without program loaded..\n");
jtag_dmi_write(5'h10,32'h40000000,2'h2,result);
jtag_dmi_write(5'h10,32'h00000000,2'h2,result);
//$write("Info: JTAG TAP: wait some cycles.\n"); 
jtag_wait8;
//$write("Info: JTAG TAP: halt hart again..\n");
jtag_dmi_write(5'h10,32'h80000000,2'h2,result);
jtag_dmi_write(5'h10,32'h00000000,2'h2,result);
//$write("Info: JTAG TAP: wait some cycles.\n");
jtag_wait8;
//$write("Info: JTAG TAP: resume hart without program loaded..\n");
jtag_dmi_write(5'h10,32'h40000000,2'h2,result);
jtag_dmi_write(5'h10,32'h00000000,2'h2,result);
//$write("Info: JTAG TAP: wait some cycles.\n"); 
jtag_wait8;
$write("Info: JTAG TAP: halt hart again..\n");
jtag_dmi_write(5'h10,32'h80000000,2'h2,result);
jtag_dmi_write(5'h10,32'h00000000,2'h2,result);
$write("Info: JTAG TAP: write minimal test program to mem..\n");
jtag_write_mem(32'h80000000,32'h10000013,result);
jtag_write_mem(32'h80000004,32'h20000013,result);
jtag_write_mem(32'h80000008,32'h30000013,result);
jtag_write_mem(32'h8000000C,32'hff5ff06f,result);
jtag_write_mem(32'h80000010,32'h00000000,result);
jtag_write_mem(32'h80000014,32'h00000000,result);
jtag_write_mem(32'h80000018,32'h00000000,result);
jtag_wait8;
$write("Info: JTAG TAP: resume and halt hart several times with minimal test program loaded..\n");
jtag_dmi_write(5'h10,32'h40000000,2'h2,result);
jtag_dmi_write(5'h10,32'h00000000,2'h2,result);
//$write("Info: JTAG TAP: wait some cycles.\n"); 
jtag_wait8;
jtag_dmi_write(5'h10,32'h40000000,2'h2,result);
//$write("Info: JTAG TAP: halt hart again..\n");
jtag_dmi_write(5'h10,32'h80000000,2'h2,result);
jtag_dmi_write(5'h10,32'h00000000,2'h2,result);
//$write("Info: JTAG TAP: wait some cycles.\n"); 
jtag_wait8;
//$write("Info: JTAG TAP: resume hart without loaded..\n");
jtag_dmi_write(5'h10,32'h40000000,2'h2,result);
jtag_dmi_write(5'h10,32'h00000000,2'h2,result);
//$write("Info: JTAG TAP: halt hart again..\n");
jtag_dmi_write(5'h10,32'h80000000,2'h2,result);
jtag_dmi_write(5'h10,32'h00000000,2'h2,result);
//$write("Info: JTAG TAP: wait some cycles.\n"); 
jtag_wait8;
$write("Info: enable step mode\n");    
jtag_dmi_write(5'h04,32'h00000007,2'h2,result); // set stepmode bit, prv = 3 (M)
jtag_dmi_write(5'h17,32'h002307b0,2'h2,result); // write to 07b0 (dcsr)
$write("execute 10 steps .. ");
jtag_dmi_write(5'h10,32'h40000000,2'h2,result);
jtag_dmi_write(5'h10,32'h00000000,2'h2,result);
//$write("execute step 2\n");
jtag_dmi_write(5'h10,32'h40000000,2'h2,result);
jtag_dmi_write(5'h10,32'h00000000,2'h2,result);
//$write("execute step 3\n");
jtag_dmi_write(5'h10,32'h40000000,2'h2,result);
jtag_dmi_write(5'h10,32'h00000000,2'h2,result);
//$write("execute step 4\n");
jtag_dmi_write(5'h10,32'h40000000,2'h2,result);
jtag_dmi_write(5'h10,32'h00000000,2'h2,result);
//$write("execute step 5\n");
jtag_dmi_write(5'h10,32'h40000000,2'h2,result);
jtag_dmi_write(5'h10,32'h00000000,2'h2,result);
//$write("execute step 6\n");
jtag_dmi_write(5'h10,32'h40000000,2'h2,result);
jtag_dmi_write(5'h10,32'h00000000,2'h2,result);
//$write("execute step 7\n");
jtag_dmi_write(5'h10,32'h40000000,2'h2,result);
jtag_dmi_write(5'h10,32'h00000000,2'h2,result);
//$write("execute step 8\n");
jtag_dmi_write(5'h10,32'h40000000,2'h2,result);
jtag_dmi_write(5'h10,32'h00000000,2'h2,result);
//$write("execute step 9\n");
jtag_dmi_write(5'h10,32'h40000000,2'h2,result);
jtag_dmi_write(5'h10,32'h00000000,2'h2,result);
//$write("execute step 10\n");
jtag_dmi_write(5'h10,32'h40000000,2'h2,result);
jtag_dmi_write(5'h10,32'h00000000,2'h2,result);
$write("done stepping. should be in debug mode now..\n");

$write("Info: test read/write of peripheral memory regions.. \n");
$write("Info: JTAG TAP: write data to TIMECMPL register..\n");
jtag_write_mem(32'hC0000108,32'h0000CEFF,result);
jtag_wait8;
$write("Info: read value of TIMEL register.. ");
jtag_read_mem(32'hC0000100,result);
$write("read %x from memory 0xc0000100\n",result);
jtag_wait8;
$write("Info: read first instruction from IMEM.. ");
jtag_read_mem(32'h80000000,result);
$write("read %x from memory 0x80000000\n",result);

