# C++深究

### 函数指针

```cpp
double pam(int, double); // prototype
double (*pf)(int, double); // declare function pointer
pf = pam; // pf now points to the pam() function
double y = (*pf)(1, 5); // call pam() using pointer pf
```

### 内联函数

适用范围：不是递归调用的函数；函数多次被调用；

```cpp
inline double square(double x) {
	return x * x;
}
```

### 函数模板

```
// non template function prototype
void Swap(job &a, job &b);
// template prototype
temple<class T>
void Swap(T &a, T &b);
// explicit specialization for the job type
template<> void Swap<job>(job &a, job &b);
```

### 关键字decltype

```
int x;	double y;
decltype(x + y) xpy; // make xpy the same type as x + y
```

### 关键字explicit

作用：防止隐式转换

```
class A {
private:
	string s;
public:
	A(string _s = "") : s(_s) {}
	int compare(const A& other);
};

class B {
private:
	string s;
public:
	explicit B(string _s = "") : s(_s) {}
	int compare(const B& other);
};

int main() {
	A a;
	a.compare("Valid"); // Is valid to do that
	B b;
	b.compare("InValid"); // Is invalid to do that
	return 0;
}
```

### 关键字auto

作用：自动推导变量类型

```
vector<int> v;
auto it = v.begin();
```

### 运算符dynamic_cast

作用：判断指针pg的类型是否被安全地转换为Superb*。如果可以，运算符将返回对象的地址，否则返回一个空指针。

```cpp
class Superb : public Grand {...}
Grand *pg = new Grand;
Superb *pm = dynamic_cast<Superb*>(pg);
```

### 运算符typeid

作用：确定两个对象是否为同种类型

```
typeid(Grand) == typeid(*pg);
```

### 运算符const_cast

作用：删除const typename* 中的const，当且仅当指向的值的声明是非const的时候有效

```cpp
void change(const int *pt, int n) {
	int *pc = const_cast<int*>(pt);
	*pc += n;
}
int pop1 = 38383;
change(&pop1, -103); // valid
const int pop2 = 2000;
change(&pop2, -103); // invalid
```

### 运算符static_cast

作用：可隐式转换的时候才生效

```
High bar;
Low blow;
High *pb = static_cast<High*>(&blow); // valid
Low *pl = static_cast<Low*>(&bar); // valid
Pond *pmer  = static_cast<Pond*>(&blow); // invalid
```

### 运算符reinterpret_cast

作用：天生危险的类型转换

```
struct dat {short a, b};
long value = 0xaaaaaaaa;
dat *pd = reinterpret_cast<dat*>(&value); // valid
```

### 智能指针auto_ptr

作用：离开作用域的时候自动调用析构函数释放动态内存

```
void function() {
	auto_ptr<double> ap(new double);
	*ap = 2.333;
	return;
}
```

### 智能指针shared_ptr

作用：跟踪引用特定对象的智能指针数，当最后一个指针过期时，才调用delete

### 智能指针unique_ptr

作用：唯一所有权(ownship)，不允许智能指针直接拷贝赋值

### Lambda函数

作用：允许使用匿名函数
说明：&表示引用变量，=表示取值变量

```
[](int x) {return x % 3 == 0;}
bool f(int x) {return x % 3 == 0;}
[&count, =sock]() {count++;}
```

### 包装器function

作用：用作形式参数，作为一个function包装器对象

```
template<class T>
T use_f(T v, std::function<T(T)> f);

function<double(int, char)> f;
// 等价于
double f(int, char);
```

### 可变参数模板

作用：传递未知数量的参数

```
void print() {}

template<class T>
void print(T value) {
	std::cout << value << std::endl;
}

template<class T, class... Args>
void print(T value, Args... args) {
	std::cout << value << ", ";
	print(args...);
}
```