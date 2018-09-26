clc; close all; clear;
addpath('functions');


%% Load and Show

% filename = 'samplemeshes\bimba_3_7Mf.off';        %  3.7 [M]  B
% filename = 'samplemeshes\lucy.off';               % 526  [K]
% filename = 'samplemeshes\lucy_reduced25.off';     % 127   K
% filename = 'samplemeshes\feline.off';             % 100	K
% filename = 'samplemeshes\female2WB25param.off';	%  66   K   B
% filename = 'samplemeshes\tweety-54k.off';         %  54   K   
% filename = 'samplemeshes\sphere_dense.off';       %  20   K
% filename = 'samplemeshes\head.off';               %  16   K   B
% filename = 'samplemeshes\fandisk.off';            %  13   K   Heavy ----
% filename = 'samplemeshes\pumpkin_tall_10k.off';   %  10   K
% filename = 'samplemeshes\pig.off';                %   4   K   B
% filename = 'samplemeshes\hand.off';               %   3   K   B
% filename = 'samplemeshes\sphere_coarse.off';      %   2   K
filename = 'samplemeshes\torus.off';              %   1.6 K
% filename = 'samplemeshes\eightparam.off';         %   1.5 K   B
% filename = 'samplemeshes\balls_param.off';        %   1   K   B
% filename = 'samplemeshes\mushroom.off';           %   0.5 K
% filename = 'samplemeshes\sphere.off';             %   0.2 K   B

[p, t, nv, nt] = loadmesh(filename); 
p=p'; t=t';
% figure; plotmesh(p',t');
% rzview('on')


%%
voi = 93;
C = NaiveTraversal(p, t);
facets = t(C{voi, :}', :);


fig_sz      = 900;
figure('Position', [1920, 50, fig_sz, fig_sz]); hold on;
hold on;
X = []; Y = []; Z = [];
for i = 1:size(facets, 1)
    X = []; Y = []; Z = [];
    for j = 1:size(facets, 2)
        X = [X p(facets(i,j), 1)];
        Y = [Y p(facets(i,j), 2)];
        Z = [Z p(facets(i,j), 3)];
    end
%     plot3(X,Y,Z, 'linewidth', 2);
    T = [X' Y' Z'];                 % triangle
    V = circshift(T, -1, 1) - T;    % vectors
    quiver3(T(:, 1), T(:, 2), T(:, 3), ...
            V(:, 1), V(:, 2), V(:, 3), 'linewidth', 2)
%     break;
end
legend( 'triangle 1', ...
        'triangle 2', ...
        'triangle 3',...
        'triangle 4',...
        'triangle 5',...
        'triangle 6');