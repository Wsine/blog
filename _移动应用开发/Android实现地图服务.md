#Android实现地图服务

开发工具：Andorid Studio 1.3
运行环境：Android 4.4 KitKat

##代码实现

这里使用的是百度地图，具体配置方法请看官方文档即可。（也可以参考我的工程）

首先考虑到使用地图应用，需要上网权限和定位权限等，因此先添加相应的权限

```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="com.android.launcher.permission.READ_SETTINGS" />
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.GET_TASKS" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_SETTINGS" />
```

当界面初始化的时候，建立地图指定到一个指定的中心点

```java
//在使用SDK各组件之前初始化context信息，传入ApplicationContext
//注意该方法要再setContentView方法之前实现
SDKInitializer.initialize(getApplicationContext());
LatLng center = new LatLng(22.352921, 113.596621);
mapView = new MapView(this, new BaiduMapOptions().mapStatus(new MapStatus.Builder().target(center).build()));
setContentView(mapView);
```

手动设置一个当前位置，也就是地图的中心位置，并定位到此处。给地图上手动标注4个点，分别是图书馆、珠影超市、中国银行和体育馆。用一个小小的图标显示，并添加消息传递。（这里只展示其中两个点，写法基本一致）。然后为地图上的标注添加点击响应，显示相应的地点信息。

```java
private void locateMap() {
    baiduMap = mapView.getMap();
    baiduMap.setBaiduHeatMapEnabled(true);
    MyLocationData locationData = new MyLocationData.Builder().latitude(22.352921).longitude(113.596621).build();
    baiduMap.setMyLocationData(locationData);
    BitmapDescriptor bitmapDescriptor = BitmapDescriptorFactory.fromResource(R.mipmap.location);
    MyLocationConfiguration configuration = new MyLocationConfiguration(MyLocationConfiguration.LocationMode.NORMAL,
                                                                        true, bitmapDescriptor);
    baiduMap.setMyLocationConfigeration(configuration);

    addMaker();

    BaiduMap.OnMarkerClickListener listener = new BaiduMap.OnMarkerClickListener() {
        @Override
        public boolean onMarkerClick(Marker marker) {
            String info = marker.getExtraInfo().getString("info");
            Toast.makeText(getApplicationContext(), info, Toast.LENGTH_SHORT).show();
            return false;
        }
    };
    baiduMap.setOnMarkerClickListener(listener);
}

private void addMaker() {
    LatLng latLngA = new LatLng(22.349821, 113.595543);
    BitmapDescriptor bitmapDescriptorA = BitmapDescriptorFactory.fromResource(R.mipmap.marker_a);
    OverlayOptions optionsA = new MarkerOptions().position(latLngA).icon(bitmapDescriptorA).zIndex(9).draggable(true);
    markerA = (Marker)(baiduMap.addOverlay(optionsA));

    Bundle bundleA = new Bundle();
    bundleA.putString("info", "图书馆");
    markerA.setExtraInfo(bundleA);
    /*********************************************************/
    LatLng latLngB = new LatLng(22.35618, 113.592003);
    BitmapDescriptor bitmapDescriptorB = BitmapDescriptorFactory.fromResource(R.mipmap.marker_b);
    OverlayOptions optionsB = new MarkerOptions().position(latLngB).icon(bitmapDescriptorB).zIndex(9).draggable(true);
    markerB = (Marker)(baiduMap.addOverlay(optionsB));

    Bundle bundleB = new Bundle();
    bundleB.putString("info", "珠影超市");
    markerB.setExtraInfo(bundleB);
    /*********************************************************/
    LatLng latLngC = new LatLng(22.352821, 113.595615);
    BitmapDescriptor bitmapDescriptorC = BitmapDescriptorFactory.fromResource(R.mipmap.marker_c);
    OverlayOptions optionsC = new MarkerOptions().position(latLngC).icon(bitmapDescriptorC).zIndex(9).draggable(true);
    markerC = (Marker)(baiduMap.addOverlay(optionsC));

    Bundle bundleC = new Bundle();
    bundleC.putString("info", "中国银行");
    markerC.setExtraInfo(bundleC);
    /*********************************************************/
    LatLng latLngD = new LatLng(22.355788, 113.587332);
    BitmapDescriptor bitmapDescriptorD = BitmapDescriptorFactory.fromResource(R.mipmap.marker_d);
    OverlayOptions optionsD = new MarkerOptions().position(latLngD).icon(bitmapDescriptorD).zIndex(9).draggable(true);
    markerD = (Marker)(baiduMap.addOverlay(optionsD));

    Bundle bundleD = new Bundle();
    bundleD.putString("info", "体育馆");
    markerD.setExtraInfo(bundleD);
}
```

最后重载Activity的生命周期，添加上地图服务的上面周期

```java
@Override
protected void onDestroy() {
    super.onDestroy();
    //在activity执行onDestroy时执行mMapView.onDestroy()，实现地图生命周期管理
    mapView.onDestroy();
}

@Override
protected void onResume() {
    super.onResume();
    //在activity执行onResume时执行mMapView. onResume ()，实现地图生命周期管理
    mapView.onResume();
}

@Override
protected void onPause() {
    super.onPause();
    //在activity执行onPause时执行mMapView. onPause ()，实现地图生命周期管理
    mapView.onPause();
}
```

##效果图

<img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202163631491-2100398596.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202163642882-1347291661.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202163656788-1245558273.png" alt="cant show" style="display: inline-block; width: 22%; " /> <img src="http://images2015.cnblogs.com/blog/701997/201602/701997-20160202163706460-1257058216.png" alt="cant show" style="display: inline-block; width: 22%; " />

##工程下载

传送门：[下载](http://pan.baidu.com/s/1eRucFy6)