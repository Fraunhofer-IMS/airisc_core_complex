# -----------------------------------------------------------------------------
# USER CONFIGURATION
# -----------------------------------------------------------------------------
# User's application sources (*.c, *.cpp, *.s, *.S); add additional files here
APP_SRC ?= $(wildcard ./src/*.c) $(wildcard ./src/*.s) $(wildcard ./src/*.cpp) $(wildcard ./src/*.S)

# User's application include folders (don't forget the '-I' before each entry)
APP_INC ?= 
# User's application include folders - for assembly files only (don't forget the '-I' before each entry)
ASM_INC ?= 

# Optimization
EFFORT ?= -Os

# Compiler toolchain
TOOLCHAIN_PREFIX = riscv32-unknown-elf-

# CPU architecture and ABI
MARCH ?= rv32im
MABI  ?= ilp32

# User flags for additional configuration
USER_FLAGS ?= -MD -O3 -DRISCV -std=gnu11

# Relative or absolute path to the AIRISC home folder
AIRISC_HOME ?= .


######################################
### AIRISC specific files
######################################

# Path to AIRISC linker script and startup file
AIRISC_COM_PATH = $(AIRISC_HOME)/bsp

# Core libraries (peripheral and CPU drivers)
CORE_SRC  = $(wildcard $(AIRISC_HOME)/bsp/*.c)

# Application start-up code
CORE_SRC += $(AIRISC_COM_PATH)/bsp/crt0.S

# Core headers
CORE_HEADERS = $(wildcard $(AIRISC_HOME)/bsp/*.h)

# Linker script
LD_SCRIPT = $(AIRISC_COM_PATH)/link_core_complex_nexys.ld


# -----------------------------------------------------------------------------
# Tools and flags
# -----------------------------------------------------------------------------
# Compiler tools
CC      = $(TOOLCHAIN_PREFIX)gcc
OBJDUMP = $(TOOLCHAIN_PREFIX)objdump
OBJCOPY = $(TOOLCHAIN_PREFIX)objcopy
SIZE    = $(TOOLCHAIN_PREFIX)size

# Compiler & linker flags
#CC_OPTS  = -march=$(MARCH) -mabi=$(MABI) $(EFFORT) -Wall -ffunction-sections -fdata-sections 
#CC_OPTS += -Wl,-nostartfiles -nostdlib -nodefaultlibs -mno-fdiv
#CC_OPTS += -Wl,--gc-sections -lm -lc -lgcc -lc
#CC_OPTS += $(USER_FLAGS)


# -----------------------------------------------------------------------------
# Sources and objects
# -----------------------------------------------------------------------------
# Define all sources
SRC  = $(APP_SRC)
SRC += $(CORE_SRC)

# Define all object files
OBJS = $(SRC:%=%.o)



airisc-hello-world.elf:
	@echo 'Building target: $@'
	@echo "syscalls"
	$(CC) -march=rv32im -mabi=ilp32 -msmall-data-limit=8 -mstrict-align -msave-restore -O3 -I$(AIRISC_HOME)/bsp -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -g3 -std=gnu11 -Wa,-adhlns="bsp/airisc_syscalls.o.lst" -MMD -MP -MF"bsp/airisc_syscalls.d" -MT"bsp/airisc_syscalls.o" -c -o "bsp/airisc_syscalls.o" "bsp/airisc_syscalls.c"
	@echo "airisc"
	$(CC) -march=rv32im -mabi=ilp32 -msmall-data-limit=8 -mstrict-align -msave-restore -O3 -I$(AIRISC_HOME)/bsp -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -g3 -std=gnu11 -Wa,-adhlns="bsp/airisc.o.lst" -MMD -MP -MF"bsp/airisc.d" -MT"bsp/airisc.o" -c -o "bsp/airisc.o" "bsp/airisc.c"

#	@echo "airisc_util"
#	$(CC) -march=rv32im -mabi=ilp32 -msmall-data-limit=8 -mstrict-align -msave-restore -O3 -I$(AIRISC_HOME)/bsp -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -g3 -std=gnu11 -Wa,-adhlns="bsp/airisc_util.o.lst" -MMD -MP -MF"bsp/airisc_util.d" -MT"bsp/airisc_util.o" -c -o "bsp/airisc_util.o" "bsp/airisc_util.c"
	@echo "crt0"
	$(CC) -march=rv32im -mabi=ilp32 -msmall-data-limit=8 -mstrict-align -msave-restore -O3 -I$(AIRISC_HOME)/bsp -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -g3 -x assembler-with-cpp -Wa,-adhlns="bsp/crt0.o.lst" -MMD -MP -MF"bsp/crt0.d" -MT"bsp/crt0.o" -c -o "bsp/crt0.o" "bsp/crt0.S"
	@echo "main"
	$(CC) -march=rv32im -mabi=ilp32 -msmall-data-limit=8 -mstrict-align -msave-restore -O3 -I$(AIRISC_HOME)/bsp -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -g3 -std=gnu11 -Wa,-adhlns="src/main.o.lst" -MMD -MP -MF"src/main.d" -MT"src/main.o" -c -o "src/main.o" "src/main.c"
	@echo "elf"
	$(CC) -march=rv32im -mabi=ilp32 -msmall-data-limit=8 -mstrict-align -msave-restore -O3 -I$(AIRISC_HOME)/bsp -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -g3 -T $(LD_SCRIPT) -nostartfiles -Xlinker --gc-sections -Wl,-Map,"airisc-hello-world.map" --specs=nano.specs -u _printf_float -o "airisc-hello-world.elf" ./bsp/airisc.o ./bsp/airisc_syscalls.o ./bsp/crt0.o ./src/main.o -lc_nano -lm -lgcc
	@echo 'Finished building: $@'
	@echo ' '


airisc-hello-world.siz: airisc-hello-world.elf
	@echo 'Invoking: GNU RISC-V Cross Print Size'
	riscv32-unknown-elf-size --format=berkeley "airisc-hello-world.elf"
	@echo 'Finished building: $@'
	@echo ' '

clean:
	rm -rf *.o bsp/*.o src/*.o *.d bsp/*.d src/*.d bsp/*.lst src/*.lst bsp/*.map src/*.map airisc-hello-world.elf airisc-hello-world.map

all: airisc-hello-world.elf airisc-hello-world.siz
# -----------------------------------------------------------------------------
# Check toolchain
# -----------------------------------------------------------------------------
check: 
	@echo "AIRISC_HOME: $(AIRISC_HOME)"
	@echo "---------------- Check: $(CC) ----------------"
	@$(CC) -v
	@echo "---------------- Check: $(OBJDUMP) ----------------"
	@$(OBJDUMP) -V
	@echo "---------------- Check: $(OBJCOPY) ----------------"
	@$(OBJCOPY) -V
	@echo "---------------- Check: $(SIZE) ----------------"
	@$(SIZE) -V
	@echo
	@echo "Toolchain check OK"


# -----------------------------------------------------------------------------
# Show configuration
# -----------------------------------------------------------------------------
info:
	@echo "---------------- Info: Project ----------------"
	@echo "Project folder:        $(shell basename $(CURDIR))"
	@echo "Source files:          $(APP_SRC)"
	@echo "Include folder(s):     $(APP_INC)"
	@echo "ASM include folder(s): $(ASM_INC)"
	@echo "---------------- Info: AIRSC ----------------"
	@echo "AIRISC home folder (AIRISC_HOME): $(AIRISC_HOME)"
	@echo "Core source files:"
	@echo "$(CORE_SRC)"
	@echo "Core header files:"
	@echo "$(CORE_HEADERS)"
	@echo "---------------- Info: Objects ----------------"
	@echo "Project object files:"
	@echo "$(OBJS)"
	@echo "---------------- Info: RISC-V CPU ----------------"
	@echo "MARCH:      $(MARCH)"
	@echo "MABI:       $(MABI)"
	@echo "---------------- Info: Toolchain ----------------"
	@echo "Toolchain:  $(RISCV_TOLLCHAIN)"
	@echo "CC:         $(CC)"
	@echo "OBJDUMP:    $(OBJDUMP)"
	@echo "OBJCOPY:    $(OBJCOPY)"
	@echo "SIZE:       $(SIZE)"
	@echo "---------------- Info: Compiler Configuration ----------------"
	@$(CC) -v
	@echo "---------------- Info: Compiler Libraries ----------------"
	@echo "LIBGCC:"
	@$(CC) -print-libgcc-file-name
	@echo "SEARCH-DIRS:"
	@$(CC) -print-search-dirs
	@echo "\nSupported RISC-V Multilibs:"
	@$(CC) --print-multi-lib	
	@echo "---------------- Info: Flags ----------------"
	@echo "USER_FLAGS: $(USER_FLAGS)"
	@echo "CC_OPTS:    $(CC_OPTS)"

# -----------------------------------------------------------------------------
# Show final ELF details (just for debugging)
# -----------------------------------------------------------------------------
elf_info: main.elf
	@$(OBJDUMP) -x main.elf

.PHONY: main.elf check info elf_info clean
