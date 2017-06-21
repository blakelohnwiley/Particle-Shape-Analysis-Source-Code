function sol = solidity(points,varargin)
% SOLIDITY calculate polygon solidity. The polygon may contain holes.
% 
% sol = SOLIDITY(points) returns the solidity for the Nx3 matrix of 
% vertices, points. The polygon must be closed.
% 
% sol = SOLIDITY(points,holeCell) returns the solidity for the polygon
% with an outer boundary, points, and one or more holes. The vertices of
% the holes are contained in the cell array holeCell. holeCell has
% dimesnions 1 X [number of holes]. Each element of holeCell is a Kx3
% matrix, where K is the number of vertices on the polygon that describes
% that hole.
% 
% sol = SOLIDITY(points,holeCell,planeNormal) same as
% solidity(points,holeCell), but faster. If a normal vector to the polygon 
% is already known, it may be provided to improve calculation speed.
% planeNormal is a 1x3 vector.
% 
% All polygons must be closed.
% 
% 
% Author: Team Regolith
% Written with MATLAB Student 2012a.
% 23 September 2014


% Handle the optional inputs holeVertsCell and planeNormal.
numVarArgs = length(varargin);
if numVarArgs > 2
    error(  'myfuns:solidity:tooManyInputs'    ,   ...
            'This function takes at most 2 optional inputs.');
end
% By default, holesVerticesCell is an empty cell. planeNormal is -1.
optArgs = {cell(0), -1};
optArgs(1:numVarArgs) = varargin;
[holeVertsCell,planeNormal] = optArgs{:};

% Check optional input type, size.
if ~iscell(holeVertsCell)
    error(  'myfuns:solidity:optArgInType'      ,   ...
            'Hole(s) vertices must be contained in a cell array.');
end
if ~isnumeric(planeNormal)
    error(  'myfuns:solidity:optArgInType'      ,   ...
            'Plane normal vector must be numeric.');
end
if ~all(size(planeNormal) == [1,3])  && planeNormal ~= -1
    error(  'myfuns:solidity:optArgInType'      ,   ...
            'Plane normal vector must have size 1x3.');
end

if planeNormal == -1
    % Calculate the plane normal vector.
    planeNormal = polynormal(points);
    if any(isnan(planeNormal))
        error(  'myfuns:solidity:normVecCalc' , ...
                'Normal vector for this polygon could not be calculated.');
    end
end
    
% Polygons must be in the XY plane before areas are calculated.
% Ensure that the polygon is in the XY plane. rotate2xy is not used because
% it does not maintain relative angular orientation.
if ~isequal(abs(planeNormal), [0,0,1])
    % Rotate so that the polygon has normal [0,0,1]. Capture q, the
    % quaternion used for this rotation.
    [pointsXY,~,q] = quatRotVerts([0,0,1], planeNormal, points);
    rotated = true;
else
    pointsXY = points;
    rotated = false;
end

% Rotate hole(s) to the XY plane, too. To maintain relative orientation of
% all polygons, use the quaternion q caputred above to perform the same
% quaternion rotation to each polygon.
% Calculate hole area as polygons are rotated.
holeAreaArray = zeros(1,numel(holeVertsCell));
for numHole = 1:numel(holeVertsCell)
    if rotated
        qCell = num2cell(repmat(q,size(holeVertsCell{numHole},1),1), 2);
        holeVertsCell{numHole} =                                    ...
                   cell2mat(                                        ...
                            cellfun(                                ...
                                @quatRotVec,                        ...
                                qCell,holeVertsCell{numHole},       ...
                                'UniformOutput',false               ...
                                )                                   ...
                            );
    end
    holeAreaArray(numHole) = polyarea(holeVertsCell{numHole}(:,1), ...
                                      holeVertsCell{numHole}(:,2));
end
% Get the net area of any holes that may be in the polygon.
totalHoleArea = sum(holeAreaArray);

% Ignore z coordinate values.
poly = pointsXY(:,1:2);
% Get the polygon convex hull.
polyConvHull = poly(convhull(poly(:,1), poly(:,2)),:);

% Calculate solidity. Subtract net hole area from outer polygon area.
sol = (polyarea(poly(:,1),poly(:,2)) - totalHoleArea) / ...
                            polyarea(polyConvHull(:,1),polyConvHull(:,2));
end