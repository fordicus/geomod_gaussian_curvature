function [ facets ] = PivotSharedVertex( facets, k )
    
    sharedVertex = k;
    
    for i = 1:size(facets, 1)
        loc = find(facets(i, :) == sharedVertex);
        if      loc == 1; continue; 
        else    
            tmp = facets(i, 1);
            facets(i, 1) = facets(i, loc);
            facets(i, loc) = tmp;
        end;
        
    end
end