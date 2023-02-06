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
###############################################################################
#
#
#	Makefile for AIRI5C RISC-V FPGA
#
# Author	: Rol
# Date		: 26.11.20
#
# Changelog	: 
#	26.11.20 - initial version (based on FhG AISEC FPGA makefile)
#                https://github.com/Fraunhofer-AISEC/leakres-updatable-SoC
#     22.12.20 - TCP script based project recreation
#     ??.12.20 - new target board: digilent Cmod A7-35T
#
###############################################################################
#ELF_PATH = /home/barthel/git/make_update_elf/airi5c-base-core/Airisc Debug.elf


BASE_DIR = $(abspath .)

# User configuration - hardware (zedboardRevD / NexysVideo / CmodA7)
# zedboardRevD: http://zedboard.org/product/zedboard
# NexysVideo: https://reference.digilentinc.com/reference/programmable-logic/nexys-video/start
# Cmod A7 (-35T): https://store.digilentinc.com/cmod-a7-breadboardable-artix-7-fpga-module/
# -----------------------------------------------------------------------------
BOARD = NexysVideo
#BOARD = ArtyA7
#BOARD = CmodA7

# User configuration - design (AIRI5C_FPGA)
# -----------------------------------------------------------------------------
#CONFIG = AIRI5C_FPGA
CONFIG = AIRI5C_BASIC_FPGA

# User configuration - Vivado version (2019.2-tested / 2020.2-tested)
# ----------------------------------------------------------------------------
VIVADO_VER = 2020.2

# Other configurations
# -----------------------------------------------------------------------------
BINARIES_OUTPUT_DIR = images
PRODUCTS_OUTPUT_DIR = sdcard

# project configuration
# -----------------------------------------------------------------------------
PROJ_NAME = $(CONFIG)_$(BOARD)
#PROJ_NAME = AIRI5C_FPGA_NexysVideo
#PROJ_NAME = AIRI5C_FPGA_ArtyA7
#PROJ_NAME = AIRI5C_FPGA_CmodA7

ELF_PATH = src_$(BOARD)/ip/HelloWorld.elf
BIN_PATH = $(basename $(ELF_PATH)).bin
COE_PATH = src_$(BOARD)/ip/$(basename $(notdir $(ELF_PATH))).coe

# hardware configuration 
# -----------------------------------------------------------------------------
ifeq ($(BOARD), zedboardRevD)
	BOARD_MODEL = em.avnet.com:zed:part0:1.2
	PART = xc7z020clg484-1
	UBOOT_CONFIG = zed
	ZYNQ_CONFIG = ZedBoard 
else ifeq ($(BOARD), zc702)
	BOARD_MODEL = xilinx.com:zc702:part0:1.0
	PART = xc7z020clg484-1
	UBOOT_CONFIG = zc702
	ZYNQ_CONFIG = ZC702 
else ifeq ($(BOARD), zedboardRevC)
	BOARD_MODEL = em.avnet.com:zed:part0:0.9
	PART = xc7z020clg484-1
	UBOOT_CONFIG = zed
	ZYNQ_CONFIG = ZedBoard 
else ifeq ($(BOARD), zybo)
	BOARD_MODEL = digilentinc.com:zybo-z7-10:part0:1.0
	PART = xc7z010clg400-1
	UBOOT_CONFIG = zybo
	ZYNQ_CONFIG = Zybo-10 
else ifeq ($(BOARD), NexysVideo)
        BOARD_MODEL = digilentinc.com:nexys_video:part0:1.1
        PART = xc7a200tsbg484-1
        UBOOT_CONFIG = none
        ZYNQ_CONFIG = none
else ifeq ($(BOARD), ArtyA7)
        BOARD_MODEL = digilentinc.com:arty-a7-35:part0:1.0
        PART = xc7a35ticsg324-1L
        UBOOT_CONFIG = none
        ZYNQ_CONFIG = none
else ifeq ($(BOARD), CmodA7)
        BOARD_MODEL = digilentinc.com:cmod_a7-35t:part0:1.1
        PART = XC7A35T-1CPG236C
        UBOOT_CONFIG = none
        ZYNQ_CONFIG = none
else
	BOARD_MODEL = em.avnet.com:zed:part0:1.2
	PART = xc7z020clg484-1
	UBOOT_CONFIG = zed
	ZYNQ_CONFIG = ZedBoard
endif

# -----------------------------------------------------------------------------
default: all-fpga

all-fpga: update-boards project build-fpga copy-bitstream sim-fpga program-fpga


# build fpga hardware 
#-------------------------------------------------------------------------------

update-boards:
	git clone https://github.com/Xilinx/XilinxBoardStore.git
#       Only once needed: 
#	vivado -mode batch -source update_boards.tcl

# recreate vivado project file from tcl
project:
	vivado -mode batch -notrace -source $(PROJ_NAME).tcl -nojournal -nolog

build-fpga:
	vivado -mode tcl -source make_bitstream.tcl -tclargs $(PROJ_NAME)

# opens vivado project in GUI
vivado-gui:
	vivado $(PROJ_NAME)/$(PROJ_NAME).xpr &

copy-bitstream:
	[ -d ./$(PRODUCTS_OUTPUT_DIR) ] && echo "Directory ./$(PRODUCTS_OUTPUT_DIR) Exists" || mkdir ./$(PRODUCTS_OUTPUT_DIR)
	cp $(PROJ_NAME)/$(PROJ_NAME).runs/impl_1/FPGA_Top.bit $(PRODUCTS_OUTPUT_DIR)/FPGA_Top_$(BOARD).bit

update-elf:
	@echo "make sure the path provided does not contain any spaces!"
	riscv32-unknown-elf-objcopy -O binary "$(ELF_PATH)" "$(BIN_PATH)"
	../external/bin2coe/bin/Release/bin2coe "$(BIN_PATH)" "$(COE_PATH)"
	rm "$(BIN_PATH)"
	vivado -mode tcl -source make_update_coe.tcl -tclargs "$(abspath .)" $(BOARD) $(PROJ_NAME) "$(COE_PATH)"
	@echo "initial memory conent has been changed, remember to rebuild the bitstream using 'make build-fpga'"


# Generate xcelium-compatible simulation libraries from Vivado sources
# -------------------------------------------------------------------------------
simlibs:
	$(Display Generate SimLibs for third-party simulator XCelium)
	vivado -mode tcl -source simlibs.tcl -tclargs $(PROJ_NAME)

design-xcelium:
	$(Display Generate Simulation Design for third-party simulator XCelium)
	vivado -mode tcl -source xcelium_design.tcl -tclargs $(PROJ_NAME)


# simulate fpga design
# -------------------------------------------------------------------------------
sim-fpga:
	$(info Simulation of TopLevel Design with TB)
	vivado -mode tcl -source generate_sim_scripts.tcl -tclargs $(PROJ_NAME)
	cp -r ../tb/memfiles ./$(PROJ_NAME)/$(PROJ_NAME).sim/sim_1/behav/xsim/
	vivado -mode tcl -source sim_toplevel.tcl -tclargs $(PROJ_NAME)
	grep "TB PASSED" ./vivado.log && echo "passed" && exit 0 || echo "failed" && exit 1

# simulate fpga design using xcelium simulator
# -------------------------------------------------------------------------------
sim-fpga-xcelium:
	$(info Simulation of TopLevel Design with TB using xcelium)
	$(warning IMPLEMENTATION sim-fpga to be tested with on the fly generated mem files)
	cp -r ../tb/memfiles ./sim_xcelium/xcelium/memfiles/
	cd sim_xcelium/xcelium && ./airi5c_top_tb.sh
	grep "TB PASSED" ./sim_xcelium/xcelium/xrun.log && echo "passed" && exit 0 || echo "failed" && exit 1



# program fpga board
# -------------------------------------------------------------------------------
program-fpga:
	$(info FPGA board needs to be connected to JTAG and powered)
	vivado -mode batch -source prog_fpga.tcl -tclargs $(PROJ_NAME) $(BOARD)

# info of fpga design
# -------------------------------------------------------------------------------
info-fpga:
	$(Display Info of Vivado Project)
	vivado -mode tcl -source project_info.tcl -tclargs $(PROJ_NAME)


# clean project
# -------------------------------------------------------------------------------
clean-fpga:
	- rm -f *.log *.jou *.str
	- rm -f *_webtalk.html
	- rm -f *_webtalk.xml
	- rm -rf $(PROJ_NAME)
	- rm -rf sdcard
	- rm -rf src/ip/.Xil
	
clean-board:
	- rm -rf XilinxBoardStore
	
clean-fpga-all: clean-fpga clean-board

.PHONY: vivado-gui build-fpga update-boards clean-fpga clean-fpga-all clean-board all-fpga copy-bitstream sim-fpga program-fpga
