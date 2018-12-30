# Jsp实现筛选并压缩文件批量下载

首先明确一下需求，网页端点击一下button，传递特定的参数到download.jsp网页，筛选文件，对过滤得到的文件进行压缩，然后返回前端一个压缩包下载。

> 以下的代码来源于网络，没找到源发地出处，经过了自定义的修改。

### 方法声明

```jsp
<%@ page 
	language="java" 
	import="java.util.*"
%>
<%@ page import="java.io.BufferedInputStream" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.FileFilter" %>
<%@ page import="java.io.FileInputStream" %>
<%@ page import="java.io.FileOutputStream" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="org.apache.tools.zip.*" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%@ page import="java.util.zip.*" %>
<%@ page import="java.util.regex.Pattern" %>
<%@ page import="java.util.regex.Matcher" %>

<%!
// 得到该文件夹，及其所有子文件夹下的所有目标文件
List<File> getAllFiles(File file, String regex) {
	List<File> valueFiles = new ArrayList<File>();
	File[] fs = file.listFiles();
	for (int i = 0; i < fs.length; i++) {
		if (fs[i].isDirectory()) {
			// 递归得到每个子文件夹下的目标文件
			valueFiles.addAll(getAllFiles(fs[i], regex));
		}
	}
	// 把file文件夹下的目标文件放进去
	valueFiles.addAll(Arrays.asList(getFiles(file, regex)));
	return valueFiles;
}

// 得到一个文件夹下的目标文件，不包括子文件夹
File[] getFiles(File file, String _regex) {
	final String regexTemp = _regex;
	// 图个方便，用匿名类了
	FileFilter filter = new FileFilter() {
		String regex = regexTemp;

		public boolean accept(File pathname) {
			// return pathname.getName().matches(regex);// 文件后缀为.jsp
			Pattern pattern = Pattern.compile(regex);
			Matcher matcher = pattern.matcher(pathname.getName());
			return matcher.find();
		}
	};
	File[] fs = file.listFiles(filter);
	return fs;
}

String[] listToStringArray(List<File> listF) {
	List<String> listS = new ArrayList<String>();
	for (File f : listF) {
		listS.add(f.getAbsolutePath());
	}
	int size = listS.size();
	return (String[])listS.toArray(new String[size]);
}

public class JspFileDownload {
	/** request object */
	private HttpServletResponse response = null;
  
	/** file type: -1 un-setting; 0 normal file; 1 zip file ;2 stream*/
	private int fileType = -1;
	
	/** file name to be displayed */
	private String disFileName = null;
	
	/** zip file path */
	private String zipFilePath = null;
	
	/** file to be zipped */
	private String[] zipFileNames = null;
	
	private boolean zipDelFlag = false;
	
	/** file to be downloaded */
	private String downFileName = null;
	
	/** error code 0 */
	private static final int PROCESS_OK = 0;
	
	/** error code 1 */
	private static final int RESPONSE_IS_NULL = 1;
	
	/** error code 2 */
	private static final int UNSET_DOWNLOADTYPE = 2;
	
	/** error code 3 */
	private static final int UNSET_DIS_FILE_NAME = 3;
	
	/** error code 4 */
	private static final int UNSET_DOWN_FILE_NAME = 4;
	
	/** error code 9 */
	private static final int IO_EXCEPTION = 9;
	
	/**
	 * set response object
	 * @param response response Object
	 */
	public void setResponse(HttpServletResponse response){
		this.response = response;
	}
	
	/**
	 * set file type 0 normal file; 1 zip file ;2 stream
	 * @param fileType
	 */
	public void setDownType(int fileType){
		this.fileType = fileType;
	}
	
	/**
	 * set display file name
	 * @param fileName
	 */
	public void setDisFileName(String fileName){
		this.disFileName = fileName;
	}
	
	/**
	 * set zip file path
	 * @param fileNames
	 */
	public void setZipFilePath( String path ){
		this.zipFilePath = path;
	}
	
	public void setZipDelFlag(boolean b){
		this.zipDelFlag = b;
	}
	
	/**
	 * set zip file names
	 * @param fileNames
	 */
	public void setZipFileNames(String[] fileNames){
		this.zipFileNames = fileNames;
	}
	
	/**
	 * set download file name
	 * @param fileName
	 */
	public void setDownFileName(String fileName){
		this.downFileName = fileName;
	}
	
	/**
	 * set file content
	 * @param fileContent
	 */
	public int setFileContent(String fileContent){
		try{
			// byte[] buffs = fileContent.getBytes("GBK");
			byte[] buffs = fileContent.getBytes("UTF-8");
			response.getOutputStream().write(buffs);
		}catch(IOException e){
			return IO_EXCEPTION;
		}
		return PROCESS_OK;
	}
	
	/**
	 * set file content
	 * @param fileContent
	 */
	public int setFileContent(byte[] fileContent){
		try{
			response.getOutputStream().write(fileContent);
		}catch(IOException e){
			return IO_EXCEPTION;
		}
		return PROCESS_OK;
	}
	
	/**
	 * set file content end
	 *
	 */
	public int setFileContentEnd(){
		try{
			response.getOutputStream().close();
		}catch(IOException e){
			return IO_EXCEPTION;
		}
		return PROCESS_OK;
	}
	
	/**
	 * main process
	 * @return
	 */
	public int process(){
		int status = PROCESS_OK;
		
		status = preCheck();
		if ( status != PROCESS_OK )
			return status;
			
		String fileName = disFileName;
		
		response.setContentType("APPLICATION/OCTET-STREAM");
		response.setHeader("Content-Disposition","attachment;filename=\"" + fileName + "\"");
		int BUFSIZE = 1024 * 8;
		int rtnPos = 0;
		byte[] buffs = new byte[ BUFSIZE ];
		FileInputStream inStream = null;
		ZipOutputStream zos = null;
		InputStream is = null;
		String filepath = null;
		try{
			 
			if ( fileType == 0 || fileType == 1){
				if ( fileType == 0 ){
					filepath = downFileName;
				} else {
					filepath = zipFilePath + fileName;
					String[] fileToZip = zipFileNames;
					zos=new ZipOutputStream(new FileOutputStream(filepath));
					ZipEntry ze=null;
					byte[] buf=new byte[BUFSIZE];
					int readLen=0;
					for (int i= 0;i<fileToZip.length;i++){
						File f= new File(fileToZip[i]);
		
						ze=new ZipEntry(f.getName());
						ze.setSize(f.length());
						ze.setTime(f.lastModified());
		
						zos.putNextEntry(ze);
						is=new BufferedInputStream(new FileInputStream(f));
						while ((readLen=is.read(buf, 0, BUFSIZE))!=-1) {
							zos.write(buf, 0, readLen);
						}
						is.close();
					}
					zos.close();
				}
			
				// 以下为输出文件
				inStream =new FileInputStream(filepath);
				while((rtnPos=inStream.read(buffs)) >0)
					response.getOutputStream().write(buffs,0,rtnPos);
				response.getOutputStream().close();
				inStream.close();
			}
			if ( zipDelFlag ){
				File fToDel = new File(filepath);
				fToDel.delete();
			}

		}catch(IOException e){
			return IO_EXCEPTION;
		}finally{
			try{
				if ( inStream != null ){
					inStream.close();
					inStream = null;
				}
				if ( zos != null ){
					zos.close();
					zos = null;
				}
				if ( is != null ){
					is.close();
					is = null;
				}
			}catch (IOException e){
			}
		}
		return status;
	}
	
	/**
	 * pre check.
	 * @return
	 */
	private int preCheck(){
		if ( response == null )
			return RESPONSE_IS_NULL;
			
		if ( disFileName == null || disFileName.trim().length() == 0 )
			return UNSET_DIS_FILE_NAME;
		if ( fileType == -1 )
			return UNSET_DOWNLOADTYPE;
		else if ( fileType == 0 ){
			if ( downFileName == null || downFileName.trim().length() == 0 )
				return UNSET_DOWN_FILE_NAME;
			else{
				if ( !isFile( downFileName ) )
					return UNSET_DOWN_FILE_NAME;
			}
			
		}else if ( fileType == 1 ){
			if ( zipFilePath == null || zipFilePath.length() == 0 )
				return UNSET_DOWN_FILE_NAME;
			else{
				if ( !isDirect(zipFilePath) )
					return UNSET_DOWN_FILE_NAME;
			}
			if ( zipFileNames == null || zipFileNames.length == 0 )
				return UNSET_DOWN_FILE_NAME;
			else{
				for ( int i=0;i<zipFileNames.length;i++ ){
					if ( zipFileNames[i] == null || zipFileNames[i].trim().length() == 0 )
						return UNSET_DOWN_FILE_NAME;
					else{
						if ( !isFile( zipFileNames[i] ) )
							return UNSET_DOWN_FILE_NAME;
					}
				}
			}
		}else if ( fileType == 2 ){
			//doing nothing
		}else{
			return UNSET_DOWNLOADTYPE;
		}
		return PROCESS_OK;
	}
	
	private boolean isFile(String fileName){
		File f = new File(fileName);
		if (!f.exists() || !f.isFile())
			return false;
		return true;
	}
	
	private boolean isDirect(String filePath){
		File f = new File(filePath);
		if (!f.exists() || !f.isDirectory())
			return false;
		return true;
	}
}
%>
```

### 代码调用

```jsp
<%@ include file="downloadFilesHelper.jsp" %>
<%
	// 服务器路径
	String filePath = request.getRealPath("/") + "homeworkUpload\\";
	// 构建路径File
	File path = new File(filePath);
	// 正则表达式
	String homeworkNamePrefix = request.getParameter("homeworkNamePrefix");
	// String homeworkNamePrefix = "数据库第一周作业";
	String regex = "^(" + homeworkNamePrefix + ")";
	// String regex = "^(数据库第一周作业)";
	// 获取文件List
	List<File> listFiles = getAllFiles(path, regex);
	// List转String[]
	String[] files = listToStringArray(listFiles);
	// 压缩文件名
	// String outputFileName = "批量下载" + homeworkNamePrefix + ".zip";
	String outputFileName = "Homework.zip";
	// 准备压缩
	JspFileDownload jspFileDownload = new JspFileDownload();
	jspFileDownload.setResponse(response);
	jspFileDownload.setDownType(1); // zip file
	jspFileDownload.setDisFileName(outputFileName);
	jspFileDownload.setZipFilePath(filePath);
	jspFileDownload.setZipDelFlag(false); // 不删除压缩文件
	jspFileDownload.setZipFileNames(files);
	jspFileDownload.setDownFileName(outputFileName);
	// jspFileDownload.setFileContent(homeworkNamePrefix);
	// jspFileDownload.setFileContentEnd();
	// 开始压缩并下载
	int status = jspFileDownload.process();
	// Debug
	// out.println("status = " + status + "<br/>");
	// out.println("regex = " + regex + "<br/>");
	// for (int i = 0; i < files.length; i++) {
	// 	out.println(files[i] + "<br/>");
	// }
	// out.println(outputFileName + "<br/>");
	if (status == 4) {
		out.println("<p>还没有同学上交作业</p>");
	}
%>
```

已知bug，outputFileName不能赋值为中文名，如果赋值为中文名，返回前端的压缩包名字为`------.zip`，但内容一点问题都没有。暂时没有解决，如果有园友解决了的，求告知。

至此，完毕。