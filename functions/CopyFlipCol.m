function [ unSharedVertexIdx ] = CopyFlipCol( sharedVertexIdx )

    [n, d] = size(sharedVertexIdx);    
    unSharedVertexIdx = zeros(n, d);
    unSharedVertexIdx(:, 1) = sharedVertexIdx(:, 1);    % row coordinates
    
    unSharedVertexIdx( sharedVertexIdx(:, 2) == 2, 2 ) = 3;
    unSharedVertexIdx( sharedVertexIdx(:, 2) == 3, 2 ) = 2;
    
end

