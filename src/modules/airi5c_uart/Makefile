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

topdir = .
simdir = ./simIUS
srcdir = ./src

TBFILES =\
${topdir}/tb/airi5c_uart_tb.v

HDLFILES =\
${srcdir}/airi5c_uart.v \
${srcdir}/airi5c_uart_tx.v \
${srcdir}/airi5c_uart_rx.v \
${srcdir}/airi5c_uart_fifo.v \
${TBFILES}

HDLCOM = xrun

ALLHDLCOMOPTS +=\
-assert \
+xtimescale+1ns/1ps \
-incdir ../../..

MODHDLCOMOPTS =\
-access +rc \
-covoverwrite \
$(ALLHDLCOMOPTS)

sim:
	cd $(simdir); \
	$(HDLCOM) $(MODHDLCOMOPTS) \
		-linedebug -input simsetup.tcl \

	$(foreach hdlfile,$(HDLFILES),../$(hdlfile))