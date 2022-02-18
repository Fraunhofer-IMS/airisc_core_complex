/*
 * airi5c_syscalls.c
 *
 *  Created on: 11.11.2019
 *      Author: stanitzk
 *
 *  This is a non-reentrant implementation of the 13 syscalls required by
 *  newlib.
 */

#include "airisc_defines.h"
#include "airisc_syscalls.h"


void _exit(int i)
{
	while(1);		// park loop
}

int _close(int file)
{
	return(-1);		// the only file is stdout, which cannot be closed
}


int _execve(char *name, char **argv, char **env)
{
	errno = ENOMEM;
	return -1;
}


int _fork()
{
	errno = EAGAIN;
	return(-1);
}


int _fstat(int file, struct stat *st)
{
	st->st_mode = S_IFCHR;
	return 0;
}


int _getpid(void)
{
	return 1;
}


int _isatty(int file)
{
	return 1;
}


int _kill(int pid, int sig)
{
	errno = EINVAL;
	return -1;
}


int _link(char *old, char *newp)
{
	errno = EMLINK;
	return -1;
}


int _lseek(int file, int ptr, int dir)
{
	return 0;
}


int _open(const char *name, int flags, ...)
{
	return -1;
}


int _read(int file, char *ptr, int len)
{
	// the only file is stdin, which is mapped to
	// the first UART.

	static uint8_t endOfFile = 0;

	uint32_t rx_stat_reg;
	uint32_t rx_size;
	uint32_t idx = 0;
	char c;

	// only wait for incoming data if
	// end of file has not been reached yet
	do
	{
		rx_stat_reg = uart1->RX_STAT;
		rx_size = rx_stat_reg & 0x000000FF;
	} while (rx_size == 0 && endOfFile == 0);


	// read uart rx fifo
	while (rx_size > 0 && idx < len)
	{
		c = uart1->DATA;
		if (c == '\r')
			endOfFile = 1;

		*(ptr + idx) = c;
		idx++;
		rx_stat_reg = uart1->RX_STAT;
		rx_size = rx_stat_reg & 0x000000FF;
	}

	if (idx == 0)
		endOfFile = 0;


	return idx;
}


void *_sbrk(int incr)
{
	extern unsigned char _end;
	static unsigned char *heap = NULL;
	unsigned char *prev_heap;

	if (heap == NULL)
		heap = (unsigned char *)&_end;

	prev_heap = heap;

	heap += incr;

	return (void*) prev_heap;
}


int _stat(const char *file, struct stat *st)
{
	st->st_mode = S_IFCHR;
	return 0;
}


clock_t _times(struct tms *buf)
{
	errno = EACCES;
	return -1;
}


int _unlink(char *name)
{
	errno = ENOENT;
	return -1;
}


int _wait(int *status)
{
	errno = ECHILD;
	return -1;
}

void outbyte(char c)
{
	uint32_t tx_stat_reg;
	uint32_t tx_full;

	do	// wait if tx stack is full
	{
		tx_stat_reg = uart1->TX_STAT;
		tx_full = tx_stat_reg & 0x00000100;
	} while (tx_full);
	uart1->DATA = c;
}
 
int _write(int file, char *ptr, int len)
{
	for(int i = 0; i < len; i++)
		outbyte(ptr[i]);

	return len;
}

