# Java实现Internet地址获取

## 代码内容

- 输入域名输出IPV4地址
- 输入IP地址输出域名
- 支持命令行输入
- 支持交互式输入

## 代码实现

```java
/* nslookup.java */
import java.net.*;
import java.util.regex.Pattern;
import java.io.*;

public class nslookup {
	public static void main(String[] args) {
		if (args.length > 0) {
			for (int i = 0; i < args.length; i++) {
				System.out.println("\n> " + args[i]);
				lookup(args[i]);
			}
		} else {
			BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
			System.out.println("Enter the domain names or IP addresses. Enter \"exit\" to quit.");
			try {
				boolean isEmptyLine = false;
				while (true) {
					if (isEmptyLine){
						isEmptyLine = false;
						System.out.print("> ");
					} else
						System.out.print("\n> ");
					String host = in.readLine();
					if (host.equalsIgnoreCase("exit")) {
						break;
					} else if (host.isEmpty()){
						isEmptyLine = true;
						continue;
					}
					lookup(host);
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	private static void lookup(String host) {
		if(isDomain(host)) {
			nat(host, true);
		} else {
			nat(host, false);
		}
	}

	private static boolean isDomain(String host) {
		String[] part = host.split("\\.");
		if (part.length == 4) {
			for (String pa : part) {
				if (!isNumeric(pa)) {
					return true;
				}
			}
			return false;
		} else {
			return true;
		}
	}

	public static boolean isNumeric(String str) {
		Pattern pattern = Pattern.compile("[0-9]*");
		//Pattern pattern = Pattern.compile("^[0-9]+(.[0-9]*)?$");
		return pattern.matcher(str).matches();
	}

	private static void nat(String host, boolean isDomain) {
		try {
			if (host.equals("127.0.0.1")){
				System.out.println("Name: localhost");
				return;
			}
			InetAddress[] address = InetAddress.getAllByName(host);
			if (isDomain) {
				for (int i = 0; i < address.length; i++){
					System.out.println("Address: " + address[i].getHostAddress());
				}
			}
			else if (host.equals(address[0].getHostName())){
				for (int i = 0; i < address.length; i++){
					System.out.println("Address: " + address[i].getHostAddress());
				}
			}
			else {
				for (int i = 0; i < address.length; i++){
					System.out.println("Name: " + address[i].getHostName());
				}
			}
		} catch (UnknownHostException e) {
			e.printStackTrace();
		}
	}
}
```

## 运行截图

- 输入域名的结果
	![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image206.png)

- 输入IP地址的结果
	![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image207.png)

- 输入本机上IP地址的结果
	![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image208.png)

------

## 增强版内容

- 在源程序的基础之上在输入域名时输出全部地址
- 如果查询的域名或者IP在本主机上还要输出对应的端口号
- 如果不在本主机上也需要给相应的提示信息

## 增强版代码实现

```java
/* nslookupAdvanced.java */
import java.net.*;
import java.util.regex.Pattern;
import java.io.*;

public class nslookupAdvanced {
	public static void main(String[] args) {
		if (args.length > 0) {
			for (int i = 0; i < args.length; i++) {
				System.out.println("\n> " + args[i]);
				lookup(args[i]);
			}
		} else {
			BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
			System.out.println("Enter the domain names or IP addresses. Enter \"exit\" to quit.");
			try {
				boolean isEmptyLine = false;
				while (true) {
					if (isEmptyLine){
						isEmptyLine = false;
						System.out.print("> ");
					} else
						System.out.print("\n> ");
					String host = in.readLine();
					if (host.equalsIgnoreCase("exit")) {
						break;
					} else if (host.isEmpty()){
						isEmptyLine = true;
						continue;
					}
					lookup(host);
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	private static void lookup(String host) {
		if(isDomain(host)) {
			nat(host, true);
			decideNI(host);
		} else {
			nat(host, false);
			decideNI(host);
		}
	}

	private static boolean isDomain(String host) {
		String[] part = host.split("\\.");
		if (part.length == 4) {
			for (String pa : part) {
				if (!isNumeric(pa)) {
					return true;
				}
			}
			return false;
		} else {
			return true;
		}
	}

	public static boolean isNumeric(String str) {
		Pattern pattern = Pattern.compile("[0-9]*");
		//Pattern pattern = Pattern.compile("^[0-9]+(.[0-9]*)?$");
		return pattern.matcher(str).matches();
	}

	private static void nat(String host, boolean isDomain) {
		try {
			if (host.equals("127.0.0.1")){
				System.out.println("Name: localhost");
				return;
			}
			InetAddress[] address = InetAddress.getAllByName(host);
			if (isDomain || host.equals(address[0].getHostName())) {
				for (int i = 0; i < address.length; i++) {
					System.out.println("Address: " + address[i].getHostAddress());
				}
			} else {
				System.out.println("Name: " + address[0].getHostName());
			}
		} catch (UnknownHostException e) {
			e.printStackTrace();
		}
	}

	private static void decideNI(String host) {
		try {
			InetAddress address = InetAddress.getByName(host);
			NetworkInterface ni = NetworkInterface.getByInetAddress(address);
			if (ni != null) {
				String niName = ni.getName();
				String[] niDisplayName = ni.getDisplayName().split(" ");
				System.out.println("This is local address " + niName + 
					niDisplayName[niDisplayName.length - 1] + ".");
			} else {
				System.out.println("This is not local address.");
			}
		} catch (SocketException e) {
			e.printStackTrace();
		} catch (UnknownHostException e) {
			e.printStackTrace();
		}
	}
}
```

## 增强版运行结果

- 输入一个绑定到多个IP地址上的域名的结果
	![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image209.png)

- 输入IP地址的结果
	![](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image210.png)