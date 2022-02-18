#ifndef AIRISC_SYSCALLS_H_
#define AIRISC_SYSCALLS_H_

#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/times.h>
#include <sys/errno.h>

// #undef errno
// extern int errno;

extern void _exit(int i);
extern int _close(int file);
extern int execve(char *name, char **argv, char **env);
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
extern void outbyte(char payload);
extern int _write(int file, char *ptr, int len);

#endif /* AIRI5C_SYSCALLS_H_ */
