function [ Neighborhoods ] = NaiveTraversal( p, t )

    [vn, dim]	= size(p);
    vt          = length(t);
    
    Neighborhoods = {};
    for k = 1:vn
        triangles = [];
        for j = 1:dim
            triangles = [triangles find((t(:,j) == k))'];            
        end
%         C(k, :) = { triangles };
        Neighborhoods(k, :) = { sort(triangles) };
    end
    
end

