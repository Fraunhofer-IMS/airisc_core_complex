#
# Copyright 2023 FRAUNHOFER INSTITUTE OF MICROELECTRONIC CIRCUITS AND SYSTEMS (IMS), DUISBURG, GERMANY.
# --- All rights reserved --- 
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
# Licensed under the Solderpad Hardware License v 2.1 (the "License");
# you may not use this file except in compliance with the License, or, at your option, the Apache License version 2.0.
# You may obtain a copy of the License at
# https://solderpad.org/licenses/SHL-2.1/
# Unless required by applicable law or agreed to in writing, any work distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
#
#
# File             : Makefile
# Author           : S. Nolting
# Last Modified    : 30.01.2023
# Abstract         : Local AIRISC application makefile.
#

# Configure memory layout (just an example)
USER_FLAGS+="-Wl,--defsym,__airisc_ram_size=64k"
USER_FLAGS+="-Wl,--defsym,__airisc_ccram_base=0x80010000"
USER_FLAGS+="-Wl,--defsym,__airisc_ccram_size=64k"
USER_FLAGS+="-Wl,--defsym,__airisc_xmem_size=0"

# Relative or absolute path to the "AIRISC Base Core" home folder
AIRISC_HOME ?= ../..
include $(AIRISC_HOME)/bsp/common/common.mk

