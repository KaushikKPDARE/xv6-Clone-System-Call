#include "types.h"
#include "user.h"
#include "x86.h"
#include "threadlib.h"

void mutex_init(mutex_t *m) {
  // 0 indicates that lock is available, 1 that it is held by a thread
  m->flag = 0;
}

void mutex_lock(mutex_t *m)
{
  while (xchg(&m->flag, 1) == 1); // spin-wait (do nothing)
}

void mutex_unlock(mutex_t *m)
{
  m->flag = 0;
} 

/*int thread_create( void *(*start_routine)(void*), void *arg)
{
  void *sp = malloc(1024);
  int pid = thread(sp);
  if(!pid) (*start_routine)(arg);
  else return pid;
}*/

int thread_create(void(*child)(void*), void *arg_ptr)
{
	void *stack = malloc(4096);
	int clone_pid = clone(child, arg_ptr, stack);
	return clone_pid;
}

int thread_join(void)
{
    void *join_s;
    int join_pid = join(&join_s);
    return join_pid;
} 