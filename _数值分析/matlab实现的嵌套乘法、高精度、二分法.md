嵌套乘法的计算：

$$ P(x) = 1 - x + x^2 - x^3 + ...+ x ^ {98} - x^{99} $$

```
function y = nest( d, c, x, b )
    if nargin < 4, b = zeros(d, 1); end
    y = c(d + 1);
    for i = d : -1 : 1
        y = y.*(x - b(i)) + c(i);
    end
end
```

等比数列的实现方式：
$$ P(x) = \frac{1 - (-x)^{100} } {1 - (-x)} $$

```
function y = nestup(x, n, a)
    if nargin < 3, a = 1;   end
    q = -1 * x;
    y = (a * (1 - q ^ n)) / (1 - q);
end
```


高精度计算的处理
$$ \sqrt{c^2 + d} - c $$

转换为下述形式
$$ \frac{c^2}{\sqrt{c^2 + d} + c} $$

```
 c = 246886422468;
 d = 13579;
 
 x = sqrt(c * c + d) - c;   % x = 0     wrong answer
 % x must equals to y
 y = d / (sqrt(c * c + d) + c) % y = 2.7500e-08
```

二分法的实现：
```
function xc = CalDetBisect(f, a, b, tol)
   fa = f(a);
   fb = f(b);
   if sign(fa) * sign(fb) >= 0
       error('f(a)f(b)<0  not satisified!')
   end
   while (b - a) / 2 > tol
       c = (a + b) / 2;
       fc = f(c);
       if fc == 0
           break;
       end
       if sign(fc) * sign(fa) < 0
            b = c;
            fb = fc;
       else
            a = c;
            fa = fc;
       end
   end
   xc = (a + b) / 2;
end
```