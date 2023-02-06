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

if { $argc != 4 } {
	puts "The script requires 4 inputs: BASE_DIR, BOARD, PROJ_NAME and COE_PATH"
} else {
	set BASE_DIR [lindex $argv 0]
	set BOARD [lindex $argv 1]
	set PROJ_NAME [lindex $argv 2]
	set COE_PATH [lindex $argv 3]
}

open_project $PROJ_NAME/$PROJ_NAME.xpr

# remove existing coe file from project
set OLD_COE_NAME [file tail [get_property CONFIG.Coe_File [get_ips blk_mem_gen_0]]]

if {$OLD_COE_NAME != "no_coe_file_loaded"} {
	export_ip_user_files -of_objects [get_files "src_$BOARD/ip/$OLD_COE_NAME"] -no_script -reset -force -quiet
	remove_files "src_$BOARD/ip/$OLD_COE_NAME"
}

# reset output products
reset_target all [get_files  $BASE_DIR/src_$BOARD/ip/blk_mem_gen_0/blk_mem_gen_0.xci]
export_ip_user_files -of_objects  [get_files  $BASE_DIR/src_$BOARD/ip/blk_mem_gen_0/blk_mem_gen_0.xci] -sync -no_script -force -quiet

# update coe file
set_property -dict [list CONFIG.Load_Init_File {true} CONFIG.Coe_File "$BASE_DIR/$COE_PATH"] [get_ips blk_mem_gen_0]

# generate output products
generate_target all [get_files $BASE_DIR/src_$BOARD/ip/blk_mem_gen_0/blk_mem_gen_0.xci] -force

catch { config_ip_cache -export [get_ips -all blk_mem_gen_0] }
catch { [ delete_ip_run [get_ips -all blk_mem_gen_0] ] }

export_ip_user_files -of_objects [get_files $BASE_DIR/src_$BOARD/ip/blk_mem_gen_0/blk_mem_gen_0.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] $BASE_DIR/src_$BOARD/ip/blk_mem_gen_0/blk_mem_gen_0.xci] -force
#launch_runs blk_mem_gen_0_synth_1

export_simulation -of_objects [get_files $BASE_DIR/src_$BOARD/ip/blk_mem_gen_0/blk_mem_gen_0.xci] -directory \
$BASE_DIR/$PROJ_NAME/$PROJ_NAME.ip_user_files/sim_scripts \
-ip_user_files_dir $BASE_DIR/$PROJ_NAME/$PROJ_NAME.ip_user_files \
-ipstatic_source_dir $BASE_DIR/$PROJ_NAME/$PROJ_NAME.ip_user_files/ipstatic \
-lib_map_path [list {modelsim=$BASE_DIR/$PROJ_NAME/$PROJ_NAME.cache/compile_simlib/modelsim} \
{questa=$BASE_DIR/$PROJ_NAME/$PROJ_NAME.cache/compile_simlib/questa} \
{ies=$BASE_DIR/$PROJ_NAME/$PROJ_NAME.cache/compile_simlib/ies} \
{xcelium=$BASE_DIR/AIRI5C_FA_ArtyA7/$PROJ_NAME.cache/compile_simlib/xcelium} \
{vcs=$BASE_DIR/$PROJ_NAME/$PROJ_NAME.cache/compile_simlib/vcs} \
{riviera=$BASE_DIR/$PROJ_NAME/$PROJ_NAME.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet

close_project
exit

