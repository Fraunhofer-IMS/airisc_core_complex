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
##
## File             : simsetup.tcl
## Author           : A. Stanitzki 
## Creation Date    : 11.12.19
## Last Modified    : 19.02.21
## Version          : 1.0
## Abstract         : Simulation Setup
## History          : 
## Notes            : 
##

database -open output -shm 
probe -create airi5c_spi_tb -depth all -all -all -shm -database output
#dumptcf -internal -overwrite -scope airi5c_top_tb:DUT -output ../synGENUS/SA_BEHAV.tcf 
#dumptcf -internal -overwrite -scope airi5c_top_tb:DUT -output ../prINNO/SA_SYN.tcf 

run
#dumptcf -end
