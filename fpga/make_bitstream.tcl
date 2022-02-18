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
######                  SYNTHESIZE DESIGN                 ######
################################################################

open_project $PROJ_NAME/$PROJ_NAME.xpr

reset_run synth_1
reset_run impl_1
launch_runs synth_1
wait_on_run synth_1


################################################################
######                PLACE & ROUTE DESIGN                ######
################################################################

launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
puts "Implementation done!"

close_project
exit