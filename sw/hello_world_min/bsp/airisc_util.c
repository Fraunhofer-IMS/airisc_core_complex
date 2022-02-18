#include "airisc_defines.h"
#include <stdint.h>

/*
int read_csr(int csr_num) {
    int result = 0;
    asm("csrr %0, %1" : "=r"(result) : "i"(csr_num));
    return result; }

void write_csr(int csr_num, int val) {
	asm("csrrw x0, %0, %1" : : "i"(csr_num),"r"(val));
}
*/

void uart_config(int baudrate, int parity, int stopbits) {
	uint32_t temp;
	uint32_t cycles_per_baud = AIRISC_CLK_RATE/baudrate;
	temp = uart1->CTRL;
	temp &= 0xFFFFF000;
	//temp |= 0x00000115;
	temp |= cycles_per_baud;
	uart1->CTRL = temp;
}

uint32_t get_time_ms(void) {
	uint32_t result;
	result = (timer1->TIMEL / (AIRISC_CLK_RATE/1000));
	return(result);
}

void icap_iprog() {
	 icap->CTRL   = 0x00000000;
	 icap->CTRL   = 0x00000001;

	 icap->DATAIN = 0xFFFFFFFF;
	 icap->DATAIN = 0x000000BB;
	 icap->DATAIN = 0x11220044;
	 icap->DATAIN = 0xFFFFFFFF;
	 icap->DATAIN = 0xFFFFFFFF;
	 icap->DATAIN = 0xAA995566;
	 icap->DATAIN = 0x20000000;
	 icap->DATAIN = 0x30020001;
	 icap->DATAIN = 0x00000000;
	 icap->DATAIN = 0x30008001;
	 icap->DATAIN = 0x0000000F;
	 icap->DATAIN = 0x20000000;

	 icap->CTRL   = 0x00000000;
}
