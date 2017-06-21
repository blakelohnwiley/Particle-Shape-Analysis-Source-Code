function [ar,maxFer,orthFer,mfp1,mfp2] = aspectRatio(points)
% ASPECTRATIO_RETPTS Calculate aspect ratio for a polygon.
% [ar, maxFeret, orthFeret, p1, p2] = aspectRatio(points) calculates the 
% aspect ratio for a matrix of cartesian points. 
% 
% Input:
%   points      Nx3 matrix of polygon vertices cartesian points.
% 
% Outputs:
%   ar          Aspect ratio
%   maxFeret    Maximum feret distance (max caliper diamter).
%   orthFeret   Orthogonal feret distance.
%   pmf1, pmf2  The x, y, z coordinates of the two points that define the
%               maximum feret.
% 
% Written by Team Regolith.

% [maxFeret, pmf1, pmf2] = maxVerticesDist(points);
% orthFeret = maxOrthogFeret(points, pmf1, pmf2);
% ar = orthFeret/maxFeret;

maxFer = [ 0 NaN NaN ];
Q1 = size(points,1)-1;
for j = 1:Q1
    for k = 1:Q1
        % Calculates the distance between points
        d_n1 = sqrt( (points(j,1)-points(k,1))^2 + (points(j,2)-points(k,2))^2 + (points(j,3)-points(k,3))^2);
        % Store the maximum distance
        if d_n1 > maxFer(1)
            maxFer = [ d_n1 j k ];
            % i & j are indices in rec of the most distant vertices, ie if i=2 & j = 5,
            % then rec(2,:) & rec(5,:) are the most distant
        end
    end
end

% Remove points used for the maximum feret diameter.
int1 = NaN(0,3);
for j = 1:Q1
    if j~=maxFer(2) && j~=maxFer(3)
        int1 = union(int1,points(j,:),'rows');
    end
end

normalvec = polynormal(points);

L = size(int1,1);

mfp1 = points(maxFer(2),:);
mfp2 = points(maxFer(3),:);

m = mfp2 - mfp1; 
% Creates the vector for the line of the maximum Feret
% diameter. The normal (AKA cross product) of this with the normal to
% the plane will give the normal for an imaginary plane that cuts the
% points in half. Now that I have the imaginary plane, all of the
% points above it get put into one group, and those below it into
% another.

n_imag = cross(normalvec, m);

above_s = zeros(1,2);
below_s = zeros(1,2);

for j = 1:L
    if (dot(n_imag,(int1(j,:)-mfp1)) > 0)
        % Store dist and iteration of 'int' that it was obtained from.
        above = [distancePointLine3d(int1(j,:), [mfp1 m]) j];
        above_s = union(above_s,above,'rows');
    else
        below = [distancePointLine3d(int1(j,:), [mfp1 m]) j];
        below_s = union(below_s,below,'rows');
    end
end

% Following 2 lines retain only the maximum value above and below the line.
above = max(above_s(:,1));
below = max(below_s(:,1));
orthFer = above(1) + below(1);
ar = orthFer/maxFer(1); % calculates the aspect ratio