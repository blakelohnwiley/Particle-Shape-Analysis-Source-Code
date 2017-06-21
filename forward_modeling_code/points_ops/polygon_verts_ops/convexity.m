function cvty = convexity(points)
% CONVEXITY calculate polygon convexity.
% 
% conv = convexity(points) returns the convexity for the Nx3 matrix of 
% vertices, points. The polygon must be closed.
% 
% Author: Team Regolith
% Written with MATLAB Student 2012a.
% Last updated on 13 August 2014.

% Ensure that the polygon is in the xy plane.
pointsXY = rotate2xy(points);
poly = pointsXY(:,1:2);
polyConvHull = poly(convhull(poly(:,1), poly(:,2)),:);
cvty = perimcalc(polyConvHull(:,1),polyConvHull(:,2))/ ...
                                            perimcalc(poly(:,1),poly(:,2));
end

function perim = perimcalc(X,Y)
% Calculate the perimeter of a polygon in the x-y plane.
perim = sum(sqrt(diff(X).^2 + diff(Y).^2));
end