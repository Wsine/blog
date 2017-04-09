#Android实现网络访问

开发工具：Andorid Studio 1.3
运行环境：Android 4.4 KitKat

##工程内容

1)	 熟练使用HttpURLConnection访问WebService
2)	 熟练使用多线程以及Handler更新UI
3)	 熟练使用XmlPullParser解析xml文档数据

##代码实现

当用户点击查询按钮的时候，用正则表达式匹配是否是手机号码，若是则调用查询函数，否则用Toast提示用户检查输入

```java
((Button)this.findViewById(R.id.btnSearch)).setOnClickListener(new View.OnClickListener() {
    @Override
    public void onClick(View view) {
        if (edtPhoneNumber.getText().toString().matches("^[1-9]\\d{10}$")) {
            edtContent.setText("Querying the data");
            sendRequestWithHttpURLConnection();
        } else {
            edtContent.setText("");
            Toast.makeText(MainActivity.this, "Please correct the phone number", Toast.LENGTH_SHORT).show();
        }
    }
});
```

用户输入正确的时候，新开一个线程Thread在后台使用HttpURLConnection建立连接，设置请求方式是POST，设置连接超时和读数据超时为20s。如若超时捕获超时异常，更新UI显示为超时。然后往Http发送请求，给予手机号码，等待回复。接着从Http中读回返回的结果到一个String中。读回来的数据是Xml的字符串内容，需要用XmlPullParserFactory解析xml得到想要的内容。接着把这个得到的内容写入一个Message发出去让主线程的Handler捕获消息。良好习惯是，Http的connection要记得关闭，并且要让线程启动。

```java
private void sendRequestWithHttpURLConnection() {
    Thread workThread = new Thread(new Runnable() {
        @Override
        public void run() {
            HttpURLConnection connection = null;
            try {
                // Create a connection use url
                //connection = (HttpURLConnection)((new URL(url.toString()).openConnection()));
                connection = (HttpURLConnection)((new URL(getResources().getString(R.string.webService)).openConnection()));
                Log.d("myDebug", "successfully open connection");
                // Set method
                connection.setRequestMethod("POST");
                connection.setConnectTimeout(20000);
                connection.setReadTimeout(20000);
                Log.d("myDebug", "successfully set parameter");
                // Write into outputStream
                DataOutputStream out = new DataOutputStream(connection.getOutputStream());
                // use post method to post our data
                out.writeBytes("mobileCode=" + edtPhoneNumber.getText().toString() + "&userID=");
                Log.d("myDebug", "successfully write bytes");
                // get response data
                InputStream in = null;
                if (connection.getResponseCode() == 200) {
                    in = connection.getInputStream();
                } else {
                    in = connection.getErrorStream();
                }
                BufferedReader reader = new BufferedReader(new InputStreamReader(in));
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
                Log.d("myDebug", "successfully get respone");
                Message message = new Message();
                message.what = UPDATE_CONTENT;
                message.obj = parseXMLWithPull(response.toString());
                handler.sendMessage(message);
                Log.d("myDebug", "successfully send message");
            } catch (java.net.SocketTimeoutException e) {
                Message message = new Message();
                message.what = TIME_OUT;
                handler.sendMessage(message);
                e.printStackTrace();
                Log.d("myDebug", "Timeout to get the data");
            } catch (Exception e) {
                e.printStackTrace();
                Log.d("myDebug", "Can't not connect to the service");
            } finally {
                if (connection != null) {
                    connection.disconnect();
                }
            }
        }
    });
    workThread.start();
}

private String parseXMLWithPull(String xml) {
    String str = "";
    try {
        // use pull to parse xml
        XmlPullParserFactory factory = XmlPullParserFactory.newInstance();
        XmlPullParser parser = factory.newPullParser();

        parser.setInput(new StringReader(xml));
        int eventType = parser.getEventType();
        while (eventType != XmlPullParser.END_DOCUMENT) {
            switch (eventType) {
                case XmlPullParser.START_TAG:
                    if ("string".equals(parser.getName())) {
                        str = parser.nextText();
                    }
                    break;
                case XmlPullParser.END_TAG:
                    break;
                default:
                    break;
            }
            eventType = parser.next();
        }
    } catch (Exception e) {
        e.printStackTrace();
        Log.d("myDebug", "can not parse the xml");
    }
    return str;
}
```

主线程中需要捕获消息并更新UI，只捕获自己的消息，其余消息交给父类原本的处理

```java
private static final int UPDATE_CONTENT = 0;
private static final int TIME_OUT = 1;
private Handler handler = new Handler() {
    @Override
    public void handleMessage(Message message) {
        switch (message.what) {
            case UPDATE_CONTENT:
                edtContent.setText(message.obj.toString());
                break;
            case TIME_OUT:
                edtContent.setText("Time out for getting the data");
                break;
            default:
                super.handleMessage(message);
                break;
        }
    }
};
```

最后需要给程序赋予上网权限和检测网络权限即可

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

##效果图

初始化界面->输入错误或不完整手机号码->输入正确并查询->查询结果

<img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202150909850-48390256.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202150905647-27911751.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202150918163-1208959184.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202150913554-1400418952.png" alt="cant show" style="display: inline-block; width: 22%; " />
<img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202150857804-1737490091.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202150901944-1400549402.png" alt="cant show" style="display: inline-block; width: 22%; " />

##一些总结

这个实验中最大的问题就在于免费的东西有使用次数限制，根据网站的说法是24小时内容不超过100次。
然后跟踪Http的进度使用Log方法来调试程序比较快。
对于有些超时的情况，我选择了捕获这个超时异常来更新UI，否则子线程超时后什么内容也没有显示不太符合正常情况。

**实际上，在http请求中，直接使用主进程请求数据也是没问题的，为什么android非要使用子线程进行http请求呢？**
答：Http请求并不能即时出结果，需要有时间等待，如果在主线程请求数据，那么请求的时候整个程序就会停留在请求的状态，界面卡住不动，因此使用子线程来做这件事比较合适。

**为什么不在子线程中直接修改UI，而是需要通过Handler来实现消息的传递，如果直接修改UI会出现什么问题？**
答：如果多个子线程同时修改一个UI，那个程序会出现未知的错误。因此每个子线程发送各自的消息，让主线程在消息队列中按到达顺序依次处理消息，是最好的办法。


##工程下载

传送门：[下载](http://pan.baidu.com/s/1dEoEVgl)