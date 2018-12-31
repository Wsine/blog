# Java实现UDP之Echo客户端和服务端

## 代码内容

- 采用UDP协议编写服务器端代码(端口任意)
- 编写客户机的代码访问该端口
- 客户机按行输入
- 服务器将收到的字符流和接收到的时间输出在服务器console
- 原样返回给客户机在客户机console显示出来

## 代码实现

```java
/* UDPEchoClient.java */
import java.io.*;
import java.net.*;

public class UDPEchoClient {
	public final static String serverIP = "localhost";
	public final static int serverPort = 13;
	public static String userName = null;

	@SuppressWarnings("resource")
	public static void main(String[] args) {
		DatagramSocket client = null;
		try {
			/* 获取服务器地址 */
			InetAddress server = InetAddress.getByName(serverIP);
			/* 创建客户端DatagramSocket */
			client = new DatagramSocket();
			/* 从用户键盘读取输入 */
			BufferedReader sin = new BufferedReader(new InputStreamReader(System.in));
			/* 登陆 */
			System.out.print("Please Login: ");
			userName = sin.readLine();
			/* 获取用户输入的一行，exit则退出 */
			String line;
			System.out.print("> ");
			line = sin.readLine();
			while (!line.equals("exit")) {
				line = "[" + userName + "]: " + line;
				/* 从用户输入转化为byte */
				byte[] data = line.getBytes("utf-8");
				/* 将byte内容转化为UDP数据包 */
				DatagramPacket sendPacket = new DatagramPacket(data, data.length, server, serverPort);
				/* UPD发送数据包 */
				client.send(sendPacket);
				/* 定义接收byte空间 */
				byte[] buffer = new byte[8192];
				/* 将UDP数据包内容保存在byte中 */
				DatagramPacket receivePacket = new DatagramPacket(buffer, buffer.length);
				/* UDP接收数据包 */
				client.receive(receivePacket);
				/* 输出服务器返回的内容 */
				System.out.println(new String(receivePacket.getData(), receivePacket.getOffset(), 
												receivePacket.getLength(), "utf-8"));
				/* 读取用户下一行输入 */
				System.out.print("> ");
				line = sin.readLine();
			}
		} catch (SocketException e) {
			e.printStackTrace();
		} catch (UnknownHostException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			/* 安全关闭Socket */
			try {
				if (client != null) {
					client.close();
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
}
```

```java
/* UDPEchoServer.java */
import java.io.*;
import java.net.*;
import java.util.Date;

public class UDPEchoServer {
	public final static int serverPort = 13;

	@SuppressWarnings({ "resource", "static-access", "unused" })
	public static void main(String[] args) {
		DatagramSocket server = null;
		try {
			/* 创建服务端DatagramSocket */
			server = new DatagramSocket(serverPort);
			System.out.println("Server start running...");
			while (true) {
				/* 定义接收byte空间 */
				byte[] buffer = new byte[8192];
				/* 将UDP数据包内容保存在byte中 */
				DatagramPacket receivePacket = new DatagramPacket(buffer, buffer.length);
				/* UDP接收数据包 */
				server.receive(receivePacket);
				/* 获取当前系统时间 */
				Date currentTime = new Date();
				/* 处理客户端的输入 */
				String echo = new String(receivePacket.getData(), receivePacket.getOffset(), 
											receivePacket.getLength(), "utf-8");
				echo = currentTime.toString().split(" ")[3] + " " + echo;
				/* 打印系统日志记录用户输入 */
				System.out.println(echo);
				/* 从客户端输入转化为byte */
				byte[] data = echo.getBytes("utf-8");
				/* 将byte内容转化为UDP数据包 */
				DatagramPacket sendPacket = new DatagramPacket(data, data.length, 
											receivePacket.getAddress(), receivePacket.getPort());
				/* UPD发送数据包 */
				server.send(sendPacket);
			}
		} catch (SocketException e) {
			e.printStackTrace();
		} catch (UnknownHostException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			/* 安全关闭Socket */
			try {
				if (server != null) {
					server.close();
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
}
```

```makefile
/* Makefile */
target:
	javac -encoding utf-8 UDPEchoClient.java
	javac -encoding utf-8 UDPEchoServer.java

run-UDPEchoClient:
	java UDPEchoClient

run-UDPEchoServer:
	java UDPEchoServer

clean:
	rm *.class
```

## 运行截图

![](http://images2015.cnblogs.com/blog/701997/201602/701997-20160204150232272-393180205.png)

## 问题解决方案

1.	中文编码问题：在代码使用UTF-8编码并且编译选项添加UTF8参数的话，不需要在代码中声明为UTF8编码，使用了反而会出错，亲测。
2.	面向连接的传输TCP：由于需要面向连接，因此一个服务端需要和多个客户端进行通信，这就需要在服务端使用多线程技术，一个客户端分配一个线程，分别处理不同客户端的通信。
3.	面向无连接的传输UDP：由于不需要连接，也不在意可靠传输，因此当客户端发送了一个数据包之后，若一定时间内没有返回内容，可以认为传输失败，让用户接着输入下一个内容。
4.	关于TCP的聊天室：在客户端中无法体现出一个聊天室的完成功能，但是服务端是体现出来了，如果需要在客户端也有这个体现，需要做线程之间的通信，想想还是太麻烦我就没做了。
5.	还有一点是面向连接的程序，不应该每发送一次就连接一次再断开连接，这样子的通信效率太低，而是应该等到客户端退出后再断开连接，这点已实现。

## 样例代码下载

传送门：[下载](http://pan.baidu.com/s/1geubvNX)