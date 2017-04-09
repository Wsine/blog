#Android实现简单拨号器

开发工具：Andorid Studio 1.3
运行环境：Android 4.4 KitKat

##代码实现

界面布局只有GridLayout和EditText两个控件，全部Button都是动态添加

```xml
<GridLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="wrap_content" android:layout_height="wrap_content"
    android:paddingLeft="@dimen/activity_horizontal_margin" android:paddingRight="@dimen/activity_horizontal_margin"
    android:paddingTop="80dp" android:paddingBottom="@dimen/activity_vertical_margin"
    android:orientation="horizontal" android:rowCount="6"
    android:columnCount="3" android:layout_gravity="center"
    android:id="@+id/girdLayoutMain" tools:context=".CallPhone">

    <EditText
        android:layout_columnSpan="3"
        android:layout_gravity="fill_horizontal"
        android:layout_width="match_parent"
        android:maxWidth="600px"
        android:singleLine="false"
        android:maxLines="3"
        android:editable="false"
        android:textSize="30dp"
        android:gravity="center"
        android:id="@+id/edtPhoneNumber"/>
</GridLayout>
```

动态添加按钮，通过for循环从1到9，给 Button设置Tag值以示区分，根据网格中i对应的关系找到位置，填充整个网格，并绑定响应

```java
for(int i = 1; i <= 9; i++){
    Button btnNumber = new Button(this);
    btnNumber.setTag(i);
    btnNumber.setText(Integer.toString(i));
    btnNumber.setMinWidth(minButtonWidth);
    btnNumber.setMinHeight(minButtonHeight);
    btnNumber.setOnClickListener(numClickListener);
    GridLayout.Spec rowSpec = GridLayout.spec((i - 1) / 3 + 1);
    GridLayout.Spec colSpec = GridLayout.spec((i - 1) % 3);
    GridLayout.LayoutParams layoutParams = new GridLayout.LayoutParams(rowSpec, colSpec);
    layoutParams.setGravity(Gravity.FILL);
    gridLayout.addView(btnNumber, layoutParams);
}
```

为* 0 # 呼叫 清除 特别设置Text内容，其中，呼叫按钮占两个网格，需要特别设置

```java
for(int i = 10; i <= 14; i++){
    Button btnOther = new Button(this);
    btnOther.setTag(i);
    btnOther.setMinWidth(minButtonWidth);
    btnOther.setMinHeight(minButtonHeight);
    switch (i){
        case 10:
            btnOther.setText("*");
            btnOther.setOnClickListener(numClickListener);
            break;
        case 11:
            btnOther.setText("0");
            btnOther.setOnClickListener(numClickListener);
            break;
        case 12:
            btnOther.setText("#");
            btnOther.setOnClickListener(numClickListener);
            break;
        case 13:
            btnOther.setText(R.string.str_call);
            btnOther.setOnClickListener(callClickListener);
            break;
        case 14:
            btnOther.setText(R.string.str_clear);
            btnOther.setOnTouchListener(clearTouchListener);
            break;
        default:
            break;
    }

    if(i == 13){
        GridLayout.Spec rowSpec = GridLayout.spec((i - 1) / 3 + 1);
        GridLayout.Spec colSpec = GridLayout.spec((i - 1) % 3, 2);
        GridLayout.LayoutParams layoutParams = new GridLayout.LayoutParams(rowSpec, colSpec);
        layoutParams.setGravity(Gravity.FILL);
        gridLayout.addView(btnOther, layoutParams);
    } else if(i == 14){
        GridLayout.Spec rowSpec = GridLayout.spec((i - 1) / 3 + 1);
        GridLayout.Spec colSpec = GridLayout.spec((i - 1) % 3);
        GridLayout.LayoutParams layoutParams = new GridLayout.LayoutParams(rowSpec, colSpec);
        layoutParams.setGravity(Gravity.FILL);
        gridLayout.addView(btnOther);
    } else{
        GridLayout.Spec rowSpec = GridLayout.spec((i - 1) / 3 + 1);
        GridLayout.Spec colSpec = GridLayout.spec((i - 1) % 3);
        GridLayout.LayoutParams layoutParams = new GridLayout.LayoutParams(rowSpec, colSpec);
        layoutParams.setGravity(Gravity.FILL);
        gridLayout.addView(btnOther, layoutParams);
    }
}
```

普通数字和特别字符只需要在字符串尾端添加相应字符，再设置Text内容即可

```java
View.OnClickListener numClickListener = new View.OnClickListener() {
    @Override
    public void onClick(View v) {
        String phoneNumber = edtPhoneNumber.getText().toString();
        int tag = (Integer)v.getTag();
        if(tag <= 9){
            phoneNumber += Integer.toString(tag);
        }else if(tag == 10){
            phoneNumber += "*";
        }else if(tag == 11){
            phoneNumber += "0";
        } else if(tag == 12){
            phoneNumber += "#";
        }
        edtPhoneNumber.setText(phoneNumber);
        edtPhoneNumber.clearFocus();
    }
};
```

呼叫按钮，需要在Manifest.xml文件中申请拨打电话权限，字符串不为空即可拨打电话，如为空，通过Toast控件给予用户提示

```java
<uses-permission android:name="android.permission.CALL_PHONE" />
View.OnClickListener callClickListener = new View.OnClickListener(){
    @Override
    public void onClick(View v){
        String phoneNumber = edtPhoneNumber.getText().toString();
        try{
            if(!phoneNumber.isEmpty()) {
                Intent intent = new Intent(Intent.ACTION_CALL, Uri.parse("tel:" + phoneNumber));
                startActivity(intent);
            }else{
                Toast toast = Toast.makeText(CallPhone.this, "请输入号码", Toast.LENGTH_LONG);
                toast.setGravity(Gravity.TOP, 0, 150);
                toast.show();
            }
        } catch (Exception e) {
            Log.d("Hint", "Call phone number is empty");
        }
    }
};
```

清除按钮，OnTouchListener，两种响应方式：点击的时候记录下点击的当前时间，并修改button的颜色为红色，提高用户体验；放开手指的时候，用当前时间和记录时间相比，如果小于800ms，则认为是短按，仅清除一个字符（判断字符是否为空），如果大于800ms，则认为是长按，清除整个字符串，手指离开时修改button为原本的默认样式

```java
private long touchTime = 0;
private Drawable originButtonColor;
View.OnTouchListener clearTouchListener = new View.OnTouchListener() {
    @Override
    public boolean onTouch(View v, MotionEvent event) {
        if(event.getAction() == MotionEvent.ACTION_DOWN) {
            touchTime = event.getEventTime();
            originButtonColor = v.getBackground();
            v.setBackgroundColor(Color.RED);
            return true;
        } else if(event.getAction() == MotionEvent.ACTION_UP){
            long subStaTime = event.getEventTime() - touchTime;
            v.setBackground(originButtonColor);
            if(subStaTime < 800){
                try{
                    String phoneNumber = edtPhoneNumber.getText().toString();
                    if(!phoneNumber.isEmpty()){
                        String temp = phoneNumber.substring(0, phoneNumber.length() - 1);
                        edtPhoneNumber.setText(temp);
                        edtPhoneNumber.clearFocus();
                    }
                    Log.d("Hint", "Clear a char successfully");
                }catch (Exception e){
                    Log.d("Hint", "Can't clear no char");
                    return false;
                }
                return true;
            } else{
                edtPhoneNumber.setText(null);
                return true;
            }
        }
        return false;
    }
};
```



##效果图

初始界面->依次输入->短按清除->长按清除

<img src="http://images2015.cnblogs.com/blog/701997/201601/701997-20160129144927833-1424051815.jpg" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201601/701997-20160129144933349-1566338237.jpg" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201601/701997-20160129144938489-230455039.jpg" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201601/701997-20160129144944130-762308960.jpg" alt="cant show" style="display: inline-block; width: 22%; " />

空白呼叫->最长三行->输入电话号码->成功呼叫

<img src="http://images2015.cnblogs.com/blog/701997/201601/701997-20160129144948677-1936642997.jpg" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201601/701997-20160129144953239-592553562.jpg" alt="cant show" style="display: inline-block; width: 22%; " /><img src="http://images2015.cnblogs.com/blog/701997/201601/701997-20160129144957614-1378734194.jpg" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201601/701997-20160129145002161-181732559.jpg" alt="cant show" style="display: inline-block; width: 22%; " />

##一些总结

1. 字符串变长的时候按钮控件也会变宽：通过设置button的最小宽度和最大宽度可以固定按钮的大小，这里我让EditText变为允许多行输入，行宽最大值与按钮齐宽。
2. 一个按钮占两个网格：在以前的API中，通过设置Gravity的大小或者setColumnConent()函数可以修改达到目的，这也是博客中多使用的方法；在新版的API中，通过设置colspec中的第二个参数达到目的，通过翻阅API中文论坛查询得知。


##工程下载

传送门：[下载](http://pan.baidu.com/s/1mhlHkSw)