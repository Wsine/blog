如题:
```
function X = IsStrictDiagMatrix(A)
% input: A matrix
% output: The matrix after transformation

    % if the matrix is not a square matrix, return error
    if size(A, 1) ~= size(A, 2)
        error('It is not a square matrix');
    end
    
    % get the size of A and set the size of X
    % use an array to accord if all the row be set
    N = size(A, 1);
    X = zeros(N, N);
    has_set = zeros(N);
    
    for i = 1 : N
        % find out the max element in a row
        row_max = max(abs(A(i, : )));
        % if the max element is not larger than sum of others, return error
        if (row_max <= (sum(abs(A(i, : ))) - row_max))
            error('It can not be transformed to strict diagonal dominance matrix');
        end
        % find out the index of max element and set the row j of matrix X
        % accord row j has been set
        for j = 1 : N
           if (abs(A(i, j)) == row_max)
              X(j, : ) = A(i, : );
              has_set(j) = 1;
           end
        end
    end
    
    % if any hasn't been set, return error
    for i = 1 : N
       if (has_set == 0)
          error('It can not be transformed to strict diagonal dominance matrix'); 
       end
    end
    
    % output success
    fprintf('It can be transformed to a strict diagonal dominance matrix: \n');
end
```