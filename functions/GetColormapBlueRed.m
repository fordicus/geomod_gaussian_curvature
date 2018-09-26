function [ colorMap ] = GetColormapBlueRed( numberOfColors )

    %bluered shades of red and blue color map
    %   bluered(numberOfColors), is an numberOfColors-by-3 matrix that defines a colormap.
    %   The colors begin with bright blue, range through shades of
    %   blue to white, and then through shades of red to bright red.
    %   bluered, by itself, is the same length as the current figure's
    %   colormap. If no figure exists, MATLAB creates one.
    %
    %   For example, to reset the colormap of the current figure:
    %
    %             colormap(redblue)
    %
    %   See also HSV, GRAY, HOT, BONE, COPPER, PINK, FLAG, 
    %   COLORMAP, RGBPLOT.

    %   Adam Auton, 9th October 2009
    %   https://de.mathworks.com/matlabcentral/fileexchange/25536-red-blue-colormap

    if nargin < 1, numberOfColors = size(get(gcf,'colormap'),1); end

    if (mod(numberOfColors,2) == 0)
        % From [0 0 1] to [1 1 1], then [1 1 1] to [1 0 0];
        m1 = numberOfColors*0.5;
        r = (0:m1-1)'/max(m1-1,1);
        g = r;
        r = [r; ones(m1,1)];
        g = [g; flipud(g)];
        b = flipud(r);
    else
        % From [0 0 1] to [1 1 1] to [1 0 0];
        m1 = floor(numberOfColors*0.5);
        r = (0:m1-1)'/max(m1,1);
        g = r;
        r = [r; ones(m1+1,1)];
        g = [g; 1; flipud(g)];
        b = flipud(r);
    end

    colorMap = [r g b];

end

