function polyCell = xsecmesh(plane,verts,faces,varargin)
% XSECMESH Find polygon(s) formed by a cross-section between a mesh and a plane.
% 
% XSECMESH(plane, verts, faces, distMin) Generate closed polygon(s) 
% representing the cross-section that results from the intersection of a 
% mesh with a plane. (Note: an intersection point is defined as the 
% intersection between an edge and the plane.)
% 
% Inputs:
%   plane       A plane in the form [x0,y0,z0,vx1,vy1,vz1,vx2,vy2,vz2]. 
%               First 3 elements are a point on the plane. The next 6  
%               represent two in-plane vectors.
%   verts       Vertices matrix for the mesh.
%   faces       Faces matrix for the mesh.
% Optional input:
%   nSigFig     Truncate cartesian values to nSigFig digits.
% 
% Output:
%   polyCell    Cell array of closed polygons.
% 
% Note: No intersection is identified when an edge end point (a vertex of 
% the solid) lies on the plane.
% 
% See also: mindist.m
% 
% Author: B. Hannan
% Written while working under the direction of Dr. Doug Rickman at NASA's Marshall Space
% Flight Center. Conversations with Dr. Rickman and Josh Knicely guided the development 
% of this function.
% Written with MATLAB 2012a.
% Last updated on 30 Dec. 2015.

% Note: because ismember R2014a has changed and I am using R2012a, I am
% using the 'R2012a' flag each time I use ismember.

% Handle the optional input arg distMin.
numVarArgs = length(varargin);
if numVarArgs > 1
    error(  'myfuns:processGeomStruct:TooManyInputs'    ,   ...
            'This function takes at most 1 optional input.');
end
optArgs = {6};
optArgs(1:numVarArgs) = varargin;
nSigFig = optArgs{:};

% Require triangular mesh input.
NUM_EDGES_PER_FACE = 3;

% If plane intersects one or more vertices, ignore plane of section.
vertsCell = mat2cell(verts, ones(1, size(verts, 1)), size(verts, 2));
distArray = cellfun(@planePointDist, vertsCell, ...
                                        repmat({plane},size(vertsCell)));

% edgeCheckedMat is a list that will be populated with the endpoinds of 
% those edges that have been checked for intersection.
edgeCheckedMat = zeros(3*size(faces,1),6);
edgeCheckedIx = 1;

if any(truncate_matrix_values(~distArray, nSigFig))
    % Return empty cell.
    polyCell = {};
    disp(['Mesh cross-section operation terminated because a mesh vertex '...
        'lies on the slicing plane.']);
else
    % Each row of intPtsAndNbrFaces will contain the [x,y,z] coordinates of 
    % an intersection point in 1:3. In the same row, elements 4:5 hold the 
    % ixs of the two faces that the point point lies on.
    % Why combine intersection point coords and face labels in one matrix?  
    % Repeated entries will need to be removed. This operation is simpler
    % when the data are stored in a single matrix.
    intPtsAndNbrFaces = zeros(NUM_EDGES_PER_FACE*size(faces,1), 5);
    usedRows = zeros(1, size(intPtsAndNbrFaces,2)); % Which intPtsAndNbrFaces rows have been used?
    for faceNum = 1:size(faces, 1)
        tfFaceIntersect = test_face_plane_intersect(verts,faces,faceNum,plane);
        if tfFaceIntersect % Find the intersection points' coordinates.
            vertIxsCurrentFace = faces(faceNum, :);
            faceVertIxList = [vertIxsCurrentFace, vertIxsCurrentFace(1)];
            for edgeNum = 1:NUM_EDGES_PER_FACE
                p1 = verts(faceVertIxList(edgeNum), :);
                p2 = verts(faceVertIxList(edgeNum+1), :);
                tfEdgeChecked = query_edge_intersect_checked(p1, p2, edgeCheckedMat);
                if ~tfEdgeChecked
                    % Add this edge to the list of edges tested for intersect.
                    edgeCheckedMat(edgeCheckedIx, :) = [p1, p2];
                    edgeCheckedIx = edgeCheckedIx + 1;
                    tfEdgeIntersect = test_edge_plane_intersect(p1, p2, plane);
                    if tfEdgeIntersect
                        usedRows(4*(faceNum-1)+edgeNum) = 1;
                        intPtNow = intersectEdgePlane([p1, p2], plane);
                        ixsFacesContainingPoint = find_face_ixs_from_edge(p1, ...
                            p2, verts, faces);
                        assert(numel(ixsFacesContainingPoint) == 2, ...
                            sprintf(['Current intersection point lies on ' ...
                                '%d faces. Expected result is 2.'], ...
                                numel(ixsFacesContainingPoint)));
                        intPtsAndNbrFaces(4*(faceNum-1)+edgeNum, :) = ...
                            [intPtNow(1), intPtNow(2), intPtNow(3), ...
                            ixsFacesContainingPoint];
                    end
                end
            end
        end
    end
    
    % Truncate coord vals.
    intPtsAndNbrFaces = truncate_matrix_values(intPtsAndNbrFaces,nSigFig);
    intPtsAndNbrFaces = unique(intPtsAndNbrFaces(logical(usedRows)',:), 'rows');
    % Separate intPts, nbrFaces.
    nbrFaces = intPtsAndNbrFaces(:, 4:5);
    intPts = intPtsAndNbrFaces(:, 1:3);
    % Check that no intersection points coincide with a vertex after values
    % are truncated.
    % In order to determine vertex, intPoint equality, the same truncation
    % operation has to be performed on both intPts AND verts.
    if ~any(ismember(intPts, truncate_matrix_values(verts,nSigFig), 'rows', 'R2012a'))
        % Pass intersection points matrix and connectivity matrix nbrFaces 
        % to buildSectionPolys to generate a cell of polygons.
        polyCell = buildSectionPolys(intPts,nbrFaces);
    else
        polyCell = {};
    end
end
end % main


% ----------------------------------------------------------------------- %
function polyCell = buildSectionPolys(intPts, nbrFaces)
% BUILDSECTIONPOLYS Constructs closed polygon(s) for a plane of section
% from a list of intersection points and their connectivity.
% 
% buildSectionPolys(intPts, nbrFaces) returns a cell of polygons.
% Polygons are generated from the vertices in intPts and their
% connectivity, contained in nbrFaces.
% 
% Inputs:
%   intPts      Nx3 matrix of cartesian points.
%   nbrFaces    Nx2 matrix. Row k contains the ixs of the two faces
%               that neighbor the point intPts(k,:).
% 
% Output:
%   polyCell    Cell array of polygons. Each cell in polyCell holds 
%               one polygon.

% Once the points of intersection are found for one "slice", these points 
% must be connected to draw the polygon(s) that represent cross-
% section(s). (Note: an "intersection point" is found by calculating the 
% intersection between an edge and the cutting plane.) Each face of the
% triangular mesh that intersects the plane must produce two intersection
% points (faces that intersect at one point or are coplanar with the
% cutting plane are discarded). Therefore, polygons may be constructed by
% joining intersection points that lie on the same face.

% Preallocate cell for multiple polygon output. Max no. polygons is 1/3 
% number of intersection points.
polyCell = cell(1, floor(size(intPts,1)/3));
isPtChecked = false(size(intPts,1), 1);

newPoly = true;
nPoly = 0;
loopCount = 0;
while ~all(isPtChecked)
    if newPoly
        intPtCount = 1;
        % Preallocate polyNowPts so it may hold all remaining int pts.
        polyNowPts = nan(sum(~isPtChecked), 3);
        % Get ix of the first unchecked point. Store this poly's 1st pt.
        ip_now_ix = find(~isPtChecked,1);
        polyNowFirstPtIx = ip_now_ix;
        % Temporarily mark start point as checked.
        isPtChecked(polyNowFirstPtIx) = true;
        % Count nPoly, the polygon count for this plane of section.
        nPoly = nPoly + 1;
        % An int pt belongs to 2 faces. We can select either as the 
        % "current face" since this choice is equivalent to choosing to 
        % traverse CW or CCW about the poly. Pick element 1.
        f_now = nbrFaces(ip_now_ix,1);
        newPoly = false;
    end
    
    % At 3rd step, set start point to unchecked so the polygon can close.
    % Start pt labeled checked at intPtCount==2 to prevent back-tracking.
    if intPtCount == 3
        isPtChecked(polyNowFirstPtIx) = false;
    end
    
    % Get (x,y,z) coords of this intersection point. Store in polyNowPts.
    intPtNow = intPts(ip_now_ix,:);
    polyNowPts(intPtCount,:) = intPtNow;
    isPtChecked(ip_now_ix) = true;
    
    % Get a matrix with dims equal to nbrFaces. 1s indicate locations
    % of current face in nbrFaces.
    fnow_in_ipnf = ismember(nbrFaces,f_now,'R2012a');
    % Identify ixs of rows in nbrFaces that contain f_now.
    sumrow_fnow_in_ipnf = sum(fnow_in_ipnf,2);
    ixs_fnow_in_ipnf = find(sumrow_fnow_in_ipnf);
    % Find the "other" row in nbrFaces that also contains f_now.
    ip_next_ix = ixs_fnow_in_ipnf(ixs_fnow_in_ipnf ~= ip_now_ix);
    
    nbr_faces_of_n_ip_next = nbrFaces(ip_next_ix,:);
    % Ix of next face, f_next, is the element in nbr_faces_of_n_ip_next 
    % that is not equal to f_now.
    f_next = nbr_faces_of_n_ip_next(nbr_faces_of_n_ip_next ~= f_now);
    
    % On to the next intersection point.
    f_now = f_next;
    ip_now_ix = ip_next_ix;
    intPtCount = intPtCount + 1;
    
    if ip_now_ix == polyNowFirstPtIx
        % Polygon is complete. Close, store it in output cell.
        polyNowPts(intPtCount,:) = intPts(polyNowFirstPtIx,:);
        % Remove any excess preallocated rows.
        polyNowPts = polyNowPts(1:intPtCount,:);
        % A polygon must have at least 3 unique vertices. If less than 3
        % are identified, do not output a polygon. < 3 vertices may be
        % present for very small polygons that have been reduced to 1 or 2 
        % points after values are rounded.
        if size(unique(polyNowPts,'rows') > 2)
            polyCell{nPoly} = polyNowPts;
        end
        % Mark start as checked. All pts on polygon have now been checked.
        isPtChecked(ip_now_ix) = true;
        newPoly = true;
    end
    
    if loopCount > size(intPts,1)
        error(  'myfuns:xsecmesh:loopRunaway'   ,   ...
                '[xsecmesh] Failed to ID next point in polygon.');
    end
    loopCount = loopCount + 1;
end

% Remove empty cells.
polyCell = polyCell(~cellfun(@isempty,polyCell));
end


% ----------------------------------------------------------------------- %
function dist = planePointDist(point,plane)
% Calculate the shortest distance between a point [x,y,z] and a plane 
% [xp,yp,zp,xv1,yv1,zv1,xv2,yv2,zv2].
% Distance is found by calculating the projection of w (a vector from a
% point on the plane to the query point) onto the plane's normal vector.
% Returns signed distance.
planeNormUV = cross(plane(4:6), plane(7:9)) ./ ...
    norm(cross(plane(4:6),plane(7:9)));
w = -[plane(1)-point(1), plane(2)-point(2), plane(3)-point(3)];
dist = dot(planeNormUV,w);
end

function faceIxs = find_face_ixs_from_edge(point1, point2, vertsMat, facesMat)
% Find the ixs of all mesh faces in facesMat that have an edge defined by the 
% points point1 and point2.
p1VertsRowIx = find_row_in_matrix(point1, vertsMat);
p2VertsRowIx = find_row_in_matrix(point2, vertsMat);
% Get matrices with dims equal to facesMat. If anentry in this mat equals 1, 
% then one of these points is located here.
tfP1InFacesMat = ismember(facesMat, p1VertsRowIx);
tfP2InFacesMat = ismember(facesMat, p2VertsRowIx);
tfP1P2InFacesMat = tfP1InFacesMat + tfP2InFacesMat;
faceIxs = find(sum(tfP1P2InFacesMat,2) == 2)';
end

% ----------------------------------------------------------------------- %
function tfIntersect = test_face_plane_intersect(vertsMat,facesMat,faceIx,myPlane)
pointPlaneDistanceMat = [
    planePointDist(vertsMat(facesMat(faceIx,1),:), myPlane), ...
    planePointDist(vertsMat(facesMat(faceIx,2),:), myPlane), ...
    planePointDist(vertsMat(facesMat(faceIx,3),:), myPlane)
    ];
pointPlaneDistanceMat = truncate_matrix_values(pointPlaneDistanceMat, 13);
vertDists_isPos = pointPlaneDistanceMat > 0;
vertDists_isNeg = pointPlaneDistanceMat < 0;
tfIntersect = sum(vertDists_isPos)>0 && sum(vertDists_isNeg)>0;
end

% ----------------------------------------------------------------------- %
function tfIntersect = test_edge_plane_intersect(p1, p2, myPlane)
% Use signed endpt-plane dist to identify edge/plane intersect.
% Return true if the line segment with endpoints p1 and p2 intersects the 
% plane myPlane. Returns false if the segment does not intersect or if the 
% line segment lies on the plane. myPlane has the form 
% [x0,y0,z0,vx1,vy1,vz1,vx2,vy2,vz2].
edgeEndPlaneDists = [planePointDist(p1,myPlane), planePointDist(p2,myPlane)];
isPosEdgeEndDists = edgeEndPlaneDists > 0;
isNegEdgeEndDists = edgeEndPlaneDists < 0;
tfIntersect = sum(isPosEdgeEndDists)>0 && sum(isNegEdgeEndDists)>0;
end

% ----------------------------------------------------------------------- %
function tfChecked = query_edge_intersect_checked(p1, p2, checkedEdgesMat)
% Edges generally belong to more than one face. When looking for face/plane 
% intersection, avoid repeated operations by comparing the current edge to a 
% list of previously checked edges.
% The inputs p1 and p2 are 1x3 vectors representing cartesian points. 
% checkedEdgesMat is a matrix of size Nx6. Each row is formed by horizontally 
% concatenating two points. Look for equivalent rows of the form [p1,p2] and 
% [p2,p1].
is_row_in_matrix = @(myRow) any(ismember(checkedEdgesMat, ...
    repmat(myRow, size(checkedEdgesMat,1), 1), 'rows'));
tfChecked = is_row_in_matrix([p1, p2]) || is_row_in_matrix([p2, p1]);
end

function rowIx = find_row_in_matrix(myRow, myMatrix)
rowIx = find(ismember(myMatrix, repmat(myRow,size(myMatrix,1),1), 'rows'));
assert(~isempty(rowIx), 'Searched for a matrix row that does not exist.');
end

function roundedMat = truncate_matrix_values(myMatrix, nSigFig)
% Truncate all numerical values in a matrix. Rounds all elements of 
% myMatrix to nSigFig significant digits.
roundedMat = arrayfun(@(val,nsf) round(val*10^(nsf-1))/10^(nsf-1), ...
    myMatrix, nSigFig.*ones(size(myMatrix)));
end
