# Android实现SharePreferences和AutoCompletedTextView

开发工具：Andorid Studio 1.3
运行环境：Android 4.4 KitKat

## 工程内容

1.	登录界面，使用SharedPreferences记录登陆状态，点击Register按钮，能够将User和Password写入SharedPreferences，写入后使用Toast提示写入成功
2.	注册账号成功后，输入账号和密码，点击登陆按钮，若账号与密码正确，则跳转到文件操作界面，否则使用Toast提示登陆错误
3.	文件操作界面返回登录界面时，如果Remember Password CheckBox没有勾上，则Password控件不保存相应的信息，否则将SharedPreferences保存的信息自动填上相应的控件
4.	使用AutoCompletedTextView实现文件自动提示功能，如果文件存在，则该匹配的文件自动在AutoCompletedTextView下生成
5.	在FileContent下输入文件的内容，点击Save File后能够自动保存文件，并且文件名自动提示已经更新；点击ReadFile按钮能够自动读取文件保存的数据，并将内容显示在File Content控件下面
6.	点击Delete File控件能够删除文件，并且文件名自动提示已经更新，重新点击Read File，发现已经不能够读取文件内容了
7.	检查是否成功生成文件

## 代码实现

新建一个类Filetils作为工具类，让别的类调用以进行文件操作。主要功能有三点：

- 保存文件
	使用FileOutputStream把字符串写入到指定文件名的地方，权限设置为仅该程序私有，把String类型转为byte数组类型保存
```java
	public void saveContent(Context context, String fileName, String fileText) {
    try {
        FileOutputStream fos = context.openFileOutput(fileName, Context.MODE_PRIVATE);
        fos.write(fileText.getBytes());
        fos.close();
        Toast.makeText(context, context.getResources().getString(R.string.msgSaveSuc), Toast.LENGTH_SHORT).show();
    } catch (IOException e) {
        Toast.makeText(context, context.getResources().getString(R.string.msgSaveFail), Toast.LENGTH_SHORT).show();
        e.printStackTrace();
    }
}
```
- 读取文件
	使用FileInputStream从指定地方读取文件，写入到一个byte数组中，用byte数组为构造参数构建String类型返回

```java
public String getContent(Context context, String fileName) {
    try{
        FileInputStream fis = context.openFileInput(fileName);
        byte[] contents = new byte[fis.available()];
        fis.read(contents);
        fis.close();
        Toast.makeText(context, context.getResources().getString(R.string.msgReadSuc), Toast.LENGTH_SHORT).show();
        return new String(contents);
    } catch (IOException e) {
        Toast.makeText(context, context.getResources().getString(R.string.msgReadFail), Toast.LENGTH_SHORT).show();
        e.printStackTrace();
        return new String("");
    }
}
```

- 删除文件
	用Context对象中的deleteFile()方法删除指定文件名即可
```java
public void deleteFile(Context context, String fileName) {
    context.deleteFile(fileName);
    Toast.makeText(context, context.getResources().getString(R.string.msgDelSuc), Toast.LENGTH_SHORT).show();
}
```

为每个界面的按钮设置响应函数

注册按钮点击响应函数：
使用SharedPreferences对象的Editor对象操作保存数据，每次保存后必须提交一遍，提示注册语

```java
Button btnRegister = (Button)this.findViewById(R.id.btnRegister);
btnRegister.setOnClickListener(new View.OnClickListener() {
    @Override
    public void onClick(View view) {
        try {
            String usr = edtUsr.getText().toString();
            String pwd = edtPwd.getText().toString();
            if(usr.isEmpty() || pwd.isEmpty()) {
                throw new Exception();
            }
            editor.putString("username", usr);
            editor.putString("password", pwd);
            editor.commit();
            Toast.makeText(getApplicationContext(), getResources().getString(R.string.msgRegSuc), Toast.LENGTH_SHORT).show();
        } catch (Exception e) {
            e.printStackTrace();
            Toast.makeText(getApplicationContext(), getResources().getString(R.string.msgRegFail), Toast.LENGTH_SHORT).show();
        }
    }
});
```

登陆按钮点击响应函数：
判断username和password是否和使用SharedPreferences保存的内容相同，如相同，则新建一个Intent对象跳转页面，并设置字段为空，finish掉当前页面，提示登录语

```java
final Button btnLogin = (Button)this.findViewById(R.id.btnLogin);
btnLogin.setOnClickListener(new View.OnClickListener() {
    @Override
    public void onClick(View view) {
        String usr = edtUsr.getText().toString();
        String pwd = edtPwd.getText().toString();
        if(usr.equals(sp.getString("username", null)) && pwd.equals(sp.getString("password", null))) {
            Intent intent = new Intent(LoginActivity.this, EditFileActivity.class);
            startActivity(intent);
            edtUsr.setText("");
            edtPwd.setText("");
            LoginActivity.this.finish();
        } else {
            Toast.makeText(getApplicationContext(), getResources().getString(R.string.msgLogErr), Toast.LENGTH_SHORT).show();
        }
    }
});
```

选择框状态改变响应函数：
使用SharedPreferences记录当前选择状态，如果是选择状态，判断用户名是否和注册的用户名相匹配，如果匹配，则自动填充密码

```java
chboxRem = (CheckBox)this.findViewById(R.id.chboxRemPwd);
chboxRem.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
    @Override
    public void onCheckedChanged(CompoundButton compoundButton, boolean isChecked) {
        editor.putBoolean("isChecked", isChecked);
        editor.commit();
        if(isChecked && edtUsr.getText().toString().equals(sp.getString("username", null))) {
            edtPwd.setText(sp.getString("password", null));
        }
    }
});
```

保存文件按钮点击响应函数：
使用工具类FileUtil中的saveContent方法保存成文件，然后必须更新AutoCompletedTextView的适配器，（这里使用新数组代替，旧数组会被系统资源回收）

```java
case R.id.btnSaveFile:
    fileUtils.saveContent(EditFileActivity.this, fileName.getText().toString(),
            fileContent.getText().toString());
    fileName.setAdapter(new ArrayAdapter<String>(EditFileActivity.this,
            android.R.layout.simple_dropdown_item_1line, EditFileActivity.this.fileList()));
    break;
```

读取文件按钮点击响应函数：
使用工具类FileUtil中的readContent方法读取文件，并将内容设置到fileContent的一个EditText中，如果文件不存在，则返回空内容

```java
case R.id.btnReadFile:
    String contents = fileUtils.getContent(EditFileActivity.this, fileName.getText().toString());
    fileContent.setText(contents);
    break;
```

删除文件按钮点击相应函数：
使用工具类FileUtil中的deleteContent方法删除指定文件，然后必须更新AutoCompletedTextView的适配器，（这里使用新数组代替，旧数组会被系统资源回收）

```java
case R.id.btnDeleteFile:
    fileUtils.deleteFile(EditFileActivity.this, fileName.getText().toString());
    fileName.setAdapter(new ArrayAdapter<String>(EditFileActivity.this,
            android.R.layout.simple_dropdown_item_1line, EditFileActivity.this.fileList()));
    break;
```

AutoCompletedTextView中Item点击响应函数：
为了提高用户体验，当用户点击Item后应当自动填充所选内容，把系统输入法隐藏，这里使用AutoCompletedTextView中的setOnItemClickListener方法，使用InputMethodManager获取系统服务，检查输入法是否开启状态，如开启，则隐藏输入法

```java
fileName.setOnItemClickListener(new AdapterView.OnItemClickListener() {
    @Override
    public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
        InputMethodManager imm = (InputMethodManager)getSystemService(Context.INPUT_METHOD_SERVICE);
        if(imm.isActive()) {
            imm.hideSoftInputFromWindow(EditFileActivity.this.getCurrentFocus().getWindowToken(),
                    InputMethodManager.HIDE_NOT_ALWAYS);
        }
    }
});
```

当用户处于文件编辑界面时，点击返回按钮主动注销界面，这里自己重载这个返回按钮响应

```java
@Override
public boolean onKeyDown(int keyCode, KeyEvent event) {
    if(keyCode == KeyEvent.KEYCODE_BACK) {
        Intent intent = new Intent(EditFileActivity.this, LoginActivity.class);
        startActivity(intent);
        EditFileActivity.this.finish();
    }
    return true;
}
```

当用户从文件编辑界面回退到登陆界面的时候，如果之前选择了保存密码，则需要将内容填充回相应的区域，否则仅填充用户名，密码字段填充为空，这里使用onResume()函数重载，同时保证checkbox控件也是逻辑同步的

```java
@Override
protected void onResume() {
    super.onResume();
    if(sp.getBoolean("isChecked", false)) {
        edtUsr.setText(sp.getString("username", null));
        edtPwd.setText(sp.getString("password", null));
        chboxRem.setChecked(true);
    } else {
        edtUsr.setText(sp.getString("username", null));
        edtPwd.setText("");
        chboxRem.setChecked(false);
    }
}
```

## 效果图

初始化界面->填入账号密码(掩码)并选择记住密码->点击登陆正确则跳转页面->输入部分提示

<img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image323.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image324.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image325.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image326.png" alt="cant show" style="display: inline-block; width: 22%; " />

点击读取文件->新建并保存文件->删除文件->重新读取返回失败

<img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image327.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image328.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image329.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image330.png" alt="cant show" style="display: inline-block; width: 22%; " />

返回按钮登陆信息还在(页面已注销了的)->取消记住密码->登陆跳转->返回按钮登陆密码消失

<img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image331.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image332.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image333.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="https://wsine.cn-gd.ufileos.com/image/wsine-blog-image334.png" alt="cant show" style="display: inline-block; width: 22%; " />

## 一些总结

1.	测试的时候由于跳转页面时没有清除当前页面，导致返回原界面的时候用户名和密码都还在，解决方案是跳转页面后，清除用户名和密码两个字段，同时注销页面
2.	测试AutuCompletedTextView的时候，输入法的响应令人比较苦恼，明明已经自动填充完毕，输入法还处在这个界面，这用户体验不能忍，然后就加入了AutuCompletedTextView的Item点击响应
3.	还发现一个问题就在于，界面在onResume的时候检测保存的isChecked是否为true，如果为true则填充用户名和密码，但是checkbox的状态并没有更新，例如退出app后重新进入只有username和password是填充了，checkbox并没有，因此修改了上面的onResume函数重载的代码，更加符合实际

## 工程下载

传送门：[下载](http://pan.baidu.com/s/1hrnSPqk)