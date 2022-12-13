//
// Copyright 2022 FRAUNHOFER INSTITUTE OF MICROELECTRONIC CIRCUITS AND SYSTEMS (IMS), DUISBURG, GERMANY.
// --- All rights reserved --- 
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
// Licensed under the Solderpad Hardware License v 2.1 (the “License”);
// you may not use this file except in compliance with the License, or, at your option, the Apache License version 2.0.
// You may obtain a copy of the License at
// https://solderpad.org/licenses/SHL-2.1/
// Unless required by applicable law or agreed to in writing, any work distributed under the License is distributed on an “AS IS” BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and limitations under the License.
//
//
// airi5c_syscalls.c
//
//  Created on: 11.11.2019
//      Author: stanitzk
//
//  This is a non-reentrant implementation of the syscalls required by newlib.
//

#include <airisc.h>

// exit program
void _exit(int i)
{
	while (1);
}

// close file
int _close(int file)
{
	// there is no file system support, so a file can never be closed
	return -1;
}

// transfer control to a new process
int _execve(char *name, char **argv, char **env)
{
	// there is only 1 process supported, so it can never be switched to another process
	errno = ENOMEM;
	return -1;
}

// create new process
int _fork()
{
	// there is only 1 process supported, so a new process can never be created
	errno = EAGAIN;
	return -1;
}

// get status of a file
int _fstat(int file, struct stat *st)
{
	// the only files are stdout, stderr and stdin
	if ((file == STDOUT_FILENO) || (file == STDERR_FILENO) || (file == STDIN_FILENO)) {
		st->st_mode = S_IFCHR;
		return  0;
	}
	// return an error for other files
	errno = EBADF;
	return -1;
}

// get process id
int _getpid(void)
{
	// there is only 1 process supported, which is always returned
	return 1;
}

// check if a stream is a terminal
int _isatty(int file)
{
	if ((file == STDOUT_FILENO) || (file == STDERR_FILENO) || (file == STDIN_FILENO))
		return  1;

	errno = EBADF;
	return -1;
}

// send signal
int _kill(int pid, int sig)
{
	// there is only 1 process supported, so there are no other processes that signals can be sent to
	errno = EINVAL;
	return -1;
}

// rename file
int _link(char *old, char *newp)
{
	// there is no file system supported, so no file can be renamed
	errno = EMLINK;
	return -1;
}

// set file position
int _lseek(int file, int ptr, int dir)
{
	if ((file == STDOUT_FILENO) || (file == STDERR_FILENO))
		return  0;

	errno = EBADF;
	return -1;
}

// open file
int _open(const char *name, int flags, ...)
{
	// there is no file system supported, so no file can be opened
	errno = ENOSYS;
	return -1;
}

// read chars
int _read(int file, char *ptr, int len)
{
	// stdin is mapped to uart0
	if (file != STDIN_FILENO)
	{
		errno = EBADF;
		return  -1;
	}

	for (int i = 0; i < len; i++)
	{
		ptr[i] = uart_readByte(uart0);
		if (ptr[i] == '\r')
		{
			//ptr[i] = '\n';
			return i + 1;
		}
	}

	return len;
}

// allocate heap memory
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

// get file status
int _stat(const char *file, struct stat *st)
{
	// there is no file system supported, so a file status can never be obtained
	errno = EACCES;
	return -1;
}

// get process timing information
clock_t _times(struct tms *buf)
{
	// there is only 1 process supported, so there are no timing information of other processes
	errno = EACCES;
	return -1;
}

// remove file
int _unlink(char *name)
{
	// there is no file system supported, so there are no files to delete
	errno = ENOENT;
	return -1;
}

// wait for chhild process
int _wait(int *status)
{
	// there is only 1 process supported, so there are no other processes to wait for
	errno = ECHILD;
	return -1;
}

// write chars
int _write(int file, char *ptr, int len)
{
	// stdout and stderr are mapped to uart0
	if ((file != STDOUT_FILENO) && (file != STDERR_FILENO))
	{
		errno = EBADF;
		return  -1;
	}

	uart_writeData(uart0, (uint8_t*)ptr, len);
	return len;
}

