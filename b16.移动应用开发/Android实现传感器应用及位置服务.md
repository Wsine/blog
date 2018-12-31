# Android实现传感器应用及位置服务

开发工具：Andorid Studio 1.3
运行环境：Android 4.4 KitKat

## 代码实现

这里需用获取加速度传感器和地磁传感器，手机获取旋转的方向都是通过加速度传感器和地磁传感器共同计算得出来的，给传感器注册监听器，这里由于精度要求，需要使用SENSOR_DELAY_GAME来提高传感器更新速率

```java
private void initSensor() {
    sensorManager = (SensorManager)getSystemService(Context.SENSOR_SERVICE);
    Sensor magneticSensor = sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD);
    Sensor accelerometerSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
    sensorManager.registerListener(sensorEventListener, magneticSensor, SensorManager.SENSOR_DELAY_GAME);
    sensorManager.registerListener(sensorEventListener, accelerometerSensor, SensorManager.SENSOR_DELAY_GAME);
}
```

在监听器里面的主要工作就是通过两者的数据共同计算旋转角度，通过矩阵计算出所需旋转的角度，更新图片旋转角度

```java
private SensorEventListener sensorEventListener  = new SensorEventListener() {
    float[] accelerometerValues = new float[3];
    float[] magneticValues = new float[3];
    private float lastRotateDegree;
    @Override
    public void onSensorChanged(SensorEvent sensorEvent) {
        if (sensorEvent.sensor.getType() == Sensor.TYPE_ACCELEROMETER) {
            accelerometerValues = sensorEvent.values.clone();
        } else if (sensorEvent.sensor.getType() == Sensor.TYPE_MAGNETIC_FIELD) {
            magneticValues = sensorEvent.values.clone();
        }
        float[] R = new float[9];
        float[] values = new float[3];
        SensorManager.getRotationMatrix(R, null, accelerometerValues, magneticValues);
        SensorManager.getOrientation(R, values);
        float rotateDegree = -(float)Math.toDegrees(values[0]);

        if (Math.abs(rotateDegree - lastRotateDegree) > 1) {
            RotateAnimation animation = new RotateAnimation(lastRotateDegree, rotateDegree,
                    Animation.RELATIVE_TO_SELF, 0.5f,
                    Animation.RELATIVE_TO_SELF, 0.5f);
            animation.setFillAfter(true);
            imgCompass.startAnimation(animation);
            lastRotateDegree = rotateDegree;
        }
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {}
};
```

位置服务这边通过LocationManager来获取位置服务，检测手机是否打开位置服务，主要就是调用手机的位置服务，包括GPS和Network，从Provider中获得相应的经纬度，更新UI

```java
private void initLocation() {
    locationManager = (LocationManager)getSystemService(Context.LOCATION_SERVICE);
    List<String> providerList = locationManager.getProviders(true);
    String provider = null;
    if (providerList.contains(LocationManager.GPS_PROVIDER)) {
        provider = LocationManager.GPS_PROVIDER;
    }  else if (providerList.contains(LocationManager.NETWORK_PROVIDER)) {
        provider = LocationManager.NETWORK_PROVIDER;
    } else {
        Toast.makeText(this, "No location provider to use", Toast.LENGTH_SHORT).show();
        return;
    }

    try {
        Location location = locationManager.getLastKnownLocation(provider);
        if (location != null) {
            showLocation(location);
        }
        locationManager.requestLocationUpdates(provider, 5000, 1, locationListener);
    } catch (Exception e) {
        e.printStackTrace();
    }
}
```

注册的locationListener中只需要使用onLocationChanged即可，就是更新UI

```java
private LocationListener locationListener = new LocationListener() {
    @Override
    public void onLocationChanged(Location location) { showLocation(location); }

    @Override
    public void onStatusChanged(String s, int i, Bundle bundle) {}

    @Override
    public void onProviderEnabled(String s) {}

    @Override
    public void onProviderDisabled(String s) {}
};

private void showLocation(Location location) {
    edtLott.setText("" + location.getLongitude());
    edtLatt.setText("" + location.getLatitude());
}
```

当程序退出的时候，需要注销已经注册的监听，关于Location的部分使用try语句，因为有可能需用使用到Network

```java
@Override
public void onDestroy() {
    super.onDestroy();
    if (sensorManager != null) {
        sensorManager.unregisterListener(sensorEventListener);
    }
    if (locationListener != null) {
        try {
            locationManager.removeUpdates(locationListener);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

最后给程序添加使用传感器的权限即可

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

## 效果图

初始化界面->偏转手机->点击按钮->刷出经纬度

<img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202162614866-1977779062.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202162625819-1517190013.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202162638944-757171592.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202162633116-1400568131.png" alt="cant show" style="display: inline-block; width: 22%; " />

## 工程下载

传送门：[下载](http://pan.baidu.com/s/1hrxwv1i)