#
# Copyright 2022 FRAUNHOFER INSTITUTE OF MICROELECTRONIC CIRCUITS AND SYSTEMS (IMS), DUISBURG, GERMANY.
# --- All rights reserved --- 
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
# Licensed under the Solderpad Hardware License v 2.1 (the “License”);
# you may not use this file except in compliance with the License, or, at your option, the Apache License version 2.0.
# You may obtain a copy of the License at
# https://solderpad.org/licenses/SHL-2.1/
# Unless required by applicable law or agreed to in writing, any work distributed under the License is distributed on an “AS IS” BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
#
if { $argc != 2 } {
        puts "The script requires two inputs. PROJ_NAME and BOARD"
	} else {
	set PROJ_NAME [lindex $argv 0]
	set BOARD [lindex $argv 1]
	puts "PROJ_NAME: $PROJ_NAME"
	puts "BOARD: $BOARD"
	}

################################################################
######                PROGRAM FPGA BOARD                  ######
################################################################

#open_project $PROJ_NAME/$PROJ_NAME.xpr

open_hw_manager
connect_hw_server


if {$BOARD == {NexysVideo}} {
   puts "Programming BOARD: NexysVideo"
   set BITFILE ./sdcard/FPGA_Top_NexysVideo.bit
   open_hw_target {localhost:3121/xilinx_tcf/Digilent/210276AD4B83B}
   set_property PROGRAM.FILE $BITFILE [get_hw_devices xc7a200t_0]
   current_hw_device [get_hw_devices xc7a200t_0]
   refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xc7a200t_0] 0]
   set_property PROBES.FILE {} [get_hw_devices xc7a200t_0]
   set_property FULL_PROBES.FILE {} [get_hw_devices xc7a200t_0]
   program_hw_devices [get_hw_devices xc7a200t_0]
   refresh_hw_device [lindex [get_hw_devices xc7a200t_0] 0]
   close_project
} elseif {$BOARD == {ArtyA7}} {
   puts "Programming BOARD: Arty-A7"
   set BITFILE ./sdcard/FPGA_Top_ArtyA7.bit
   open_hw_target {localhost:3121/xilinx_tcf/Digilent/210319B0C184A}
   set_property PROGRAM.FILE $BITFILE [get_hw_devices xc7a35t_0]
   current_hw_device [get_hw_devices xc7a35t_0]
   refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xc7a35t_0] 0]
   set_property PROBES.FILE {} [get_hw_devices xc7a35t_0]
   set_property FULL_PROBES.FILE {} [get_hw_devices xc7a35t_0]
   program_hw_devices [get_hw_devices xc7a35t_0]
   refresh_hw_device [lindex [get_hw_devices xc7a35t_0] 0]
   close_project
} else {
   puts "BOARD not supported"
}

exit
