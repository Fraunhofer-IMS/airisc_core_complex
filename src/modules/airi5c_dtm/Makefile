#
# Copyright 2022 FRAUNHOFER INSTITUTE OF MICROELECTRONIC CIRCUITS AND SYSTEMS (IMS), DUISBURG, GERMANY.
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
##
## File             : Makefile
## Author           : A. Stanitzki 
## Creation Date    : 30.07.20
## Last Modified    : 15.02.21
## Version          : 1.0
## Abstract         : Makefile for JTAG based Debug Transfer Module (DTM)
## History          : 30.07.20 - derived from main Makefile (ASt)
##					  11.12.19 - added changelog (ASt)
## Notes            : 
##

# ==============================
# =	Target tech	       =
# ==============================
#TECH = L035
TECH = XH018

ifndef TECH
$(error Configuration error: No technology selected)
else
ifeq ($(TECH),L035)
$(info Tech   : ELMOS L035)
endif
ifeq ($(TECH),XH018)
$(info Tech   : X-Fab XH018)
endif
endif

#one testbench for all cases
bench = worklib.airi5c_dtm_tb:v
topmodule = airi5c_dtm

topdir = .
simdir = ./simIUS
srcdir = ./tb
covdir = ./coverage
syndir = ./synGENUS
prdir  = ./prINNO

# Verilog description of standard cells
# =====================================
ifeq ($(TECH),L035)
libdir = /sw/ims_db/lib/L035/l035v0v6dc/.lib/
DCLIB = ${libdir}/verilog/L035dc_18_c4.v
endif
ifeq ($(TECH),XH018)
libdir = /sw/lx_sw/lxcad/pdks/XFab/xh18/XKIT/xh018/diglibs/D_CELLS_HD/v3_0/
DCLIB = "${libdir}verilog/v3_0_0/D_CELLS_HD.v"
DCLIB2 = "${libdir}verilog/v3_0_0/VLG_PRIMITIVES.v"
endif

## Simulation testbench and files
TBFILES =\
${topdir}/tb/airi5c_top_tb.v \
${topdir}/tb/airi5c_top_asic.v \
${topdir}/tb/airi5c_top_asic_qspi.v \
${topdir}/tb/airi5c_top_asic_qspi_xh018.v \
${topdir}/tb/airi5c_dp_hasti_sram.v \
${topdir}/src/modules/airi5c_qspi_if/CY14V101QS_official/cy14v101xs_ncvlog.vp

## Simulation testbench for virtual prototyping
TBFILES_VPI =\
${topdir}/tb/airi5c_top_tb_vpi.v \
${topdir}/tb/airi5c_top_asic.v \
${topdir}/tb/airi5c_top_asic_qspi.v \
${topdir}/tb/airi5c_top_asic_qspi_xh018.v \
${topdir}/tb/airi5c_dp_hasti_sram.v \
${topdir}/src/modules/airi5c_qspi_if/CY14V101QS_official/cy14v101xs_ncvlog.vp \
${topdir}/tb/jtag_vpi-master/jtag_vpi-master/jtag_vpi.v


## Synthesis files
HDLFILES =\
${topdir}/src/airi5c_alu.v \
${topdir}/src/airi5c_csr_file.v \
${topdir}/src/airi5c_ctrl.v \
${topdir}/src/airi5c_hasti_bridge.v \
${topdir}/src/airi5c_sync_to_hasti_bridge.v \
${topdir}/src/airi5c_imm_gen.v \
${topdir}/src/airi5c_PC_mux.v \
${topdir}/src/airi5c_pipeline.v \
${topdir}/src/airi5c_regfile.v \
${topdir}/src/airi5c_src_a_mux.v \
${topdir}/src/airi5c_src_b_mux.v \
${topdir}/src/airi5c_core.v \
${topdir}/src/airi5c_mul_div.v \
${topdir}/src/airi5c_debug_rom.v \
${topdir}/src/airi5c_debug_module.v \
${topdir}/src/airi5c_mem_arbiter.v \
${topdir}/src/modules/airi5c_dtm/src/airi5c_dtm.v \
${topdir}/src/modules/airi5c_qspi_if/airi5c_qspi_if.v \
${topdir}/src/modules/airi5c_gpio/src/airi5c_gpio.v \
${topdir}/src/modules/airi5c_timer/src/airi5c_timer.v \
${topdir}/src/modules/airi5c_cext/src/airi5c_cext.v \
${topdir}/src/modules/cs_puf/permut_sel/src/permut_sel.v \
${topdir}/IP/xh018/dpram/XDPRAMJI_2048X32_M8P/v2_9_0/verilog/XDPRAMJI_2048X32_M8P.v \
$(TBFILES) $(SINCNL)

## VPI files
HDLFILES_VPI =\
${topdir}/src/airi5c_alu.v \
${topdir}/src/airi5c_csr_file.v \
${topdir}/src/airi5c_ctrl.v \
${topdir}/src/airi5c_hasti_bridge.v \
${topdir}/src/airi5c_sync_to_hasti_bridge.v \
${topdir}/src/airi5c_imm_gen.v \
${topdir}/src/airi5c_PC_mux.v \
${topdir}/src/airi5c_pipeline.v \
${topdir}/src/airi5c_regfile.v \
${topdir}/src/airi5c_src_a_mux.v \
${topdir}/src/airi5c_src_b_mux.v \
${topdir}/src/airi5c_core.v \
${topdir}/src/airi5c_mul_div.v \
${topdir}/src/airi5c_debug_rom.v \
${topdir}/src/airi5c_debug_module.v \
${topdir}/src/airi5c_dtm.v \
${topdir}/src/airi5c_mem_arbiter.v \
${topdir}/src/modules/airi5c_dtm/src/airi5c_dtm.v \
${topdir}/src/modules/airi5c_qspi_if/airi5c_qspi_if.v \
${topdir}/src/modules/airi5c_gpio/src/airi5c_gpio.v \
${topdir}/src/modules/airi5c_timer/src/airi5c_timer.v \
$(TBFILES_VPI) $(SINCNL)


DCLIB = /sw/lx_sw/lxcad/pdks/XFab/xh18/XKIT/xh018/diglibs/D_CELLS_JIHD/v4_1/verilog/v4_1_0/VLG_PRIMITIVES.v \
/sw/lx_sw/lxcad/pdks/XFab/xh18/XKIT/xh018/diglibs/D_CELLS_JIHD/v4_1/verilog/v4_1_0/D_CELLS_JIHD.v

## Postsynthesis simulation.
POSTSYN_HDLFILES =\
$(syndir)/results/$(topmodule).v \
$(topdir)/tb/airi5c_top_tb.v \
${topdir}/src/modules/airi5c_dtm/src/airi5c_dtm.v \
${topdir}/tb/airi5c_dp_hasti_sram.v \
${topdir}/src/modules/airi5c_qspi_if/CY14V101QS_official/cy14v101xs_ncvlog.vp



## ATPG simulation files 
ATPG_HDLFILES =\
$(syndir)/results/$(topmodule).v \
${topdir}/dftET/testresults/verilog/VER.FULLSCAN.mainsim.v

## Post-PR simulation.
POSTPR_HDLFILES =\
$(prdir)/results/$(topmodule).v \
$(topdir)/tb/airi5c_top_tb.v \
${topdir}/src/modules/airi5c_dtm/src/airi5c_dtm.v \
${topdir}/tb/airi5c_dp_hasti_sram.v \
${topdir}/src/modules/airi5c_qspi_if/CY14V101QS_official/cy14v101xs_ncvlog.vp


## Simulator command
HDLCOM = irun
SDFCOM = ncsdfc

## General Compiler options
ALLHDLCOMOPTS +=\
-assert \
+nctimescale+1ns/10ps \
-incdir ../src -incdir ../src/modules/airi5c_qspi_if -incdir ../tb -incdir ../src/modules/airi5c_qspi_if/CY14V101QS_official 

# Module HDL compiler options
MODHDLCOMOPTS =\
-access +rc \
-notimingchecks \
-covoverwrite \
$(ALLHDLCOMOPTS)
 
## Postsynthesis SDF file
POSTSYN_SDFFILE =\
$(syndir)/results/$(topmodule).sdf

## Postlayout SDF file
POSTPR_SDFFILE =\
$(prdir)/results/$(topmodule).sdf_typical

#-define POSTLAYOUT_SIM \
#-define POSTPR_SIM  \
#-define SYN \

POSTSYN_MODHDLCOMOPTS =\
$(ALLHDLCOMOPTS)\
-logfile logfile_postsyn.log \
-ncelabargs "-sdf_cmd_file airi5c_top_asic_qspi_xh018.sdf_cmd -sdf_verbose" \
+maxdelays \
-access +rwc

ATPG_MODHDLCOMOPTS =\
$(ALLHDLCOMOPTS)\
-input @"run" \
+TESTFILE1=../dftET/testresults/verilog/VER.FULLSCAN.data.logic.ex1.ts1.verilog

POSTPR_MODHDLCOMOPTS =\
$(ALLHDLCOMOPTS)\
-ncelabargs "-sdf_cmd_file airi5c_top_asic_qspi_xh018_postpr.sdf_cmd -sdf_verbose" \
-access +rwc \
-logfile logfile_postpr.log

POSTPR_MODHDLCOMOPTS_MIN =\
$(ALLHDLCOMOPTS)\
-ncelabargs "-sdf_cmd_file airi5c_core.sdf_cmd_min"
POSTPR_MODHDLCOMOPTS_MAX =\
$(ALLHDLCOMOPTS)\
-ncelabargs "-sdf_cmd_file airi5c_core.sdf_cmd_max"

nop:


sim:
	cd $(simdir); \
	$(HDLCOM) $(MODHDLCOMOPTS) \
    	-v $(DCLIB) ${IOLIB} -input simsetup.tcl \
	$(foreach hdlfile,$(HDLFILES),../$(hdlfile))

sim_vpi:
	cd $(simdir); \
	$(HDLCOM) -64bit -profile -q +access+r \
	-loadvpi ../tb/jtag_vpi-master/jtag_vpi-master/jtag_vpi:register_check_for_command,register_send_result_to_server,setup_endofcompile_callbacks,setup_finish_callbacks +jtag_vpi_enable=1 \
	$(MODHDLCOMOPTS) \
    	-v $(DCLIB) ${IOLIB} \
	$(foreach hdlfile,$(HDLFILES_VPI),../$(hdlfile))

new: compile elaborate

compile:
	cd $(simdir); \
	ncvlog -incdir ../src \
	$(DCLIB) \
	$(foreach hdlfile,$(HDLFILES),../$(hdlfile))

elaborate:
	cd $(simdir); \
	ncelab -work worklib -lib_binding $(bench)

simSyn:
	cd $(simdir); \
	$(SDFCOM) -Update -Output ./$(topmodule).sdf.X ../$(POSTSYN_SDFFILE) && \
	$(HDLCOM) $(IOLIB) -ncelabargs -notimingchecks "-sdf_cmd_file airi5c_top_asic_qspi_xh018.sdf_cmd" -logfile logfile_postsyn.log $(ALLHDLCOMOPTS) +access+r \
	-v $(DCLIB) $(foreach hdlfile,$(POSTSYN_HDLFILES),../$(hdlfile)) \
	-input simsetup.tcl
#	-input @"dumptcf -internal -overwrite -scope airi5c_top_tb:DUT -output ../prINNO/SA_SYNTH.tcf" -input @"run" -input @"dumptcf -end" \
#	-input @"set pack_assert_off {std_logic_arith numeric_std}"	

simATPG:
	cd $(simdir); \
	$(SDFCOM) -Update -Output ./$(topmodule).sdf.X ../$(POSTSYN_SDFFILE) && \
	$(HDLCOM) $(ATPG_MODHDLCOMOPTS) -v ${DCLIB} -v ${DCLIB2} \
	$(foreach hdlfile,$(ATPG_HDLFILES),../$(hdlfile)) -end


simPR:
	cd $(simdir); \
	$(SDFCOM) -Update -Output ./$(topmodule)_postpr.sdf.X ../$(POSTPR_SDFFILE) && \
	$(HDLCOM) $(POSTPR_MODHDLCOMOPTS) \
	-v $(DCLIB) \
	$(foreach hdlfile,$(POSTPR_HDLFILES),../$(hdlfile)) \
	-input simsetup.tcl

simPRall: simPRmin simPRmax

simPRmax:
	cd $(simdir); \
	$(SDFCOM) -Update -Output ./$(topmodule).sdf.X ../$(POSTPR_SDFFILE) && \
	$(HDLCOM) $(POSTPR_MODHDLCOMOPTS_MAX) \
	-v $(DCLIB) \
	$(foreach hdlfile,$(POSTPR_HDLFILES),../$(hdlfile))
simPRmin:
	cd $(simdir); \
	$(SDFCOM) -Update -Output ./$(topmodule).sdf.X ../$(POSTPR_SDFFILE) && \
	$(HDLCOM) $(POSTPR_MODHDLCOMOPTS_MIN) \
	-v $(DCLIB) \
	$(foreach hdlfile,$(POSTPR_HDLFILES),../$(hdlfile))

check:
	cd $(simdir); \
	$(HDLCOM) $(ALLHDLCOMOPTS) -elaborate \
	-v $(DCLIB) $(IOLIB) \
	$(foreach hdlfile,$(HDLFILES),../$(hdlfile))


ifeq ($(TECH),XH018)
syn:
	cd $(syndir); \
	genus -file synth_xh018_sr_mmmc.tcl
endif
ifeq ($(TECH),L035)
syn:
	cd $(syndir); \
	genus -file synth_l035_sr_mmmc.tcl
endif

pr:
	cd $(prdir); \
	innovus -common_ui -win -init pr_easy.tcl -wait 10

atpg:
	cd $(atpgdir); \
	et -tcl atpg.tcl

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
	rm -rf $(syndir)/results/* \
	rm -rf $(syndir)/reports/* \
	rm -rf $(prdir)/*.cmd* \
	rm -rf $(prdir)/*.log* \
	rm -rf $(prdir)/results/* \
	rm -rf $(prdir)/reports/* \
	rm -rf $(atpgdir)/*.log* \
	rm -rf $(atpgdir)/*.cmd*
