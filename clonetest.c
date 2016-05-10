#include "types.h"
#include "user.h"
#include "threadlib.h"

int ppid;
int x = 0;
mutex_t lock;

void
child(void *arg_ptr) 
{
   int i;
   for(i=0;i<100000;i++)
 {
   mutex_lock(&lock);
   x++;
   mutex_unlock(&lock);
 }
   exit();
}

int 
main(int argc, char *argv[])
{
   printf(1, "clone test\n");
   ppid = getpid();
   
   int arg1 = 10, arg2 =20;
   //int thread_cnt = atoi(argv[1]);
   void *arg_ptr1  = &arg1;
   void *arg_ptr2  = &arg2;
     int c_pid  = thread_create(child,arg_ptr1);
     int c_pid1  = thread_create(child,arg_ptr2);
     int j_pid  = thread_join();
     int j_pid1  = thread_join();
     if(j_pid == c_pid){} else{kill(ppid); exit();}
     if(j_pid1 == c_pid1){} else{kill(ppid); exit();}
   printf(1,"The counter: %d\n",x);
   printf(1, "clone test OK\n");
   exit();
}