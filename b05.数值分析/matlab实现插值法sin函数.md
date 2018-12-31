插值法实现sin函数：
```
%calculate and print the sine function
%input: x
%output: sin(x) similar
function y = sin2(x)
%save a copy of x
x_temp = x;
%calculate the interpolation polynomial
%save the coefficient
n = 4;
b = pi/4 + (pi/4)*cos((1:2:2*n-1)*pi/(2*n));
yb = sin(b);
c = newtdd(b, yb, n);c
%for any x, exchange it to base
%interpolation method calculation
len = size(x, 2);
s = ones(1, len);
y = zeros(1, len);
for i = 1 : len
   if x(i) < 0
       s(i) = s(i) * -1;
       x(i) = x(i) * -1;
   end
   x1(i) =  mod(x(i), 2*pi);
   if x1(i) > pi
      x1(i) = 2*pi-x1(i);
      s(i) = s(i) * -1;
   end
   if x1(i) > pi/2
       x1(i) = pi - x1(i);
   end
   y(i) = s(i) * nest(n-1, c, x1(i), b);
end
plot(x_temp, y);
grid on
title('sin2(x)');
end

```