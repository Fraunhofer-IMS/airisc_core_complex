#ifndef AIRISC_DEFINES_H_
#define AIRISC_DEFINES_H_

#include <stdint.h>

typedef struct
{
	uint32_t TIMEL;    		// timer register LSB
	uint32_t TIMEH;    		// timer register MSB
	uint32_t TIMECMPL; 		// timer compare register LSB
	uint32_t TIMECMPH; 		// timer compare register MSB
} TIMER_t __attribute__((aligned(4)));


typedef struct
{
	uint32_t DATA;     		// data i/o
	uint32_t EN;       		// output enable
} GPIO_t __attribute__((aligned(4)));

typedef struct
{
	uint32_t DATA;     		// SPI tx/rx FIFO stack
	uint32_t CTRL;			// SPI control register
	uint32_t CTRL_SET;		// set specified bits in SPI control register
	uint32_t CTRL_CLR;		// clear specified bits in SPI control register
	uint32_t TX_STAT;		// tx status register
	uint32_t TX_STAT_SET;	// set specified bits in tx status register
	uint32_t TX_STAT_CLR;	// clear specified bits in tx status register
	uint32_t RX_STAT;		// tx status register
	uint32_t RX_STAT_SET;	// set specified bits in tx status register
	uint32_t RX_STAT_CLR;	// clear specified bits in tx status register
} SPI_t __attribute__((aligned(4)));

typedef struct
{
	uint32_t DATA;     		// UART tx/rx FIFO stack
	uint32_t CTRL;			// UART control register
	uint32_t CTRL_SET;		// set specified bits in UART control register
	uint32_t CTRL_CLR;		// clear specified bits in UART control register
	uint32_t TX_STAT;		// tx status register
	uint32_t TX_STAT_SET;	// set specified bits in tx status register
	uint32_t TX_STAT_CLR;	// clear specified bits in tx status register
	uint32_t RX_STAT;		// tx status register
	uint32_t RX_STAT_SET;	// set specified bits in tx status register
	uint32_t RX_STAT_CLR;	// clear specified bits in tx status register
} UART_t __attribute__((aligned(4)));

// default register mapping for AIRI5C Core Complex
extern volatile TIMER_t* const timer1;
extern volatile GPIO_t*  const gpio1;
extern volatile UART_t*  const uart1;
extern volatile SPI_t*   const spi1;

#endif
