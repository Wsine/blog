#Android实现AppWidget、Broadcast静态注册

> 本篇博客是基于我上一篇博客继续修改的，详情请看[Android实现AppWidget、Broadcast动态注册](http://www.cnblogs.com/wsine/p/5169227.html)

开发工具：Andorid Studio 1.3
运行环境：Android 4.4 KitKat

##工程内容

1. 主界面可以编辑广播的信息，点击发送广播的按钮发送广播
2. 主页面上设置一个按钮进行广播接收器的注册与注销
3. 广播接收器若已被注册，发送的广播信息能够及时更新桌面上Widget上文字内容
4. 点击Widget可以跳转回主页面

##代码实现

静态注册MyBroadcastReceiver，intent-filter中的action标签内容对应广播时的intent中的内容，必须对应才能成功接收到广播

```xml
<receiver
    android:name=".MyBroadcastReceiver">
    <intent-filter>
        <!-- <action android:name="@string/sysu"/> -->
        <action android:name="SYSU_ANDROID_2015_2"/>
    </intent-filter>
</receiver>
```

注释掉之前使用的动态注册的函数，为按钮SEND设置可见相应，只有逻辑上注册了的按钮才会显示，否则默认不显示按钮SEND

```java
regBroCast.setOnClickListener(new View.OnClickListener() {
    @Override
    public void onClick(View view) {
        if(isRegister){
            //unregisterReceiver(myBroadcastReceiver);
            regBroCast.setText(getResources().getString(R.string.regBroadcast));
            isRegister = false;
            send.setVisibility(View.GONE);
        } else {
            //registerReceiver(myBroadcastReceiver, new IntentFilter());
            regBroCast.setText(getResources().getString(R.string.unRegBroadcast));
            isRegister = true;
            send.setVisibility(View.VISIBLE);
        }
    }
});
```

按钮SEND的响应不变，发送一个intent，命名中和静态注册的intent-filter中保持一致，加入message内容发送广播

```java
send.setOnClickListener(new View.OnClickListener() {
    @Override
    public void onClick(View view) {
        //Intent intent = new Intent(getResources().getString(R.string.sysu));
        Intent intent = new Intent("SYSU_ANDROID_2015_2");
        intent.putExtra("message", mainEditText.getText().toString());
        sendBroadcast(intent);
        Log.d("hint","click send");
    }
});
```

##效果图

初始化界面->输入hello world2->点击注册弹出SEND按钮->点击SEND->Widget界面出现hello world2文字

<img src="http://images2015.cnblogs.com/blog/701997/201601/701997-20160129155857614-1968770589.jpg" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201601/701997-20160129155901974-1665279659.jpg" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201601/701997-20160129155905630-608323604.jpg" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201601/701997-20160129155915911-1848754662.jpg" alt="cant show" style="display: inline-block; width: 22%; " />

##一些总结

1.	在string.xml文件中定义的常量给intent发送广播和给MyBroadcastReceiver静态注册时使用，但是MyBroadcastReceiver接收不到广播，只能在代码中写死了静态常量才有效
2.	上一个问题找到原因的方法是：Log.d(“hint”, “click send”)找到问题所在
3.	有两个app，其中一个发出广播两个都可以接收得到，原因是两个的inter-filter都相同，为不同的app定制intent-filter即可

##工程下载

传送门：[下载](http://pan.baidu.com/s/1nuxQ6Gp)