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
// File              : jtag_tasks.vh
// Author            : A. Stanitzki
// Creation Date     : 09.10.20
// Last Modified     : 15.02.21
// Version           : 1.0         
// Abstract          : Definitions of jtag tasks 
//

task jtag_tap_reset;
begin
  tdi <= 1'b0;
  tms <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
end
endtask

task jtag_bypass1f_write;
input [15:0] data;

output reg[15:0] result;

begin
  // DEBUG if(command == 2'h2) $display("dmi: write to %h : %h",addr, data);
  // goto Shift-IR state
  tdi <= 1'b0;
  tms <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  // Shift in address of DMI register (LSB to MSB)
  tms <= 1'b0;

  tdi <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;

  tdi <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;

  tdi <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;

  tdi <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;

  tms <= 1'b1;
  tdi <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  // goto Update-IR state
  tdi <= 1'b0;
  tms <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  // goto Shift-DR state
  tdi <= 1'b0;
  tms <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  // shift in DMI address (0x10), data (0x80000000) and write command (0x2)
  tms <= 1'b0;
  tdi <= data[0]; #(`JTAG_CLK_PERIOD/2) result[0] <= tdo; tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[1]; #(`JTAG_CLK_PERIOD/2) result[1] <= tdo; tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[2]; #(`JTAG_CLK_PERIOD/2) result[2] <= tdo; tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[3]; #(`JTAG_CLK_PERIOD/2) result[3] <= tdo; tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;

  tdi <= data[4]; #(`JTAG_CLK_PERIOD/2) result[4] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[5]; #(`JTAG_CLK_PERIOD/2) result[5] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[6]; #(`JTAG_CLK_PERIOD/2) result[6] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[7]; #(`JTAG_CLK_PERIOD/2) result[7] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;

  tdi <= data[8]; #(`JTAG_CLK_PERIOD/2) result[8] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[9]; #(`JTAG_CLK_PERIOD/2) result[9] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[10]; #(`JTAG_CLK_PERIOD/2) result[10] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[11]; #(`JTAG_CLK_PERIOD/2) result[11] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;

  tdi <= data[12]; #(`JTAG_CLK_PERIOD/2) result[12] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[13]; #(`JTAG_CLK_PERIOD/2) result[13] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[14]; #(`JTAG_CLK_PERIOD/2) result[14] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;

  tms <= 1'b1;
  tdi <= data[15]; #(`JTAG_CLK_PERIOD/2) result[15] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  // goto Update-DR state
  tdi <= 1'b0;
  tms <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  // goto RUN_TEST_IDLE state
  tms <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
end
endtask



task jtag_dmi_write;
input [5:0] addr;
input [31:0] data;
input [1:0] command;

output reg[31:0] result;

begin
  // DEBUG if(command == 2'h2) $display("dmi: write to %h : %h",addr, data);
  // goto Shift-IR state
  tdi <= 1'b0;
  tms <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  // Shift in address of DMI register (LSB to MSB)
  tms <= 1'b0;
  tdi <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b1;
  tdi <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  // goto Update-IR state
  tdi <= 1'b0;
  tms <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  // goto Shift-DR state
  tdi <= 1'b0;
  tms <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  // shift in DMI address (0x10), data (0x80000000) and write command (0x2)
  tms <= 1'b0;
  tdi <= command[0]; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= command[1]; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;

  tdi <= data[0]; #(`JTAG_CLK_PERIOD/2) result[0] <= tdo; tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[1]; #(`JTAG_CLK_PERIOD/2) result[1] <= tdo; tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[2]; #(`JTAG_CLK_PERIOD/2) result[2] <= tdo; tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[3]; #(`JTAG_CLK_PERIOD/2) result[3] <= tdo; tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;

  tdi <= data[4]; #(`JTAG_CLK_PERIOD/2) result[4] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[5]; #(`JTAG_CLK_PERIOD/2) result[5] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[6]; #(`JTAG_CLK_PERIOD/2) result[6] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[7]; #(`JTAG_CLK_PERIOD/2) result[7] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;

  tdi <= data[8]; #(`JTAG_CLK_PERIOD/2) result[8] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[9]; #(`JTAG_CLK_PERIOD/2) result[9] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[10]; #(`JTAG_CLK_PERIOD/2) result[10] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[11]; #(`JTAG_CLK_PERIOD/2) result[11] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;

  tdi <= data[12]; #(`JTAG_CLK_PERIOD/2) result[12] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[13]; #(`JTAG_CLK_PERIOD/2) result[13] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[14]; #(`JTAG_CLK_PERIOD/2) result[14] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[15]; #(`JTAG_CLK_PERIOD/2) result[15] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;

  tdi <= data[16]; #(`JTAG_CLK_PERIOD/2) result[16] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[17]; #(`JTAG_CLK_PERIOD/2) result[17] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[18]; #(`JTAG_CLK_PERIOD/2) result[18] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[19]; #(`JTAG_CLK_PERIOD/2) result[19] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;

  tdi <= data[20]; #(`JTAG_CLK_PERIOD/2) result[20] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[21]; #(`JTAG_CLK_PERIOD/2) result[21] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[22]; #(`JTAG_CLK_PERIOD/2) result[22] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[23]; #(`JTAG_CLK_PERIOD/2) result[23] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;

  tdi <= data[24]; #(`JTAG_CLK_PERIOD/2) result[24] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[25]; #(`JTAG_CLK_PERIOD/2) result[25] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[26]; #(`JTAG_CLK_PERIOD/2) result[26] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[27]; #(`JTAG_CLK_PERIOD/2) result[27] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;

  tdi <= data[28]; #(`JTAG_CLK_PERIOD/2) result[28] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[29]; #(`JTAG_CLK_PERIOD/2) result[29] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[30]; #(`JTAG_CLK_PERIOD/2) result[30] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= data[31]; #(`JTAG_CLK_PERIOD/2) result[31] <= tdo;  tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;

  tdi <= addr[0]; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= addr[1]; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= addr[2]; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= addr[3]; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= addr[4]; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tdi <= addr[5]; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b1;
  tdi <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  // goto Update-DR state
  tdi <= 1'b0;
  tms <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  // goto RUN_TEST_IDLE state
  tms <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
end
endtask

task jtag_wait8;
begin
  tms <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
  tms <= 1'b0; #(`JTAG_CLK_PERIOD/2) tck <= 1'b1; #(`JTAG_CLK_PERIOD/2) tck <= 1'b0;
end
endtask

task jtag_dmi_read;
input [5:0] addr;
output reg [31:0] result;

begin
  jtag_dmi_write(addr,32'h0,2'h1,result);    // dummy write to copy data to DMI
  jtag_dmi_write(addr,32'h0,2'h1,result);    // dummy write to retrieve output
end
endtask

task jtag_write_mem;
input [31:0] maddr;
input [31:0] mwdata;
output reg [31:0] result;
begin
  jtag_dmi_write(5'h10,32'h80000000,2'h2,result);
  // stay and wait ...
  jtag_wait8;

  // sw s1, s0(0) - 0000 0000 1001 0100 0010 0000 0010 0011 - 00942023
  // addi s0, s0, 4 - 0000 0000 0100 0100 0000 0100 0001 0011 - 00440413

  jtag_dmi_write(6'h20,32'h00942023,2'h2,result);
  jtag_dmi_write(6'h21,32'h00440413,2'h2,result);
  jtag_dmi_write(6'h04,maddr,2'h2,result);        // data0
  jtag_dmi_write(6'h17,32'h00231008,2'h2,result); // command
  jtag_dmi_write(6'h04,mwdata,2'h2,result);       // data0
  jtag_dmi_write(6'h17,32'h00271009,2'h2,result); // command
end
endtask

task jtag_write_mem_bulk_init;
begin
  jtag_dmi_write(6'h18,32'h00000001,2'h2,result); // set autoexecdata
end
endtask

task jtag_write_mem_bulk_end;
begin
  jtag_dmi_write(6'h18,32'h00000000,2'h2,result); // clear autoexecdata
end
endtask


task jtag_write_mem_bulk;
input [31:0] maddr;
input [31:0] mwdata;
output reg [31:0] result;
begin
  jtag_dmi_write(6'h04,mwdata,2'h2,result); // data0
end
endtask

task jtag_read_mem;
input [31:0] maddr;
output reg [31:0] result;
begin
  jtag_dmi_write(5'h10,32'h80000000,2'h2,result);
  // stay and wait ...
  jtag_wait8;

  // lw s0, 0(s0) - 0000 0000 0000 0100 0010 0100 0000 0011 - 00042403
  // ebreak - 0000 0000 0001 0000 0000 0000 0111 0011 - 00100073

  jtag_dmi_write(6'h20,32'h00042403,2'h2,result);
  jtag_dmi_write(6'h21,32'h00100073,2'h2,result);
  jtag_dmi_write(6'h04,maddr,2'h2,result); // data0
  jtag_dmi_read(6'h04,result);
  jtag_dmi_write(6'h17,32'h00271008,2'h2,result); // command (write s0, postexec)
  jtag_dmi_write(6'h17,32'h00221008,2'h2,result); // command (read s0)
  jtag_dmi_read(6'h04,result);
end
endtask



task jtag_write_mem_burst;
input [31:0] maddr;
input [31:0] mwdata;
output reg [31:0] result;
begin
  jtag_dmi_write(5'h10,32'h80000000,2'h2,result);
  // stay and wait ...
  jtag_wait8;

  // sw s1, s0(0) - 0000 0000 1001 0100 0010 0000 0010 0011 - 00942023
  // addi s0, s0, 4 - 0000 0000 0100 0100 0000 0100 0001 0011 - 00440413

  jtag_dmi_write(6'h20,32'h00942023,2'h2,result);
  jtag_dmi_write(6'h21,32'h00440413,2'h2,result);
  jtag_dmi_write(6'h04,maddr,2'h2,result);        // data0
  jtag_dmi_write(6'h17,32'h00231008,2'h2,result); // command
  jtag_dmi_write(6'h04,mwdata,2'h2,result);       // data0
  jtag_dmi_write(6'h17,32'h00271009,2'h2,result); // command
end

endtask
