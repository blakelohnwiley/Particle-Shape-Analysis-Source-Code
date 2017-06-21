function N = polynormal(points)
% polynormal(points) returns a unit normal vector to the 3d polygon 
% defined by the matrix points.
% 
% Returns NaN if normal cannot be defined (if all points are collinear).
% 
% Input:
%   points  Nx3 matrix of cartesian points.
% 
% Output:
%   N       Normal vector to the polygon plane.
% 
% B. Hannan
% Written with MATLAB student 2012a
% 24 August 2014

% It's not difficult to calculate a normal vector from three points.
% However, we're bound to run into problems if we simply calculate N from  
% the first 3 points we see. That method fails, for example, when the 
% points are colinear, which occurs often in plane-mesh intersection.

% First get the maximally separated pair of points. Maximizing point
% distance minimizes error: If we conisider a coordinate axes 
% transformation to the frame of the polygon such that the best-fit plane
% lies in X'Y', then N uncertainty would be dominated by dZ' when
% dX', dY' are of order dZ'. 
% Next find the point having greatest distance from this line. Use these 3 
% points to calculate the polygon normal N.

% Remove duplicate points, which may be present in the closed polygon.
points = unique(points,'rows');
[~, p1, p2] = maxVerticesDist(points);

% Convert points to a [num points]-by-1 cell array. 
pointsCell = mat2cell(points, ones(1, size(points, 1)), size(points, 2));
% Use cellfun to call distFromLine(p0, linePoint1, linePoint2) on all
% points. Output distArray is a [num points]-by-1 array of distances
% between each point and the line.
distArray = cellfun(@distFromLine, pointsCell, ...
            repmat({p1},size(pointsCell)), repmat({p2},size(pointsCell)));

% Get first instance of a point with max distance from line.
maxDistFromLineIx = find(distArray == max(distArray), 1);

if all(distArray == 0) || size(points,1)<3
    % All polygon points are collinear or there are too few points.
    N = [NaN, NaN, NaN];
else
    p3 = points(maxDistFromLineIx, :);
    N = cross(p2-p1, p3-p1);
    N = N./norm(N);
end