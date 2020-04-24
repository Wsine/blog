不动点迭代
```
function xc = fpi( g, x0, tol )
    x(1) = x0;
    i = 1;
    while 1
        x(i + 1) = g(x(i));
        if(abs(x(i+1) - x(i)) < tol)
            break
        end
        i = i + 1;
    end
    xc = x(i+1);
end
```


牛顿法：

```
function xk = funNewton(f, x0, max_steps, tol)
    syms x
    symbol_f = f(x);
    dif_f = matlabFunction(diff(symbol_f));
    clear x
    x = x0;
    for k = 1:max_steps
       xk = x;
       disp(['the ', num2str(k), ' time is ', num2str(x)])
       %xk to save the last time value of x
       x = x - f(x) / dif_f(x);
       %newton solve 
       if(abs(xk - x) < tol)
       %decide whether to break out
            break;
       end
    end
end
```

割线法：
```
function xc = CutLine( f, x0, x1, tol )
    x(1) = x0;
    x(2) = x1;
    i = 2;
    while 1
        x(i + 1) = x(i) - (f(x(i)) * (x(i) - x(i - 1))) / (f(x(i)) - f(x(i - 1)));
        if(abs(x(i + 1) - x(i)) < tol)
            break;
        end
        i = i + 1;
    end
    xc = x(i + 1);
end
```

Stewart平台运动学问题求解：
```
function out = Stewart( theta )
    % set the parameter
    x1 = 4; 
    x2 = 0; 
    y2 = 4; 
    L1 = 2;
    L2 = sqrt(2);
    L3 = sqrt(2);
    gamma = pi / 2;
    p1 = sqrt(5);
    p2 = sqrt(5);
    p3 = sqrt(5);
    % calculate the answer
    A2 = L3 * cos(theta) - x1;
    B2 = L3 * sin(theta);
    A3 = L2 * cos(theta + gamma) - x2;
    B3 = L2 * sin(theta + gamma) - y2;
    
    N1 = B3 * (p2 ^ 2 - p1 ^ 2 - A2 ^ 2 - B2 ^ 2) - B2 * (p3 ^ 2 - p1 ^ 2 - A3 ^ 2 - B3 ^ 2);
    N2 =  -A3 * (p2 ^ 2 - p1 ^ 2 - A2 ^ 2 - B2 ^ 2) + A2 * (p3 ^ 2 - p1 ^ 2 - A3 ^ 2 - B3 ^ 2);
    D = 2 * (A2 * B3 - B2 * A3);
    
    out = N1 ^ 2 + N2 ^ 2 - p1 ^ 2 * D ^ 2;

end
```

test our function at **theta = - pi / 4** and **theta = pi / 4**
```
clear all
clc

format short

disp('f(- pi / 4) is ')
out1 = Stewart(- pi / 4)

disp('--------------')

disp('f(pi / 4) is ')
out2 = Stewart(pi / 4)
```