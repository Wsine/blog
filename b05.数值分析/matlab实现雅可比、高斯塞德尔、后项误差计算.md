稀疏矩阵生成：
```
function [a, b] = aparsesetup(n)
    e = ones(n, 1);
    n2 = n / 2;
    a = spdiags([-e 3*e -e], -1:1, n, n);
    a(n2+1, n2) = -1;   a(n2, n2+1) = -1;
    b = zeros(n, 1);
    b(1) = 2; b(n) = 2;
    b(2 : n-1) = 1;
end
```

雅可比方法：
```
function x = jacobi(a, b, k)
   n = length(b);
   d = diag(a);
   r = a - diag(d);
   x = zeros(n, 1);
   for j = 1 : k
       x = (b - r * x) ./ d;
   end
end
```

高斯塞德尔方法：
```
function [x, k] = GaussSeidel(a, b)
    err = 1e-6;
    n = length(b);
    x = zeros(n, 1);
    k = 0;
    L = zeros(n, 1);
    while 1
        xk = x;
        for i = 1 : n
            for j = 1 : n
                if i ~= j
                    L(j) = a(i, j) * x(j);
                end
            end
            s = sum(L);
            L = 0;
            x(i) = (b(i) - s) / a(i, i);
        end
        if norm(x - xk, Inf)<err
            break;
        end
        k = k + 1;
    end
end
```

后项误差计算：
```
function be = getbackerror(x, x0)
    n = length(x);
    if nargin==1
        x0 = ones(n, 1);
    end
    sum = 0;
    for i = 1 : n
        sum = sum + abs(x(i) - x0(i));
    end
    be = sum;
end
```