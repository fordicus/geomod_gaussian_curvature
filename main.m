clc; close all; clear;
addpath('functions');


%% ----------------------------------------------------------------------------
%  USER CTRL
%  ----------------------------------------------------------------------------
isDebug                             = 1;            % (1) extract [debugData] from [PaperEins]

numberOfColorsInCurvatureColormap   = 1e3;          % determine number of possible colors
colorSaturation                     = 0.25;         % in (0, 0.5], the lower the vivid

isDraw                              = 1;            % plot mesh and use colormap
isDrawNormal                        = 1;            % overhaul with mean curvature normals
isVectorScaledByCurvature           = 1;            % (1) normals are scaled by mean curvatures
isDrawTriangleAreaStatistics        = 0;            % Investigation: Quality of Sampling

stat_fig_sz                         = 900  * 0.5;   % Plot Gaussian Curvature -----------------
stat_fig_x                          = 1920 * 0.5;   % x-offset from left-bottom of monitor
stat_fig_y                          = 100  * 0.2;   % y-offset from left-bottom of monitor
mesh_fig_sz                         = 900  * 0.85;  % Plot 3D Mesh ----------------------------
mesh_fig_x                          = 1920 * 0.1;
mesh_fig_y                          = 100  * 0.2;



%% ----------------------------------------------------------------------------
%  LOAD 3D-MESH
%  ----------------------------------------------------------------------------

% filename = 'samplemeshes\bimba_3_7Mf.off';        %  3.7 [M]  B
% filename = 'samplemeshes\lucy.off';               % 526  [K]
% filename = 'samplemeshes\lucy_reduced25.off';     % 127   K
% filename = 'samplemeshes\feline.off';             % 100	K
% filename = 'samplemeshes\female2WB25param.off';	%  66   K   B ;error
% filename = 'samplemeshes\tweety-54k.off';         %  54   K
filename = 'samplemeshes\sphere_dense.off';       %  20   K
% filename = 'samplemeshes\head.off';               %  16   K   B
% filename = 'samplemeshes\fandisk.off';            %  13   K
% filename = 'samplemeshes\pumpkin_tall_10k.off';   %  10   K
% filename = 'samplemeshes\pig.off';                %   4   K   B
% filename = 'samplemeshes\hand.off';               %   3   K   B
% filename = 'samplemeshes\sphere_coarse.off';      %   2   K
% filename = 'samplemeshes\torus.off';              %   1.6 K
% filename = 'samplemeshes\eightparam.off';         %   1.5 K   B
% filename = 'samplemeshes\balls_param.off';        %   1   K   B
% filename = 'samplemeshes\mushroom.off';           %   0.5 K
% filename = 'samplemeshes\sphere.off';             %   0.2 K   B


[p, t, nv, nt] = loadmesh(filename); 
p=p'; t=t';
[n, d] = size(p);



%% ----------------------------------------------------------------------------
%  CURVATURE-RADIUS VERIFICATION FOR SPHERE
%  ----------------------------------------------------------------------------
% maxDist = GetMaxDistFromVertexSet( p );
% radius = maxDist/2;
% fprintf('radius\t= %f\n', radius);



%% ----------------------------------------------------------------------------
%  1ST PAPER: [1] MEAN CURVATURE [2] GAUSSIAN CURVATURE
%  ----------------------------------------------------------------------------
[   meanCurvatures,          ...
	meanCurvatureNormals,    ...
	gaussianCurvatures,      ...
    debugData1,              ...        % 2018-06-27 21:07, Triangles' Areas
    debugData2               ...
] = PapierEins(p, t, isDebug);

if isVectorScaledByCurvature == 1       % Mean Curvature Normals scaled
    meanCurvatureNormals =  meanCurvatureNormals .* ...
                            repmat(meanCurvatures, 1, d);
end

if (isDrawTriangleAreaStatistics == 1) && (debugData == 1)
    figure; hold on; 
    plot(debugData); 
    title('Triangle Area Statistics');
    hold off;
end



%% ----------------------------------------------------------------------------
%  FOR VERIFYING (n, d) CORRECTNESS OF THE RESULT.
%  ----------------------------------------------------------------------------
[nres, dres] = size(meanCurvatureNormals);
nonNegativeGaussianCurvatureIdx = find(gaussianCurvatures >= 0);
negativeGaussianCurvatureIdx	= find(gaussianCurvatures  < 0);
nngc    = length(nonNegativeGaussianCurvatureIdx);
ngc     = length(negativeGaussianCurvatureIdx);
fprintf('\n\n----------------------------------------------------------------------------\n');
fprintf('\tnon-negative curvatures\t\t= %d\n',  nngc);
fprintf('\tnegative curvatures\t\t\t= %d\n',    ngc);
fprintf('\tnv from found idices\t\t= %d\n',     ngc + nngc);
fprintf('\tnumber of vertices\t\t\t= %d\n',     nv);
fprintf('----------------------------------------------------------------------------\n');



%% ----------------------------------------------------------------------------
%  GET COLORMAP
%  ----------------------------------------------------------------------------
% Strategy [1] Mean: Obsolete, it is only printed but not used for colormap
averageGaussianCurvature    = mean(gaussianCurvatures);
standardDeviation           = gaussianCurvatures - ...
    repmat(averageGaussianCurvature, length(gaussianCurvatures), 1);
standardDeviation           = sum(standardDeviation.^2, 1) ...
                            / length(gaussianCurvatures);
standardDeviation           = sqrt(standardDeviation);                        
upperBound      = averageGaussianCurvature + colorSaturation * standardDeviation;
lowerBound      = averageGaussianCurvature - colorSaturation * standardDeviation;
% absUpperBound	= abs(upperBound);
% absLowerBound	= abs(lowerBound);
% if absUpperBound > absLowerBound; 	boundMax = absUpperBound;
% else                                boundMax = absLowerBound;
% end
fprintf('\tAverage Gaussian Curvature\t= %f\n',  averageGaussianCurvature)
fprintf('\tSTD Gaussian Curvature\t\t= %f\n',    standardDeviation)


%----------------------------------------------------------------------------
% Strategy [2] Median: Used for Colormap
sortedGaussianCurvatures    = sort(gaussianCurvatures);
medianIdx                   = floor(0.5 * nv);
upperIdx                    = medianIdx + floor(colorSaturation * nv);
lowerIdx                    = medianIdx - floor(colorSaturation * nv);
medianGaussianCurvature     = sortedGaussianCurvatures(medianIdx);
absUpperBound               = sortedGaussianCurvatures(upperIdx);
absLowerBound               = sortedGaussianCurvatures(lowerIdx);
if absUpperBound > absLowerBound; 	boundMax = absUpperBound;
else                                boundMax = absLowerBound;
end
fprintf('\tMedian Gaussian Curvature\t= %f\n',  medianGaussianCurvature)
fprintf('\tColormap bounds for Gaussian Curvature\n\t\t= [%f, %f]\n', ...
    -boundMax, boundMax);


% ----------------------------------------------------------------------------
% Colormap is determined. It is the same mechanism as previous homework
colorIdx = GetColorIdx( gaussianCurvatures,	...
                        -boundMax,          ...
                         boundMax,          ...
                        numberOfColorsInCurvatureColormap );
                    
colorMap = GetColormapBlueRed( numberOfColorsInCurvatureColormap );
colorMap = colorMap(colorIdx, :);


% ----------------------------------------------------------------------------
% Plot Statistic for Gaussian Curvature
figure('Position', [stat_fig_x, stat_fig_y, stat_fig_sz, stat_fig_sz]); hold on;
    plot(gaussianCurvatures, '*');
    plot((0:nv)', ...
         averageGaussianCurvature .* ones(nv+1, 1), ...
         'linewidth', 1.2);
    plot((0:nv)', ...
         medianGaussianCurvature .* ones(nv+1, 1), ...
         'linewidth', 1.2);
    legend('Gaussian Curvatures', 'Average', 'Median');
titleString = sprintf('-- Gaussian Curvatures --\n   Mean-Kg = %f\nMedian-Kg = %f', ...
    averageGaussianCurvature, medianGaussianCurvature);
title(titleString);
hold off;



%% ----------------------------------------------------------------------------
%  PLOT GAUSSIAN CURVATURE NORMAL
%  ----------------------------------------------------------------------------
figure('Position', [mesh_fig_x, mesh_fig_y , mesh_fig_sz, mesh_fig_sz]); hold on;
if isDrawNormal == 1
    fprintf('----------------------------------------------------------------------------\n');    

%   origin = zeros(nres, dres);     % Gaussian map on Unit Sphere
    origin = p;
    quiver3(origin(:, 1), origin(:, 2), origin(:, 3), ...
            meanCurvatureNormals(:, 1), ...
            meanCurvatureNormals(:, 2), ...
            meanCurvatureNormals(:, 3), ...
            'k', 'linewidth', 1.2);
end

%  ----------------------------------------------------------------------------
%  PLOT 3D-MESH with COLORMAP
%  ----------------------------------------------------------------------------
if isDraw == 1
    colorOption.face_color          = 0;
    colorOption.edge_color          = 0;
    colorOption.face_vertex_color   = colorMap;     % This maps the defined
    plotmesh(p,t, colorOption);
    hold off;
end


%% ----------------------------------------------------------------------------
%  REPORT IRREGULAR VERTICES
%  ----------------------------------------------------------------------------
fprintf('Number of Irregular vertices (skipped processing) =\n');
fprintf('\t[ %s ] %d ( %.2f%% )\n', filename, debugData2, 100*(debugData2/nv))