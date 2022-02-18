#include <stdio.h>
#include <stdlib.h>

#include "airisc.h"

int main()
{
	uint64_t startCounter;
	uint64_t stopCounter;
	uint64_t deltaCounter;

	startCounter = readCounter();

	gpio1->EN	= 0xffffffff;
	gpio1->DATA = 0x000000aa;
	printf("Hello World!\n");
	fflush(stdout);

	stopCounter = readCounter();
	deltaCounter = stopCounter - startCounter;

	printf("Program executed in %u clock cycles (%f s at 32 MHz)\n", (uint32_t)deltaCounter, (float)deltaCounter / 32e6f);
	fflush(stdout);

	return 0;
}
