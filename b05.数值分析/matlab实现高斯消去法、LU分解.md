朴素高斯消去法：
```
function x = GauElim(n, A, b)
    if nargin < 2
        for i = 1 : 1 : n
            for j = 1 : 1 : n
                A(i, j) = 1 / (i + j - 1);
            end
            b(i, 1) = 1;
        end
    end
    
    for j = 1 : n - 1
        if abs(A(j, j)) < eps;
            error('zero pivot encountered');
        end
        for i = j + 1 : n
            mult = A(i, j) / A(j, j);
            for k = j + 1 : n
                A(i, k) = A(i, k) - mult * A(j, k);
            end
            A(i, j) = 0;
            b(i, 1) = b(i, 1) - mult * b(j);
        end
    end
    
    for i = n : -1 : 1
        for j = i + 1 : n
            b(i, 1) = b(i, 1) - A(i, j) * x(j, 1);
        end
        x(i, 1) = b(i, 1) / A(i, i);
    end
end

```

LU分解：
$$ A = LU$$

```
function [ L, U ] = LUfactory( n, A )
    A
    L = zeros(n);
    for j = 1 : n
        if abs(A(j, j)) < eps;
            error('zero pivot encountered');
        end
        L(j, j) = 1;
        for i = j + 1 : n
            L(i, j) = A(i, j) / A(j, j);
            mult = A(i, j) / A(j, j);
            for k = j + 1 : n
                A(i, k) = A(i, k) - mult * A(j, k);
            end
            A(i, j) = 0;
        end
    end
    U = A;
    L
    U
end
```

input parameter:
- n : the dimension of matrix A
- A : the matrix A

output parameter
- L : the matrix L
- U : the matrix U

firstly, set the matrix L be all zero. When simplifying the matrix A to matrix U, set the lower triangular matrix elements.

The single line with only A, L and U is to print the matrix( in matlab ).