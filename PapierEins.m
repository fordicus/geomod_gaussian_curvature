function [  resulting_meanCurvatures,       ...
            resulting_meanCurvatureNormals, ...
            resulting_gaussianCurvatures,   ...
            debugData1,                     ...     % Can be eliminated in Final Version
            debugData2                      ...
         ] = PapierEins( p, t, isDebug )
        
    [nv, dim]                       = size(p);
    
    resulting_meanCurvatures        = zeros(nv, 1);
    resulting_meanCurvatureNormals  = zeros(nv, dim);
    resulting_gaussianCurvatures    = zeros(nv, 1);
    debugData2                      = 0;
    
    debugData1                       = [];
    cAng                            = 2.0 * pi;     % full  angle
    rAng                            = 0.5 * pi;     % right angle
    octa                            = 1/8;
       
    
    
    %% ----------------------------------------------------------------------------
    %  ITERATION OVER ALL THE VERTICES
    %  ----------------------------------------------------------------------------
    for i = 1:nv
        triangles           = []; % 1-ring neighborhood collector
        pivotVertexIdx      = i;  % shared vertex xi of 1-ring neighborhood
        xi                  = p(pivotVertexIdx, :);  % Coordinate(xi)
        
        for j = 1:dim       % Find triangles which share the same vertex xi
            triangles       = [triangles find((t(:,j) == i))'];
                            % std::vector.push()
        end
        
        % -----------------------------------------------------------------
        % Extract 1-ring neighborhood facets with member triangles
        % -----------------------------------------------------------------
        % 0. They all share the same vertex xi =: pivot
        % 1. Allign pivot to be in the 1st column of this memory
        % 2. Then 2nd, and 3rd vertices are either 
        %    xj := another shared vertex to the shared edge
        %    xk := unshared vertices
        % 8. uniqueVertices := neighboring vertices except for the pivot
        % 9. Winding order of the mesh DOES NOT matter
        
        neighboringFacets   = t(triangles(1, :)', :);
        neighboringFacets   = PivotSharedVertex(neighboringFacets, i);
        nNeighbors          = size(neighboringFacets, 1);
        uniqueVertices      = unique(neighboringFacets);
        nJ                  = length(uniqueVertices) - 1;
                            % nJ := number of shared edges
                            %	    except for the shared vertex xi
        
        sharedVertexIdx     = zeros(2, 2);      % For (xj, xk)
        sharedEdgeVectors   = zeros(nJ, dim);   % per shared edges, (x,y,z)
        cotanSums           = zeros(nJ, 1);     % per shared edges
        mixedArea           = 0;                % per 1-ring neighborhood,  by cumalative-areas
        gaussianCurvature   = 0;                % per 1-ring neighborhood,  by cumalative-angles
        J                   = 1;                % increment till nJ
        
        
                
        for u = 1:(nJ+1)
                        
            curSharedVertexIdx = uniqueVertices(u);
            if curSharedVertexIdx == i; continue; end;                      % except for the shared vertex
            
            candidates = find(neighboringFacets == curSharedVertexIdx);     % need to find 2 facets which share xj
            if length(candidates) ~= 2;
                if isDebug == 1;  % For debugging anything if necessary
                    if size(find(debugData1 == candidates(1, 1))) == 0
                        debugData1 = [debugData1; candidates(1, 1)];
                        debugData2 = debugData2 + 1;
                    end
                end                
                continue; 
            end;                                                            % only for edge sharing 2-triangles
            remainders = rem(candidates, nNeighbors);                       % extraction mechanism from neighboringFacets
            remainders(remainders == 0) = nNeighbors;
            sharedVertexIdx(:, 1)   = remainders;                           % x-coordinate from neighboringFacets
            sharedVertexIdx(:, 2)   = ceil(candidates ./ nNeighbors);       % y-coordinate from neighboringFacets
            unSharedVertexIdx       = CopyFlipCol(sharedVertexIdx);         % get unshared: swap(2rd, 3rd) vertices
            
            xj  = p( neighboringFacets(         ...                         % shared vertex along the shared edge
                     sharedVertexIdx(1,1),      ...                         
                     sharedVertexIdx(1,2)), :   );
                
            x1k = p( neighboringFacets(         ...                         % unshared vertex
                     unSharedVertexIdx(1,1),    ...                         % for triangle-1
                     unSharedVertexIdx(1,2)), : );
                
            x2k = p( neighboringFacets(         ...                         % unshared vertex
                     unSharedVertexIdx(2,1),    ...                         % for triangle-2
                     unSharedVertexIdx(2,2)), : );
            
            % -----------------------------------------------------------------
            % Extract vectors sharing the edge
            % -----------------------------------------------------------------
            v11	= xi - xj;	v11norm = norm(v11); v11normSqr = power(v11norm, 2);
            v12	= xj - x1k;	v12norm = norm(v12); sharedEdgeVectors(J, :) = v11;
            v13	= xi - x1k;	v13norm = norm(v13);
            v22	= xj - x2k;	v22norm = norm(v22);
            v23	= xi - x2k;	v23norm = norm(v23);
            
            % -----------------------------------------------------------------
            % Extract angles sharing the edge
            % -----------------------------------------------------------------
            a1	= acos(dot( v12,  v13) / (v12norm * v13norm));
            a2  = acos(dot(-v11, -v13) / (v11norm * v13norm));
            a3  = acos(dot( v11, -v12) / (v11norm * v12norm));
            b1  = acos(dot( v22,  v23) / (v22norm * v23norm));
            b2  = acos(dot(-v11, -v23) / (v11norm * v23norm));
            b3  = acos(dot( v11, -v22) / (v11norm * v22norm));

            % -------------------------------------------------------------
            % Angle Sum for Gaussian Curvature
            % -------------------------------------------------------------
            gaussianCurvature   = gaussianCurvature + (a2 + b2);
            
            cotangents          = [cot(a1); cot(b1)];
            cotanSums(J, 1)     = sum(cotangents, 1);
            % J = J + 1;        at 'the end of the loop'(!)
            
            
            %% ------------------------------------------------------------
            %  Determine non-obtuse triangle
            %  ------------------------------------------------------------
            % - 0: non-obtuse
            % - 1: central angle; theta[j] is obtuse 
            % - 2: other angle is obtuse
            if      (    a1 <= rAng && ...
                         a2 <= rAng && ...
                         a3 <= rAng        );	caseA = 0;
            elseif  (    a1 <= rAng && ...
                         a2 >  rAng && ...
                         a3 <= rAng        );	caseA = 1;
            else                                caseA = 2;                
            end
            if      (    b1 <= rAng && ...
                         b2 <= rAng && ...
                         b3 <= rAng        );	caseB = 0;
            elseif  (    b1 <= rAng && ...
                         b2 >  rAng && ...
                         b3 <= rAng        );	caseB = 1;
            else                                caseB = 2;                
            end
            
            % -------------------------------------------------------------
            %  Mixed-area
            %  ------------------------------------------------------------
            switch caseA        % area = |cross| / 2
                case 0;         % Voronoi Area is shared for 2 adjacent triangles
                    mixedArea = mixedArea + (octa * cotanSums(J, 1) * v11normSqr);
                case 1;         mixedArea	= mixedArea + norm(cross(v12, v13)) / 4;
                case 2;         mixedArea	= mixedArea + norm(cross(v12, v13)) / 8;
            end
            switch caseB        % Voronoi Area already added in [case 0] of [caseA]
                case 1;         mixedArea	= mixedArea + norm(cross(v22, v23)) / 4;
                case 2;         mixedArea	= mixedArea + norm(cross(v22, v23)) / 8;
            end            
            
            J = J + 1; 
        end  % 1-RING NEIGHBORHOOD TRASVERSED
        
        
        
        %% ----------------------------------------------------------------
        %  Mean Curvature: Normal, and Magnitude extracted separately
        %  ----------------------------------------------------------------
        meanCurvature       = repmat(cotanSums, 1, dim) .* sharedEdgeVectors;
        meanCurvature       = sum(meanCurvature, 1) ./ (2.* mixedArea);
        normMeanCurvature   = norm(meanCurvature);
        meanCurvatureNormal = meanCurvature./normMeanCurvature;
        meanCurvature       = normMeanCurvature / 2;
        
        resulting_meanCurvatures(i, 1)          = meanCurvature;
        resulting_meanCurvatureNormals(i, :)	= meanCurvatureNormal;
        
        
        % ----------------------------------------------------------------
        % Gaussian Curvature: A lot simpler
        %  ----------------------------------------------------------------
        gaussianCurvature   = (cAng - (gaussianCurvature / 2)) / mixedArea;
        
        resulting_gaussianCurvatures(i, 1) = gaussianCurvature;
    end
    
    
end


