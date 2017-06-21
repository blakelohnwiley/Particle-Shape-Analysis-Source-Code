function [ptsXYplane, q] = rotate2xy(points)
% ROTATE2XY Rotate points to a plane parallel to the x-y plane.
% 
% [ptsXYplane, q] = rotate2xy(points) uses quaternian operations to rotate 
% a Nx3 matrix of co-planar Cartesian points so that they lie in a plane
% parallel to x-y. q is the quaternion used to rotate the points matrix.
% 
% See also: polynormal.m, quatRotverts.m, quatRotVec.m, quatCalc.m
% 
% B. Hannan 2014

% Translate polygon so its centroid lies at the origin.
centroidPoints = centroid(points);
points = trans2origin(points, centroidPoints);

% Get polygon normal. Planar input is presumed.
N = polynormal(points);

% Rotate if polygon normal isn't in the X-Y plane.
if ~isequal(abs(N), [0,0,1])
    [ptsXYplane,~,q] = quatRotVerts([0,0,1], N, points);
else
    ptsXYplane = points;
end