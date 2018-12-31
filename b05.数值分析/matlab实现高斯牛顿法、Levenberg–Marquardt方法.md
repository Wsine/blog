高斯牛顿法：

```
function [ x_ans ] = GaussNewton( xi, yi, ri)
% input : x = the x vector of 3 points
%         y = the y vector of 3 points
%         r = the radius vector of 3 circles
% output : x_ans = the best answer
    % set up r equations
    r1 = @(x, y) sqrt((x-xi(1))^2+(y-yi(1))^2) - ri(1);
    r2 = @(x, y) sqrt((x-xi(2))^2+(y-yi(2))^2) - ri(2);
    r3 = @(x, y) sqrt((x-xi(3))^2+(y-yi(3))^2) - ri(3);
    % set up Dr matrix
    Dr = @(x) [(x(1) - xi(1))/(sqrt((x(1) - xi(1))^2+(x(2)-yi(1))^2)), (x(2) - yi(1))/(sqrt((x(1) - xi(1))^2+(x(2)-yi(1))^2));
               (x(1) - xi(2))/(sqrt((x(1) - xi(2))^2+(x(2)-yi(2))^2)), (x(2) - yi(2))/(sqrt((x(1) - xi(2))^2+(x(2)-yi(2))^2));
               (x(1) - xi(3))/(sqrt((x(1) - xi(3))^2+(x(2)-yi(3))^2)), (x(2) - yi(3))/(sqrt((x(1) - xi(3))^2+(x(2)-yi(3))^2))];
    % set up r matrix
    r = @(x) [r1(x(1), x(2)); r2(x(1), x(2)); r3(x(1), x(2))];
    x0 = [0, 0]; % initial guess
    while 1
       A = Dr(x0);
       v0 = (A' * A) \ (- A' * r(x0));
       x1 = x0 + v0';
       if norm(x1-x0)<1e-6 % break squest
           break;
       end
       x0 = x1;
    end
    x_ans = x1;
end
```
Levenberg–Marquardt方法：
```
function [ x_ans ] = LeveMarq( ti, yi, x_guess, lmd)
% input : t = the x vector of 5 points
%         y = the y vector of 5 points
%         x_guess = the guess vector of x_ans
% output : x_ans = the best answer
    % set up r matrix
    r = @(x) [x(1) * exp(-x(2)*(ti(1) - x(3))^2) - yi(1);
              x(1) * exp(-x(2)*(ti(2) - x(3))^2) - yi(2);
              x(1) * exp(-x(2)*(ti(3) - x(3))^2) - yi(3);
              x(1) * exp(-x(2)*(ti(4) - x(3))^2) - yi(4);
              x(1) * exp(-x(2)*(ti(5) - x(3))^2) - yi(5)];
    % set up Dr matrix
    Dr = @(x) [exp(-x(2)*(ti(1)-x(3))^2), -x(1)*(ti(1)-x(3))^2*exp(-x(2)*(ti(1)-x(3))^2), 2*x(1)*x(2)*(ti(1)-x(3))*exp(-x(2)*(ti(1)-x(3))^2);
               exp(-x(2)*(ti(2)-x(3))^2), -x(1)*(ti(2)-x(3))^2*exp(-x(2)*(ti(2)-x(3))^2), 2*x(1)*x(2)*(ti(2)-x(3))*exp(-x(2)*(ti(2)-x(3))^2);
               exp(-x(2)*(ti(3)-x(3))^2), -x(1)*(ti(3)-x(3))^2*exp(-x(2)*(ti(3)-x(3))^2), 2*x(1)*x(2)*(ti(3)-x(3))*exp(-x(2)*(ti(3)-x(3))^2);
               exp(-x(2)*(ti(4)-x(3))^2), -x(1)*(ti(4)-x(3))^2*exp(-x(2)*(ti(4)-x(3))^2), 2*x(1)*x(2)*(ti(4)-x(3))*exp(-x(2)*(ti(4)-x(3))^2);
               exp(-x(2)*(ti(5)-x(3))^2), -x(1)*(ti(5)-x(3))^2*exp(-x(2)*(ti(5)-x(3))^2), 2*x(1)*x(2)*(ti(5)-x(3))*exp(-x(2)*(ti(5)-x(3))^2)];

    x0 = x_guess; % initial guess
    while 1
       A = Dr(x0);
       M_A = A' * A + lmd .* diag(diag(A' * A));
       M_b = - A' * r(x0);
       v0 = M_A \ M_b;
       x1 = x0 + v0';
       if norm(x1-x0)<1e-6 % break squest
           break;
       end
       x0 = x1;
    end
    x_ans = x1;
end
```