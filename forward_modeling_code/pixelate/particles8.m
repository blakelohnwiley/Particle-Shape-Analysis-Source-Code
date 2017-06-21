function [xverts,yverts,heywood,area] = particles8(mask)
% PARTICLES8 Binarize a polygon a la Particles8.
% 
% [xverts, yverts, heywood, area] = PARTICLES8(mask) identifies the 
% boundary of the blob described by mask. Returns the closed polygon 
% boundary and its Heywood factor.
% If the mask is empty or contains no polygons formed by >1 pixels, all
% outputs are NaN.
% 
% Note: the outputs xverts and yverts are row vectors.
% 
% This code is a MATLAB implementation of a portion of Gabriel Landini's 
% Particles8_ class for ImageJ.
% 
% Author: B. Hannan
% Written with MATLAB 2014a.
% Last edited on 19 Dec 2014.

% Use a Freeman chain to identify boundary. Calculate area according to the
% Freeman algorithm. Calculate HF = 2*sqrt(pi*[observed area]) / [observed
% perim].

% Set mask values to PIX_CHECKED_VAL after pixel identified on perimeter.
PIX_CHECKED_VAL = 0.9;

mask = +mask;       % Convert mask to double.

xe = size(mask,2);  % Get mask dimensions.
ye = size(mask,1);

xd  = [1,1,1,0,-1,-1,-1,0];     % x distances
yd  = [-1,0,1,1,1,0,-1,-1];     % y distances
g   = [7,1,1,3,3,5,5,7];        % Freeman chain direction ixs

z = [1.414213538169861, 1.0, 1.414213538169861, 1.0, ...    % perim vals
     1.414213538169861, 1.0, 1.414213538169861, 1.0];

% Preallocate polygon vertices matrices.
xverts = zeros(1,numel(mask));
yverts = zeros(1,numel(mask));

    % Is this pixel a single pixel "island"?
    function tfOnePx = isPixelIsland()
        tfOnePx = true;     % Initialize output.
        for qq = 1:8        % Loop over all 8 neighbor pixels.
            if mask(x+xd(qq),y+yd(qq)) == 1
                tfOnePx = false;
                break;
            end
        end
    end

polyCompleteFlag = false;
nVert = 0;
area = -1;

% Find first scanned pixel and go around the edge.
for y = 1:ye
    for x = 1:xe
        if mask(x,y)==1 && ~isPixelIsland()
            
            x1 = x;
            y1 = y;
            
            % Bounding box.
            uy = y-1;   % upper y
            dy = 1;     % lower y
            rx = 1;     % right x
            lx = xe-1;  % left x
            
            nz = 0;
            area = 0;
            mask(x,y) = PIX_CHECKED_VAL;
            q = 1;
            
            loopCount = 1;
            while true
                if mask(x1+xd(q),y1+yd(q)) > 0
                    
                    x2=x1;
                    y2=y1;
                    x1 = x1 + xd(q);
                    y1 = y1 + yd(q);
                    
                    area = area + 0.5*(y1+y2)*(x2-x1);
                    mask(x1,y1) = PIX_CHECKED_VAL;
                    
                    % Update coordinates of ROI box.
                    if x1 > rx
                        rx = x1;
                    end
                    if x1 < lx
                        lx = x1;
                    end
                    if y1 > dy
                        dy = y1;
                    end
                    if y1 < uy
                        uy = y1;
                    end
                    
                    nz = nz + z(q); % perimeter
                    q = g(q);
                    
                    % Store new polygon vertex.
                    nVert = nVert + 1;
                    xverts(nVert) = x1;
                    yverts(nVert) = y1;
                    
                    % Is the polygon closed?
                    if x1==x && y1==y && mask(x-1,y+1) ~= 1
                        polyCompleteFlag = true;
                        break;
                    end
                    
                    if polyCompleteFlag, break; end
                    
                else
                    
                    q = mod(q,8)+1;
                    
                end
                
                loopCount = loopCount + 1;
                if loopCount > size(mask,1)^2
                    error(  'myfuns:particles8:looprunaway' , ...
                            'Loop runaway. Could not close the polygon.');
                end
                
                if polyCompleteFlag, break; end
            end % while loop
            
            if polyCompleteFlag, break; end
        end % if mask(x,y)==1
        if polyCompleteFlag, break; end
    end % xe
    if polyCompleteFlag, break; end
end % ye

if area > 0 % Polygon >1 pixel identified.
    xverts  = [xverts(1:nVert), xverts(1)]; % Remove unused entries in 
    yverts  = [yverts(1:nVert), yverts(1)]; % vertices matrices.
    heywood = 2*sqrt(pi*area)/nz;
else        % Largest polygon was single pixel.
    xverts  = NaN;
    yverts  = NaN;
    heywood = NaN;
end

end % main