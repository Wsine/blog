# Android实现Button事件的处理

开发工具：Andorid Studio 1.3
运行环境：Android 4.4 KitKat

### 代码实现

首先是最基本的线性布局，给每个控件设立id值，以供代码中findViewById使用

```xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:paddingLeft="@dimen/activity_horizontal_margin" android:paddingRight="@dimen/activity_horizontal_margin"
    android:paddingTop="@dimen/activity_vertical_margin" android:paddingBottom="@dimen/activity_vertical_margin"
    android:orientation="vertical" tools:context=".LoginActivity"
    android:id="@+id/LinLayoutMain">
    <EditText
        android:layout_width="fill_parent"
        android:layout_height="wrap_content"
        android:id="@+id/editUsername"
        android:hint="@string/hint_username"/>
    <EditText
        android:layout_width="fill_parent"
        android:layout_height="wrap_content"
        android:id="@+id/editPassword"
        android:hint="@string/hint_password"/>
    <ImageButton
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:id="@+id/imaBtnSicily"
        android:src="@mipmap/state1"
        android:background="@color/backgroundWhit"/>
    <Button
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:id="@+id/reset"
        android:text="@string/reset"/>
</LinearLayout>
```

在界面创建的时候即onCreate的时候，绑定控件到全局变量中

```java
protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_login);

    linLayoutMain = (LinearLayout)this.findViewById(R.id.LinLayoutMain);

    edtUsername = (EditText)this.findViewById(R.id.editUsername);
    edtPassword = (EditText)this.findViewById(R.id.editPassword);

    imaBtnSicily = (ImageButton)this.findViewById(R.id.imaBtnSicily);
    imaBtnSicily.setOnClickListener(SicilyListener);

    btnreset = (Button)this.findViewById(R.id.reset);
    btnreset.setOnClickListener(ResetListener);

    DynamicTextViewCount = 0;
    imaBtnSicily.setOnLongClickListener(SicilyLongClickListener);
}
```

点击图片登陆的时候，用字符串getText().toString()函数得到用户名和密码，然后进一步判断，requestFocus()函数可以让焦点停留在想要的控件中，setImageDrawable()函数可以修改ImageButton中的图片，setVisibility()函数可以设置控件是否可见

```java
View.OnClickListener SicilyListener = new View.OnClickListener(){
    @Override
    public void onClick(View v){
        String username = edtUsername.getText().toString();
        String password = edtPassword.getText().toString();
        if(username.equals("LeiBusi") && password.equals("Halo3Q")){
            imaBtnSicily.setImageDrawable(getResources().getDrawable(R.mipmap.state2));
            edtUsername.setVisibility(View.GONE);
            edtPassword.setVisibility(View.GONE);
        }
        else{
            imaBtnSicily.setImageDrawable(getResources().getDrawable(R.mipmap.state1));
            edtPassword.setText(null);
            edtPassword.setHint(R.string.error_pawword);
            edtPassword.requestFocus();
        }
    }
};
```

长按图片的时候addview()函数可以动态添加控件，在这里我给每个TextView控件进行了一个编号，通过全局变量DynamicTextViewCount来计数。显示效果如上图所示

```java
View.OnLongClickListener SicilyLongClickListener = new View.OnLongClickListener(){
    @Override
    public boolean onLongClick(View v){
        try{
            TextView DynamicTextViewTemp = new TextView(LoginActivity.this);
            DynamicTextViewTemp.setText("这是动态添加的textView" + " " + Integer.toString(DynamicTextViewCount++));
            LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT,
                                                                                    ViewGroup.LayoutParams.WRAP_CONTENT);

            linLayoutMain.addView(DynamicTextViewTemp, layoutParams);
            Log.d("Hint", "Enter the try block");
        }
        catch (Exception e){
            Log.d("Hint", "Can't not add TextView by count");
            return false;
        }
        return true;
    }
};
```

清除按钮的功能是短按重置所有内容。这里主要在于对多个或0个TextView控件的删除功能，通过getChildCount()函数获知线性布局中有多少个子元素，通过removeViewAt()函数清除特定的控件

```java
View.OnClickListener ResetListener = new View.OnClickListener(){
    @Override
    public void onClick(View v){
        int childCount = linLayoutMain.getChildCount();
        while(DynamicTextViewCount > 0){
            linLayoutMain.removeViewAt(childCount - 1);
            childCount = linLayoutMain.getChildCount();
            DynamicTextViewCount--;
        }

        imaBtnSicily.setImageDrawable(getResources().getDrawable(R.mipmap.state1));

        edtUsername.setText(null);
        edtUsername.setHint(R.string.hint_username);
        edtUsername.setVisibility(View.VISIBLE);

        edtPassword.setText(null);
        edtPassword.setHint(R.string.hint_password);
        edtPassword.setVisibility(View.VISIBLE);

        edtUsername.requestFocus();
    }
};
```

### 效果图

<img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image310.jpg" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image311.jpg" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image312.jpg" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image313.jpg" alt="cant show" style="display: inline-block; width: 22%; " />
<img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image314.jpg" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image315.jpg" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image316.jpg" alt="cant show" style="display: inline-block; width: 22%; " />

### 一些总结

1. 字符串匹配相等的问题：在Java语言中，String类型没有对==这个操作符进行重载，但有特定的函数equal函数进行判断是否相等。
2. 用户名密码登陆不正确：R.string.right_username这个的实质是一个Int类型的常量，并不是String类型的常量。
3. 动态添加按钮只有一个：addView()函数中的控件必须是没被添加过的，因此哪怕是添加相同的按钮，也必须是在局部变量中new出来的一个新控件，函数结束后会被Java回收机制回收，因此每次new出来的都是没被添加过的。


### 工程下载

传送门：[下载](http://pan.baidu.com/s/1c0UwBNM)