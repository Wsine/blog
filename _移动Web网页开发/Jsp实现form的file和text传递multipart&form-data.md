# Jsp实现form的file和text传递(multipart/form-data)

首先是form部分，因为要有`<input type="file" />`的类型，所以需要添加`enctype="multipart/form-data"`这一参数，实现大文件传递

#### 表单部分

```
<form action="addHomework.jsp" method="post" enctype = "multipart/form-data">
	课程号： <input type="text" name="course_id" value="<%=course_id%>" /><br /><br />
	作业号： <input type="text" name="homework_id" value="<%=homework_id%>" /><br /><br />
	作业标题： <input type="text" name="homework_title"
		value="<%=homework_title%>" /><br /><br /> 
	作业描述： <input type="text"
		name="homework_description" value="<%=homework_description%>" /><br /><br />
	附件： <input type="file" name="detail_attach_file"
		value="<%=detail_attach_file%>" /><br /><br />
	DDL： <input
		type="date" name="ddl" value="<%=ddl%>"/><br /><br /> 
	<input type="submit"
		value="发布" name="postHomework"><br /><br />
	<%=hintToUser%>
</form>
```

#### Java部分

```
<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ include file="MySQLHelper.jsp"%>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.FileUploadException" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>

<%
	String method = request.getMethod();
	String course_id = "";
	String homework_id = "";
	String homework_title = "";
	String homework_description = "";
	String detail_attach_file = "";
	String post_date = "";
	String ddl = "";
	String hintToUser = "";
	if (method.equals("POST")) {
		DiskFileItemFactory diskFileItemFactory = new DiskFileItemFactory();
		ServletFileUpload servletFileUpload = new ServletFileUpload(diskFileItemFactory);
		try {
			List list = servletFileUpload.parseRequest(request);
			Iterator iterator = list.iterator();
			while (iterator.hasNext()) {
				FileItem item = (FileItem)iterator.next();
				if (item.isFormField()) { // judge if it is not the file field
					String name = item.getFieldName(); // get the form's child name
					if (name.equals("course_id")) 
						course_id = item.getString("utf-8");
					else if (name.equals("homework_id")) 
						homework_id = item.getString("utf-8");
					else if (name.equals("homework_title"))
						homework_title = item.getString("utf-8");
					else if (name.equals("homework_description"))
						homework_description = item.getString("utf-8");
					else if (name.equals("ddl"))
						ddl = item.getString("utf-8");
				} else { // else it is the file field
					String fName = item.getName();  // get the file name
					int i = fName.lastIndexOf("\\");// fix the bug in ie
					fName = fName.substring(i + 1, fName.length());
					String filepath = request.getRealPath("/") + "detail_attach";
					File path = new File(filepath);
					if (!path.isDirectory()) {
						path.mkdir();
					}
					detail_attach_file = path + "/" + fName;
					try {
						if (fName != "") {
							item.write(new File(detail_attach_file));
						}
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
			}
		} catch (FileUploadException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}
		// do whatever you want below
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		post_date = df.format(new Date());
		MySQLHelper.HomeworkPost homeworkPost = new MySQLHelper.HomeworkPost(course_id, homework_id,
				homework_title, homework_description, detail_attach_file, post_date, ddl);
		if(MySQLHelper.addHomework(homeworkPost)) {
			hintToUser = "成功发布作业";
		}
	}
%>
```

至此，完毕