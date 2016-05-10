int thread_create( void (*start_routine)(void*), void *arg);
int thread_join(void);
 
typedef struct mutex{
  uint flag;
} mutex_t;

void mutex_init(mutex_t *m);
void mutex_lock(mutex_t *m);
void mutex_unlock(mutex_t *m); 
