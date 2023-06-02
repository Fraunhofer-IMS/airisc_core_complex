//
// Copyright 2022 FRAUNHOFER INSTITUTE OF MICROELECTRONIC CIRCUITS AND SYSTEMS (IMS), DUISBURG, GERMANY.
// --- All rights reserved --- 
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
// Licensed under the Solderpad Hardware License v 2.1 (the "License");
// you may not use this file except in compliance with the License, or, at your option, the Apache License version 2.0.
// You may obtain a copy of the License at
// https://solderpad.org/licenses/SHL-2.1/
// Unless required by applicable law or agreed to in writing, any work distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and limitations under the License.
//

#ifndef AIRISC_SYSCALLS_H_
#define AIRISC_SYSCALLS_H_

#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/times.h>
#include <sys/errno.h>
#include <unistd.h>

#undef errno
extern int errno;

extern void _exit(int i);
extern int _close(int file);
extern int _execve(char *name, char **argv, char **env);
extern int _fork();
extern int _fstat(int file, struct stat *st);
extern int _getpid();
extern int _isatty(int file);
extern int _kill(int pid, int sig);
extern int _link(char *old, char *newp);
extern int _lseek(int file, int ptr, int dir);
extern int _open(const char *name, int flags, ...);
extern int _read(int file, char *ptr, int len);
extern void *_sbrk(int incr);
extern int _stat(const char *file, struct stat *st);
extern clock_t _times(struct tms *buf);
extern int _unlink(char *name);
extern int _wait(int *status);
extern int _write(int file, char *ptr, int len);

#endif /* AIRI5C_SYSCALLS_H_ */

