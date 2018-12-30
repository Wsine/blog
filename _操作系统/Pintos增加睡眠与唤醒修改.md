# Pintos增加睡眠与唤醒修改

原来的设计当中，进程进入休眠的时候，并没有释放CPU，而是一直占有着，直到睡眠时间流逝掉，又继续占用着CPU。假如遇到一些流氓进程，电脑就会卡死在这一进程当中。术语中叫做“忙等待”。
原本的唤醒机制中，并不是根据优先级进行唤醒的。而是直接加入到ready队列中，这样设计一旦高优先级的进程进入了waiting队列后回到ready队列的时候要重新排队等待CPU。造成了不合理，也就没办法过alarm-priority这个test。

### 代码修改

修改thread的结构，增加一个int tick_blocked成员变量，决定休眠的时间

```
struct thread
{
	/* Owned by thread.c. */
	tid_t tid;                          /* Thread identifier. */
	enum thread_status status;          /* Thread state. */
	char name[16];                      /* Name (for debugging purposes). */
	uint8_t *stack;                     /* Saved stack pointer. */
	int priority;                       /* Priority. */
	struct list_elem allelem;           /* List element for all threads list. */

	/* Shared between thread.c and synch.c. */
	struct list_elem elem;              /* List element. */

#ifdef USERPROG
	/* Owned by userprog/process.c. */
	uint32_t *pagedir;                  /* Page directory. */
#endif
	int tick_blocked;
	/* Owned by thread.c. */
	unsigned magic;                     /* Detects stack overflow. */
};
```

当新建一个thread的时候，初始化tick_blocked变量

```
/* Initialize thread. */
init_thread(t, name, priority);
tid = t->tid = allocate_tid();
t->tick_blocked = 0;
```

当进程进入休眠调用timer_sleep的时候，赋值tick_blocked变量，并block掉这个线程

```
void
timer_sleep(int64_t ticks)
{
	if(ticks <= 0)
		return;
	enum intr_level old_level = intr_disable();
	struct thread* curThread = thread_current();
	curThread->tick_blocked = ticks;
	thread_block();
	intr_set_level(old_level);
}
```

当系统中断调用timer_interrupt的时候，系统ticks增加，并检查所有休眠中的线程，tick_blocked-1，如果休眠时间为0，则unblocked这个进程

```
static void
timer_interrupt(struct intr_frame *args UNUSED)
{
	ticks++;
	enum intr_level old_level = intr_disable();
	thread_foreach(checkInvoke, NULL);
	intr_set_level(old_level);
	thread_tick();
}

void
checkInvoke(struct thread* t, void* aux UNUSED){
	if(t->status == THREAD_BLOCKED && t->tick_blocked > 0){
		t->tick_blocked--;
		if(t->tick_blocked == 0){
			thread_unblock(t);
		}
	}
}
```

当线程从休眠状态变回就绪状态的时候以及系统中断发生当前进程让出CPU的时候，unblocked函数和yield函数根据进程优先级插入ready队列中

```
static bool
priority_less(const struct list_elem *a, const struct list_elem *b, void *aux){
	struct thread *a_thread, *b_thread;
	a_thread = list_entry(a, struct thread, elem);
	b_thread = list_entry(b, struct thread, elem);
	return (a_thread->priority > b_thread->priority);
}
```

这个是优先级的比较实现，和书本的一致，priority越大，优先级越高

```
void
thread_unblock(struct thread *t)
{
	enum intr_level old_level;

	ASSERT(is_thread(t));

	old_level = intr_disable();
	ASSERT(t->status == THREAD_BLOCKED);
	//list_push_back (&ready_list, &t->elem);
	list_insert_ordered(&ready_list, &t->elem, priority_less, NULL);
	t->status = THREAD_READY;
	intr_set_level(old_level);
}

void
thread_yield(void)
{
	struct thread *cur = thread_current();
	enum intr_level old_level;

	ASSERT(!intr_context());

	old_level = intr_disable();
	if(cur != idle_thread)
		//list_push_back (&ready_list, &cur->elem);
		list_insert_ordered(&ready_list, &cur->elem, priority_less, NULL);
	cur->status = THREAD_READY;
	schedule();
	intr_set_level(old_level);
}
```

list_insert_ordered函数是本来就封装好的，仅仅是自己写了一个比较函数。

至此，该部分完成了。

### 传送门

开源学习地址：
https://github.com/Wsine/pintos-ubuntu

这部分的Commit：
https://github.com/Wsine/pintos-ubuntu/tree/ee20b6bffc0e93b130d8d8befe25e035bace448d