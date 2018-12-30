# Java实现Socket之TimeClient

## 代码内容

- 从[time.nist.gov](time.nist.gov)服务器的37号端口得到时间信息，并对时间进行解析后显示出来

## 代码实现

```java
/* TimeClient.java */
import java.io.*;
import java.net.*;
import java.util.Date;

public class TimeClient {
	public final static long differenceBetweenEpochs = 2208988800L;

	public static void main(String[] args) {
		try {
			/* 设置服务器地址和端口号 */
			InetAddress host = InetAddress.getByName("time.nist.gov");
			int port = 37;
			if (args.length > 0) {
				host  = InetAddress.getByName(args[0]);
			}
			/* 建立Socket连接 */
			Socket s = new Socket(host, port);
			/* 从Socket中读取数据 */
			InputStream raw = s.getInputStream();
			/* 时间转换 */
			long secondsSince1900 = 0;
			for (int i = 0; i < 4; i++) {
				secondsSince1900 = (secondsSince1900 << 8) | raw.read();
			}

			long secondsSince1970 = secondsSince1900 - differenceBetweenEpochs;
			long msSince1970 = secondsSince1970 * 1000;
			Date time = new Date(msSince1970);
			System.out.println("It is " + time);

		} catch (UnknownHostException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
```

## 运行截图

![](http://images2015.cnblogs.com/blog/701997/201602/701997-20160204143927007-632521991.png)