# Java实现Package编译和访问

**说明**
1. 所有文件都是使用UTF-8编码来写的，请不要用Windows记事本随便打开
2. Test.java文件中注释的方法说明了该类是不能访问其方法的

## 文件目录树

- bin
	- Test1.class
	- Test2.class
	- Test3.class
- classes
	- X
		- Y
			- A.class
			- B.class
- lib
	- E.jar
		- S
			- T
				- C.class
				- D.class
- src
	- A.java
	- B.java
	- C.java
	- D.java
	- Test1.java
	- Test2.java
	- Test3.java
- Makefile

## 代码一览

```java
/* A.java */
package X.Y;

import java.util.*;

public class A {

	public void sayPublic() {
		System.out.println("Hi, " + this.getClass() + ". (public)");
	}

	private void sayPrivate() {
		System.out.println("Hi, " + this.getClass() + ". (private)");
	}

	protected void sayProtected() {
		System.out.println("Hi, " + this.getClass() + ". (protected)");
	}

	void sayDefault() {
		System.out.println("Hi, " + this.getClass() + ". (default)");
	}
}
```

```java
/* B.java */
package X.Y;

import java.util.*;

public class B {

	public void sayPublic() {
		System.out.println("Hi, " + this.getClass() + ". (public)");
	}

	private void sayPrivate() {
		System.out.println("Hi, " + this.getClass() + ". (private)");
	}

	protected void sayProtected() {
		System.out.println("Hi, " + this.getClass() + ". (protected)");
	}

	void sayDefault() {
		System.out.println("Hi, " + this.getClass() + ". (default)");
	}
}
```

```java
/* C.java */
package S.T;

import java.util.*;

public class C {

	public void sayPublic() {
		System.out.println("Hi, " + this.getClass() + ". (public)");
	}

	private void sayPrivate() {
		System.out.println("Hi, " + this.getClass() + ". (private)");
	}

	protected void sayProtected() {
		System.out.println("Hi, " + this.getClass() + ". (protected)");
	}

	void sayDefault() {
		System.out.println("Hi, " + this.getClass() + ". (default)");
	}
}
```

```java
/* D.java */
package S.T;

import java.util.*;

public class D {

	public void sayPublic() {
		System.out.println("Hi, " + this.getClass() + ". (public)");
	}

	private void sayPrivate() {
		System.out.println("Hi, " + this.getClass() + ". (private)");
	}

	protected void sayProtected() {
		System.out.println("Hi, " + this.getClass() + ". (protected)");
	}

	void sayDefault() {
		System.out.println("Hi, " + this.getClass() + ". (default)");
	}
}
```

```java
/* Test1.java */
import java.util.*;
import X.Y.*;
import S.T.*;

class Test1 {
	public static void main(String[] args) {
		A a = new A();
		a.sayPublic();
		//a.sayPrivate();
		//a.sayProtected();
		//a.sayDefault();

		C c = new C();
		c.sayPublic();
		//c.sayPrivate();
		//c.sayProtected();
		//c.sayDefault();
	}
}
```

```java
/* Test2.java */
import java.util.*;
import X.Y.*;
import S.T.*;

class Test2 extends B {
	public static void main(String[] args) {
		Test2 test2 = new Test2();
		test2.sayPublic();
		//test2.sayPrivate();
		test2.sayProtected();
		//test2.sayDefault();
	}
}
```

```java
/* Test3.java */
import java.util.*;
import X.Y.*;
import S.T.*;

class Test3 extends D {
	public static void main(String[] args) {
		Test3 test3 = new Test3();
		test3.sayPublic();
		//test3.sayPrivate();
		test3.sayProtected();
		//test3.sayDefault();
	}
}
```

```makefile
/* Makefile */
target:
	javac -encoding utf-8 ./src/A.java -d ./classes
	javac -encoding utf-8 ./src/B.java -d ./classes
	javac -encoding utf-8 ./src/C.java -d .
	javac -encoding utf-8 ./src/D.java -d .
	jar cvf ./lib/E.jar ./S/*
	rm -rf ./S
	javac -encoding utf-8 -classpath "./lib/E.jar;./classes;" ./src/Test1.java -d ./bin
	javac -encoding utf-8 -classpath "./lib/E.jar;./classes;" ./src/Test2.java -d ./bin
	javac -encoding utf-8 -classpath "./lib/E.jar;./classes;" ./src/Test3.java -d ./bin

run-Test1:
	java -classpath "./bin;./lib/E.jar;./classes;" Test1

run-Test2:
	java -classpath "./bin;./lib/E.jar;./classes;" Test2

run-Test3:
	java -classpath "./bin;./lib/E.jar;./classes;" Test3

clean:
	rm -rf ./bin/*.class
	rm -rf ./classes/*
	rm -rf ./lib/*.jar
```

## 样例代码

传送门：[下载](http://pan.baidu.com/s/1eRqGf30)