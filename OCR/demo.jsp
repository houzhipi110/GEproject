<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.io.*,java.util.*,java.security.*"%>

<%@page import="org.apache.commons.httpclient.*"%>
<%@page import="org.apache.commons.httpclient.methods.*"%>
<%@page import="org.apache.commons.httpclient.params.*"%>

<%
System.out.println(">> start demo......");
//例子：
//把测试图片放到D盘下面，也可以放到别的地方，但需要调整filePath对应的物理路径
String filePath="D:\\test_doc.jpg";//测试图片物理路径

File file=null;
try{
	file=new File(filePath);//要识别的文件路径
}catch(Exception e){
	out.print(">> 文件加载失败！");
	return;
}
String result = "123";
result=Scan(file2byte(file),OCR_LAN_CHINESE,OCR_CODE_NIL,filePath.substring(filePath.lastIndexOf(".")+1));//调用网络接口识别
out.print(result);//打印出识别结果
System.out.println(">> end demo.");
%>
<%!
//识别API的URL
public static final String ENGINE_URL="http://www.yunmaiocr.com/SrvXMLAPI";
public static final String username="xxxxxx";//替换OCR SDK开发者平台API帐号
public static final String password="xxxxxx";//替换OCR SDK开发者平台API密码

// OCR language
public static final int OCR_LAN_NIL = 0; // NIL
public static final int OCR_LAN_ENGLISH = 1; // English
public static final int OCR_LAN_CHINESE = 2; // Chinese


// KEY language
//当OCR language为中文时，可以选择识别出来的是简体还是繁体，一般没有特殊要求，选择默认0即可
public static final int OCR_CODE_NIL = 0;//default
public static final int OCR_CODE_GB = 1;//Simplified
public static final int OCR_CODE_B5 = 2;//
public static final int OCR_CODE_GB2B5 = 3;//Traditional

public static String Scan(byte[] file,int ocrLang,int keyLang,String ext){
	String xml = getSendXML( "doc.scan",ocrLang+"",keyLang+"",ext);
	return send(xml,file);
}

private static String getSendXML(String action,String ocrLang,String keyLang,String ext) {
	ArrayList<String[]> arr = new ArrayList<String[]>();
	arr.add(new String[] { "action", action});
	arr.add(new String[] { "client", username });
	arr.add(new String[] { "system", "web_saas"});
	arr.add(new String[] { "password", MD5(password)});
	arr.add(new String[] { "ocrlang", ocrLang});
	arr.add(new String[] { "keylang",  keyLang});
	arr.add(new String[] { "ext",ext });
	arr.add(new String[] { "json", "0" });//返回结果是否转成json格式，不传及默认是xml格式，为1时：转换成json格式
	arr.add(new String[] { "er","0" });//1:不显示坐标，默认为1，0：显示座标
	return getXML(arr,false);
}
public static String getXML(ArrayList<String[]> arr,boolean IsUpper) {
	if (arr == null || arr.size() == 0)
		return "";
	StringBuffer sb = new StringBuffer();
	String tag="";
	for (int idx = 0; idx < arr.size(); idx++) {
		tag=arr.get(idx)[0];
		if(IsUpper){
			tag=tag.toUpperCase();
		}
		sb.append("<");
		sb.append(tag);
		sb.append(">");
		sb.append(arr.get(idx)[1]);
		//sb.append(XMLFunctions.code(arr.get(idx)[1]));
		sb.append("</");
		sb.append(tag);
		sb.append(">");
	}
	return sb.toString();
}
private static String send(String xml,byte[] file){
	byte[] dest = new byte[xml.getBytes().length+file.length+"<file></file>".getBytes().length];
	int pos = 0;
	System.arraycopy(xml.getBytes(), 0, dest, pos, xml.getBytes().length);
	pos += xml.getBytes().length;
	System.arraycopy("<file>".getBytes(), 0, dest, pos, "<file>".getBytes().length);
	pos += "<file>".getBytes().length;
	System.arraycopy(file, 0, dest, pos, file.length);
	pos += file.length;
	System.arraycopy("</file>".getBytes(), 0, dest, pos, "</file>".getBytes().length);
	try {
		return httpClient(ENGINE_URL, dest);
	} catch (IOException e) {
		return "-1";
	}
}
public static String httpClient(String url,byte[] content) throws IOException{
	HttpClient httpClient = new HttpClient();
	HttpClientParams httparams = new HttpClientParams();
	httpClient.setParams(httparams);

	PostMethod method = new PostMethod(url);
	RequestEntity requestEntity = new ByteArrayRequestEntity(content);
	method.setRequestEntity(requestEntity);
	String responseBody = null;
	try {
		method.getParams().setContentCharset("utf-8");
		method.getParams().setParameter(HttpMethodParams.RETRY_HANDLER, new DefaultHttpMethodRetryHandler());
		int statusCode = httpClient.executeMethod(method);
		if (statusCode != HttpStatus.SC_OK) {
			System.out.println("\r\nMethod failed: " + method.getStatusLine() + ",url:\r\n" + url + "\r\n");
		}
		StringBuffer resultBuffer = new StringBuffer();
		BufferedReader in = new BufferedReader(new InputStreamReader(method.getResponseBodyAsStream(),
				method.getResponseCharSet()));
		String inputLine = null;
		while ((inputLine = in.readLine()) != null) {
			resultBuffer.append(inputLine);
			resultBuffer.append("\r\n");
		}
		in.close();
		responseBody = resultBuffer.toString().trim();
	} catch (Exception e) {
		System.out.println(">>> http请求异常，url=" + url);
		e.printStackTrace();
		responseBody = "-2";
	} finally {
		if (method != null) {
			method.releaseConnection();
			method = null;
		}
		return responseBody;
	}

}
public static byte[] file2byte(File file) throws IOException {
	byte[] bytes = null;
	if (file != null) {
		InputStream is = new FileInputStream(file);
		int length = (int) file.length();
		if (length > Integer.MAX_VALUE) // 当文件的长度超过了int的最大值
		{
			System.out.println("this file is max ");
			return null;
		}
		bytes = new byte[length];
		int offset = 0;
		int numRead = 0;
		while (offset < bytes.length&& (numRead = is.read(bytes, offset, bytes.length - offset)) >= 0) {
			offset += numRead;
		}
		// 如果得到的字节长度和file实际的长度不一致就可能出错了
		if (offset < bytes.length) {
			System.out.println("file length is error");
			return null;
		}
		is.close();
	}
	return bytes;
}
public final static String MD5(String pwd) {
	//用于加密的字符
	char md5String[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
			'A', 'B', 'C', 'D', 'E', 'F' };
	try {
		byte[] btInput = pwd.getBytes();
		
		MessageDigest mdInst = MessageDigest.getInstance("MD5");
		mdInst.update(btInput);
		byte[] md = mdInst.digest();
		int j = md.length;
		char str[] = new char[j * 2];
		int k = 0;
		for (int i = 0; i < j; i++) {   //  i = 0
			byte byte0 = md[i];  //95
			str[k++] = md5String[byte0 >>> 4 & 0xf];    //    5  
			str[k++] = md5String[byte0 & 0xf];   //   F
		}
		return new String(str);
		
	} catch (Exception e) {
		e.printStackTrace();
		return null;
	}
}
%>