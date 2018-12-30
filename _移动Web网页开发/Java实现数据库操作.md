# Java实现数据库操作

这里的样例是使用mysql数据库

## 代码实现

```java
/* MySQLHelper.java */
import java.io.*;
import java.util.*;
import java.sql.*;

public class MySQLHelper {

	private static final String databaseHostIp = "localhost";
	private static final String databaseHostPort = "3306";
	private static final String databaseName = "databaseName";
	private static final String databaseUserName = "username";
	private static final String databaseUserPassword = "password";

	/*
	 *	描述：获取数据库连接对象，失败返回null
	 *	输入：空
	 *	输出：数据库连接对象Connection
	 */
	private static Connection getConnection() {
		String connectString = "jdbc:mysql://" + databaseHostIp 
								+ ":" + databaseHostPort 
								+ "/" + databaseName 
								+ "?autoReconnect=true&useUnicode=true&characterEncoding=UTF-8";
		Connection conn = null;
		try {
			Class.forName("com.mysql.jdbc.Driver");
			conn = DriverManager.getConnection(connectString, databaseUserName, databaseUserPassword);
			return conn;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	/*
	 *	描述：增删改操作
	 *	输入：sql语句
	 *	输出：成功 true | 失败 false
	 */
	public static boolean update(String sql) {
		Connection conn = null;
		try {
			conn = getConnection();
			Statement stat = conn.createStatement();
			stat.executeUpdate(sql);
			return true;
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				conn.close();
			} catch	(Exception e) {
				e.printStackTrace();
			}
		}
		return false;
	}

	/*
	 *	描述：查询操作
	 *	输入：sql语句
	 *	输出：查询结果数据集
	 */
	public static ResultSet query(String sql) {
		ResultSet rs = null;
		try {
			Connection conn = getConnection();
			Statement stat = conn.createStatement();
			rs = stat.executeQuery(sql);
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				conn.close();
			} catch	(Exception e) {
				e.printStackTrace();
			}
		}
		return rs;
	}
}
```

调用样例代码

```java
import java.io.*;
import java.util.*;
import MySQLHelper.*;

public class Test {
	public static void main(String[] args) {
		testUpdate();
		testQuery();
	}

	public boolean testUpdate() {
		String sql = "INSERT INTO USER_WEB values('Sicily', 'foolish')";
		if (update(sql)) {
			return true;
		} else {
			return false;
		}
	}

	public boolean testQuery() {
		String sql = "SELECT * FROM USER_WEB";
		try {
			ResultSet rs = query(sql);
			while (rs.next()) {
				String id = rs.getString("user_id");
				String pwd = rs.getString("password");
				System.out.println(String.format("user_id = '%s', password = '%s'", id, pwd));
			}
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
		return true;
	}
}
```