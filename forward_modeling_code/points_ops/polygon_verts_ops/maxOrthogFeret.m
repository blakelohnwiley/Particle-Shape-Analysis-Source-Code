function orthFeret = maxOrthogFeret(points, maxFerP1, maxFerP2)
% MAXORTHOGFERET Calculate the maximum orthogonal feret for a polygon.
% 
% maxOrthogFeret(points,maxFerP1,maxFerP2) returns the maximum orthogonal
% feret for the polygon with vertices contained in points and maximum
% feret with endpionts at maxFerP1 and maxFerP2.
% 
% Inputs:
%   points      Nx3 matrix of Cartesian points.
%   maxFerP1    Maximum feret diameter line segement end point 1.
%   maxFerP2    Maximum feret diameter line segement end point 2.
% 
% Output:
%   orthFeret   Orthogonal feret distance.
% 
% Author: Team Regolith
% Written with MATLAB student 2012a.
% Last updated on 14 July 2014.

ptDistsAndXcz = zeros(size(points,1)-2, 2);
ptDistIx = 1;
for nPoint = 1:size(points,1)
    if ~(isequal(points(nPoint,:), maxFerP1) || ...
                                isequal(points(nPoint,:), maxFerP2))
        [dFromLine, xpz] = distFromLine(...
                                points(nPoint,:), maxFerP1, maxFerP2);
        ptDistsAndXcz(ptDistIx, :) = [dFromLine, xpz];
        ptDistIx = ptDistIx + 1;
    end
end

ptDists_side1 = ptDistsAndXcz(:,2) > 0;
ptDists_side2 = ptDistsAndXcz(:,2) < 0;

ptDists = ptDistsAndXcz(:, 1);

dist1 = max(ptDists(ptDists_side1(:,1)));
dist2 = max(ptDists(ptDists_side2(:,1)));

% if there are no points to one side of the maximum feret diameter line,
% set the corresponding distance = 0
if numel(dist1) == 0
    dist1 = 0;
elseif numel(dist2) == 0
    dist2 = 0;
end

orthFeret = dist1 + dist2;