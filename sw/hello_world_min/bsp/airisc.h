#ifndef AIRISC_H_
#define AIRISC_H_

#include "airisc_defines.h"
#include "airisc_syscalls.h"

void trap_handler(unsigned int cause);
unsigned int exception_handler(unsigned int cause, unsigned int instr);

uint64_t readCounter();

void cls();

#endif
