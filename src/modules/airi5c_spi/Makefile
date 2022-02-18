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
## File             : Makefile
## Author           : A. Stanitzki
## Creation Date    : 09.10.20
## Last Modified    : 15.02.21
## Version          : 1.0   
## Version          : 1.0
## Abstract         : Makefile for the spi module
##

# RISC-V core

topmodule = airi5c_spi
bench = worklib.airi5c_spi_tb:v

topdir = .
simdir = ./simIUS
srcdir = ./src

# XH018 D_CELLS_HD
libdir = /sw/lx_sw/lxcad/pdks/XFab/xh18/XKIT/xh018/diglibs/D_CELLS_HD/v3_0/

# Standard Cell Library

## Simulation testbench and files
TBFILES =\
${topdir}/tb/airi5c_spi_tb.v

##
HDLFILES =\
${srcdir}/airi5c_spi.v \
${TBFILES}

## Simulator command
HDLCOM = irun
SDFCOM = ncsdfc

## General Compiler options
ALLHDLCOMOPTS +=\
-assert \
+nctimescale+1ns/1ps \
-incdir ../src/ \

# Module HDL compiler options
MODHDLCOMOPTS =\
-access +rc \
-covoverwrite \
$(ALLHDLCOMOPTS)
 
sim:
	cd $(simdir); \
	$(HDLCOM) $(MODHDLCOMOPTS) \
    	-linedebug -input simsetup.tcl \
	$(foreach hdlfile,$(HDLFILES),../$(hdlfile))

new: compile elaborate

compile:
	cd $(simdir); \
	ncvlog -incdir ../src \
	$(DCLIB) \
	$(foreach hdlfile,$(HDLFILES),../$(hdlfile))

elaborate:
	cd $(simdir); \
	ncelab -work worklib -lib_binding $(bench)

check:
	cd $(simdir); \
	$(HDLCOM) $(ALLHDLCOMOPTS) -elaborate \
	-v $(DCLIB) $(IOLIB) \
	$(foreach hdlfile,$(HDLFILES),../$(hdlfile))

clean:
	rm $(topdir)/*.log \
	rm $(simdir)/*.key \
	rm $(simdir)/*.log \
	rm $(simdir)/*.X \
	rm -rf $(simdir)/*.shm \
	rm -rf $(simdir)/INCA_libs \
	rm -rf $(simdir)/cov_work \
	rm -rf $(simdir)/coverage/* \
	rm -rf $(simdir)/reports/* \
	rm -rf $(syndir)/*.cmd* \
	rm -rf $(syndir)/*.log* \
	rm -rf $(prdir)/*.cmd* \
	rm -rf $(prdir)/*.log* \
	rm -rf $(atpgdir)/*.log* \
	rm -rf $(atpgdir)/*.cmd*
