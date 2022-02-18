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
// File              : init_tests.vh
// Author            : A. Stanitzki
// Creation Date     : 09.10.20
// Last Modified     : 15.02.21
// Version           : 1.0         
//

$write("\n");
$write("==========================\n");
$write("= Init and Basic tests   =\n");
$write("==========================\n");

$write("Core configuration: RV32I");
`ifdef ISA_EXT_E $write("E"); `endif
`ifdef ISA_EXT_M $write("M"); `endif
`ifdef ISA_EXT_M_FAST $write("M_FAST"); `endif
`ifdef ISA_EXT_F $write("F"); `endif
`ifdef ISA_EXT_C $write("C"); `endif
`ifdef ISA_EXT_P $write("P"); `endif
`ifdef ISA_EXT_CUSTOM $write("_+custom_"); `endif
`ifdef ISA_EXT_EFPGA $write("_+eFPGA_"); `endif
$write("\n");
errortotal = 0;
$write("Info: VDD: 0, RESET: 1, CLK: 0     , CLKQSPI: 0     , GPIO_I: GPIO_D, EXT_INT: 0, tms: 0, tdi: 0, tck: 0, sen: 0, sdi: 0\n");
VDD <= 1'b0; RESET <= 1'b1; CLK <= 1'b0; CLKQSPI <= 1'b0; EXT_INT <= 1'b0; tms <= 1'b0; tdi <= 1'b0; tck <= 1'b0;
SEN <= 0; SDI <= 0;
#(56*`CLK_PERIOD); 
$write("Info: VDD: 1, RESET: 1, CLK: taktet, CLKQSPI: taktet, GPIO_I: GPIO_D, EXT_INT: 0, tms: 0, tdi: 0, tck: 0, sen: 0, sdi: 0\n");
@(~CLK) VDD <= 1'b1; 
//RESET <= 1'b1; 
#(5*`CLK_PERIOD); 
$write("Info: waiting 2ms for NVRAM startup..\n");
#2000000;
$write("Info: VDD: 1, RESET: 0, CLK: taktet, CLKQSPI: taktet, GPIO_I: GPIO_D, EXT_INT: 0, tms: 0, tdi: 0, tck: 0, sen: 0, sdi: 0\n");
@(posedge CLK) RESET <= 1'b0;
#(5*`CLK_PERIOD) 

// Read Debug Module status as a simple 
// JTAG interface health check.
$write("Info: JTAG TAP: reset..\n"); jtag_tap_reset;
$write("Info: JTAG TAP: send core halt request.\n");
jtag_dmi_write(5'h10,32'h80000000,2'h2,result);
$write("JTAG TAP: wait some cycles.\n"); jtag_wait8;
$write("JTAG TAP: Read status of debug module.. ");
jtag_dmi_read(5'h12,result);
$write("%x ",result);
if(result == 32'h00011043) $write("ok.\n");
else begin
  $write("error.\n");
  $finish();
end

