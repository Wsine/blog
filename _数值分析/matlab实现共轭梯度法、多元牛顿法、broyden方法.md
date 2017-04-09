共轭梯度法：

```
function [ x, r, k ] = CorGrant( x0, A, b )
    x = x0;
    r = b - A * x0;
    d = r;
    X = ones(length(x), 1);
    k = 0;
    while 1
        if norm(r, Inf)<1e-6
            break
        end
        k = k + 1;
        
        arf = (r' * r) / (d' * A * d);
        x = x + arf * d;
        r2 = r - arf * A * d;
        brt = (r2' * r2) / (r' * r);
        d = r2 + brt * d;
        
        r = r2;
    end

end
```
About the code:
- A : the input A of Ax = b
- b : the input b of Ax = b
- x0 : the input guess of x
- x : the output x of Ax = b
- r : the remainder between calculation x and exact x
- k : calculation times 

多元牛顿方法：
使用了共轭梯度法来辅助，其中需要用到雅可比矩阵
```
function [x] = Multi_Newdd(x0, df1_1, df1_2, df2_1, df2_2, f1, f2, k)
    x = x0;
    n = length(x0);
    for i = 1 : k
       A = DF(df1_1, df1_2, df2_1, df2_2, x);
       b = -1 * F(f1, f2, x);
       s = CorGrant_ForNewdd(zeros(n, 1), A, b, 7); 
       x = x + s;
    end
end

function [ x ] = CorGrant_ForNewdd( x0, A, b, k )
    x = x0;
    r = b - A * x0;
    d = r;
    X = ones(length(x), 1);
    for i = 1 : k
        
        arf = (r' * r) / (d' * A * d);
        x = x + arf * d;
        r2 = r - arf * A * d;
        brt = (r2' * r2) / (r' * r);
        d = r2 + brt * d;
        
        r = r2;
    end

end

function [x] = DF(df1_1, df1_2, df2_1, df2_2, x0)
    x = zeros(length(x0), length(x0));
    x(1, 1) = df1_1(x0(1, 1), x0(2, 1));
    x(1, 2) = df1_2(x0(1, 1), x0(2, 1));
    x(2, 1) = df2_1(x0(1, 1), x0(2, 1));
    x(2, 2) = df2_2(x0(1, 1), x0(2, 1));
end

function [x] = F(f1, f2, x0)
    x = zeros(length(x0), 1);
    x(1, 1) = f1(x0(1, 1), x0(2, 1));
    x(2, 1) = f2(x0(1, 1), x0(2, 1));
end
```
About the code:
- f1 : the input handle of Function F
- f2 : the input handle of Function F
- df1_1 : the input handle of Function DF
- df1_2 : the input handle of Function DF
- df2_1 : the input handle of Function DF
- df2_2 : the input handle of Function DF
- x0 : the input guess of x
- x : the output x of Ax = b
- k : calculation times 

例子：

```
clear all
clc

f1 = @(u, v) 6*u^3+u*v-3*v^3-4;
f2 = @(u, v) u^2-18*u*v^2+16*v^3+1;

df1_1 = @(u, v) 18*u^2+v;
df1_2 = @(u, v) u-9*v^2;
df2_1 = @(u, v) 2*u-18*v^2;
df2_2 = @(u, v) -36*u*v+48*v^2;

n = 2;
k = 7;
x0_1 = [1.15; 1.15];
x0_2 = [2; 2];
x0_3 = [3; 3];

x1 = Multi_Newdd(x0_1, df1_1, df1_2, df2_1, df2_2, f1, f2, k)
x2 = Multi_Newdd(x0_2, df1_1, df1_2, df2_1, df2_2, f1, f2, k)
x3 = Multi_Newdd(x0_3, df1_1, df1_2, df2_1, df2_2, f1, f2, k)
```

Broyden方法：
```
function [x, k] = Broyden_I(x0, A, f1, f2, k)
    for i = 1 : k
       x1 = x0 - inv(A) * F(f1, f2, x0);
       r = x1 - x0;
       tri = F(f1, f2,x1) - F(f1, f2, x0);
       A = A + ((tri - A * r) * r') / (r' * r);
       x0 = x1;
    end
    x = x1;
end
```
About the code:
- f1 : the input handle of Function F
- f2 : the input handle of Function F
- x0 : the input guess of x
- x : the output x of Ax = b
- k : calculation times 

例子：
```
clear all
clc

x0 = [1; 1];
A = eye(2);

% (a)
f1 = @(u, v) u^2+v^2-1;
f2 = @(u, v) (u-1)^2+v^2-1;
x_ans = [0.5; (3^0.5)/2];
[xa, ka] = Broyden_I(x0, A, f1, f2, 9);xa
norm(xa - x_ans, Inf)

% (b)
f1 = @(u, v) u^2+4*v^4-4;
f2 = @(u, v) 4*u^2+v^2-4;
x_ans = [2/(5^0.5); 2/(5^0.5)];
[xb, kb] = Broyden_I(x0, A, f1, f2, 9);xb
norm(xb - x_ans, Inf)

% (c)
f1 = @(u, v) u^2-4*v^2-4;
f2 = @(u, v) (u-1)^2+v^2-4;
x_ans = [4*(1+6^0.5)/5; ((3+8*6^0.5)^0.5)/5];
[xc, kc] = Broyden_I(x0, A, f1, f2, 10);xc
norm(xc - x_ans, Inf)
```