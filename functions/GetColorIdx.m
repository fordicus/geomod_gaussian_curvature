function [ colorIdx ] = GetColorIdx( curvature,          ...
                                     min_curv, max_curv, ...
                                     number_of_colors )

    %% curvature:    vector of curvatures from the curve
    %  min_curv:     user-defined minimum curvature
    %  max_curv:     user-defined maximum curvature

    % I have pre-defined the look-up table,
    % where it has the dimension of [3+1 x nsp] inside myhandles.
    % color_idx is immediately used by: myhandles.cmap_look_up(:, idx)
    
    
    paramT      = ...   % paramT is in [0, 1]
        max(0.0, min(1.0, (curvature - min_curv)./(max_curv - min_curv)));
    
    colorIdx   = floor(1 + (paramT) .* (number_of_colors - 1) );

end

