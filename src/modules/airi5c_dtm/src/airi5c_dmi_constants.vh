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
// File              : airi5c_dmi_constants.vh 
// Author            : A. Stanitzki
// Creation Date     : 09.10.20
// Last Modified     : 15.02.21
// Version           : 1.0         
// Abstract          : Constants for the Debug Module Interface (DMI)



`define    DMI_ADDR_WIDTH     7
`define    DMI_WIDTH          32


`define DMI_ADDR_DATA0        `DMI_ADDR_WIDTH'h04

`define DMI_ADDR_DMCONTROL    `DMI_ADDR_WIDTH'h10
`define DMI_ADDR_DMSTATUS     `DMI_ADDR_WIDTH'h11
`define DMI_ADDR_HARTINFO     `DMI_ADDR_WIDTH'h12
`define DMI_ADDR_HALTSUM      `DMI_ADDR_WIDTH'h13
`define DMI_ADDR_HAWINDOWSEL  `DMI_ADDR_WIDTH'h14
`define DMI_ADDR_HAWINDOW     `DMI_ADDR_WIDTH'h15
`define DMI_ADDR_ABSTRACTCS   `DMI_ADDR_WIDTH'h16
`define DMI_ADDR_COMMAND      `DMI_ADDR_WIDTH'h17
`define DMI_ADDR_ABSTRACTAUTO `DMI_ADDR_WIDTH'h18
`define DMI_ADDR_DEVTREEADDR0 `DMI_ADDR_WIDTH'h19

`define DMI_ADDR_PROGBUF0     `DMI_ADDR_WIDTH'h20
`define DMI_ADDR_PROGBUF1     `DMI_ADDR_WIDTH'h21


`define DMI_ADDR_AUTHDATA     `DMI_ADDR_WIDTH'h30

`define DMI_ADDR_SBCS         `DMI_ADDR_WIDTH'h38
`define DMI_ADDR_SBADDRESS0   `DMI_ADDR_WIDTH'h39
`define DMI_ADDR_SBADDRESS1   `DMI_ADDR_WIDTH'h3A
`define DMI_ADDR_SBADDRESS2   `DMI_ADDR_WIDTH'h3B

`define DMI_ADDR_SBDATA0      `DMI_ADDR_WIDTH'h3C
`define DMI_ADDR_SBDATA1      `DMI_ADDR_WIDTH'h3D
`define DMI_ADDR_SBDATA2      `DMI_ADDR_WIDTH'h3E
`define DMI_ADDR_SBDATA3      `DMI_ADDR_WIDTH'h3F

`define DMI_STATE_IDLE        1 // DMI is idle
`define DMI_STATE_READ        2 // DMI received a read request from transport interface
`define DMI_STATE_WRITE       4 // DMI received a write request from transponder interface
`define DMI_STATE_WAITEND     8 // DMI waits for deassertion of enable


// Constants for the Debug Module (DM)

`define DM_CMD_WIDTH          8
`define DM_CMD_ACCESSREG      `DM_CMD_WIDTH'h0
`define DM_CMD_QUICKACCESS    `DM_CMD_WIDTH'h1


`define DM_STATE_IDLE             0  // DM is idle
`define DM_STATE_DECODE           1
`define DM_STATE_ACCESSREG_R      2
`define DM_STATE_ACCESSREG_W      3                
`define DM_STATE_POSTEXEC         4
`define DM_STATE_ERROR_BUSY       5
`define DM_STATE_ERROR_NOTSUPP    6
`define DM_STATE_ERROR_EXCEPT     7
`define DM_STATE_ERROR_HALTRESUME 8
`define DM_STATE_ERROR_OTHER      9