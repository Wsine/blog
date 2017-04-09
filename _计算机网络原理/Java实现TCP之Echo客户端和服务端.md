#Java实现TCP之Echo客户端和服务端

##代码内容

- 采用TCP协议编写服务器端代码(端口任意)
- 编写客户机的代码访问该端口
- 客户机按行输入
- 服务器将收到的字符流和接收到的时间输出在服务器console
- 原样返回给客户机在客户机console显示出来

##代码实现

```java
/* TCPEchoClient.java */
import java.io.*;
import java.net.*;

public class TCPEchoClient {
	public final static String serverIP = "localhost";
	public final static int serverPort = 4347;
	public static String userName = null;

	public static void main(String[] args) {
		Socket client = null;
		BufferedReader sin = null;
		Writer cout = null;
		BufferedReader cin = null;
		try {
			/* 建立Socket连接 */
			client = new Socket(serverIP, serverPort);
			/* 从用户键盘读取输入 */
			sin = new BufferedReader(new InputStreamReader(System.in));
			/* 写入数据到Socket中 */
			cout = new OutputStreamWriter(client.getOutputStream());
			/* 从Socket读取输入 */
			cin = new BufferedReader(new InputStreamReader(client.getInputStream()));
			/* 登陆 */
			System.out.print("Please login: ");
			userName = sin.readLine();
			/* 获取用户输入的一行，exit则退出 */
			String line;
			System.out.print("> ");
			line = sin.readLine();
			while (!line.equals("exit")) {
				/* 将用户输入发送给Server */
				cout.write("[" + userName + "]: " + line + "\n");
				/* 刷新输出流使Server马上收到用户输入 */
				cout.flush();
				/* 从Server读入输入并显示 */
				System.out.println(cin.readLine());
				/* 读取用户下一行输入 */
				System.out.print("> ");
				line = sin.readLine();
			}
		} catch (UnknownHostException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			/* 安全关闭输入输出和Socket */
			try {
				cout.close();
				cin.close();
				client.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
}
```

```java
/* TCPEchoServer.java */
import java.io.*;
import java.net.*;
import java.util.Date;
import java.lang.System;
import java.lang.Thread;
import java.lang.Runnable;

public class TCPEchoServer {
	public final static int serverPort = 4347;
	public static int count = 0;

	@SuppressWarnings({"resource"})
	public static void main(String[] args) {
		ServerSocket server = null;
		Socket connection = null;
		try {
			/* 创建一个ServerSocket监听端口 */
			server = new ServerSocket(serverPort);
			System.out.println("Server start running...");
			while (true) {
				/* accept()阻塞等待客户返回Socket */
				connection = server.accept();
				System.out.println("Socket " + count + " established...");
				/* 创建一个线程与该用户交互 */
				Thread workThread = new Thread(new Handler(connection, count++));
				workThread.start();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public static class Handler implements Runnable {
		private Socket socket = null;
		private int index = -1;
		
		public Handler(Socket _socket, int _index) {
			this.socket = _socket;
			this.index = _index;
		}

		public void run() {
			BufferedReader cin = null;
			Writer cout = null;
			try {
				/* 从Socket读取输入 */
				cin = new BufferedReader(new InputStreamReader(socket.getInputStream()));
				/* 写入数据到Socket中 */
				cout = new OutputStreamWriter(socket.getOutputStream());
				String line;
				/* 当Socket连接正常时 */
				while (socket.isConnected() && !socket.isClosed()) {
					/* 当阻塞成功获取用户输入时 */
					line = cin.readLine();
					/* 获取当前系统时间 */
					Date currentTime = new Date();
					String echo = currentTime.toString().split(" ")[3] + " " + line;
					/* 打印系统日志记录用户输入 */
					System.out.println(echo);
					/* 发送数据给用户 */
					cout.write(echo + '\n');
					/* 刷新输出流使用户马上收到消息 */
					cout.flush();
				}
			} catch (SocketException e) {
				// do nothing
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				try {
					/* 安全关闭输入输出和Socket */
					if (socket != null) {
						cout.close();
						cin.close();
						socket.close();
					}
				} catch (IOException e) {
					e.printStackTrace();
				}
				System.out.println("Socket " + index + " exit...");
			}
		}
	}
}
```

```makefile
/* Makefile */
target:
	javac -encoding utf-8 TCPEchoClient.java
	javac -encoding utf-8 TCPEchoServer.java
	javac -encoding utf-8

run-TCPEchoClient:
	java TCPEchoClient

run-TCPEchoServer:
	java TCPEchoServer

clean:
	rm *.class
```

##运行截图

![](http://images2015.cnblogs.com/blog/701997/201602/701997-20160204145755772-872748234.png)

##问题解决方案

1.	中文编码问题：在代码使用UTF-8编码并且编译选项添加UTF8参数的话，不需要在代码中声明为UTF8编码，使用了反而会出错，亲测。
2.	面向连接的传输TCP：由于需要面向连接，因此一个服务端需要和多个客户端进行通信，这就需要在服务端使用多线程技术，一个客户端分配一个线程，分别处理不同客户端的通信。
3.	面向无连接的传输UDP：由于不需要连接，也不在意可靠传输，因此当客户端发送了一个数据包之后，若一定时间内没有返回内容，可以认为传输失败，让用户接着输入下一个内容。
4.	关于TCP的聊天室：在客户端中无法体现出一个聊天室的完成功能，但是服务端是体现出来了，如果需要在客户端也有这个体现，需要做线程之间的通信，想想还是太麻烦我就没做了。
5.	还有一点是面向连接的程序，不应该每发送一次就连接一次再断开连接，这样子的通信效率太低，而是应该等到客户端退出后再断开连接，这点已实现。

##样例代码下载

传送门：[下载](http://pan.baidu.com/s/1geubvNX)