# Android实现简单音乐播放器(MediaPlayer)

开发工具：Andorid Studio 1.3
运行环境：Android 4.4 KitKat

## 工程内容

实现一个简单的音乐播放器，要求功能有：
- 播放、暂停功能；
- 进度条显示播放进度功能
- 拖动进度条改变进度功能；
- 后台播放功能；
- 停止功能；
- 退出功能；

## 代码实现

导入歌曲到手机SD卡的Music目录中，这里我导入了4首歌曲：仙剑六里面的《誓言成晖》、《剑客不能说》、《镜中人》和《浪花》，也推荐大家听喔（捂脸

然后新建一个类MusicService继承Service，在类中定义一个MyBinder，有一个方法用于返回MusicService本身，在重载onBind()方法的时候返回

```java
public class MusicService extends Service {

    public final IBinder binder = new MyBinder();
    public class MyBinder extends Binder{
        MusicService getService() {
            return MusicService.this;
        }
    }

    @Override
    public IBinder onBind(Intent intent) {
        return binder;
    }
}
```

在MusicService中，声明一个MediaPlayer变量，进行设置歌曲路径，这里我选择歌曲1作为初始化时候的歌曲

```java
private String[] musicDir = new String[]{
        Environment.getExternalStorageDirectory().getAbsolutePath() + "/Music/仙剑奇侠传六-主题曲-《誓言成晖》.mp3",
        Environment.getExternalStorageDirectory().getAbsolutePath() + "/Music/仙剑奇侠传六-主题曲-《剑客不能说》.mp3",
        Environment.getExternalStorageDirectory().getAbsolutePath() + "/Music/仙剑奇侠传六-主题曲-《镜中人》.mp3",
        Environment.getExternalStorageDirectory().getAbsolutePath() + "/Music/仙剑奇侠传六-主题曲-《浪花》.mp3"};
private int musicIndex = 1;

public static MediaPlayer mp = new MediaPlayer();
public MusicService() {
    try {
        musicIndex = 1;
        mp.setDataSource(musicDir[musicIndex]);
        mp.prepare();
    } catch (Exception e) {
        Log.d("hint","can't get to the song");
        e.printStackTrace();
    }
}
```

设计一些歌曲播放、暂停、停止、退出相应的逻辑，此外我还设计了上一首和下一首的逻辑

```java
public void playOrPause() {
    if(mp.isPlaying()){
        mp.pause();
    } else {
        mp.start();
    }
}
public void stop() {
    if(mp != null) {
        mp.stop();
        try {
            mp.prepare();
            mp.seekTo(0);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
public void nextMusic() {
    if(mp != null && musicIndex < 3) {
        mp.stop();
        try {
            mp.reset();
            mp.setDataSource(musicDir[musicIndex+1]);
            musicIndex++;
            mp.prepare();
            mp.seekTo(0);
            mp.start();
        } catch (Exception e) {
            Log.d("hint", "can't jump next music");
            e.printStackTrace();
        }
    }
}
public void preMusic() {
    if(mp != null && musicIndex > 0) {
        mp.stop();
        try {
            mp.reset();
            mp.setDataSource(musicDir[musicIndex-1]);
            musicIndex--;
            mp.prepare();
            mp.seekTo(0);
            mp.start();
        } catch (Exception e) {
            Log.d("hint", "can't jump pre music");
            e.printStackTrace();
        }
    }
}
```

注册MusicService并赋予权限，允许读取外部存储空间

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>

<service android:name="com.wsine.west.exp5_AfterClass.MusicService" android:exported="true"></service>
```

在MainAcitvity中声明ServiceConnection，调用bindService保持与MusicService通信，通过intent的事件进行通信，在onCreate()函数中绑定Service

```java
private ServiceConnection sc = new ServiceConnection() {
    @Override
    public void onServiceConnected(ComponentName componentName, IBinder iBinder) {
        musicService = ((MusicService.MyBinder)iBinder).getService();
    }

    @Override
    public void onServiceDisconnected(ComponentName componentName) {
        musicService = null;
    }
};
private void bindServiceConnection() {
    Intent intent = new Intent(MainActivity.this, MusicService.class);
    startService(intent);
    bindService(intent, sc, this.BIND_AUTO_CREATE);
}

@Override
protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_main);

    Log.d("hint", "ready to new MusicService");
    musicService = new MusicService();
    Log.d("hint", "finish to new MusicService");
    bindServiceConnection();

    seekBar = (SeekBar)this.findViewById(R.id.MusicSeekBar);
    seekBar.setProgress(musicService.mp.getCurrentPosition());
    seekBar.setMax(musicService.mp.getDuration());

    musicStatus = (TextView)this.findViewById(R.id.MusicStatus);
    musicTime = (TextView)this.findViewById(R.id.MusicTime);

    btnPlayOrPause = (Button)this.findViewById(R.id.BtnPlayorPause);

    Log.d("hint", Environment.getExternalStorageDirectory().getAbsolutePath()+"/You.mp3");
}
```

bindService函数回调onSerciceConnented函数，通过MusiceService函数下的onBind()方法获得binder对象并实现绑定

通过Handle实时更新UI，这里主要使用了post方法并在Runnable中调用postDelay方法实现实时更新UI，Handle.post方法在onResume()中调用，使得程序刚开始时和重新进入应用时能够更新UI

在Runnable中更新SeekBar的状态，并设置SeekBar滑动条的响应函数，使歌曲跳动到指定位置

```java
public android.os.Handler handler = new android.os.Handler();
public Runnable runnable = new Runnable() {
    @Override
    public void run() {
        if(musicService.mp.isPlaying()) {
            musicStatus.setText(getResources().getString(R.string.playing));
            btnPlayOrPause.setText(getResources().getString(R.string.pause).toUpperCase());
        } else {
            musicStatus.setText(getResources().getString(R.string.pause));
            btnPlayOrPause.setText(getResources().getString(R.string.play).toUpperCase());
        }
        musicTime.setText(time.format(musicService.mp.getCurrentPosition()) + "/"
                + time.format(musicService.mp.getDuration()));
        seekBar.setProgress(musicService.mp.getCurrentPosition());
        seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (fromUser) {
                    musicService.mp.seekTo(seekBar.getProgress());
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });
        handler.postDelayed(runnable, 100);
    }
};

@Override
protected void onResume() {
    if(musicService.mp.isPlaying()) {
        musicStatus.setText(getResources().getString(R.string.playing));
    } else {
        musicStatus.setText(getResources().getString(R.string.pause));
    }

    seekBar.setProgress(musicService.mp.getCurrentPosition());
    seekBar.setMax(musicService.mp.getDuration());
    handler.post(runnable);
    super.onResume();
    Log.d("hint", "handler post runnable");
}
```

给每个按钮设置响应函数，在onDestroy()中添加解除绑定，避免内存泄漏

```java
public void onClick(View view) {
    switch (view.getId()) {
        case R.id.BtnPlayorPause:
            musicService.playOrPause();
            break;
        case R.id.BtnStop:
            musicService.stop();
            seekBar.setProgress(0);
            break;
        case R.id.BtnQuit:
            handler.removeCallbacks(runnable);
            unbindService(sc);
            try {
                System.exit(0);
            } catch (Exception e) {
                e.printStackTrace();
            }
            break;
        case R.id.btnPre:
            musicService.preMusic();
            break;
        case R.id.btnNext:
            musicService.nextMusic();
            break;
        default:
            break;
    }
}

@Override
public void onDestroy() {
    unbindService(sc);
    super.onDestroy();
}
```

在Button中赋予onClick属性指向接口函数

```xml
<Button
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:id="@+id/BtnPlayorPause"
    android:text="@string/btnPlayorPause"
    android:onClick="onClick"/>
```


## 效果图

打开界面->播放一会儿进度条实时变化->拖动进度条->点击暂停->点击Stop->点击下一首（歌曲时间变化）->点击上一首->点击退出

<img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image363.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image364.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image365.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image366.png" alt="cant show" style="display: inline-block; width: 22%; " />
<img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image367.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image368.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image369.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image370.png" alt="cant show" style="display: inline-block; width: 22%; " />

## 一些总结

1.	读取SD卡内存的时候，应该使用android.os.Environment库中的getExternalStorageDirectory()方法，然而并不能生效。应该再使用getAbsolutePath()获取绝对路径后读取音乐才生效。
2.	切换歌曲的时候try块不能正确执行。检查过后，也是执行了stop()函数后再重新setDataSource()来切换歌曲的，但是没有效果。查阅资料后，发现setDataSource()之前需要调用reSet()方法，才可以重新设置歌曲

**了解Service中startService(service)和bindService(service, conn, flags)两种模式的执行方法特点及其生命周期，还有为什么这次要一起用**

startService方法是让Service启动，让Service进入后台running状态；但是这种方法，service与用户是不能交互的，更准确的说法是，service与用户不能进行直接的交互。
因此需要使用bindService方法绑定Service服务，bindService返回一个binder接口实例，用户就可以通过该实例与Service进行交互。

Service的生命周期简单到不能再简单了，一条流水线表达了整个生命周期。
service的活动生命周期是在onStart()之后，这个方法会处理通过startServices()方法传递来的Intent对象。音乐service可以通过开打intent对象来找到要播放的音乐，然后开始后台播放。注： service停止时没有相应的回调方法，即没有onStop()方法，只有onDestroy()销毁方法。
onCreate()方法和onDestroy()方法是针对所有的services，无论它们是否启动，通过Context.startService()和Context.bindService()方法都可以访问执行。然而，只有通过startService()方法启动service服务时才会调用onStart()方法。

![Service](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image371.png)
图片来自网络，忘记出处了

**简述如何使用Handler实时更新UI**

方法一：
Handle的post方法，在post的Runable的run方法中，使用postDelay方法再次post该Runable对象，在Runable中更新UI，达到实时更新UI的目的
方法二：
多开一个线程，线程写一个持续循环，每次进入循环内即post一次Runable，然后休眠1000ms，亦可做到实时更新UI

## 工程下载

传送门：[下载](http://pan.baidu.com/s/1skoWvnf)