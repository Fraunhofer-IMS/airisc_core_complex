##
## This is confidential and proprietary software which may be used only as
## authorized by a licensing agreement from Fraunhofer Institute of
## Microelectronic Circuits and Systems, Duisburg, Germany.
##
## In the event of publication, the following notice is applicable:
##
## (C) COPYRIGHT 2020 FRAUNHOFER INSTITUTE OF MICROELECTRONIC CIRCUITS
## AND SYSTEMS, DUISBURG, GERMANY.
## ALL RIGHTS RESERVED.
##
## The entire notice above must be reproduced on all authorized copies.
##
##
## File             : Makefile
## Author           : C.Rolfes
## Creation Date    : 17.02.22
## Last Modified    : 
## Version          : 1.0
## Abstract         : Makefile for ISA Tests
## History          : 17.02.22 inital version
## Notes            : 
##

# ==================================
# = Configuration                  =
# ==================================
topdir = ${CURDIR}
#externaldir = $(topdir)/external
toolsdir = $(topdir)/tools

patch:
	cd ./riscv-tests && git apply ../patch-fence_zifencei

compile-elf2hex:
	cd ./elf2hex && ./configure --target=riscv32-unknown-elf --prefix=$(toolsdir) && make && make install
	
compile-isa-tests:
	cd ./riscv-tests && autoconf && ./configure --prefix=$(topdir)/rv32ui --with-xlen=32 && make

prepare-mem-files: 
	find -type f -not \( -name "*.dump" -or -name "*.S" \) -and -name "*rv32*" -exec $(toolsdir)/bin/riscv32-unknown-elf-elf2hex --bit-width 32 --input {} --output {}.mem \;
	
copy-mem-files:
#	mkdir -p ../tb/memfiles/rv32
	mkdir -p ../tb/memfiles/rv32mi && cd riscv-tests/isa/ && find -type f -name "*.mem" -and -name "rv32mi*" | xargs cp -t ../../../tb/memfiles/rv32mi/
	mkdir -p ../tb/memfiles/rv32ua && cd riscv-tests/isa/ && find -type f -name "*.mem" -and -name "rv32ua*" | xargs cp -t ../../../tb/memfiles/rv32ua/
	mkdir -p ../tb/memfiles/rv32uc && 	cd riscv-tests/isa/ && find -type f -name "*.mem" -and -name "rv32uc*" | xargs cp -t ../../../tb/memfiles/rv32uc/
	mkdir -p ../tb/memfiles/rv32ud && 	cd riscv-tests/isa/ && find -type f -name "*.mem" -and -name "rv32ud*" | xargs cp -t ../../../tb/memfiles/rv32ud/
	mkdir -p ../tb/memfiles/rv32uf && 	cd riscv-tests/isa/ && find -type f -name "*.mem" -and -name "rv32uf*" | xargs cp -t ../../../tb/memfiles/rv32uf/
	mkdir -p ../tb/memfiles/rv32ui && 	cd riscv-tests/isa/ && find -type f -name "*.mem" -and -name "rv32ui*" | xargs cp -t ../../../tb/memfiles/rv32ui/
	mkdir -p ../tb/memfiles/rv32um && 	cd riscv-tests/isa/ && find -type f -name "*.mem" -and -name "rv32um*" | xargs cp -t ../../../tb/memfiles/rv32um/

all: patch compile-elf2hex compile-isa-tests prepare-mem-files copy-mem-files

clean:
	make -f ./elf2hex/Makefile clean 
	make -f ./riscv-tests/Makefile clean 
	rm ../tb/memfiles/rv32/*.mem
