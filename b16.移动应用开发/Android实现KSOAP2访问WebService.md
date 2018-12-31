# Android实现KSOAP2访问WebService

开发工具：Andorid Studio 1.3
运行环境：Android 4.4 KitKat

## 代码实现

写一个工具类来给主界面使用，作用是使用Ksoap访问特定的网站服务，获取返回的验证码图片字节码，发送Message给主界面

```java
public class DownLoad implements Runnable {
    private final String NAMESPACE = "http://WebXml.com.cn/";
    private final String METHODNAME = "enValidateByte";
    private final String SOAPACTION = "http://WebXml.com.cn/enValidateByte";
    private final String URL = "http://webservice.webxml.com.cn/WebServices/ValidateCodeWebService.asmx";

    @Override
    public void run() {
        try {
            SoapObject request = new SoapObject(NAMESPACE, METHODNAME);
            Log.d("myDebug_str", MainActivity.str);
            request.addProperty("byString", MainActivity.str);
            SoapSerializationEnvelope envelope = new SoapSerializationEnvelope(SoapEnvelope.VER10);
            envelope.dotNet = true;
            envelope.setOutputSoapObject(request);
            HttpTransportSE transportSE = new HttpTransportSE(URL);
            try {
                transportSE.call(SOAPACTION, envelope);
            } catch (Exception e) {
                Log.d("myDebug_call", "failed to call SOAPACTION");
                e.printStackTrace();
            }
            Log.d("myDebug_fault", envelope.bodyIn.toString());
            SoapObject result = (SoapObject) envelope.bodyIn;
            SoapPrimitive detail = (SoapPrimitive) result.getProperty("enValidateByteResult");
            Message msg = new Message();
            msg.what = MainActivity.GET_CODE;
            msg.obj = detail.toString();
            MainActivity.handler.sendMessage(msg);
            Log.d("myDebug_sendMsg", "Send Msg successfully..");
        } catch (Exception e) {
            Message msg = new Message();
            msg.what = MainActivity.ERROR_CODE;
            MainActivity.handler.sendMessage(msg);
            e.printStackTrace();
            Log.d("myDebug", "Fail to finish the Progressing..");
        }
    }
}
```

这里需要注意的是，Http请求的时候没有设定超时时间，是根据默认值来设定的。整个流程中用了try语句捕捉异常，主要异常在于超时返回内容为空，可以手动捕捉该异常返回Message为异常给主界面。

主界面中点击Create的Button的时候，打开显示图片的boolean值的成员变量，说明用户等待接收验证码。点击Button后提高用户体验为在程序中控制关闭输入法的弹出。如果用户输入空值，提示用户输入内容。用ProgressDialog显示等待，该等待可取消，取消后返回的验证码也不显示

```java
Button btnCreate = (Button)this.findViewById(R.id.btnCreate);
btnCreate.setOnClickListener(new View.OnClickListener() {
    @Override
    public void onClick(View view) {
        InputMethodManager imm = (InputMethodManager)getSystemService(Context.INPUT_METHOD_SERVICE);
        if (imm.isActive()) {
            imm.hideSoftInputFromWindow(MainActivity.this.getCurrentFocus().getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
        }
        if (!edtStr.getText().toString().isEmpty()) {
            toShowPic = true;
            MainActivity.str = edtStr.getText().toString();
            progressDialog = ProgressDialog.show(MainActivity.this, "Requesting", "Requesting...", true, true);
            progressDialog.setOnCancelListener(progressDialogCancelListener);
            workThread = new Thread(new DownLoad());
            workThread.start();
        } else {
            imageView.setVisibility(View.GONE);
            Toast.makeText(MainActivity.this, "请输入验证码字符!", Toast.LENGTH_SHORT).show();
        }
    }
});

public static DialogInterface.OnCancelListener progressDialogCancelListener = new DialogInterface.OnCancelListener() {
    @Override
    public void onCancel(DialogInterface dialogInterface) {
        toShowPic = false;
    }
};
```

接着就是用Handler捕获消息，作出相应的处理。因为返回的内容是字节码，需要解码生成一个Bitmap图像。由于图像的大小不一，通过作变换矩阵Matrix拉伸或缩小到设备宽度，填充到ImageView中，使得用户体验提升

```java
public static final int GET_CODE = 0;
public static final int ERROR_CODE = 1;
public static Handler handler = new Handler() {
    @Override
    public void handleMessage(Message msg) {
        switch (msg.what) {
            case GET_CODE:
                if (toShowPic) {
                    progressDialog.cancel();
                    byte[] data = Base64.decode((msg.obj.toString()).getBytes(), Base64.DEFAULT);
                    Bitmap bitmap = BitmapFactory.decodeByteArray(data, 0, data.length);
                    Matrix matrix = new Matrix();
                    float scale = (float) linearLayout.getWidth() / (float) bitmap.getWidth();
                    Log.d("myDebug", "scale = " + scale);
                    matrix.postScale(scale, scale);
                    Bitmap resizeBitmap = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
                    imageView.setImageBitmap(resizeBitmap);
                    imageView.setVisibility(View.VISIBLE);
                }
                break;
            case ERROR_CODE:
                if (toShowPic) {
                    progressDialog.cancel();
                    Toast.makeText(mContext, "获取验证码超时", Toast.LENGTH_SHORT).show();
                }
                break;
            default:
                super.handleMessage(msg);
                break;
        }
    }
};
```

最后不忘记给app加上访问网络的权限

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

## 效果图

初始化界面->点击Create界面->成功获取验证码界面->Create空白验证码界面->

<img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202152055804-1680426632.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202152059397-922334520.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202152104600-323868279.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202152108210-1627968771.png" alt="cant show" style="display: inline-block; width: 22%; " />

中文测试->获取验证码超时界面

<img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202152116741-1298214102.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202152121350-941916298.png" alt="cant show" style="display: inline-block; width: 22%; " />

## 一些总结

1.	最大的问题在于访问该网络服务的时候经常超时，因此使用try语句运行，后面捕获异常即可。
2.	本来打算ProgressDialog可以取消，然后停止或注销相应的子线程，但是发现该做法会造成内存泄漏，在官方文档和Android Studio中均有说明，后来选择使用boolean成员变量达到相同目的。

**了解Android中网络通讯的多种方法，进行简单的总结**
- 针对TCP网络的Socket和ServerSocket方法
	该方法和Java中的Socket编程一致，用到了Send和Receive两个方法。
- 针对UDP的DatagramSocket和DatagramPackage方法
	该方法和Java中的一致，和上面的差不多，也是监听端口，用到了Send和Receive方法。
- 针对URL的HttpClient和HttpURLConnection方法
	该方法主要用过URL使用TCP的传输层协议完成通信，有超时和重传次数等设置，可以通过URL中特定的参数访问网络。
- 针对Http的Apache Http方法
	该方法主要使用了Http网络协议中的GET和POST请求，可以被重定向，可以返回任意内容。封装得比较好，使用起来比较方便。
- 针对WebService的Xmlrpc，Jsonrpc和Ksoap2等方法
	该方法主要方便在于用有限的枚举类型访问相应的WebService，从而得到相应的服务内容，是专门用来请求WebService的方法。
- 针对Web的WebView方法
	该方法使用了Google的开源Web浏览器渲染特定的Web页面在一定的手机区域，有UI界面，可以直观得看到上网的内容。


## 工程下载

传送门：[下载](http://pan.baidu.com/s/1dEsIKG5)