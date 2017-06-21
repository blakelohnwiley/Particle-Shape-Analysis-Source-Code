function [heywoodFactor,area] = heywood(points,varargin)
% HEYWOOD calculate the Heywood factor for a polygon. The polygon may 
% contain holes.
% 
% [heywoodFactor, area] = HEYWOOD(points) returns the Heywood factor for  
% the Nx3 matrix of vertices, points. Returns Heywood factor and polygon 
% area.
% 
% [heywoodFactor, area] = HEYWOOD(points,holeCell) returns the Heywood 
% factor for the polygon with an outer boundary, points, and one or more 
% holes. The vertices of the holes are contained in the cell array 
% holeCell. holeCell has dimesnions 1 X [number of holes]. Each element of
% holeCell is a Kx3 matrix, where K is the number of vertices on the 
% polygon that describes that hole. The returned area value accoutns for 
% hole area.
% 
% [heywoodFactor, area] = HEYWOOD(points,holeCell,planeNormal) same as
% solidity(points,holeCell), but faster. If a normal vector to the polygon 
% is already known, it may be provided to improve calculation speed.
% planeNormal is a 1x3 vector.
% 
% All polygons must be closed.
% 
% Written by Team Regolith.
% 23 September 2014

% Handle the optional inputs holeVertsCell and planeNormal.
numVarArgs = length(varargin);
if numVarArgs > 2
    error(  'myfuns:heywood:tooManyInputs'    ,   ...
            'This function takes at most 2 optional inputs.');
end
% By default, holesVerticesCell is an empty cell. planeNormal is -1.
optArgs = {cell(0), -1};
optArgs(1:numVarArgs) = varargin;
[holeVertsCell,planeNormal] = optArgs{:};

% Check optional input type, size.
if ~iscell(holeVertsCell)
    error(  'myfuns:heywood:optArgInType'      ,   ...
            'Hole(s) vertices must be contained in a cell array.');
end
if ~isnumeric(planeNormal)
    error(  'myfuns:heywood:optArgInType'      ,   ...
            'Plane normal vector must be numeric.');
end
if ~all(size(planeNormal) == [1,3]) && planeNormal ~= -1
    error(  'myfuns:heywood:optArgInType'      ,   ...
            'Plane normal vector must have size 1x3.');
end

if planeNormal == -1
    % Calculate the plane normal vector.
    planeNormal = polynormal(points);
    if any(isnan(planeNormal))
        error(  'myfuns:heywood:normVecCalc' , ...
                'Normal vector for this polygon could not be calculated.');
    end
end
    
% Polygons must be in the XY plane before areas are calculated.
isPolygonRotated = false;
if ~isequal(abs(planeNormal), [0,0,1])
    points = rotate2xy(points);
    isPolygonRotated = true;
end

% Rotate hole(s) to the XY plane, too. To maintain relative orientation of
% all polygons, use the quaternion q caputred above to perform the same
% quaternion rotation to each polygon.
% Calculate hole area as polygons are rotated.
totalHoleArea = 0;
for numHole = 1:numel(holeVertsCell)
    if ~isPolygonRotated
        holeVerts = rotate2xy(holeVertsCell{numHole});
    else
        holeVerts = holeVertsCell{numHole};
    end
    totalHoleArea = totalHoleArea+polyarea(holeVerts(:,1),holeVerts(:,2));
end

% Get the polygon perimeter.
perim = sum(                                ...
            sqrt(                           ...
                    diff(points(:,1)).^2 +  ...
                    diff(points(:,2)).^2 +  ...
                    diff(points(:,3)).^2    ...
                )                           ...
            );

area = polyarea(points(:,1),points(:,2)) - totalHoleArea;

% Calculate Heywood factor.
heywoodFactor = 2*sqrt(pi*area)/perim;