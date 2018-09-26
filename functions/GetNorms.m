function [ norms ] = GetNorms( rowVectors, pow )

    [n, d]  = size(rowVectors);    
    norms   = zeros(n, 1);
    
    for i = 1:n
        norms(i, 1) = power(norm(rowVectors(i, :)), pow);
    end
    
end

