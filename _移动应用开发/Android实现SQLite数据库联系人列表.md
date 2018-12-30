# Android实现SQLite数据库联系人列表

开发工具：Andorid Studio 1.3
运行环境：Android 4.4 KitKat

## 工程内容

实现一个通讯录查看程序：
1.	要求使用SQLite数据库保存通讯录，使得每次运行程序均能显示当前联系人的列表
2.	主界面包含一个添加联系人按钮和一个联系人列表，每一项显示联系人学号，姓名，手机号码。
3.	点击添加联系人按钮能添加新的联系人。
4.	在次界面输入联系人信息之后点击确定按钮后会返回主界面。（前提输入正确）
5.	长按某个联系人，弹出对话框，询问是否删除该联系人。
6.	单击某个联系人，弹出修改联想人的界面。

## 代码实现

为联系人添加一个类Contact，封装学号姓名手机号码三个字段，并重构三个构造函数，给每个字段设置公有的get、set函数，这是类最标准的做法。

```java
public class Contact {
    private String no;
    private String name;
    private String phoneNumber;

    public Contact() {}
    public Contact(String _name, String _phoneNumber) {
        this.name = _name;
        this.phoneNumber = _phoneNumber;
    }
    public Contact(String _no, String _name, String _phoneNumber) {
        this.no = _no;
        this.name = _name;
        this.phoneNumber = _phoneNumber;
    }

    public String getNo() { return no; }
    public void setNo(String _no) { this.no = _no; }
    public String getName() { return name; }
    public void setName(String _name) { this.name = _name; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String _phoneNumber) { this.phoneNumber = _phoneNumber; }

}
```

为接下来要用到的数据库方法新建一个类MyDatabaseHelper继承自SQLiteOpenHelper，设置好数据库名称和表格名称以及比较重要的版本号，封装好以便后面使用。

```java
public class MyDatabaseHelper extends SQLiteOpenHelper {
    private static final String DB_NAME = "Contacts.db";
    private static final String TABLE_NAME = "Contacts";
    private static final int DB_VERSION = 1;

    public MyDatabaseHelper(Context context) {
        super(context, DB_NAME, null, DB_VERSION);
    }
}
```

一开始是创建数据库，这里使用自增的id字段为关键字，其余学号姓名手机为基本字段，创建
一个表格存储，当这个MyDatabaseHelper被实例化的时候即创建表格，因此在onCreate()中做

```java
@Override
public void onCreate(SQLiteDatabase db) {
    String CREATE_TABLE = "create table " + TABLE_NAME
            + " (_id integer primary key autoincrement, "
            + "_no text not null, "
            + "_name text not null, "
            + "_pnumber text);";
    db.execSQL(CREATE_TABLE);
}
```

为了能创建实例需要重载onUpgrade()函数，这里简单地重载，但是调用会出事，整张表格内容会丢失，但在这次程序里面不会被调用，先暂且写着

```java
@Override
public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
    String DROP_TABLE = "DROP TABLE IF EXITS " + TABLE_NAME;
    db.execSQL(DROP_TABLE);
    onCreate(db);
}
```

在数据库中插入一个联系人，传入一个联系人对象即可，插入一个数据库项

```java
public long insert(Contact entity) {
    SQLiteDatabase db = getWritableDatabase();
    ContentValues values = new ContentValues();
    values.put("_no", entity.getNo());
    values.put("_name", entity.getName());
    values.put("_pnumber", entity.getPhoneNumber());
    long id = db.insert(TABLE_NAME, null, values);
    db.close();
    return id;
}
```

在数据库中更新联系人，根据传入的联系人学号查找数据库，将新的数据覆盖原来数据库中的数据即可更新

```java
public int update(Contact entity) {
    SQLiteDatabase db = getWritableDatabase();
    String whereClause = "_no = ?";
    String[] whereArgs = { entity.getNo() };

    ContentValues values = new ContentValues();
    values.put("_no", entity.getNo());
    values.put("_name", entity.getName());
    values.put("_pnumber", entity.getPhoneNumber());

    int rows = db.update(TABLE_NAME, values, whereClause, whereArgs);
    db.close();
    return rows;
}
```

在数据库中删除联系人，根据传入的联系人的学号查找数据库，找到后删除即可

```java
public int delete(Contact entity) {
    SQLiteDatabase db = getWritableDatabase();
    String whereClause = "_no = ?";
    String[] whereArgs = { entity.getNo() };

    int rows = db.delete(TABLE_NAME, whereClause, whereArgs);
    db.close();
    return rows;
}
```

在数据库中查询数据库表头，使用query方法参数全部为空即可匹配数据库表的第一项，返回内容是指向第一项的指针类，可以向后遍历表格中的项

```java
public Cursor query() {
    SQLiteDatabase db = getReadableDatabase();
    return db.query(TABLE_NAME, null, null, null, null, null, null);
}
```

为ListView建立一个MySimpleAdapter类继承自SimpleAdapter，可以方便地绑定到ListView中

```java
public class MySimpleAdapter extends SimpleAdapter {
    private ArrayList<Map<String, String>> mData;

    public MySimpleAdapter(Context context, List<? extends Map<String, ?>> data,
                           int resource, String[] from, int[] to) {
        super(context, data, resource, from, to);
        this.mData = (ArrayList<Map<String, String>>)data;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        final int mPosition = position;
        return super.getView(position, convertView, parent);
    }
}
```

准备工作已经做好了，剩下的就是程序的逻辑编写。
进入主界面需要更新ListView的内容，使用刚才写好的query方法访问数据库中全部的内容，加入到一个List中，并通过该List和之前写好的ListView Item Layout创建一个MySimpleAdapter绑定到ListView中，完成更新。由于这步工作在后续的添加联系人、修改联系人和删除联系人中都使用到，因此封装成一个函数以便调用。


```java
private void setData(List<Map<String, String>> mDataList) {
    Map<String, String> mData;
    Cursor c = myDatabaseHelper.query();
    while (c.moveToNext()) {
        mData = new HashMap<String, String>();
        mData.put("no", c.getString(c.getColumnIndex("_no")));
        mData.put("name", c.getString(c.getColumnIndex("_name")));
        mData.put("pnumber", c.getString(c.getColumnIndex("_pnumber")));
        mDataList.add(mData);
    }
}

private void updateListView() {
    dataList.clear();
    setData(dataList);
    MySimpleAdapter mySimpleAdapter = new MySimpleAdapter(this, dataList, R.layout.contact_item,
            new String[] { "no", "name", "pnumber" },
            new int[] { R.id.contact_no, R.id.contact_name, R.id.contact_phonenumber });
    ListView lv = (ListView)this.findViewById(R.id.lv_contact);
    lv.setAdapter(mySimpleAdapter);
}
```

当用户点击添加按钮的时候，跳转到次界面，并传递消息给次界面是通过Add按钮跳转到这里来的，使用startActivityForResult方法，并设定Add按钮的requestCode为1

```java
Button btnAdd = (Button)this.findViewById(R.id.btn_add);
btnAdd.setOnClickListener(new View.OnClickListener() {
    @Override
    public void onClick(View view) {
        Intent intent = new Intent(MainActivity.this, DetailActivity.class);
        Bundle bundle = new Bundle();
        bundle.putBoolean("AddorNot", true);
        intent.putExtras(bundle);
        int requestCode = 1;
        startActivityForResult(intent, requestCode);
    }
});
```

次界面中根据主界面传递进来的消息，更新界面，显示是否是添加联系人或者修改联系人，如果是添加联系人，界面全部字段为空，如果是修改联系人，填入原本的联系人信息到界面字段中

```java
Bundle bundle = getIntent().getExtras();
final boolean addOrNot = bundle.getBoolean("AddorNot");
if (addOrNot) {
    tvTitle.setText(getResources().getString(R.string.titleAdd));
    edtNo.setText("");
    edtName.setText("");
    edtPNumber.setText("");
} else {
    tvTitle.setText(getResources().getString(R.string.titleModify));
    edtNo.setText(bundle.getString("oldNo"));
    edtName.setText(bundle.getString("oldName"));
    edtPNumber.setText(bundle.getString("oldPNumber"));
}
```

当用户在次界面点击按钮的时候，用正则表达式判断输入是否符合学号和手机号码的规则，以及姓名不能为空，然后根据是添加联系人或者修改联系人设定返回信息，并传递联系人消息回主界面

```java
Button btnConfirm = (Button)this.findViewById(R.id.btn_confirm);
btnConfirm.setOnClickListener(new View.OnClickListener() {
    @Override
    public void onClick(View view) {
        String newNo = edtNo.getText().toString();
        String newName = edtName.getText().toString();
        String newPNumber = edtPNumber.getText().toString();

        if (!newNo.matches("^[1-9]\\d{7}$")
                || !newPNumber.matches("^[1-9]\\d{10}$")
                || newName.isEmpty()) {
            Toast.makeText(getApplicationContext(), getResources().getString(R.string.msgWarning),
                    Toast.LENGTH_SHORT).show();
            return;
        }

        Intent intent = new Intent();
        intent.putExtra("_newNo", newNo);
        intent.putExtra("_newName", newName);
        intent.putExtra("_newPNumber", newPNumber);
        int resultCode = 0;
        if (addOrNot)   resultCode = 1;
        else            resultCode = 2;

        DetailActivity.this.setResult(resultCode, intent);
        DetailActivity.this.finish();
    }
});
```

主界面需要重载onActivityResult方法捕获从次界面传递回来的消息，判断是否为更新联系人或者添加联系人，然后均需要更新整个界面

```java
@Override
protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    Log.d("Hint", "requestCode = " + requestCode);
    Log.d("Hint", "resultCode = " + resultCode);
    if (resultCode == 0)
        return;
    String newNo = data.getStringExtra("_newNo");
    String newName = data.getStringExtra("_newName");
    String newPNumber = data.getStringExtra("_newPNumber");
    switch (requestCode) {
        case 1:
            myDatabaseHelper.insert(new Contact(newNo, newName, newPNumber));
            break;
        case 2:
            myDatabaseHelper.update(new Contact(newNo, newName, newPNumber));
            break;
        default:
            break;
    }
    updateListView();
}
```

点击联系人进入修改联系人界面（次界面），传递消息告诉次界面为修改联系人，设置相应的requestCode为2

```java
ListView lv = (ListView)this.findViewById(R.id.lv_contact);
lv.setOnItemClickListener(new AdapterView.OnItemClickListener() {
    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        ListView listView = (ListView) parent;
        HashMap<String, String> map = (HashMap<String, String>)listView.getItemAtPosition(position);

        Intent intent = new Intent(MainActivity.this, DetailActivity.class);
        Bundle bundle = new Bundle();
        bundle.putBoolean("AddorNot", false);
        bundle.putString("oldNo", map.get("no"));
        bundle.putString("oldName", map.get("name"));
        bundle.putString("oldPNumber", map.get("pnumber"));
        intent.putExtras(bundle);
        int requestCode = 2;
        startActivityForResult(intent, requestCode);
    }
});
```

当长按联系人的时候，弹出弹窗询问是否需要删除联系，如果用户选择是删除联系人，则使用数据库的delete方法，并更新界面

```java
lv.setOnItemLongClickListener(new AdapterView.OnItemLongClickListener() {
    @Override
    public boolean onItemLongClick(AdapterView<?> parent, View view, int position, long id) {
        ListView listView = (ListView) parent;
        final HashMap<String, String> map = (HashMap<String, String>)listView.getItemAtPosition(position);
        AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);
        builder.setMessage("确认删除吗？");
        builder.setTitle("提示");
        builder.setPositiveButton("确认", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                try {
                    myDatabaseHelper.delete(new Contact(map.get("no"), map.get("name"), map.get("pnumber")));
                    updateListView();
                } catch (Exception e) {
                    Log.d("Hint", "Remove failed!");
                }
            }
        });
        builder.setNegativeButton("取消", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                // nothing to do
            }
        });
        builder.show();
        return true;
    }
});
```

基本逻辑完成，但是程序有bug，在下面会说到

## 效果图

初始化界面->点击添加->填入错误信息点击确定->填入正确信息

<img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202145058194-1282877638.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202145102569-886392416.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202145106663-1292635277.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202145111788-1078852475.png" alt="cant show" style="display: inline-block; width: 22%; " />

正确信息确定后主界面增加->点击张三进入修改->修改为正确内容->确定确定后更新

<img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202145121600-231845151.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202145125819-2077936640.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202145130132-1292244035.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202145134444-1438995011.png" alt="cant show" style="display: inline-block; width: 22%; " />

长按李四提示是否删除->点击确认删除后更新界面

<img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202145141772-546697164.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202145148054-189841865.png" alt="cant show" style="display: inline-block; width: 22%; " />

## 一些总结

当用户在次界面点击返回按钮的时候，因为主界面会捕获消息并进行相应的处理，但是返回键是没有消息返回的，因此需要重载返回按钮，否则整个程序会崩溃。通过设置resultCode为0，以区分是用返回键返回的

```java
@Override
public boolean onKeyDown(int keyCode, KeyEvent event) {
    if(keyCode == KeyEvent.KEYCODE_BACK) {
        int resultCode = 0;
        DetailActivity.this.setResult(resultCode);
        DetailActivity.this.finish();
    }
    return true;
}

@Override
protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    Log.d("Hint", "requestCode = " + requestCode);
    Log.d("Hint", "resultCode = " + resultCode);
    if (resultCode == 0)
        return;
}
```

## 工程下载

传送门：[下载](http://pan.baidu.com/s/1pJSFOYR)