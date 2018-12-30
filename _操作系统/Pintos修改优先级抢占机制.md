# Pintos修改优先级抢占机制

### 代码修改

创建线程的时候，放入ready队列中，遍历所有线程，如果新线程的优先级比所以线程的优先级都高，则当前线程让出CPU

```
/* Add to run queue. */
thread_unblock(t);

if(priority>(thread_current()->priority)){
	thread_yield();
}

return tid;
```

更改当前线程优先级的时候，遍历所以线程找到最高优先级，如果新优先级小于最高优先级，则当前线程让出CPU

```
void
thread_set_priority(int new_priority)
{
	thread_current()->priority = new_priority;
	struct list_elem* e;
	e = list_begin(&ready_list);
	if(new_priority<(list_entry(e, struct thread, elem))->priority){
		thread_yield();
	}
}
```

至此，该部分完成了。

### 传送门

开源学习地址：
https://github.com/Wsine/pintos-ubuntu

这部分的Commit：
https://github.com/Wsine/pintos-ubuntu/tree/98c2596dad597b56c78657798ee31c4ec5b61518