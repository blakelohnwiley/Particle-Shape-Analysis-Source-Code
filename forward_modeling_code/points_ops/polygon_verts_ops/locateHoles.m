function [primaryPolyCell,primaryHoleCell,chainCell,polyCellXY] = ...
                                            locateHoles(polyCell,varargin)
% LOCATEHOLES(polygonCell,isHoleArray) identify primary polygons and their
% interior structure given a cell array of co-planar polygons.
% 
% Let polygonCell be a cell array of polygons. Some of these polygons may  
% represent holes. A hole is the boundary of a void space within a polygon. 
% Others may represent islands. An island is a polygon inside a hole. 
% 
% LOCATEHOLES identifies the primary polygons (polygons which are not not
% enclosed by any other polygons) and returns their interior structure, if
% any.
% 
% A polygon has interior structure if it bounds one or more other polygons.
% LOCATEHOLES identifies whether a polygon has interior structure and
% returns that structure in its output, chainCell.
% 
% The cell array output chainCell has two "levels." The first level
% contains a cell array for each primary polygon in the input polyCell.
% 
% Syntax
% locateHoles(polyCell)
% locateHoles(polyCell,plane)
% 
% Inputs:
%   polyCell        A 1xN cell array, where N is the number of polygons. 
%                   Each cell contains a 3-column matrix containing the 
%                   vertices of a closed polygon.
% Optional input:
%   plane           The plane that contains all polygons in polyCell. plane
%                   is a 1x9 array having the form [x0,y0,z0, vx1,vy1,vz1,
%                   vx2,vy2,vz2]. Elements 1:3 represent a point on the
%                   plane. The two following groups of 3 represent vectors
%                   that, with the point, define the plane.
%                   If no plane is provided, it will be calculated from
%                   polyCell. Supplying the plane input improves speed.
% 
% Outputs:
%   primaryPolyCell A cell array containing only the primary polygons.
%   priaryHoleCell  A cell array containing only the primary holes.
%   polyCellXY      A cell array containing the polygons in the input
%                   polyCell after they have been rotated to the XY plane,
%                   if the input polygons are not already in the XY plane.
%   chainCell       A cell array of indices that point to the polygons in
%                   polyCellXY. chainCell provides the "structure" of the
%                   polygons (i.e. the primary polygons and their interior
%                   structure). 
% 
% Note:
% It is assumed that polyCell contains no self-crossing polygons and that 
% no polygon crosses another polygon. This is true if polyCell contains the
% polygons resulting from a cross-section between a plane and a manifold 
% mesh or a plane and multiple manifold meshes that do not touch or cross 
% each other.
% It is also assumed that all polygons in polyCell are co-planar. No check 
% is performed to determine whether the polygons in polyCell are co-planar 
% because in the context in which this function is currently being used, 
% speed is important and the polygons are known to be co-planar before 
% they are passed to this function. A co-planar check could easily be 
% introduced using the POLYNORMAL function.
% 
% 
% B. Hannan
% 1 October 2014
% Written with MATLAB Student 2012a.


% Handle the optional input argument, plane.
numVarArgs = length(varargin);
if numVarArgs > 1
    error(  'myfuns:locateHoles:tooManyInputs'    ,   ...
            'This function takes at most 1 optional input.');
end
% By default, plane = -1 to indicate that the plane was not provided.
optArgs = {-1};
optArgs(1:numVarArgs) = varargin;
plane = optArgs{:};
% If the plane default (-1) has been over-written and the plane does not
% have dims 1x9, there is a problem.
if ~isequal(size(plane),[1,9]) && ~isequal(plane,-1)
    error('myfuns:locateHoles:optArgInType', 'plane must have dims 1x9.');
end


% Rotate polygons to XY plane if necessary.

if plane == -1
    planeNormal = polynormal(polyCell{1});
    if any(isnan(planeNormal))
        error(  'myfuns:locateHoles:normVecCalc' , ...
                'Normal vector for this polygon could not be calculated.');
    end
else
    planeNormal = cross(plane(4:6),plane(7:9));
end
polyCellXY = cell(size(polyCell));
% If the plane normal vector does not point in +/- z, rotate all polygons.
% Apply the same quaternion rotation to all polygons so that angular
% orientations are preserved.
if ~isequal(abs(planeNormal./norm(planeNormal)),[0,0,1])
    % Calculate the quaternion to rotate all polygons in the plane to XY.
    q = quatCalc([0,0,1],planeNormal);
    for nPoly = 1:numel(polyCell)
        qCell = num2cell(repmat(q,size(polyCell{nPoly},1),1), 2);
        assignin('base','qCell',qCell); assignin('base','polyCell',polyCell);
        assignin('base','q',q);
        polyCellXY{nPoly} = cell2mat(                               ...
                                     cellfun(                       ...
                                            @quatRotVec,            ...
                                            qCell,num2cell(polyCell{nPoly},2),...
                                            'UniformOutput',false   ...
                                            )                       ...
                                     );
    end
else
    polyCellXY = polyCell;
end


% Sort the polygons by area.

% Create an array that contains the area of each polygon in polyCellXY.
areaArray = zeros(size(polyCellXY));
for k = 1:numel(areaArray)
    areaArray(k) = polyarea(polyCellXY{k}(:,1), polyCellXY{k}(:,2));
end
% Get an array that provides ixs of polygons ordered by area descending.
[~,areaIxsDesc] = sort(areaArray,'descend');
% Sort the cell array of polygons according to areaIxsDesc.
polyCellXY = polyCellXY(areaIxsDesc);


% Create polyGroupArray. 
% Each element contains an integer that labeles 
% the group (1,2,3,... num. groups). A group is one primary polygon and any
% polygon that it bounds.

% Preallocate polyGroupArray.
polyGroupArray = zeros(size(areaArray));

% Initialize the group index label.
groupLabelIx = 1;

% Iterate over all polygons and separate them into primary polygon groups.
for numLoop = 1:numel(polyCell)
    % Get the 1st empty element in polyGroupArray.
    firstZeroIx = find(polyGroupArray==0,1);
    
    % For the 1st polygon in this chain, set polyGroupArray = groupLabelIx.
    polyGroupArray(firstZeroIx) = groupLabelIx;
    
    % The polygon at polyCellXY{firstZeroIx} is the largest remaining
    % polygon. Any polygons that may be inside of this polygon must
    % necessarily have a smaller area. Check whether the remaining polygons
    % with lesser area are in this polygon.
    for k = firstZeroIx+1:numel(polyGroupArray)
        % Only perform inpolygon check if polygon k has not been "grouped."
        if ~polyGroupArray(k)
        % Is the test point from polygon k in & not on the parent polygon?
        [in,on] = inpolygon(                                ...
                            polyCellXY{k}(1,1),             ...
                            polyCellXY{k}(1,2),             ...
                            polyCellXY{firstZeroIx}(:,1),   ...
                            polyCellXY{firstZeroIx}(:,2)    ...
                         );
            if in && ~on      
                % Assign the current index to polygon k.
                polyGroupArray(k) = groupLabelIx;
            end
        end
    end
    % Increment the group index by 1.
    groupLabelIx = groupLabelIx + 1;
end


% We have now grouped the polygons, but we do not have the structure of
% this group. Determine this structure by iterating over each polygon in a
% group in order area ascending to find each polygon's parent polygon.

% Flip the polygon cell and polyGroupArray left-right so that they are
% sorted in order of ascending polygon area.
polyCellXY = fliplr(polyCellXY);
polyGroupArray = fliplr(polyGroupArray);

% The number of groups is equal to the max value in polyGroupArray.
numGroups = max(polyGroupArray);

% Preallocate a cell that will hold all polygon chains for all groups. Each
% cell is a group. Each cell contains another cell. The sub-cell contains 1
% or more arrays. The number of arrays in this cell equals the total num.
% of chains in the group. Each cell of one of these sub-cells is row vector
% containing a chain. The chain begins with the primary group polygon and 
% ends at the polygon that terminates the chain.
chainCell = cell(1,numGroups);

% For each group, identify all chains. Store them in chainCell.
for numGroup = 1:numGroups
    groupIxs = polyGroupArray == numGroup;
    groupPolyCell = polyCellXY(groupIxs);
    
    % In order to provide an index of a polygon in polyCell (and not
    % groupPolyCell), we need to map from a given index in groupPolyCell to
    % the corresponding index in polyCell.
    mapGroupToTotalPolys = find(groupIxs);
    
    if numel(groupPolyCell) == 1
        % There is only 1 polygon in this group. chainCell(numGroup)
        % contains a cell array with only one element: the ix of the single
        % polygon in polyCell.
        chainCell{numGroup} = {find(groupIxs)};
    else
        % Create an array that indicates whether each polygon in the group 
        % has been added to a chain. This will be used to identify the 
        % starting (least area) polygon for each chain.
        isPolygonInChain = false(size(groupPolyCell));
        
        % Preallocate the sub-cell containing all chains in this group.
        chainSubCell = cell(1,numel(groupPolyCell));
        
        numChain = 1;
        loopCount = 0;
        while ~all(isPolygonInChain)
            % Preallocate an array for this chain.
            chainArray = zeros(1,numel(groupPolyCell));
            
            % Initiailze the ix labeling the location in the current chain.
            numChainElement = 1;
            
            % Find ix of the first (smallest area) polygon in this chain.
            firstZeroIx = find(isPolygonInChain == false,1);

            % Put this polygon at the start of this chain.
            chainArray(numChainElement) = firstZeroIx;
            % Indicate that this polygon has been assigned to a chain.
            isPolygonInChain(firstZeroIx) = true;
            
            % Begin at smallest polygon that has not yet been added to a
            % chain. Walk through all polygons (ordered area ascending). If
            % this smallest polygon lies inside a subsequent polygon, add
            % to the chain. Continue until the largest (final) polygon in 
            % the group is reached.
            for p = firstZeroIx+1:numel(groupPolyCell)
                numChainElement = numChainElement + 1;
                
                if p == numel(groupPolyCell)
                    % The polygon with greatest area has been reached. This 
                    % must be the final polygon in this chain.
                    chainArray(numChainElement) = mapGroupToTotalPolys(numel(groupPolyCell));
                    
                    % Remove any un-used elements.
                    chainArray = chainArray(~chainArray == 0);
                    
                    % Flip the chain so that the 1st element is the largest
                    % polygon in the group.
                    chainArray = fliplr(chainArray);
                    
                    % Store this array in chainSubCell.
                    chainSubCell{numChain} = chainArray;
                    
                    % Indicate that the polygon was assigned to a chain.
                    isPolygonInChain(p) = true;

                else
                    % Is the test point in & not on the parent polygon?
                    [in, on] = inpolygon(                               ...
                                    groupPolyCell{firstZeroIx}(1,1),    ...
                                    groupPolyCell{firstZeroIx}(1,2),    ...
                                    groupPolyCell{p}(:,1),              ...
                                    groupPolyCell{p}(:,2)               ...
                                );
                    if in && ~on
                        % Add ix of polygon at groupPolyCell{p} to this chain.
                        chainArray(numChainElement) = mapGroupToTotalPolys(p);
                        % Indicate that this polygon has been assigned to a
                        % chain.
                        isPolygonInChain(p) = true;
                    end
                end
            end
            
            % Remove empty cells in chainSubCell.
            chainSubCell = chainSubCell(~cellfun(@isempty,chainSubCell));
            % Add chainSubCell to chainCell.
            chainCell{numGroup} = chainSubCell;
            
            numChain = numChain + 1;
            
            loopCount = loopCount + 1;
            if loopCount > 10*numel(polyCellXY)
                error(  'myfuns:locateHoles:loopRunaway',               ...
                        ['Loop runaway. Failed to place all polygons'   ...
                        ' in a chain']);
            end
            
        end
    end
end

% Remove empty cells in chainCell.
chainCell = chainCell(~cellfun(@isempty,chainCell));

% Identify primary polygons and primary holes.
[primaryPolyCell,primaryHoleCell] = separateHoles(polyCellXY,chainCell);
end


% ----------------------------------------------------------------------- %
function [primaryPolyCell,primaryHoleCell] = ...
                                        separateHoles(polyCellXY,chainCell)
% Identify primary polygons and primary holes in chainCell.

% Preallocate the output.
primaryPolyCell = cell(size(polyCellXY));
primaryHoleCell = cell(size(polyCellXY));
% Find the primary polygons and the holes.
for k = 1:numel(chainCell)
    for l = 1:numel(chainCell{k})
        primaryPolyCell{find(cellfun(@isempty,primaryPolyCell),1)} = ...
                                            polyCellXY{chainCell{k}{l}(1)};
        if numel(chainCell{k}{l})>1
            % There is at least one hole in this chain. Keep only the 1st
            % hole.
            primaryHoleCell{find(cellfun(@isempty,primaryHoleCell),1)} =...
                                            polyCellXY{chainCell{k}{l}(2)};
        end
    end
end

% Remove the extra cells.
primaryPolyCell = primaryPolyCell(~cellfun(@isempty,primaryPolyCell));
primaryHoleCell = primaryHoleCell(~cellfun(@isempty,primaryHoleCell));
end