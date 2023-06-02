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

//********************************
// number of data bits
`define UART_DATA_BITS_5		3'd0
`define UART_DATA_BITS_6		3'd1
`define UART_DATA_BITS_7		3'd2
`define UART_DATA_BITS_8		3'd3
`define UART_DATA_BITS_9		3'd4

//********************************
// parity settings
`define UART_PARITY_NONE		2'd0
`define UART_PARITY_EVEN		2'd1
`define UART_PARITY_ODD			2'd2

//********************************
// number of stop bits
`define UART_STOP_BITS_1		2'd0
`define UART_STOP_BITS_15		2'd1
`define UART_STOP_BITS_2		2'd2

//********************************
// flow control settings
`define UART_FLOW_CTRL_OFF	1'd0
`define UART_FLOW_CTRL_ON 	1'd1
