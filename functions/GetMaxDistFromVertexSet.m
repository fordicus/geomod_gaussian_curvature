function [ maxDist ] = GetMaxDistFromVertexSet( p )

    [nv ~] = size(p);
    
    maxDist = 0;
    
    for i = 1:nv
        for j = 1:nv
            dist = norm(p(i,:) - p(j,:));
            if dist > maxDist
                maxDist = dist;
            end
        end
    end
end


