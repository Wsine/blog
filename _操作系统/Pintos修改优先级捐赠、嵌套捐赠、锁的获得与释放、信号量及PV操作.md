# Pintos修改优先级捐赠、嵌套捐赠、锁的获得与释放、信号量及PV操作

原有的优先级更改的情况下面没有考虑到捐赠的情况，仅仅只是改变更改了当前线程的优先级，更别说恢复原本优先级了，所以不能通过任何有关捐赠的test。

原有的获得互斥锁和释放互斥锁的时候，仅仅是对信号量做一个简单的PV操作，获得互斥锁的时候应当考虑该锁当前是否被别的线程持有和优先级如何是否该被阻塞，释放互斥锁的时候也差不多同理，因此不能通过test。

原有的信号量操作仅仅是简单的加减，没有考虑信号量在不同值的情况下阻塞和唤醒的情况设计，因此不能通过test。

信号量的等待队列理应设计为优先队列。
释放锁时应该运行发生优先级抢占行为。


### 代码修改

给thread的定义增加了一些成员变量，并初始化

```
// 增加定义
int tick_blocked;
int old_priority;
struct list locks;
bool donated;
struct lock *blocked;

// 初始化
t->priority = t->old_priority = priority;
t->donated = false;
t->blocked = NULL;
list_init(&t->locks);
```

给lock增加成员变量，并初始化

```
/* Lock. */
struct lock
{
	struct thread *holder;      /* Thread holding lock (for debugging). */
	struct semaphore semaphore; /* Binary semaphore controlling access. */
	struct list_elem holder_elem;
	int lock_priority;
};

void
lock_init (struct lock *lock)
{
	ASSERT (lock != NULL);

	lock->holder = NULL;
	sema_init (&lock->semaphore, 1);

	lock->lock_priority = -1;
}
```

一开始的时候随便给lock_priority设置一个最低的优先级即可，只要不影响代码正确运行即可

**重新设计优先级更改的情况**

单独捐赠的情况：
当高优先级线程因为低优先级线程占用资源而阻塞时，应将低优先级线程的优先级提升到等待它所占有的资源的最高优先级线程的优先级。即将优先级较高的线程的优先级 donate 给持有资源的优先级的进程，让其先执行。

![single](http://images0.cnblogs.com/blog2015/701997/201507/221139209742870.png)

多重捐赠的情况：
struct thread 中的 list locks, 还有 struct locks 中的 lock_priority，两者配合使用,应对 multiple-donate 的情况。由于每次 donate 的时候都是因为优先级高的一个进程需要申请一个握在优先级比较低的线程手中的,因此锁在涉及到 priority-donate 的时候维护一个lock_priority,记录获得这个锁的线程此时的优先级,因为存在 multiple-donate,线程可能会接受几个不同的优先级,因此需要在锁中,而不是在线程的结构中维护这样一个信息,以在释放锁,undonate 的时候能够将线程优先级恢复到正确的值。

![multi](http://images0.cnblogs.com/blog2015/701997/201507/221139363188014.png)

嵌套捐赠的情况：
通过检测被捐赠的线程是否已经获得了所需要的全部锁来判断是否出现嵌套捐赠的情况，如是则设置好参数来进行下一轮的优先级捐赠。和情况一差不多，也就是多捐赠一次，知道被捐赠线程获得了所需要的全部的锁。

![nest](http://images0.cnblogs.com/blog2015/701997/201507/221139553496201.png)

```
void
thread_set_priority(int new_priority)
{
	//重定向thread_set_priority函数
	thread_set_priority_fixed(thread_current(), new_priority, true);
}
```

重定向原本的优先级更改函数，一个参数已经不能满足这次的实验需求了

```
void
thread_set_priority_fixed(struct thread *current_thread, int new_priority, bool nest){
	enum intr_level old_level;
	old_level = intr_disable();
	//没被捐赠过的同时改变两个变量
	if(current_thread->donated == false){
		current_thread->priority = current_thread->old_priority = new_priority;
	}
	//正在被捐赠
	else if(nest){
		//捐赠过的，且新优先级比当前优先级还小，更新旧优先级
		if(current_thread->priority > new_priority){
			current_thread->old_priority = new_priority;
		}
		//捐赠过的，更新当前优先级
		else{
			current_thread->priority = new_priority;
		}
	}
	//捐赠过的但取消捐赠状态，更新当前优先级
	else{
		current_thread->priority = new_priority;
	}
	//就绪队列中优先级比新设置的优先级低，则让出CPU
	if(list_entry(list_begin(&ready_list), struct thread, elem)->priority > new_priority){
		thread_yield();
	}
	intr_set_level(old_level);
}
```

其实一共就4种情况：
没被捐赠过的，直接更新priority和old_priority两个变量
正在被捐赠需要改优先级的且新优先级被当前优先级更低，更新old_priority
正在被捐赠需要改优先级的且新优先级被当前优先级高，更新priority
取消捐赠状态，恢复成旧优先级，更新priority

最后还有加一个优先级抢占的行为。

**获得互斥锁的更改**

和上述的表达一致，主要在于获得互斥锁的时候判断是否需要产生捐赠，能否获得互斥锁，以及捐赠结束后更新锁的链表

```
void
lock_acquire (struct lock *lock)
{
	ASSERT (lock != NULL);
	ASSERT (!intr_context ());
	ASSERT (!lock_held_by_current_thread (lock));

	enum intr_level old_level;
	old_level = intr_disable();
	struct thread* current_thread = thread_current();
	struct thread* lockholder_thread = lock->holder;
	struct lock* another;
	//假设当前线程会被该锁阻塞，如不会后面有解锁操作
	current_thread->blocked = another = lock;
	//该锁当前被别的线程持有且优先级比当前线程低
	while(lockholder_thread != NULL && lockholder_thread->priority < current_thread->priority){
		//持有锁的线程需要被捐赠以提高优先级
		lockholder_thread->donated = true;
		//把当前线程的优先级捐赠给锁的持有者
		thread_set_priority_fixed(lockholder_thread, current_thread->priority, true);
		//捐赠结束后修改锁的优先级
		if(another->lock_priority < current_thread->priority){
			another->lock_priority = current_thread->priority;
			list_remove(&another->holder_elem);
			list_insert_ordered(&lockholder_thread->locks, &another->holder_elem, cmp_priority2, NULL);
		}
		//假如被捐赠的线程还缺少锁，则更新下一轮的参数，嵌套捐赠
		if(lockholder_thread->status == THREAD_BLOCKED && lockholder_thread->blocked != NULL){
			another = lockholder_thread->blocked;
			lockholder_thread = lockholder_thread->blocked->holder;
		}
		//否则跳出循环，捐赠结束
		else{
			break;
		}
	}
	//进行P操作，直到拿到锁
	sema_down (&lock->semaphore);
	lock->holder = current_thread;
	lock->lock_priority = current_thread->priority;
	current_thread->blocked = NULL;
	//更新当前线程获得的锁的链表
	list_insert_ordered(&lock->holder->locks, &lock->holder_elem, cmp_priority2, NULL);
	intr_set_level(old_level);
}
```

注意一点的是，锁的记录链表是用优先队列来实现的，而不是使用普通队列。

**释放互斥锁的操作**

释放锁后主要有三种情况：
该线程已经没有锁了：恢复捐赠前的优先级
还有其它的锁：恢复成其它锁的最高优先级
因为最后的锁而没有锁了，恢复捐赠前的优先级

```
void
lock_release (struct lock *lock) 
{
	struct thread * current_thread = thread_current();
	ASSERT(current_thread->blocked == NULL);

	ASSERT (lock != NULL);
	ASSERT (lock_held_by_current_thread (lock));

	enum intr_level old_level;
	old_level = intr_disable();
	struct list_elem *l;
	struct lock *another;
	//释放锁的操作
	lock->holder = NULL;
	list_remove(&lock->holder_elem);
	lock->lock_priority = PRI_MIN - 1;
	sema_up (&lock->semaphore);
	//处理该线程拥有的其余的锁
	if(list_empty(&current_thread->locks)){
		//没有锁则恢复捐赠前的优先级
		current_thread->donated = false;
		thread_set_priority(current_thread->old_priority);
	}
	else{
		//还有其它的锁的情况
		l = list_front(&current_thread->locks);
		another = list_entry(l, struct lock, holder_elem);
		if(another->lock_priority != PRI_MIN - 1){
			//该情况锁的优先级即为当前线程得到锁时的优先级
			thread_set_priority_fixed(current_thread, another->lock_priority, false);
		}
		else{
			//该情况恢复原本的优先级
			thread_set_priority(current_thread->old_priority);
		}
	}
	intr_set_level(old_level);
}
```

这里恢复线程的优先级的时候，是通过set_priority函数发生抢占行为的，和获得锁的操作有所不一样。

**信号量的P操作**

这里主要增加一个能否得到信号量，不能则应该被阻塞，加这个操作就行了

```
void
sema_down (struct semaphore *sema) 
{
	enum intr_level old_level;

	ASSERT (sema != NULL);
	ASSERT (!intr_context ());

	old_level = intr_disable ();
	//线程一直等待其他线程产生V操作
	while (sema->value == 0) 
	{
		//当前线程一定不在就绪队列中，不会重复插入
		list_insert_ordered(&sema->waiters, &thread_current()->elem, cmp_priority, NULL);
		thread_block ();
	}
	sema->value--;
	intr_set_level (old_level);
}
```

**信号量的V操作**

V操作需要选择一个等待线程来唤醒，如果唤醒的线程比当前线程优先级更高的话，则允许发生抢占行为

```
void
sema_up (struct semaphore *sema) 
{
	enum intr_level old_level;
	struct thread* current_thread;
	struct thread* wake_up;

	ASSERT (sema != NULL);

	old_level = intr_disable ();
	wake_up = NULL;//即将被唤醒的线程
	current_thread = thread_current();
	//从信号量的waiter队列中选一个出来唤醒
	if (!list_empty (&sema->waiters)){
		//避免多重锁的时候队列变成无序，先排序
		list_sort(&sema->waiters, cmp_priority, NULL);
		wake_up = list_entry(list_pop_front(&sema->waiters), struct thread, elem);
		thread_unblock(wake_up);
		//thread_unblock (list_entry (list_pop_front (&sema->waiters), struct thread, elem));
	}
	//信号量V操作
	sema->value++;
	//多重锁的时候，捐赠后的被唤醒线程优先级比当前线程高时，当前线程让出CPU
	if(wake_up != NULL && wake_up->priority > current_thread->priority){
		thread_yield();
	}

	intr_set_level (old_level);
}
```

这里要多个锁和多个信号量的情况，会造成等待队列无序（其实应该也不会，哪怕会，加上也不会错，反正已经有序了排序也是一瞬间的事情=。=）。

至此，该部分完成了。

### 传送门

开源学习地址：
https://github.com/Wsine/pintos-ubuntu

这部分的Commit：
https://github.com/Wsine/pintos-ubuntu/tree/a472c6255de5874a618b337d729736c56142ee1a