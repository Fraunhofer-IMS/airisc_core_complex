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
// File              : test_tasks.vh
// Author            : A. Stanitzki
// Creation Date     : 09.10.20
// Last Modified     : 15.02.21       
// Abstract          : Definitions of test tasks 
//


task run_test_program;
input reg[7:0]    testnum;
input reg[255*8:1]    filename;
input reg[15:0]    length;
output reg[31:0] result;
begin
  #(10*`CORE_CLK_PERIOD) RESET <= 1'b1;
  #(3*`CORE_CLK_PERIOD) RESET <= 1'b0;
  testcase = testnum;    // marker variable so we can trace the results in simvision more easily.
  $write("read mem file for testcase ", testnum);$fflush();
  // read program into buffer
  $readmemh(filename,memimg);

  // write to QSPI-Flash via JTAG
  for (i = 0; i < length; i = i + 1) begin        
    jtag_write_mem(32'h80000000 + i*4,memimg[i],result);
  end

  $write(" o.k., running..");$fflush();
  #(10*`CORE_CLK_PERIOD) RESET <= 1'b1;
  #(3*`CORE_CLK_PERIOD) RESET <= 1'b0;
  #(50000*`CORE_CLK_PERIOD);
  if(debug_out == 1)begin    
     result = 0;
     $write("success.\n");
  end
  else begin
    $write("error.\n");
    result = 1;
  end
end
endtask



task run_test_program_long;
input reg[7:0]    testnum;
input reg[255*8:1]    filename;
input reg[15:0]    length;
output reg[31:0] result;
begin
  #(10*`CORE_CLK_PERIOD) RESET <= 1'b1;
  #(3*`CORE_CLK_PERIOD) RESET <= 1'b0;
  testcase = testnum;    // marker variable so we can trace the results in simvision more easily.
  $write("read mem file for testcase ", testnum);$fflush();
  // read program into buffer
  $readmemh(filename,memimg);



 // write to QSPI-Flash via JTAG
  #(300*`CORE_CLK_PERIOD);



 jtag_write_mem(32'h80000000,memimg[0],result);
  jtag_write_mem_bulk_init;    



 for (i = 1; i < length; i = i + 1) begin        
    jtag_write_mem_bulk(32'h80000000 + i*4,memimg[i],result);
  end
  jtag_write_mem_bulk_end;



 $write(" o.k., running..");$fflush();
  #(10*`CORE_CLK_PERIOD) RESET <= 1'b1;
  #(3*`CORE_CLK_PERIOD) RESET <= #2 1'b0;
//  #(50000*`CORE_CLK_PERIOD);
  #(40000000*`CORE_CLK_PERIOD);
  if(debug_out == 1)begin    
     result = 0;
     $write("success.\n");
  end
  else begin
    $write("error.\n");
    result = 1;
  end
end
endtask
task run_test_program_bulk;
input reg[7:0]    testnum;
input reg[255*8:1]    filename;
input reg[15:0]    length;
output reg[31:0] result;
begin
  #(10*`CORE_CLK_PERIOD) RESET <= 1'b1; 
  
  `ifdef CONFIG_DOLPHIN_SRAM MEM_RESET <= 1'b1; MEM_RESET <= #(`CORE_CLK_PERIOD) 1'b0; `endif
  #(3*`CORE_CLK_PERIOD) RESET <= 1'b0;
  testcase = testnum;    // marker variable so we can trace the results in simvision more easily.
  $write("read mem file for testcase ", testnum);$fflush();
  // read program into buffer
  $readmemh(filename,memimg);

  // write to QSPI-Flash via JTAG
  #(300*`CORE_CLK_PERIOD);

  jtag_write_mem(32'h80000000,memimg[0],result);
  jtag_write_mem_bulk_init;    

  for (i = 1; i < length; i = i + 1) begin        
    jtag_write_mem_bulk(32'h80000000 + i*4,memimg[i],result);
  end
  jtag_write_mem_bulk_end;

  $write(" o.k., running..");$fflush();
  #(10*`CORE_CLK_PERIOD) RESET <= 1'b1;// MEM_RESET <= 1'b1; No MEM_RESET here to avoid imem loss 
  #(3*`CORE_CLK_PERIOD) RESET <= #2 1'b0;// MEM_RESET <= #2 1'b0;
//  #(70000*`CORE_CLK_PERIOD);
  #(40000*`CORE_CLK_PERIOD);
  if(debug_out == 1)begin    
     result = 0;
     $write("success.\n");
  end
  else begin
    $write("error.\n");
    result = 1;
  end
end
endtask


task run_test_program_bulk_long;
input reg[7:0]    testnum;
input reg[255*8:1]    filename;
input reg[15:0]    length;
output reg[31:0] result;
begin
  #(10*`CORE_CLK_PERIOD) RESET <= 1'b1; 
  
  `ifdef CONFIG_DOLPHIN_SRAM MEM_RESET <= 1'b1; MEM_RESET <= #(`CORE_CLK_PERIOD) 1'b0; `endif
  #(3*`CORE_CLK_PERIOD) RESET <= 1'b0;
  testcase = testnum;    // marker variable so we can trace the results in simvision more easily.
  $write("read mem file for testcase ", testnum);$fflush();
  // read program into buffer
  $readmemh(filename,memimg);

  // write to QSPI-Flash via JTAG
  #(300*`CORE_CLK_PERIOD);

  jtag_write_mem(32'h80000000,memimg[0],result);
  jtag_write_mem_bulk_init;    

  for (i = 1; i < length; i = i + 1) begin        
    jtag_write_mem_bulk(32'h80000000 + i*4,memimg[i],result);
  end
  jtag_write_mem_bulk_end;

  $write(" o.k., running..");$fflush();
  #(10*`CORE_CLK_PERIOD) RESET <= 1'b1;// MEM_RESET <= 1'b1; No MEM_RESET here to avoid imem loss 
  #(3*`CORE_CLK_PERIOD) RESET <= #2 1'b0;// MEM_RESET <= #2 1'b0;
//  #(70000*`CORE_CLK_PERIOD);
  #(2000000*`CORE_CLK_PERIOD);
  if(debug_out == 1)begin    
     result = 0;
     $write("success.\n");
  end
  else begin
    $write("error.\n");
    result = 1;
  end
end
endtask



task run_test_program_step;
input reg[7:0]    testnum;
input reg[255*8:1]    filename;
input reg[15:0]    length;
output reg[31:0] result;
integer j;
begin
  #(10*`CORE_CLK_PERIOD) RESET <= 1'b1;
  #(3*`CORE_CLK_PERIOD) RESET <= 1'b0;
  testcase = testnum;    // marker variable so we can trace the results in simvision more easily.
  $write("read mem file for testcase ", testnum);$fflush();
  // read program into buffer
  $readmemh(filename,memimg);

  // write to QSPI-Flash via JTAG
  jtag_write_mem(32'h80000000,memimg[0],result);
  jtag_write_mem_bulk_init;    

  for (i = 1; i < length; i = i + 1) begin        
    jtag_write_mem_bulk(32'h80000000 + i*4,memimg[i],result);
  end
  jtag_write_mem_bulk_end;
  #(10*`CORE_CLK_PERIOD) RESET <= 1'b1;
  #(3*`CORE_CLK_PERIOD) RESET <= #2 1'b0;

  $write(" o.k., stepping..");$fflush();
  jtag_dmi_write(5'h10,32'hA0000003,2'h2,result);
  #(10*`CORE_CLK_PERIOD);
  jtag_dmi_write(5'h10,32'h80000000,2'h2,result);
  #(10*`CORE_CLK_PERIOD);
  jtag_dmi_write(5'h10,32'h00000000,2'h2,result);
  jtag_dmi_write(5'h04,32'h00000007,2'h2,result); // set stepmode bit, prv = 3 (M)
  jtag_dmi_write(5'h17,32'h002307b0,2'h2,result); // write to 07b0 (dcsr)

  for (j = 1; j < 10000000; j = j + 1) begin
    $write("execute step %x\n",j);
    jtag_dmi_write(5'h10,32'h40000000,2'h2,result);
    jtag_dmi_write(5'h10,32'h00000000,2'h2,result);
  end

  #(500000*`CORE_CLK_PERIOD);
  if(debug_out == 1)begin    
     result = 0;
     $write("success.\n");
  end
  else begin
    $write("error.\n");
    result = 1;
  end
end
endtask


task run_test_program_int;
input reg[7:0]    testnum;
input reg[255*8:1]    filename;
input reg[15:0]    length;
output reg[31:0] result;
begin
  testcase = testnum;    // marker variable so we can trace the results in simvision more easily.
  $write("read mem file for testcase ", testnum);
  // read program into buffer
  $readmemh(filename,memimg);

  // write to QSPI-Flash via JTAG
  for (i = 0; i < length; i = i + 1) begin
    jtag_write_mem(32'h80000000 + i*4,memimg[i],result);
  end

  $write(" o.k., running..");

  #(10*`CORE_CLK_PERIOD) RESET <= 1'b1;
  #(3*`CORE_CLK_PERIOD) RESET <= 1'b0;
  #(5000*`CORE_CLK_PERIOD);
  EXT_INT = 1'b1;
  #(1*`CORE_CLK_PERIOD);
  EXT_INT = 1'b0;
  #(5000*`CORE_CLK_PERIOD);
  EXT_INT = 1'b1;
  #(1*`CORE_CLK_PERIOD);
  EXT_INT = 1'b0;
  #(5000*`CORE_CLK_PERIOD);
  if(debug_out == 1)begin    
     result = 0;
     $write("success.\n");
  end
  else begin
    $write("error.\n");
    result = 1;
  end
end
endtask



task run_test_program_break;
input reg[7:0]    testnum;
input reg[255*8:1]    filename;
input reg[15:0]    length;
output reg[31:0] result;
begin
  testcase = testnum;    // marker variable so we can trace the results in simvision more easily.
  $write("read mem file for testcase ", testnum);$fflush();
  // read program into buffer
  $readmemh(filename,memimg);

  // write to QSPI-Flash via JTAG
  for (i = 0; i < length; i = i + 1) begin
    jtag_write_mem(32'h80000000 + i*4,memimg[i],result);
  end

  $write(" o.k., running..");$fflush();
  $monitor("tohost: %h",DUT.debug_out);
  #1000 RESET <= 1'b1;
  #(3*`CORE_CLK_PERIOD) RESET <= 1'b0;
  #(10*`CORE_CLK_PERIOD);
  $write("JTAG TAP: send halt request.\n");
  jtag_dmi_write(5'h10,32'h80000000,2'h2,result);
  #(5000*`CORE_CLK_PERIOD);
  // abstract command to access register
  // dcsr for hart0 stepmode
  // 0000 0000 0000 0000 1111 0000 0000 0100
  jtag_dmi_write(5'h04,32'h0000f004,2'h2,result);    
  // write word to dcsr
  // 0000 0000 0010 0011 0000 0111 1011 0000
  jtag_dmi_write(5'h17,32'h002307b0,2'h2,result);
  // resume
  jtag_dmi_write(5'h10,32'h40000000,2'h2,result); // .. and resume
  #(5000*`CORE_CLK_PERIOD);
  $write("JTAG TAP: send halt request.\n");
  jtag_dmi_write(5'h10,32'h80000000,2'h2,result);
  #(5000*`CORE_CLK_PERIOD);
  jtag_dmi_write(5'h10,32'h40000000,2'h2,result); // .. and resume
  #(5000*`CORE_CLK_PERIOD);
  // abstract command to access register
  // dcsr for hart0 stepmode
  // 0000 0000 0000 0000 1111 0000 0000 0100
  jtag_dmi_write(5'h04,32'h0000f000,2'h2,result);    
  // write word to dcsr
  // 0000 0000 0010 0011 0000 0111 1011 0000
  jtag_dmi_write(5'h17,32'h002307b0,2'h2,result);
  // resume
  jtag_dmi_write(5'h10,32'h40000000,2'h2,result); // .. and resume
  #(5000*`CORE_CLK_PERIOD);
  if(DUT.debug_out == 1)begin
    result = 0;
     $write("success.\n");
  end
  else begin
    $write("error.\n");
    result = 1;
  end
end
endtask

task run_test_program_resume;
input reg[7:0]    testnum;
input reg[255*8:1]    filename;
input reg[15:0]    length;
output reg[31:0] result;
integer j;
integer temp;
begin
  #(10*`CORE_CLK_PERIOD) RESET <= 1'b1;
  #(3*`CORE_CLK_PERIOD) RESET <= 1'b0;
  testcase = testnum;    // marker variable so we can trace the results in simvision more easily.
  $write("read mem file for testcase ", testnum);$fflush();
  // read program into buffer
  $readmemh(filename,memimg);

  // write to QSPI-Flash via JTAG
  jtag_write_mem(32'h80000000,memimg[0],result);
  jtag_write_mem_bulk_init;    

  for (i = 1; i < length; i = i + 1) begin        
    jtag_write_mem_bulk(32'h80000000 + i*4,memimg[i],result);
  end
  jtag_write_mem_bulk_end;
  #(10*`CORE_CLK_PERIOD) RESET <= 1'b1;
  #(3*`CORE_CLK_PERIOD) RESET <= #2 1'b0;

  $write(" o.k., stepping..");$fflush();
  jtag_dmi_write(5'h10,32'hA0000003,2'h2,result);
  #(10*`CORE_CLK_PERIOD);
  jtag_dmi_write(5'h10,32'h80000000,2'h2,result);
  #(10*`CORE_CLK_PERIOD);
  jtag_dmi_write(5'h10,32'h00000000,2'h2,result);

  for (j = 1; j < 10; j = j + 1) begin
    $write("update dpc and execute resume %x\n",j);
    jtag_dmi_write(5'h17,32'h002207b1,2'h2,result); // abstract cmd - read dpc
    jtag_dmi_read(5'h04,temp);                      // read dpc stored in a0
    temp = temp + 4;
    jtag_dmi_write(5'h04,temp,2'h2,result);              // store val in a0
    jtag_dmi_write(5'h17,32'h002307b1,2'h2,result); // copy a0 to dpc
    jtag_dmi_write(5'h10,32'h40000000,2'h2,result);
    jtag_dmi_write(5'h10,32'h00000000,2'h2,result);
  end

  #(500000*`CORE_CLK_PERIOD);
  if(debug_out == 1)begin    
     result = 0;
     $write("success.\n");
  end
  else begin
    $write("error.\n");
    result = 1;
  end
end
endtask


