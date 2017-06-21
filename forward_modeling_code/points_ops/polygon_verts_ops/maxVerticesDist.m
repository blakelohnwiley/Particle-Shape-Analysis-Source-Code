function [dist, p1, p2] = maxVerticesDist(points)
% MAXVERTICESDIST Calculate Cartesian distance between maximally separated
% pair of points.
% 
% [dist, p1, p2] = maxVerticesDist(points) returns dist, the Cartesian  
% distance between the points of max x-y separation, p1 and p2.
% 
% Author: B. Hannan.

if iscell(points)
    points = cell2mat(points);
end

if size(points,2)>3 || size(points,2)<2
    error(  'myfuns:maxVerticesDist:argSize'    ,   ...
            ['[maxVerticesDist] Points array is non-physical. ' ...
            'Expect 2<=size(points,2)<=3.']);
end

dmat = distmat(points);

[iMax,jMax] = find(dmat == max(dmat(:)));
dist = dmat(iMax(1),jMax(1));
p1 = points(iMax(1),:);
p2 = points(jMax(1),:);