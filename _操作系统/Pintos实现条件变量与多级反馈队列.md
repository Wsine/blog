# Pintos实现条件变量与多级反馈队列

因为原来pintos的初始仅仅是留下了一些空函数，并没有任何实现，因此不可能通过这些test 。需要根据官方文档，自己实现后才能通过。

而fair的两个test能通过，是因为原来的get_nice函数都是统一返回0，所有线程都得到相同的nice值，因此恰好满足了fair这个test的目的，所以原本就能通过。

本次部分需要参考的官方文档：
http://www.ccs.neu.edu/home/amislove/teaching/cs5600/fall10/pintos/pintos_7.html

### 代码修改

首先这次的load_average需要用到浮点数运行，而pintos是不支持double类型的运行的，只能通过整形 使用17.14格式，17位整数，14位小数，整型左移14位即为浮点型 这种方法模拟浮点数运算。官方文档说明如下：

> The following table summarizes how fixed-point arithmetic operations can be implemented in C. In the table, x and y are fixed-point numbers, n is an integer, fixed-point numbers are in signed p.q format where p + q = 31, and f is 1 << q:

![fixpoint](http://images0.cnblogs.com/blog2015/701997/201507/221544160539540.png)

根据官方文档的说明，我的实现方法是位运算模拟浮点数运算：

```
typedef int64_t fixed_t;

#define SHIFT_AMOUNT 14
#define INT2FLOAT(n) ((fixed_t)(n << SHIFT_AMOUNT))
#define FLOAT2INTPART(x) (x >> SHIFT_AMOUNT)
#define FLOAT2INTNEAR(x) (x >= 0 ? ((x + (1 << (SHIFT_AMOUNT - 1))) >> SHIFT_AMOUNT) : ((x - (1 << SHIFT_AMOUNT)) >> SHIFT_AMOUNT))
#define FLOATADDFLOAT(x, y) (x + y)
#define FLOATSUBFLOAT(x, y) (x - y)
#define FLOATADDINT(x, n) (x + (n << SHIFT_AMOUNT))
#define FLOATSUBINT(x, n) (x - (n << SHIFT_AMOUNT))
#define FLOATMULFLOAT(x, y) ((((int64_t)x) * y) >> SHIFT_AMOUNT)
#define FLOATMULINT(x, n) (x * n)
#define FLOATDIVFLOAT(x, y) ((((int64_t)x) << SHIFT_AMOUNT) / y)
#define FLOATDIVINT(x, n) (x / n)
```

官方文档的说明：

![state](http://images0.cnblogs.com/blog2015/701997/201507/221544496934029.png)

得到了关于priority 、recent_cpu 、load_avg的计算公式
具体实现：

```
/* Sets the current thread's nice value to NICE. */
void
thread_set_nice(int nice)
{
	//thread_current()->nice = nice;
	struct thread* current_thread = thread_current();
	current_thread->nice = nice;
	renew_priority(current_thread);
	//就绪队列中如果优先级大于当前线程则允许发生抢占
	if(list_entry(list_begin(&ready_list), struct thread, elem)->priority > thread_get_priority()){
		thread_yield();
	}
}

/* Returns the current thread's nice value. */
int
thread_get_nice(void)
{
	return thread_current()->nice;
}

/* Returns 100 times the system load average. */
int
thread_get_load_avg(void)
{
	return FLOAT2INTNEAR(FLOATMULINT(load_avg, 100));
}

/* Returns 100 times the current thread's recent_cpu value. */
int
thread_get_recent_cpu(void)
{
	return FLOAT2INTNEAR(FLOATMULINT(thread_current()->recent_cpu, 100));
}
```

在thread_tick函数里面，根据说明，系统每隔4s会更新全部线程的优先级，每隔100s会更新load_average和近期占用cpu的情况。

```
if(thread_mlfqs){
	/* 多级反馈队列情况需要recent_cpu + 1 */
	if(t != idle_thread)
		t->recent_cpu = FLOATADDINT(t->recent_cpu, 1);
	/* 每 100 个 timer_ticks(1 s)  更新一次系统的 load_avg */
	if(timer_ticks() % 100 == 0){
		renew_load_avg();
		thread_all_renew();//load_avg变化, recent_cpu也需要全变化
	}
	/* 每 4 个 timer_ticks 更新一次优先级 */
	if(timer_ticks() % 4 == 0){
		renew_all_priority();
	}
}
```

具体函数实现：

```
/* 获得当前就绪队列的大小，空闲线程除外 */
int64_t
get_ready_threads(){
	int64_t num_ready_threads = list_size(&ready_list);
	if(thread_current() != idle_thread)
		num_ready_threads++;
	return num_ready_threads;
}

/* 更新单个线程的优先级 */
void
renew_priority(struct thread* t){
	/* priority = PRI_MAX - (recent_cpu / 4) - (nice * 2) */
	t->priority = PRI_MAX - FLOAT2INTPART(FLOATDIVINT(t->recent_cpu, 4)) - (t->nice * 2);
	if(t->priority > PRI_MAX)
		t->priority = PRI_MAX;
	else if(t->priority < PRI_MIN)
		t->priority = PRI_MIN;
}

/* 计算并更新recent_cpu的值 */
void
renew_recent_cpu(struct thread* t){
	/* recent_cpu = (2*load_avg)/(2*load_avg + 1) * recent_cpu + nice */
	int64_t new_recent_cpu = FLOATDIVFLOAT(FLOATMULINT(load_avg, 2), FLOATADDINT(FLOATMULINT(load_avg, 2), 1));
	new_recent_cpu = FLOATADDINT(FLOATMULFLOAT(new_recent_cpu, t->recent_cpu), t->nice);

	t->recent_cpu = new_recent_cpu;
}

/* 计算并更新load_avg的值 */
void
renew_load_avg(void){
	/* load_avg = (59/60)*load_avg + (1/60)*ready_threads */
	int64_t new_load_avg_left = FLOATDIVINT(FLOATMULINT(load_avg, 59), 60);
	int64_t new_load_avg_right = FLOATDIVINT(INT2FLOAT(get_ready_threads()), 60);
	load_avg = FLOATADDFLOAT(new_load_avg_left, new_load_avg_right);
}

/* 更新全部线程的优先级 */
void
renew_all_priority(){
	struct list_elem* e;
	for(e = list_begin(&all_list); e != list_end(&all_list); e = list_next(e)){
		renew_priority(list_entry(e, struct thread, allelem));
	}
	list_sort(&ready_list, cmp_priority, NULL);
}

/* 更新全部的线程的recent_cpu值 */
void
thread_all_renew(void){
	struct list_elem* e;
	for(e = list_begin(&all_list); e != list_end(&all_list); e = list_next(e)){
		renew_recent_cpu(list_entry(e, struct thread, allelem));
	}
}
```

在thread.c文件里面，需要加上load_avg的定义，以及在thread的结构体上面添加成员变量，并初始化

```
/* The loading average of the system */
int64_t load_avg;

int nice;
int64_t recent_cpu;
```

初始化在timer_tick函数一开始为0，因此%100==0即可以自动初始化，可以不需要自己手动初始化

信号量的实现，修改信号量的等待队列为优先级队列，并设置信号量的优先级。当发出信号量的时候，可能需要让出CPU。这里的实现为强制让出CPU，如当前线程为优先级最高，则仍然是自己取回CPU。

```
void
cond_wait (struct condition *cond, struct lock *lock) 
{
	struct semaphore_elem waiter;

	ASSERT (cond != NULL);
	ASSERT (lock != NULL);
	ASSERT (!intr_context ());
	ASSERT (lock_held_by_current_thread (lock));
	
	sema_init (&waiter.semaphore, 0);
	/* 信号量的优先级为当前线程的优先级 */
	waiter.semaphore.lock_priority = thread_current() -> priority;
	//list_push_back (&cond->waiters, &waiter.elem);
	/* 信号量等待队列为优先队列 */
	list_insert_ordered(&cond->waiters, &waiter.elem, cmp_priority_sema_elem, NULL);
	lock_release (lock);
	sema_down (&waiter.semaphore);
	lock_acquire (lock);
}

void
cond_signal (struct condition *cond, struct lock *lock UNUSED) 
{
	ASSERT (cond != NULL);
	ASSERT (lock != NULL);
	ASSERT (!intr_context ());
	ASSERT (lock_held_by_current_thread (lock));

	if (!list_empty (&cond->waiters)) 
		sema_up (&list_entry (list_pop_front (&cond->waiters),
													struct semaphore_elem, elem)->semaphore);
	thread_yield();
}
```

由于多级反馈队列的CPU调度方案和优先级＋轮转法的调度机制冲突，因此填上以前挖的坑，需要修改的函数共有：
void lock_acquire (struct lock *lock) ; 
void lock_release (struct lock *lock)
void thread_tick (void);
tid_t thread_create (const char *name, int priority, thread_func *function, void *aux);
void thread_set_priority_donate(struct thread * cur, int new_priority, bool is_donate);
static void init_thread (struct thread *t, const char *name, int priority);
由于修改的地方比较多，且修改方式只是添加判断语句thread_mlfqs，这里就不截图说明了

至此，该部分完成了。

### 传送门

开源学习地址：
https://github.com/Wsine/pintos-ubuntu

这部分的Commit：
https://github.com/Wsine/pintos-ubuntu/tree/eb0d7b00a7c8798e447e826803e2cce51f470750