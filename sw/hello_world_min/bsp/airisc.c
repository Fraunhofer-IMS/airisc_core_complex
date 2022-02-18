#include "airisc.h"

#include <stdio.h>
#include <stdlib.h>

volatile TIMER_t* const timer1 = (TIMER_t*) 0xC0000100;
volatile UART_t*  const uart1  = (UART_t*)  0xC0000200;
volatile SPI_t*   const spi1   = (SPI_t*)   0xC0000300;
volatile GPIO_t*  const gpio1  = (GPIO_t*)  0xC0000400;

void trap_handler(unsigned int cause)
{
	static uint32_t uptime = 0;
	uint32_t counterLow;
	uptime++;
	printf("\33[Huptime %is\n", uptime);

	counterLow = timer1->TIMEL;
	timer1->TIMECMPH = timer1->TIMEH;
	timer1->TIMECMPL = counterLow + 32000000; // tick every 1s @ 32MHz
}

unsigned int exception_handler(unsigned int cause, unsigned int instr)
{
	fputs("EXCEPTION: ",stdout);
	switch(cause)
	{
	case 0 : fputs("misaligned access",stdout); break;
	case 1 : fputs("inst access fault",stdout); break;
	case 2 : fputs("illegal inst",stdout); break;
	case 3 : fputs("breakpoint",stdout); break;
	case 4 : fputs("la misaligned",stdout); break;
	case 5 : fputs("load access fault",stdout); break;
	case 6 : fputs("store misaligned",stdout); break;
	case 7 : fputs("store access fault",stdout); break;
	case 8 : fputs("call from u-mode",stdout); break;
	case 9 : fputs("call from s-mode",stdout); break;
	case 11: fputs("call from m-mode",stdout); break;
	default: fputs("unknown",stdout); break;
	}

	while(1);

	return 0;
}

uint64_t readCounter()
{
	uint32_t counterLow;
	uint32_t counterHigh;
	uint64_t counter;

	counterLow = timer1->TIMEL;
	counterHigh = timer1->TIMEH;

	counter = ((uint64_t)counterHigh << 32) | counterLow;

	return counter;
}

void cls()
{
	printf("\033[2J");
	printf("\033[H");
	fflush(stdout);
}
