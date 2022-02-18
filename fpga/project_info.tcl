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
if { $argc != 1 } {
        puts "The script requires one input. PROJ_NAME"
	} else {
	set PROJ_NAME [lindex $argv 0]
	}

################################################################
######            SHOW VIVADO PROJECT INFO                ######
################################################################

open_project $PROJ_NAME/$PROJ_NAME.xpr


puts [version]
puts [current_project]
report_property -all [current_project]
puts [get_filesets]
puts [get_boards]

current_fileset -simset sim_1
puts [current_fileset -simset -verbose]
report_property -all [current_fileset]
puts [current_sim]

close_project
exit
