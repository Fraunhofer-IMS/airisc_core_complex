/*
Copyright 2022 FRAUNHOFER INSTITUTE OF MICROELECTRONIC CIRCUITS AND SYSTEMS (IMS), DUISBURG, GERMANY.
--- All rights reserved --- 
SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
Licensed under the Solderpad Hardware License v 2.1 (the “License”);
you may not use this file except in compliance with the License, or, at your option, the Apache License version 2.0.
You may obtain a copy of the License at
https://solderpad.org/licenses/SHL-2.1/
Unless required by applicable law or agreed to in writing, any work distributed under the License is distributed on an “AS IS” BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.
*/


OUTPUT_FORMAT("elf32-littleriscv")
OUTPUT_ARCH("riscv")
ENTRY(_reset_entry)

MEMORY
{
	/*** ArtyA7 (35T), CmodA7 (35T) ***/
/*
	RAM (rwx)		: ORIGIN = 0x80000000, LENGTH = 0x0002E000
	CCRAM (rwx)		: ORIGIN = 0x8002E000, LENGTH = 0x00004000
	EXT_MEM (rwx)	: ORIGIN = 0x80032000, LENGTH = 0x00000000
*/

	/*** NexysVideo (200T) ***/

	RAM (rwx)		: ORIGIN = 0x80000000, LENGTH = 0x00169000
	CCRAM (rwx)		: ORIGIN = 0x80169000, LENGTH = 0x00004000
	EXT_MEM (rwx)	: ORIGIN = 0x8016D000, LENGTH = 0x00000000

}

SECTIONS
{
	. = 0x80000000;


	.init : {
		KEEP (*(SORT_NONE(.init)))
		} > RAM


	.reset_entry : {
		crt0.o(.text)
	} > RAM


	.text : {
		. = ALIGN(4);
		_stext = .;
		*(.text.unlikely .text.unlikely.*)
		*(.text.startup .text.startup.*)
		*(.text .text.*)
		*(.gnu.linkonce.t.*)
	} > RAM


	.fini : {
		KEEP (*(SORT_NONE(.fini)))
	} > RAM


	.rodata : {
		*(.rdata)
		*(.rodata .rodata.*)
		*(.gnu.linkonce.r.*)
	} > RAM
	. = ALIGN(4);


	.srodata : {
		*(.srodata)
	} > RAM


	.data : {
		. = ALIGN(4);
		*(.data)
		*(.data.*)
		_end_data = .;
	} > RAM


	__global_pointer$ = .;


	.sdata : {
		*(.sdata)
	} > RAM


	.bss : {
		. = ALIGN(4);
		_bss_start = .;
		*(.bss)
		*(.bss.*)
		*(.sbss)
		*(.sbss.*)
		. = ALIGN(4);
		_bss_end = .;
	} > RAM


	.heap : {
		. = ALIGN(4);
		_end = .;
		/* _heap_start = .; */
		/* "end" is used by newlib's syscalls!!! */
		PROVIDE(end = .);
		PROVIDE(_heap_start = end );
		PROVIDE(_heap_end = .);
	} > RAM


	.stack_dummy (COPY) : {
		_end_stack = .;
		*(.stack*)
	} > CCRAM


	/* Set stack top to end of RAM, and stack limit move down by
	 * size of stack_dummy section */
	_stack_start = ORIGIN(CCRAM) + LENGTH(CCRAM);
	_stack_size = _stack_start - SIZEOF(.stack_dummy);
	PROVIDE(__stack = _stack_start);


	.ext_mem : {
		_EXT_MEM_START = .;
		KEEP(*(.extMem))
		_EXT_MEM_END = .;
	} > EXT_MEM


	/* define labels for the system timer, so
	 * crt0 can easily initialize timer registers */
	_timer_base = 0xC0000100;
}

