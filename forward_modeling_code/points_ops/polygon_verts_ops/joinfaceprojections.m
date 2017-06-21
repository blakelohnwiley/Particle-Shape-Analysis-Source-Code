function projPoly = joinfaceprojections(faces,verts,varargin)
% JOINFACEPROJECTIONS Perform union on a group of 2D triangular faces.
% JOINFACEPROJECTIONS(faces, verts) returns the vertices of the union of
% all polygons resulting from a projection of the 3D polygons contained in
% the faces and vertices matrices onto the X-Y plane.
% 
% Inputs:
%   verts       Nx3 matrix of triangular mesh faces.
%   faces       Nx3 connectivity matrix identifying the 3 vertices that 
%               create each triangular face of the mesh.
% Optional:
%   nSigFig     Truncate Cartesian coordinate values to nSigFig digits.
% 
% Output:
%   projPoly    Mx2 matrix containing the closed polygon that results from
%               the union of all face projections.
% 
% Authors: D. Rickman, B. Hannan, J. Knicely
% Written with MATLAB R2014a.
% Last updated on 25 November 2014.

% The polygons described by the verts and faces matrices will be projected
% from 3D onto the XY plane. This funtion will perform a union (polygon
% Boolean OR operation) to join these polygons. We assume that verts and
% faces describe a set of polygons that may be joined into a single polygon
% that does not self-cross. 
% This assumption is violated if, for example, if the verts and faces 
% matrices enclose two unconnected volumes. It would also be violated 
% if the mesh described two pyramids that are joined at their peaks at a 
% single point, since the plane of projection polygon may self-cross.
% This assumption may also be violated if the mesh contains a very thin
% portion that is so narrow that the vertices near this region converge
% onto a single point when values are truncated.

% Handle the optional input argument nSigFig.
numVarArgs = length(varargin);
if numVarArgs > 1
    error(  'myfuns:joinfaceprojections:TooManyInputs'    ,   ...
            'This function takes at most 1 optional input.');
end
optArgs = {4};
optArgs(1:numVarArgs) = varargin;
nSigFig = optArgs{:};

% Define constants.
TF_PLOT             = true; % If true, composite polygons plotted (debug).
VERTS_SCALE_FACTOR  = 1e6;  % Multiplicative vertices scale vaue.  

if VERTS_SCALE_FACTOR / 10^nSigFig < 10
    warning('joinfaceporjections:verticesScale',            ...
        ['Vertices scale factor may be too small. '         ...
        'To avoid floating point problems, increase '       ...
        'VERTS_SCALE_FACTOR or decrease nSigFig. See lines' ...
        ' 37-46 of joinfaceprojections.m.']);
end

% Truncte Cartesian coordinate values.
verts = matroundsf(verts,nSigFig);

% Avoid unnecessary polygon unions. Remove faces that are on the "bottom" 
% of the solid by deleting faces with z component < 0.
% This operation requires that all faces are ordered in the same sense, 
% i.e. that [v3-v1]x[v2-v1] always points inward or always points outward, 
% where v1, v2, v3 are the 3 vertices in any row of the faces matrix.
faces = unifyMeshNormals(faces,verts);
% faces = removeFacesNegativeZ(faces,verts,ZERO_AREA_TOL);

% Remove z-coordinates from verts to project the points onto the XY plane.
verts = verts(:,1:2);

% Remove any projected face with 3 collinear points.
faces = removeCollinearTriangles(verts,faces);

% Scale vertices and convert to 64 bit int.
verts = scaleVerticesUp(verts,VERTS_SCALE_FACTOR);

% Build the neighbor groups (groups of connected triangles). The output,
% neighborGroupCell, is a cell array. Each element is an array of indices
% (not triangle vertices) which point to rows of the faces matrix.
neighborGroupCell = findConnnectedTriangles(faces);

% Union all triangles in each neighbor group. The output is a cell of
% polygon vertices. The polygons in this cell have yet to be joined to 
% each other to form the final composite polygon.
% neighborGroupPolysCell = unionNeighborGroups(neighborGroupCell,verts,faces);
neighborGroupPolysCell = createNbrGroupCell(neighborGroupCell,verts,faces);
for numGroup = 1:length(neighborGroupPolysCell)
    [xGroup,yGroup] = unionPolygonCell(neighborGroupPolysCell{numGroup});
    neighborGroupPolysCell{numGroup} = [xGroup,yGroup];
end

% Union all neighbor group polygons to produce a single composite polygon
% for this plane of projection.
[xComp,yComp] = unionPolygonCell(neighborGroupPolysCell);

% Union the composite polygon to each of its constituent triangles again in
% order to avoid narrow protrusion features.
CompositePoly.x = xComp;
CompositePoly.y = yComp;
for numTri = 1:size(faces,1)
    triangleVerts = verts(faces(numTri,:),:);
    xTri = triangleVerts(:,1);
    yTri = triangleVerts(:,2);
    CompositePoly = unionPolygons(CompositePoly,xTri,yTri);
end
xComp = CompositePoly.x;
yComp = CompositePoly.y;

% Scale the polygon down to its original size.
projPoly = (1/VERTS_SCALE_FACTOR) .* double([xComp,yComp]);

% Close the plane of projection polygon.
if ~isequal(projPoly(end,:),projPoly(1,:))
    projPoly = [projPoly; projPoly(1,:)];
end

end




% ----------------------------------------------------------------------- %
% In order to avoid unneccessarry calculations, we have thrown out faces
% whose normal vectors do not satisfy normal_vector(3)>0. Therefore, there
% may be multiple, overlapping groups of remaining polygons. Identify these
% groups of neighboring polygons.
function nbrGroupCell = findConnnectedTriangles(f)

% Preallocate isAnnexed array. This Boolean array keeps track of which
% projected faces have been annexed into any neighbor group.
isAnnexedArray = false(size(f,1),1);

% Preallocate a cell that will contain all of the neighbor groups.
nbrGroupCell = cell(1,size(f,1));

loopCount = 1;
tfNewGroup = true;
while ~all(isAnnexedArray)
    
    % If beginning a new group, find an un-annexed triangle, faces(k). This
    % index (k) then forms the initial contents of the triGroupIxs matrix.
    if tfNewGroup
        firstTriIx = find(~isAnnexedArray,1);
        neighborGroupIxs = firstTriIx;
    end
    
    tfContinueNeighborSearch = true;
    
    while tfContinueNeighborSearch
        
        % Find all neighor faces for the current neighbor group.
        nbrTriIxs = findNeighborTriIxs(neighborGroupIxs,isAnnexedArray,f);
        
        % Add the new triangles to the current neighbor group.
        if ~isempty(nbrTriIxs)
            neighborGroupIxs = [neighborGroupIxs,nbrTriIxs];
            isAnnexedArray(nbrTriIxs) = true;
        else
            tfContinueNeighborSearch = false;
        end
        
    end
    
    % Get the index of the first empty cell in neighborGroupCell.
    firstEmptyCellIx = find(cellfun(@isempty,nbrGroupCell),1);
    
    % Store the current neighbor group in neighborGroupCell.
    nbrGroupCell{firstEmptyCellIx} = neighborGroupIxs;
    
    loopCount = loopCount + 1;
    if loopCount > numel(isAnnexedArray)
        fprintf('cannot group all connected triangles\n'); %%% DEBUG
        error(  'myfuns:joinfaceprojections:runawayLoop',   ...
                'Failed to identify neighbor group triangles.'  );
    end
    
end

% Remove empty cells.
nbrGroupCell = nbrGroupCell(~cellfun(@isempty,nbrGroupCell));

end


% ----------------------------------------------------------------------- %
% Consider a collection of triangles. These triangles are a sub-set of the
% triangles in a faces matrix f. The ixs of these triangles are stored in
% the row vector triGroupIxs.
% Given triGroupIxs, faces matrix f, and the array isAnnexed, which
% indicates whether each row of f has been added to a neighbor group, find
% the indices of any triangles that share 2 vertices with any un-annexed
% triangles.
% Output is a row vector.
function nbrTriIxs = findNeighborTriIxs(triGroupIxs,isAnnexed,f)

% Get the unique ixs of the vertices for triangles in this neighbor group.
nbrGroupVertIxs = f(triGroupIxs,:);
nbrGroupVertIxs = unique(nbrGroupVertIxs(:));

% Create fRemain matrix by replacing rows in f with NaNs for each row
% that has been annexed.
fRemain = f;
for nRow = 1:size(fRemain,1)
    if isAnnexed(nRow)
        fRemain(nRow,:) = [NaN,NaN,NaN];
    end
end

% Which elements of fRemain are present in triGroupIxs?
isFacesElementInNbrGroupVertIxs = ismember(fRemain,nbrGroupVertIxs);

% Sum rows to get num. shared verts between neighbor group & each face.
numSharedVertsArray = sum(isFacesElementInNbrGroupVertIxs,2);

% Get indices of the rows in faces (triangles) that share >1 vertex.
nbrTriIxs = find(numSharedVertsArray > 1)';

end


% ----------------------------------------------------------------------- %
function nbrGroupVertsCell = createNbrGroupCell(nbrGroupIxCell,v,f)

numNeighborGroups = length(nbrGroupIxCell);

% Preallocate a cell to store output polygons.
nbrGroupVertsCell = cell(size(nbrGroupIxCell));

for numGroup = 1:numNeighborGroups
    
    % Preallocate a cell. Each element holds the vertices of one triangle 
    % in a 3x2 matrix.
    nbrGroupSubCell = cell(1,length(nbrGroupIxCell{numGroup}));
    
    % Get the ixs of the triangles in this group. These ixs point to rows
    % in the faces matrix.
    neighborGroupIxs = nbrGroupIxCell{numGroup};
    
    for numTri = 1:length(nbrGroupSubCell)
        nbrGroupSubCell{numTri} = v(f(neighborGroupIxs(numTri),:),:);
    end
    
    % Store polygon in cell.
    nbrGroupVertsCell{numGroup} = nbrGroupSubCell;
    
end

end


% ----------------------------------------------------------------------- %
% Union all polygons in a cell to produce a single composite polygon.
function [xPoly,yPoly] = unionPolygonCell(polyCell)

NUM_LOOP_CYCLES = 5;

% Choose an arbitrary "first" polygon before starting the union process.
firstPolygonIx = 1;
polygonVertices = polyCell{firstPolygonIx};
xPoly = polygonVertices(:,1);
yPoly = polygonVertices(:,2);
polyCell(firstPolygonIx) = [];  % Remove this polygon from cell array.
polygonStruct.x = xPoly;
polygonStruct.y = yPoly;

loopCount = 1;
initialCellLen = length(polyCell);

image_ix = 0; %%% DEBUG

while ~isempty(polyCell)
    
    % Union neighbor group polygons in the order that they are given in
    % cell array neighborGroupPolygonsCell.
    % Why do this? In a bugless world, this would be unneccessary. However,
    % joning many polygons is very error-prone. Success depends on the
    % order of unions. Therefore, I'm setting aside some code that
    % specifies the order of polygon unions.
    polyIxs = 1:length(polyCell);

    % Just before this function quits, remove all union-ed triangles
    % from facesRemain matrix. tfRemoveTriangle contains Boolean elements. If
    % tfRemoveTriangle, delete kth row of facesRemain.
    tfRemovePolygon = false(1,length(polyCell));

    for numGroup = 1:numel(polyIxs)
        
        % Get the vertices of a polygon (a neighbor group).
        polygonVerts = polyCell{polyIxs(numGroup)};
        xVerts = polygonVerts(:,1);
        yVerts = polygonVerts(:,2);
        
        % Attepmt polygon union.
        polygonStruct = unionPolygons(polygonStruct,xVerts,yVerts);

        tfRemovePolygon(numGroup) = true;
        
%         %%% DEBUG
%         cmap = jet(6);
%         figure(11), clf;
%         for k = 1:length(polygonStruct)
%             x = polygonStruct(k).x;
%             y = polygonStruct(k).y;
%             hp = patch(x,y,'b');
%             set(hp,'FaceAlpha',0.5,'LineWidth',2);
%         end
%         
%         hold on;
%         hTri = patch(xVerts,yVerts,'b'); 
%         set(hTri,'FaceAlpha',1,'FaceColor',cmap(rem(numGroup,6)+1,:));
%         pause;
%         
%         image_ix = image_ix + 1;
% %         pdf_file_name_string = sprintf('union_%d',image_ix);
% %         disp(pdf_file_name_string);
% %         print('-dpdf',pdf_file_name_string); %%% DEBUG

    end

    % Return any polygons that may not have been unioned.
    polyCell = polyCell(~tfRemovePolygon);

    loopCount = loopCount + 1;
    if loopCount > NUM_LOOP_CYCLES*initialCellLen
        fprintf('cannot union nbr group polygons\n'); % DEBUG
        error(  'myfuns:joinfaceprojections:runawayLoop',   ...
                'Failed to union all neighbor groups.'  );
    end
    
end

end


% ----------------------------------------------------------------------- %
% 
function ClipperOut = unionPolygons(ClipperStruct,x2,y2)

UNION_IDENTIFIER = 3;
    
poly2.x = x2;
poly2.y = y2;

ClipperOut = clipper(ClipperStruct,poly2,UNION_IDENTIFIER);

for k=1:length(ClipperOut);
%     [ClipperOut(k).x,ClipperOut(k).y] = removeProtrusions(ClipperOut(k).x,ClipperOut(k).y);
    ClipperOut(k).x = int64(ClipperOut(k).x);
    ClipperOut(k).y = int64(ClipperOut(k).y);
end

end


% ----------------------------------------------------------------------- %
% Enlarge vertices and convert to int64.
function x = scaleVerticesUp(x,scaleFactor)

x = int64(scaleFactor * x);

end


% ----------------------------------------------------------------------- %
% Remove any faces that produce line segments when projected onto XY plane.
% Outputs facesNoLines, a faces matrix with "linear triangles" removed.
% Also outputs isTriLine, a Boolean array of length equal to length(faces) 
% that indicates which rows of the faces matrix have been removed.
function [facesNoLines,isTriLine] = removeCollinearTriangles(verts,faces)

% If vertices have been converted to int64, we cannot use the function
% norm. Convert vertices to double.
if isa(verts,'integer')
    verts = double(verts);
end

% Remove any face projection if its 3 vertices are collinear. 
% Creat triVerts matrix. triVerts has dims 3*[no. faces] X 3. Rows 1:3 
% contain the x,y,z coordinates for all points on the first face, 
% 2:6 the 2nd face, etc.
triVerts = verts(reshape(faces',[],1), :);
triVertCell = mat2cell(triVerts, ...
                    3*ones(1,size(triVerts, 1)/3),size(triVerts,2));
% Now apply the function iscollinear3 to each triangle in triVertsCell.
% The output is a logical array. If an element of isTriLine is true, 
% the corresponding element of triVertsCell holds 3 collinear points.
isTriLine = cell2mat(                                   ...
                    cellfun(@iscollinear3,triVertCell,  ...
                    'UniformOutput',0)                  ...
                );
% Remove any projected faces with 3 collinear points.
facesNoLines = faces(~isTriLine,:);
    
end


% ----------------------------------------------------------------------- %
% Remove face if normal vector z component is < 0.
function facesPosZ = removeFacesNegativeZ(faces,verts,zeroAreaTol)
% Remove all faces that have a normal vector with a negative z-component.
% This function assumes that the faces matrix is arranged such that all
% faces are given in outward-facing normal order or that all faces are
% given in inward-facing normal order, i.e. that [faces(n,3)-faces(n-1)]
% crossed with [faces(n,2)-faces(n,1)] always produces an outward-facing
% vector or always prodcues an inward-facing vector.

% Remove linear faces, for which a normal vector can't be defined. A linear
% face is identified as a face with an area less than ZERO_AREA_TOL.

% Create a cell. Each element of the cell is a face (a 3x3 matrix). 
triCell = mat2cell(verts(reshape(faces',numel(faces),1), :), ...
                                            3*ones(1,numel(faces)/3), 3);
                                        
% Get the area of every element of triCell.
triArea = @(M) 0.5*norm(cross(M(2,:)-M(1,:), M(3,:)-M(1,:)));
triAreaMat = cell2mat(cellfun(triArea, triCell, 'UniformOutput', 0));

% Remove all faces with negligible area or with NaN area.
nonZeroAreaFaces = triAreaMat > zeroAreaTol;
faces = faces(nonZeroAreaFaces,:);
triCell = triCell(nonZeroAreaFaces);

% This anonymous function calculates a normal unit vector for each face. 
normCalc = @(M) cross(M(2,:)-M(1,:), M(3,:)-M(1,:))./...
                    norm(cross(M(2,:)-M(1,:), M(3,:)-M(1,:)));

% Row k of normMat is a unit vector perpendicular to face k.
normMat = cell2mat(cellfun(normCalc,triCell,'UniformOutput',0));

% Remove faces whose normal vectors have negative z components.
isZpositive = normMat(:,3) > 0;
facesPosZ = faces(isZpositive,:);

end


% ----------------------------------------------------------------------- %
% Collinearity test for 3 points.
function isCollinear = iscollinear3(tripMat)

% There is one point per row in the 3x3 matrixt tripMat.
% If cross product is approx. 0, the points are collinear.
% When collinearTol = 1E-6, iscollinear3 has an angular resolution of 
% ~6E-5 deg.
COLLINEAR_TOL = 1E-6;

% If vertices have been converted to int64, we cannot use the function
% norm. Convert vertices to double.
if isa(tripMat,'integer')
    tripMat = double(tripMat);
end

p0 = tripMat(2,:);
pA = tripMat(1,:);
pB = tripMat(3,:);

uvA = [pA-p0,0]./norm([pA-p0,0]);
uvB = [pB-p0,0]./norm([pB-p0,0]);

if any(isnan(uvA)) || any(isnan(uvB)) % NaN indicates identical points.
    isCollinear = true;
else
    isCollinear = norm(cross(uvA,uvB)) < COLLINEAR_TOL;
end

end


% ----------------------------------------------------------------------- %
% Remove any line segments that may protrude from the polygon. Protruding  
% line segments are identified by a pattern P->Q->P in the polygon 
% vertices. Returns a clockwise polygon.
function [X,Y] = removeProtrusions(X,Y)
    
if numel(X) ~= 3 % Do nothing if the polygon is a triangle.

    % Remove consecutive duplicates.
    isPrevPointEqual = false(size(X));
    for k = 2:numel(X)
        point = [X(k),Y(k)];
        last_point = [X(k-1),Y(k-1)];
        if isequal(point,last_point)
            isPrevPointEqual(k) = true;
        end
    end
    X = X(~isPrevPointEqual);
    Y = Y(~isPrevPointEqual);

    % Remove zero-area line segment extensions.
    isProtrudingSegment = false(size(X));
    for m = 3:numel(X)
        point = [X(m),Y(m)];
        point_two_steps_back = [X(m-2),Y(m-2)];
        if isequal(point,point_two_steps_back)
            isProtrudingSegment(m-1:m) = true;
        end
    end
    X = X(~isProtrudingSegment);
    Y = Y(~isProtrudingSegment);

end

end