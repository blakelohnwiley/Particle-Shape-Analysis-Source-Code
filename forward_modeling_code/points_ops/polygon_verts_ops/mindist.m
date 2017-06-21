function [dist, p1, p2] = mindist(points)
% Find distance between the pair of points with minimum Euclidean distance
% separation.
% Returns minimally separated points p1, p2 and dist.
% 
% Utilizes J. Kirk's FileExchange submission, distmat.m.
% 
% B. Hannan 2014

if iscell(points)
    points = cell2mat(points);
end

if size(points,2)>3 || size(points,2)<3
    error(  'myfuns:maxVerticesDist:argSize'    ,   ...
            'Points matrix is non-physical. Expect 2<=size(points,2)<=3.');
end

dmat = distmat(points);

% Find min non-0 separation. Substitute NaN on the main diagonal.
dmat(~dmat) = NaN;

[iMin,jMin] = find(dmat == min(dmat(:)));
dist = dmat(iMin(1),jMin(1));
p1 = points(iMin(1),:);
p2 = points(jMin(1),:);