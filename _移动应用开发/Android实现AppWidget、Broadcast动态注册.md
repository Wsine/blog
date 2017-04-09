#Android实现AppWidget、Broadcast动态注册

开发工具：Andorid Studio 1.3
运行环境：Android 4.4 KitKat

##工程内容

1. 主界面可以编辑广播的信息，点击发送广播的按钮发送广播
2. 主页面上设置一个按钮进行广播接收器的注册与注销
3. 广播接收器若已被注册，发送的广播信息能够及时更新桌面上Widget上文字内容
4. 点击Widget可以跳转回主页面

##代码实现

添加一个自定义Widget类，继承自AppWidgetProvider，重写onUpdate函数，通过RemoteView对象修改Widget中的TextView的值，AppWidgetManager被调用更新Widget

```java
public class MyWidgetProvider extends AppWidgetProvider {
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds){
        super.onUpdate(context, appWidgetManager, appWidgetIds);

        Intent intent = new Intent(context, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, intent, 0);

        // Use RemoteView to update Widget
        RemoteViews remoteViews = new RemoteViews(context.getPackageName(), R.layout.widget_layout);

        remoteViews.setOnClickPendingIntent(R.id.widget_text, pendingIntent);
        // Update AppWidget
        appWidgetManager.updateAppWidget(appWidgetIds, remoteViews);
    }
}
```

添加一个自定义的广播接收器集成自BroadcastReceiver，重写onReceive函数，通过RemoteView对象修改Widget中的TextView的值为传入intent的消息，然后用AppWidgetManager发送RemoteView通知MyWidgetProvider更新内容

```java
public class MyBroadcastReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent){
        // Use RemoteViews to update Widget
        RemoteViews remoteViews = new RemoteViews(context.getPackageName(), R.layout.widget_layout);
        // Set editText
        remoteViews.setTextViewText(R.id.widget_text, intent.getStringExtra("message"));

        AppWidgetManager.getInstance(context).updateAppWidget(new ComponentName(context.getApplicationContext(),
                MyWidgetProvider.class), remoteViews);
    }
}
```

在MainActivity.java里面，新建一个MyBroadcastReceiver对象，给注册按钮添加响应动态注册和注销MyBroadcastReceiver，注册时设置的intentFilter内容需要和后面广播时一致

```java
final Button regBroCast = (Button)this.findViewById(R.id.regBroadcast);
regBroCast.setOnClickListener(new View.OnClickListener() {
    @Override
    public void onClick(View view) {
        if(isRegister){
            unregisterReceiver(myBroadcastReceiver);
            regBroCast.setText(getResources().getString(R.string.regBroadcast));
            isRegister = false;
        } else {
            registerReceiver(myBroadcastReceiver, new IntentFilter(getResources().getString(R.string.sysu)));
            regBroCast.setText(getResources().getString(R.string.unRegBroadcast));
            isRegister = true;
        }
    }
});
```

在MainActivity.java里面，给发送按钮添加响应，intent包中放入要修改的文字，给intent设置的文字需要和上面MyBroadcastReceiver中的intentFilter一致

```java
Button send = (Button)this.findViewById(R.id.send);
send.setOnClickListener(new View.OnClickListener() {
    @Override
    public void onClick(View view) {
        Intent intent = new Intent(getResources().getString(R.string.sysu));
        intent.putExtra("message", mainEditText.getText().toString());
        sendBroadcast(intent);
    }
});
```

至此，关键内容已列出，程序运行正常

记得注册组件

```java
<receiver
    android:name=".MyWidgetProvider"
    android:label="@string/app_name">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>

    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/widget_provider" />
</receiver>
```

##效果图

没注册时敲hello world并发送->界面没有内容出现->注册后发送->widget中出现hello world

<img src="http://images2015.cnblogs.com/blog/701997/201601/701997-20160129154658552-388074970.jpg" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201601/701997-20160129154703599-1141757332.jpg" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201601/701997-20160129154711739-1509549936.jpg" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201601/701997-20160129154719099-1205487377.jpg" alt="cant show" style="display: inline-block; width: 22%; " />

##一些总结

1.	新建一个widget的时候尽量使用代码自己添加，不要使用菜单new文件出来，android studio还不是很完善，new出来的widget附带很多不必要的东西，重载的时候会出错
2.	新建一个类的时候要注意不同的类放在哪个包里面，只有在同一个包中才能省略前面的包名，否则连接时需要敲上全部的包名及路径
3.	Widget中的默认样式没有底色，字体颜色也容易和背景融合在一块，所以便于我们调试开发，可以暂时把底色改成别的颜色，易于观察开发即可

##工程下载

传送门：[下载](http://pan.baidu.com/s/1kUkxnjL)