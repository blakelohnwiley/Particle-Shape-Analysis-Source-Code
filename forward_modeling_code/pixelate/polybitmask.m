function [mask,polyScale] = polybitmask(poly,maxVertsDist,maxAreaOOM)
% POLYBITMASK Binarize a polygon.
% 
% [polyMask, polyScale] = polybitmask(poly,maxVertsDist)
% Returns a binarized polygon and the mask used to generate it, polyMask.
% 
% Inputs:
%   poly            A closed, 2D polygon.
%   maxVertsDist    A value used to determine polygon/bitmask scale. To
%                   apply the same mask to a set of polygons generated 
%                   from a single mesh, use the same maxVertsDist value 
%                   for each polygon.
%   maxAreaOOM      Order of magnitude estimate for maximum area in pixels.
% 
% Outputs:
%   mask            The mask used to generate binaryPoly.
%   polyScale       Scale factor that was applied to the original polygon
%                   for binarization.
% 
% Because this function was designed to accept input polygons generated
% from 3D solids represented as triangular meshes, the Cartesian distance 
% between the maximally separated pair of points, maxVertsDist, is used 
% to calculate polygon/mask scale.
% 
% B. Hannan
% Written with MATLAB Student 2012a.
% Last updated on 24 July 2014.

% Approx. relative scale between polygon length and length of square mask. 
MASK_SCALE = 5;

% Set polygon/mask scale. Polygons that are approximately square will best
% fit this scale factor, which aims to scale polygon vertices such that the
% scaled polygon as an area of order maxAreaOOM pixels. Scaled polygon 
% area will be significantly less than maxAreaOOM when maximum caliper 
% diameter is much greater than the orthogonal feret and also when the 
% polygon contains one or more protusions whose width are small when 
% compared to their length (for example, a starfish).
polyScale = sqrt(2*maxAreaOOM)/maxVertsDist;
nMask = round(MASK_SCALE*polyScale);

% Scale the polygon.
polysc = polyScale*poly;
xMin = min(polysc(:,1));
xMax = max(polysc(:,1));
yMin = min(polysc(:,2));
yMax = max(polysc(:,2));
dx = xMax - xMin;
dy = yMax - yMin;

% Calculate distances to translate the polygon along the x, y axes so that 
% it is approximately centered in the mask after it is translated.
xTrans = abs(xMin) + round((nMask-dx)/2);
yTrans = abs(yMin) + round((nMask-dy)/2);

% Translate the polygon.
transMat = [xTrans*ones(size(poly,1),1), yTrans*ones(size(poly,1),1)];
polysc = polysc + transMat;

if any(min(polysc<=0)) || any(max(polysc>=nMask))
    error(  'myfuns:polybitmask:bigPolygon', ...
            'Scaled polygon is too large for the mask.');
end

% Create a mask with dimensions nMask x nMask.
mask = poly2mask(polysc(:,1), polysc(:,2), nMask, nMask);

end