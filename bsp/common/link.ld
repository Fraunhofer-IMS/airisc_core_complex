/*
Copyright 2023 FRAUNHOFER INSTITUTE OF MICROELECTRONIC CIRCUITS AND SYSTEMS (IMS), DUISBURG, GERMANY.
--- All rights reserved --- 
SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
Licensed under the Solderpad Hardware License v 2.1 (the "License");
you may not use this file except in compliance with the License, or, at your option, the Apache License version 2.0.
You may obtain a copy of the License at
https://solderpad.org/licenses/SHL-2.1/
Unless required by applicable law or agreed to in writing, any work distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.

File          : link.ld
Author        : S. Nolting
Last Modified : 30.01.2023
Abstract      : AIRISC (core complex) linker script.
*/


OUTPUT_FORMAT("elf32-littleriscv")
OUTPUT_ARCH("riscv")
ENTRY(_reset_entry)

/*** Default configuration for Nexys-Video 200T             ***/
/*** DO NOT CHANGE THIS FILE! Use the SW project's          ***/
/*** Makefile to override the default memory configuration! ***/

/* Default memory base addresses */
__airisc_ram_base   = DEFINED(__airisc_ram_base)   ? __airisc_ram_base   : 0x80000000;
__airisc_ccram_base = DEFINED(__airisc_ccram_base) ? __airisc_ccram_base : 0x80169000;
__airisc_xmem_base  = DEFINED(__airisc_xmem_base)  ? __airisc_xmem_base  : 0x8016D000;

/* Default memory sizes */
__airisc_ram_size   = DEFINED(__airisc_ram_size)   ? __airisc_ram_size   : 0x00169000;
__airisc_ccram_size = DEFINED(__airisc_ccram_size) ? __airisc_ccram_size : 0x00004000;
__airisc_xmem_size  = DEFINED(__airisc_xmem_size)  ? __airisc_xmem_size  : 0x00000000;


MEMORY
{
  RAM (rwx)     : ORIGIN = __airisc_ram_base,   LENGTH = __airisc_ram_size
  CCRAM (rwx)   : ORIGIN = __airisc_ccram_base, LENGTH = __airisc_ccram_size
  EXT_MEM (rwx) : ORIGIN = __airisc_xmem_base,  LENGTH = __airisc_xmem_size
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
    *(.srodata .srodata.*)
  } > RAM


  .data : {
    . = ALIGN(4);
    *(.sdata2 .sdata2.* .gnu.linkonce.s2.*)
    *(.data1)
    *(.data .data.* .gnu.linkonce.d.*)
    *(.data.rel.ro.local* .gnu.linkonce.d.rel.ro.local.*) *(.data.rel.ro .data.rel.ro.* .gnu.linkonce.d.rel.ro.*)
    *(.dynamic)
    *(.sdata .sdata.* .gnu.linkonce.s.*)
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
