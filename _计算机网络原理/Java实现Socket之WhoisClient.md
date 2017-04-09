#Java实现Socket之WhoisClient

##代码内容

- 从常用的[whois服务器](http://www.whois.com/whois/)的43号端口得到对应域名的所有注册信息并显示出来

##代码实现

```java
/* WhoisClient.java */
import java.io.*;
import java.net.*;

public class WhoisClient {
	public static void main(String[] args) {
		BufferedReader systemIn = new BufferedReader(new InputStreamReader(System.in));
		System.out.println("Enter the domain names. Enter \"exit\" to quit.");
		try {
			while (true) {
				/* 输入流提示控制 */
				System.out.print("> ");
				String host = (args.length > 0) ? args[0] : systemIn.readLine();
				if (host.isEmpty()) {
					continue;
				} else if (host.equalsIgnoreCase("exit")) {
					break;
				}
				whois(host);
				if (args.length > 0)
					break;
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	private static void whois(String host) {
		try {
			/* 设置服务器地址和端口号 */
			InetAddress server = InetAddress.getByName("whois.markmonitor.com");
			int port = 43;
			/* 建立Socket连接 */
			Socket socket = new Socket(server, port);
			/* 写入发送消息到Socket */
			PrintWriter out = new PrintWriter(socket.getOutputStream());
			out.println(host);
			out.flush();
			/* 从Socket读取消息 */
			BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
			/* 格式化输出 */
			StringBuilder ret = new StringBuilder();
			String line;
			while ((line = in.readLine()) != null) {
				ret.append(line + "\r\n");
			}
			/* 安全关闭Socket */
			socket.close();
			/* 结果输出判断 */
			if (ret.toString().trim().isEmpty()) {
				System.out.println("该域名不在whois上注册");
			} else {
				System.out.println(ret.toString());
			}
		} catch (UnknownHostException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
```

##运行截图

![](http://images2015.cnblogs.com/blog/701997/201602/701997-20160204144347366-1890244519.png)
![](http://images2015.cnblogs.com/blog/701997/201602/701997-20160204144351663-677943006.png)
![](http://images2015.cnblogs.com/blog/701997/201602/701997-20160204144355741-1582846041.png)
![](http://images2015.cnblogs.com/blog/701997/201602/701997-20160204144400225-574371923.png)