# HTML5做的浏览器欢迎界面自动跳转

思路很简单，随手装逼呗。根据时间来控制背景图和文字，背景图加了毛玻璃效果，效果直接看图，用javascript来实现。

![效果图](http://images.cnitblog.com/blog/701997/201502/170207180337090.png)

### 完整代码


```
<!DOCTYPE html>
<html>
<head>
	<title>Navigation</title>
	<!--2秒后跳转到自定义页面-->
	<meta http-equiv="refresh" content="2; url=http://www.baidu.com" />
	<style type="text/css">
		@font-face{
			font-family: "MAILR___";
			src:url("MAILR___.TTF");
		}
		p{
			font-family: MAILR___;
			font-size: 70px;
		}
		.blur {	
    			filter: url(blur.svg#blur); /* FireFox, Chrome, Opera */
    			-webkit-filter: blur(5px); /* Chrome, Opera */
       			-moz-filter: blur(5px);
       			-ms-filter: blur(5px);    
            		filter: blur(5px);
    			filter: progid:DXImageTransform.Microsoft.Blur(PixelRadius=5, MakeShadow=false); /* IE6~IE9 */
		}
		.hvcenter{
			position: absolute;
			top: 15%;
			left: 10%;
		}
	</style>
	<script type="text/javascript">
		window.onload=CurrentTime;
		function CurrentTime(){ 
	        	var now = new Date();
		        var year = now.getFullYear();       //年
		        var month = now.getMonth() + 1;     //月
		        var day = now.getDate();            //日
		        var hh = now.getHours();            //时
		        var mm = now.getMinutes();          //分
		       
		        var clock = year + " - ";
		        if(month < 10)
		        	clock += "0";
		        clock += month + " - ";
		        if(day < 10)
		            	clock += "0";
		        clock += day + "&nbsp;&nbsp;&nbsp;";
		        if(hh < 10)
		            	clock += "0";
		        clock += hh + " : ";
		        if (mm < 10) 
		        	clock += '0'; 
		        clock += mm; 
		        document.getElementById("time").innerHTML=clock;
		        if(hh>=6&&hh<=12){
		        	document.getElementById("sayhi").innerHTML="Good morning, Wsine";
		        	document.getElementById("myimg").src="morning.jpg";
		        }
		        else if(hh>=13&&hh<=16){
		        	document.getElementById("sayhi").innerHTML="Good noon, Wsine";
		        	document.getElementById("myimg").src="noon.jpg";
		        }
		        else if(hh>=17&&hh<=18){
		        	document.getElementById("sayhi").innerHTML="Good afternoon, Wsine";
		        	document.getElementById("myimg").src="afternoon.jpeg";
		        }
		        else{
		        	document.getElementById("sayhi").innerHTML="Good evening, Wsine";
		        	document.getElementById("myimg").src="night.jpg";
		        }
		} 
	</script>
</head>
<body>
	<div id="bg_pic" style="position:absolute; width:100%; height:100%; z-index:-1">
		<img id="myimg" src="morning.jpg" alt="backgroundpicture"  class="blur" width="100%" height="100%">
	</div>
	<div id="" style="width:1000px; height:500px;  text-align:center" class="hvcenter" >
			<p id="sayhi"></p>
			<p id="time"></p>
	</div>
</body>
</html>
```

### 附录

背景图片和字体的压缩包
[下载](http://pan.baidu.com/s/1i3xMJad)