贝塞尔曲线绘图方法：
```
%Program 3.7 Freehand Draw Program Using Bezier Splines
%Click in Matlab figure window to locate first point, and click
% three more times to specify 2 control points and the next
% spline point. Continue with groups of 3 points to add more
% to the curve. Press return to terminate program.
%% This fuction is different from the text book written by the editor of the book.
%% Apart from the original functions, Dr. Wang has added its own codes to the function 
%% in order to 1) move the entire graph to positive; 2)
function modifiedbezierdraw
clear all;
close all
clc
plot([0 2],[1,1],'k',[1 1],[0 2],'k');hold on %% Modified to move the entire graph to positive.
%imshow('1588.jpg');hold on
t=0:.02:1;
xlist=[]; ylist=[]; %% Used to store the coordinate list.
[x,y]=ginput(1); % get one mouse click
xlist(1)=x; ylist(1)=y; %% Starting coordinate
while(0 == 0)
[xnew,ynew] = ginput(3); % get three mouse clicks
if length(xnew) < 3
break % if return pressed, terminate
end
xlist(length(xlist)+1:length(xlist)+3)=xnew; ylist(length(ylist)+1:length(ylist)+3)=ynew; %% Store the current three coordinates
x=[x;xnew];y=[y;ynew]; % plot spline points and control pts
plot([x(1) x(2)],[y(1) y(2)],'r:',x(2),y(2),'rs');
plot([x(3) x(4)],[y(3) y(4)],'r:',x(3),y(3),'rs');
plot(x(1),y(1),'bo',x(4),y(4),'bo');
bx=3*(x(2)-x(1)); by=3*(y(2)-y(1)); % spline equations ...
cx=3*(x(3)-x(2))-bx;cy=3*(y(3)-y(2))-by;
dx=x(4)-x(1)-bx-cx;dy=y(4)-y(1)-by-cy;
xp=x(1)+t.*(bx+t.*(cx+t*dx)); % Horner's method
yp=y(1)+t.*(by+t.*(cy+t*dy));
plot(xp,yp) % plot spline curve
x=x(4);y=y(4); % promote last to first and repeat
end
hold off
%% The remaining codes are used to store the coordinates 
%% and write them in the format of .txt which can be directly used in PDF.
save('xylist.mat','xlist','ylist');
xlist=xlist*300;
ylist=ylist*300;
fid=fopen('fontmat.txt','w');
for i=0:(length(xlist)-1)/3-1
    fprintf(fid,'%d %d %d %d %d %d %d %d c\n',fix(xlist(i*3+1)), fix(ylist(i*3+1)), fix(xlist(i*3+2)), fix(ylist(i*3+2)), fix(xlist(i*3+3)), fix(ylist(i*3+3)), fix(xlist(i*3+4)), fix(ylist(i*3+4)));
end
fclose(fid);
```

pdf使用1.7老版本的定义：
注意stream区间，第一行m为起点，即第一行c的首两个整数。使用程序会得到一份txt文件。复制并替换带c的行数即可。末尾S需保留。
```
%PDF-1.7
1 0 obj
<<
/Length 2 0 R
>>
stream
151 421 m
151 421 150 411 169 406 179 406 c
179 406 195 406 261 404 396 409 c
396 409 369 378 343 365 183 323 c
183 323 206 306 328 321 373 327 c
373 327 355 285 219 264 134 241 c
134 241 180 227 349 228 408 228 c
408 228 434 214 429 109 420 95 c
420 95 401 99 400 111 398 125 c
398 125 378 178 299 465 284 493 c
284 493 284 430 282 149 279 102 c
S
endstream
endobj
2 0 obj
1000
endobj
4 0 obj
<<
/Type /Page
/Parent 5 0 R
/Contents 1 0 R
>>
endobj
5 0 obj
<<
/Kids [4 0 R]
/Count 1
/Type /Pages
/MediaBox [0 0  612 792]
>>
endobj
3 0 obj
<<
/Pages 5 0 R
/Type /Catalog
>>
endobj
xref
0 6
0000000000 65535 f 
0000000100 00000 n 
0000000200 00000 n 
0000000500 00000 n 
0000000300 00000 n 
0000000400 00000 n 
trailer
<<
/Size 6
/Root 3 0 R
>>
startxref
1000
%%EOF
```