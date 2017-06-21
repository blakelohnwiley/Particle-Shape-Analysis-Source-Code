function order = orderAngles_v2(Points)

% This funtion takes in 1 argument, the points that define a polygon, and
% gives the order relative to each other in which the angles should be.
% Points should be an N x 3 matrix. 

% The idea behind this program is that it projects the points onto a 2D
% plane, the xy axis, the xz axis, or the yz axis. I have it set up to
% project onto the xy axis by default, but, should all of the values in the
% xy axis be the same, it will project onto one of the other 2 axis. To
% project it, I simply drop the values of one axis. While this does not
% retain information such as perimeter or area, it does maintain the
% relative positions of the points, which is all that is necessary here.
% Once I have them in a single plain, I can use the built in function
% convexHull to determine the order in which the points should be to make
% the proper convex polygon. 
% A problem can occur when dropping one of the axes in which the points are
% colinear and form a straight line. I check for collinearity with 3
% points. 

tolerance = 10^-10;
% X(3) is dropping the Z axis
X(3) = (Points(2,1)-Points(1,1)) / (Points(2,2)-Points(1,2)) - (Points(3,1)-Points(1,1)) / (Points(3,2)-Points(1,2));
% X(1) is dropping the x axis
X(1) = (Points(2,3)-Points(1,3)) / (Points(2,2)-Points(1,2)) - (Points(3,3)-Points(1,3)) / (Points(3,2)-Points(1,2));
% X(2) is dropping the y axis
X(2) = (Points(2,3)-Points(1,3)) / (Points(2,1)-Points(1,1)) - (Points(3,3)-Points(1,3)) / (Points(3,1)-Points(1,1));
% Matlab will often give values very close to zero, but not quite.
% Colinearity occurs if above equations equal zero. Values within a certain
% tolerance are set to zero.
for i = 1:3
    if abs(X(i))<=tolerance
        X(i) = 0;
    end
end

if X(3)~=0
    dt = DelaunayTri(Points(:,1),Points(:,2));
    K = convexHull(dt); 
elseif X(1)~=0
    dt = DelaunayTri(Points(:,2),Points(:,3));
    K = convexHull(dt);
elseif X(2)~=0
    dt = DelaunayTri(Points(:,1),Points(:,3));
    K = convexHull(dt);
end

order = K;
% Now the angles should be sorted from greatest to least. 
