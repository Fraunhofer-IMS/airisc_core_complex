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

# -----------------------------------------------------------------------------
# USER CONFIGURATION
# -----------------------------------------------------------------------------
# User's application sources (*.c, *.cpp, *.s, *.S); add additional files here
APP_SRC ?= $(wildcard ./*.c) $(wildcard ./*.s) $(wildcard ./*.cpp) $(wildcard ./*.S)

# User's application include folders (don't forget the '-I' before each entry)
APP_INC ?= -I .
# User's application include folders - for assembly files only (don't forget the '-I' before each entry)
ASM_INC ?= -I .

# Optimization
EFFORT ?= -Os

# Compiler toolchain
RISCV_PREFIX ?= riscv32-unknown-elf-

# CPU architecture and ABI
MARCH ?= rv32i
MABI  ?= ilp32

# User flags for additional configuration (will be added to compiler flags)
USER_FLAGS ?=

# Relative or absolute path to the "AIRISC Base Core" home folder
AIRISC_HOME ?= ../..


# -----------------------------------------------------------------------------
# AIRISC framework
# -----------------------------------------------------------------------------
# Path to AIRISC board support package
AIRISC_BSP_PATH = $(AIRISC_HOME)/bsp

# Path to main AIRISC library include files
AIRISC_INC_PATH = $(AIRISC_BSP_PATH)/include
# Path to main AIRISC library source files
AIRISC_SRC_PATH = $(AIRISC_BSP_PATH)/source
# Path to main AIRISC library common files
AIRISC_COM_PATH = $(AIRISC_BSP_PATH)/common

# Start-up code
CRT0_FILE = $(AIRISC_COM_PATH)/crt0.S
# Linker script
LD_SCRIPT = $(AIRISC_COM_PATH)/link.ld


# -----------------------------------------------------------------------------
# Sources and objects
# -----------------------------------------------------------------------------
# Core libraries
CORE_SRC  = $(wildcard $(AIRISC_SRC_PATH)/*.c)
# Application start-up code
CORE_SRC += $(CRT0_FILE)

# Define all sources
SRC  = $(APP_SRC)
SRC += $(CORE_SRC)

# Define all object files
OBJ = $(SRC:%=%.o)


# -----------------------------------------------------------------------------
# Tools and flags
# -----------------------------------------------------------------------------
# Compiler tools
CC      = $(RISCV_PREFIX)gcc
OBJDUMP = $(RISCV_PREFIX)objdump
OBJCOPY = $(RISCV_PREFIX)objcopy
READELF = $(RISCV_PREFIX)readelf
SIZE    = $(RISCV_PREFIX)size

# GCC flags
CC_OPTS = -march=$(MARCH) -mabi=$(MABI) $(EFFORT) -Wall -ffunction-sections -fdata-sections -nostartfiles -Wl,--gc-sections -lm -lc -lgcc -lc -g


# -----------------------------------------------------------------------------
# Output definitions
# -----------------------------------------------------------------------------
.PHONY: help check info elf asm mem all elf_info clean clean_all
.DEFAULT_GOAL := help

# Main output files
APP_ELF = main.elf
APP_ASM = main.asm
APP_MEM = main.mem

# Main targets
asm: $(APP_ASM)
elf: $(APP_ELF)
mem: $(APP_MEM)
all: $(APP_ASM) $(APP_ELF) $(APP_MEM)


# -----------------------------------------------------------------------------
# General targets: Assemble, compile, link, dump
# -----------------------------------------------------------------------------
# Compile app *.s sources (assembly)
%.s.o: %.s
	@$(CC) -c $(CC_OPTS) -I $(AIRISC_INC_PATH) $(ASM_INC) $< -o $@

# Compile app *.S sources (assembly + C pre-processor)
%.S.o: %.S
	@$(CC) -c $(CC_OPTS) -I $(AIRISC_INC_PATH) $(ASM_INC) $< -o $@

# Compile app *.c sources
%.c.o: %.c
	@$(CC) -c $(CC_OPTS) -I $(AIRISC_INC_PATH) $(APP_INC) $< -o $@

# Compile app *.cpp sources
%.cpp.o: %.cpp
	@$(CC) -c $(CC_OPTS) -I $(AIRISC_INC_PATH) $(APP_INC) $< -o $@

# Link object files and show memory utilization
$(APP_ELF): $(OBJ)
	@$(CC) $(CC_OPTS) -T $(LD_SCRIPT) $(OBJ) -o $@ -lm
	@echo "Memory utilization:"
	@$(SIZE) $(APP_ELF)

# Assembly listing file (for debugging)
$(APP_ASM): $(APP_ELF)
	@$(OBJDUMP) -d -S -z $< > $@

# Convert to ASCII-HEX memory initialization file (section-by-section version)
$(APP_MEM): $(APP_ELF)
	@echo "Generating BINARY executable. WARNING! This is still experimental!!!"
	@$(OBJCOPY) -I elf32-little --reverse-bytes=4 $< -j .init   -O binary init.bin
	@$(OBJCOPY) -I elf32-little --reverse-bytes=4 $< -j .text   -O binary text.bin
	@$(OBJCOPY) -I elf32-little --reverse-bytes=4 $< -j .rodata -O binary rodata.bin
	@cat init.bin text.bin rodata.bin > tmp.bin
	@xxd -c 4 -ps tmp.bin > $@
	@rm -f init.bin text.bin rodata.bin tmp.bin

## Convert to ASCII-HEX memory initialization file (straight forward version); endianness issue!
#$(APP_MEM): $(APP_ELF)
#	@$(OBJCOPY) -I elf32-little $(APP_ELF) -O verilog --verilog-data-width 4 tmp.mem
#	@sed 's/\r//g' tmp.mem > $(APP_MEM)
#	@rm -f tmp.mem


# -----------------------------------------------------------------------------
# Check toolchain
# -----------------------------------------------------------------------------
check: 
	@echo "---------------- Check: Shell ----------------"
	@echo ${SHELL}
	@readlink -f ${SHELL}
	@echo "---------------- Check: $(CC) ----------------"
	@$(CC) -v
	@echo "---------------- Check: $(OBJDUMP) ----------------"
	@$(OBJDUMP) -V
	@echo "---------------- Check: $(OBJCOPY) ----------------"
	@$(OBJCOPY) -V
	@echo "---------------- Check: $(READELF) ----------------"
	@$(READELF) -v
	@echo "---------------- Check: $(SIZE) ----------------"
	@$(SIZE) -V
	@echo
	@echo "Toolchain check OK"


# -----------------------------------------------------------------------------
# Show final ELF details (just for debugging)
# -----------------------------------------------------------------------------
elf_info: $(APP_ELF)
	@$(OBJDUMP) -x $(APP_ELF)
	@$(READELF) -e $(APP_ELF)


# -----------------------------------------------------------------------------
# Clean up
# -----------------------------------------------------------------------------
clean:
	@rm -f *.elf *.o *.out *.asm *.mem *.bin

clean_all: clean
	@rm -f $(OBJ) $(IMAGE_GEN)


# -----------------------------------------------------------------------------
# Show configuration
# -----------------------------------------------------------------------------
info:
	@echo "---------------- Info: Project ----------------"
	@echo "Project folder:        $(shell basename $(CURDIR))"
	@echo "Source files:          $(APP_SRC)"
	@echo "Include folder(s):     $(APP_INC)"
	@echo "ASM include folder(s): $(ASM_INC)"
	@echo "---------------- Info: AIRISC ----------------"
	@echo "AIRISC home folder (AIRISC_HOME): $(AIRISC_HOME)"
	@echo "Core source files:"
	@echo "$(CORE_SRC)"
	@echo "Core include folder:"
	@echo "$(AIRISC_INC_PATH)"
	@echo "---------------- Info: Objects ----------------"
	@echo "Project object files:"
	@echo "$(OBJ)"
	@echo "---------------- Info: RISC-V CPU ----------------"
	@echo "MARCH: $(MARCH)"
	@echo "MABI:  $(MABI)"
	@echo "---------------- Info: Toolchain ----------------"
	@echo "CC:      $(CC)"
	@echo "OBJDUMP: $(OBJDUMP)"
	@echo "OBJCOPY: $(OBJCOPY)"
	@echo "READELF: $(READELF)"
	@echo "SIZE:    $(SIZE)"
	@echo "---------------- Info: Compiler Configuration ----------------"
	@$(CC) -v
	@echo "---------------- Info: Compiler Libraries ----------------"
	@echo "LIBGCC:"
	@$(CC) -print-libgcc-file-name
	@echo "SEARCH-DIRS:"
	@$(CC) -print-search-dirs
	@echo "---------------- Info: Flags ----------------"
	@echo "USER_FLAGS: $(USER_FLAGS)"
	@echo "CC_OPTS:    $(CC_OPTS)"


# -----------------------------------------------------------------------------
# Help screen
# -----------------------------------------------------------------------------
help:
	@echo "AIRISC Software Application Makefile"
	@echo ""
	@echo "=== Targets ==="
	@echo " help      - Show this text"
	@echo " check     - Check RISC-V GCC toolchain"
	@echo " info      - Show makefile/toolchain configuration"
	@echo " elf       - Compile and generate <$(APP_ELF)> ELF file"
	@echo " asm       - Compile and generate <$(APP_ASM)> assembly listing file"
	@echo " mem       - Compile and generate <$(APP_MEM)> Verilog memory initialization file"
	@echo " all       - Run targets elf + asm + mem"
	@echo " elf_info  - Show ELF layout information"
	@echo " clean     - Clean up project home folder"
	@echo " clean_all - Clean up whole project including all compiled objects"
	@echo ""
	@echo "=== Variables ==="
	@echo " USER_FLAGS   - Custom toolchain flags [append only!]: \"$(USER_FLAGS)\""
	@echo " EFFORT       - Optimization level: \"$(EFFORT)\""
	@echo " MARCH        - Machine architecture: \"$(MARCH)\""
	@echo " MABI         - Machine binary interface: \"$(MABI)\""
	@echo " APP_INC      - C include folder(s) [append only!]: \"$(APP_INC)\""
	@echo " ASM_INC      - ASM include folder(s) [append only!]: \"$(ASM_INC)\""
	@echo " RISCV_PREFIX - Toolchain prefix: \"$(RISCV_PREFIX)\""
	@echo " AIRISC_HOME  - AIRISC home folder: \"$(AIRISC_HOME)\""
	@echo ""

