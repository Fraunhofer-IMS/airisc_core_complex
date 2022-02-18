#!/bin/bash

riscv32-unknown-elf-gdb -ix=gdb/airisc.gdbinit --command=gdb/gdb-change-led --command=gdb/gdb-airisc-hello