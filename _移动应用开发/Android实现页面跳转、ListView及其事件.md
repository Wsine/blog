#Android实现页面跳转、ListView及其事件

开发工具：Andorid Studio 1.3
运行环境：Android 4.4 KitKat

##工程内容

1.	进入主页面后，使用ListView实现特定页面
2.	点击其中任何一项水果，跳转到另外一个活动，使用Intent转换活动，并使用Bundle传递数据，跳转到特定页面

##代码实现

首先在主页面的xml文件中添加ListView控件并给予id

```xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools" android:layout_width="match_parent"
    android:layout_height="match_parent" android:paddingLeft="@dimen/activity_horizontal_margin"
    android:paddingRight="@dimen/activity_horizontal_margin"
    android:paddingTop="@dimen/activity_vertical_margin"
    android:paddingBottom="@dimen/activity_vertical_margin" tools:context=".FruitList">

    <ListView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:id="@+id/fruitListView">
    </ListView>
</LinearLayout>
```

接着设计一个ListView中的Item，用线性水平布局加一个ImageView和一个TextView满足要求，适当调整一下图片的大小和文字的大小以及边距，使得好看一些

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="horizontal" android:layout_width="match_parent"
    android:layout_height="wrap_content">

    <ImageView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:id="@+id/fruit_image"
        android:adjustViewBounds="true"
        android:maxHeight="@dimen/fruit_image_size"
        android:maxWidth="@dimen/fruit_image_size"/>
    <TextView
        android:layout_width="fill_parent"
        android:layout_height="@dimen/fruit_image_size"
        android:paddingLeft="@dimen/activity_horizontal_margin"
        android:id="@+id/fruit_name"
        android:textSize="@dimen/fruit_name_size"
        android:gravity="center_vertical"/>
</LinearLayout>
```

在主类FruitList中获取ListView的控件，然后给List<Fruit>添加项，新建一个adapter绑定我们建的那个layout和List<Fruit>，最后绑定到ListView中

```java
fruitListView = (ListView)this.findViewById(R.id.fruitListView);

fruitList.add(new Fruit("apple", R.mipmap.apple));
fruitList.add(new Fruit("banana", R.mipmap.banana));
fruitList.add(new Fruit("cherry", R.mipmap.cherry));
fruitList.add(new Fruit("coco", R.mipmap.coco));
fruitList.add(new Fruit("kiwi", R.mipmap.kiwi));
fruitList.add(new Fruit("orange", R.mipmap.orange));
fruitList.add(new Fruit("pear", R.mipmap.pear));
fruitList.add(new Fruit("strawberry", R.mipmap.strawberry));
fruitList.add(new Fruit("watermelon", R.mipmap.watermelon));

FruitAdapter adapter = new FruitAdapter(FruitList.this, R.layout.fruit_item, fruitList);
fruitListView.setAdapter(adapter);
```

Class Fruit和class FruitAdapter的实现如下

```java
public class Fruit {
    private String name;
    private int imageId;

    public Fruit(String _name, int _imageId){
        this.name = _name;
        this.imageId = _imageId;
    }

    public String getName(){
        return this.name;
    }

    public int getImageId(){
        return this.imageId;
    }
}

public class FruitAdapter extends ArrayAdapter<Fruit> {
    private int resourceId;

    public FruitAdapter(Context context, int textViewResourceId, List<Fruit> fruits){
        super(context, textViewResourceId, fruits);
        this.resourceId = textViewResourceId;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent){
        Fruit fruit = getItem(position);
        View view = LayoutInflater.from(this.getContext()).inflate(resourceId, null);
        ImageView fruitImage = (ImageView)view.findViewById(R.id.fruit_image);
        TextView fruitName = (TextView)view.findViewById(R.id.fruit_name);

        fruitImage.setImageResource(fruit.getImageId());
        fruitName.setText(fruit.getName());

        return view;
    }
}
```

点击某一个水果的响应是获取水果的名字，加入到一个Bundle中去，然后绑定到一个Intent，传递到另一个界面

```java
fruitListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        ListView listView = (ListView) parent;
        Fruit fruit = (Fruit) listView.getItemAtPosition(position);
        String name = fruit.getName();

        Intent intent = new Intent(FruitList.this, ShowFruitActivity.class);
        Bundle bundle = new Bundle();
        bundle.putString("name", name);
        intent.putExtras(bundle);
        startActivity(intent);
        //FruitList.this.finish();
    }
});
```

长按某一个水果的响应是：找到点击的水果，然后在适配器中删除这一水果，然后适配器发出改变通知，ListView更新删除后的状态

```java
fruitListView.setOnItemLongClickListener(new AdapterView.OnItemLongClickListener() {
    @Override
    public boolean onItemLongClick(AdapterView<?> parent, View view, int position, long id) {
        try {
            ListView listView = (ListView) parent;
            Fruit fruit = (Fruit) listView.getItemAtPosition(position);
            FruitAdapter adapter = (FruitAdapter)listView.getAdapter();
            adapter.remove(fruit);
            adapter.notifyDataSetChanged();
            listView.invalidate();
        } catch (Exception e) {
            Log.d("Hint", "Remove failed!");
            return false;
        }
        return true;
    }
});
```

显示界面中获取传入的Bundle，修改textView中的值即可，给Button添加返回响应

```java
protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_show_fruit);

    Bundle bundle = getIntent().getExtras();
    String name = bundle.getString("name");

    TextView textView = (TextView)this.findViewById(R.id.show_fruit_name);
    textView.setText("I love " + name + " !!!");
    Button button = (Button)this.findViewById(R.id.btnBack);
    button.setOnClickListener(new View.OnClickListener() {
        @Override
        public void onClick(View view) {
            //Intent intent = new Intent(ShowFruitActivity.this, Fruit.class);
            //startActivity(intent);
            ShowFruitActivity.this.finish();
        }
    });
}
```

##效果图

初始状态->点击cherry->跳转页面->点击Back ->回到上一个界面->长按banana->删除条目

<img src="http://images2015.cnblogs.com/blog/701997/201601/701997-20160129151723864-790413298.jpg" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201601/701997-20160129151729146-913600329.jpg" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201601/701997-20160129151739099-1887175644.jpg" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201601/701997-20160129151743177-965886348.jpg" alt="cant show" style="display: inline-block; width: 22%; " />

##一些总结

1. Import某一个包尽量利用Tab键的自动补全功能，Android Studio会自动添加包进来
2. 创建新的一个界面用File->new的方法，避免了手动修改AndroidManifest.xml的错误
3. Intent之间进行跳转有技巧，主界面跳转后不需要调用finish函数，而跳转显示的界面只需要调用finish结束即可回到上一个界面，即主界面
4. 删除功能要在适配器中删除条目才有效，这点通过OverflowStack找到了解决方案，之前一直都不能成功

**分别说明活动生存期在什么时候调用下列函数**

- onCreate()
	活动被创建的时候或者进程被杀死后用户重新启动该活动时，调用这个函数。
- onStart()
	在onCreate()或onRestart()函数调用完成后，仅接着调用这个函数。
- onResume()
	在onResume()函数调用完成后或被pause的活动重新回到前台时，仅接着调用这个函数。
- onPause()
	当从一个activity跳转到另一个activity的时候，当前activity会调用这个函数。
- onStop()
	如果一个已经start的活动长时间没有出现在屏幕中，则调用这个函数。
- onDestory()
	当一个已经stop的活动关闭被系统回收资源的时候，调用这个函数
- onRestart()
	当一个已经stop的活动需要重新显示在屏幕的时候，调用这个函数

引用一张图来说明，图片来自水印：
![feisky](http://images.cnblogs.com/cnblogs_com/feisky/WindowsLiveWriter/6aad9ec8a679_D53B/activity_lifecycle_2.png)

**活动的启动模式有四种，standard,singleTop,singleTask以及singleInstance，列表说明不同的启动方式有什么不同**

| 活动模式|     区别|
| :-------- | :--------|
| standard|   默认模式。只要创建了Activity实例，一旦激活该Activity，则会向任务栈中加入新创建的实例，退出Activity则会在任务栈中销毁该实例|
| singleTop|   考虑当前要激活的Activity实例在任务栈中是否正处于栈顶，如果处于栈顶则无需重新创建新的实例，会重用已存在的实例，否则会在任务栈中创建新的实例|
| singleTask|   如果任务栈中存在该模式的Activity实例，则把栈中该实例以上的Activity实例全部移除，调用该实例的newInstance()方法重用该Activity，使该实例处於栈顶位置，否则就重新创建一个新的Activity实例|
| singleInstance|   Activity实例在任务栈中创建后，只要该实例还在任务栈中，即只要激活的是该类型的Activity，都会通过调用实例的newInstance()方法重用该Activity，此时使用的都是同一个Activity实例，它都会处于任务栈的栈顶。此模式一般用于加载较慢的，比较耗性能且不需要每次都重新创建的Activity|


##工程下载

传送门：[下载](http://pan.baidu.com/s/1c1wgTv6)