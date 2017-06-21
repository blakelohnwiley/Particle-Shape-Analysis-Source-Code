function [dist, xpz] = distFromLine(p0, linePt1, linePt2)
% DISTFROMLINE Calculate shortest Cartesian distance between point and 
% line.
% 
% [dist, xpz] = distFromLine(p0, linePt1, linePt2) Returns the 
% distance between a point and a line defined by two 3D points.
% 
% Inputs
%   linePt1     A 3D point on the line.
%   linePt2     A 3D point on the line. Must be distinct from linePt1.
%   p0          The 3D point whose distance from the line is desired.
% 
% Outputs
%   dist        Distance between p0 and the line.
%   xpz         A signed value that may be used to determine whether >1 
%               points lie on the same side of the line. Has value 0 if p0 
%               is on the line (+/- tol=1E-4), +/-1 otherwise.
% 
% Author: B. Hannan
% Written with MATLAB Student 2012a.
% Last updated 15 July 2014.

% Let VL be the vector from linePt1 to linePt2. Let VP be the vector from 
% linePt1 to point. The area of the triangle defined by the 3 points is 
% 1/2 VL x VP. The height of this triangle is dist, the distance between 
% point p0 and the line. dist is therefore given by (VL x VP) / ||VL||.

% Get a vector that defines the line.
VL = linePt2 - linePt1;
% A vector from a point on the line to the point p0.
VP = p0 - linePt1;

dist = norm(cross(VL,VP)) / norm(VL);

% Calculate xpz=0 if p0 on line, +/-1 otherwise.
crossVL_VP = cross(VL, VP);
xpz = crossVL_VP(3);

tol = 1E-4;
if xpz > 0 + tol
    xpz = 1;
elseif xpz < 0 - tol
    xpz = -1;
else
    xpz = 0;
end