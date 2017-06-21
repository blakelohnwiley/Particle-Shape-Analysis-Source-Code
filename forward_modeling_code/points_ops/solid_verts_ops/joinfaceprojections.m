function projPoly = joinfaceprojections(faces,verts,varargin)
% JOINFACEPROJECTIONS Perform unions on a group of 2D triangular faces to
% form one composite polygon.
% JOINFACEPROJECTIONS(faces,verts) returns the vertices of the union of
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
% This function uses Emmit's Polygon Clipping and Offsetting tool which is 
% based on the work of Sebastian Hölz. It is a wrapper for Angus Johnson's 
% Clipper library (www.angusj.com/delphi/clipper.php).
% 
% Authors: D. Rickman, B. Hannan, J. Knicely
% Written with MATLAB R2014a.
% Last updated on 27 November 2014.

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
optArgs = {6};
optArgs(1:numVarArgs) = varargin;
nSigFig = optArgs{:};

% Define constants.
VERTS_SCALE_FACTOR  = 1e7;  % Multiplicative vertices scale value.

% Remove z-coordinates from verts to project the points onto the XY plane.
verts = verts(:,1:2);

assignin('base','f_b4',faces);
assignin('base','v',verts);

% Remove any projected face with 3 collinear points.
[faces,isTriLine] = removeCollinearTriangles(verts,faces);

assignin('base','f_af',faces);
assignin('base','isTriLine',isTriLine);

% Scale vertices and convert to 64-bit integer.
verts = int64(VERTS_SCALE_FACTOR * verts);

% Union all triangles to create a composite plane of projection polygon.
triangleVerts = verts(faces(1,:),:); % Select an arbitrary 1st triangle.
Composite.x = triangleVerts(:,1);
Composite.y = triangleVerts(:,2);
for numTri = 1:size(faces,1)
    triangleVerts = verts(faces(numTri,:),:);
    
    assignin('base','triangleVerts',triangleVerts);
    
    xTri = triangleVerts(:,1);
    yTri = triangleVerts(:,2);
    
    assignin('base','xTri',xTri); assignin('base','yTri',yTri);
    
    Triangle.x = xTri;
    Triangle.y = yTri;
    Composite = unionPolygons(Composite,Triangle);
end

% Ignore holes. If >1 polygons in projPolyCellNow, 1+ holes must be 
% present. Keep only the primary polygon, which must be the largest.
% I have assumed that the largest polygon contains all other polygons. This
% assumption is valid if the mesh is a single, manifold mesh.
if length(Composite) > 1
    
    areaArray = NaN(1,length(Composite));
    for nPoly = 1:length(Composite)
        areaArray(nPoly) = polyarea(Composite(nPoly).x,Composite(nPoly).y);
    end
    
    maxAreaLogical = areaArray == max(areaArray);
    
    % Since we process only one mesh at a time, we expect only one "main"
    % plane of projection composite polygon, which is identified as the
    % polygon with greatest area when >1 polygons exist in the projection
    % (all others are presumed to be holes). If >1 polygons have equal,
    % maximum area, an error has occurred. The error is due to a bad mesh
    % or to an error in the polygon union process.
    if sum(maxAreaLogical) > 1
        error(  'myfuns:joinfaceprojections:meshError',   ...
                ['>1 plane of projection polygons were detected.\n',...
                'Only 1 polygon is expected in plane of projection']);
    end
    
    Composite = Composite(maxAreaLogical);
    
end

% Get x, y coordinates arrays from the Composite struct.
xComp = Composite.x;
yComp = Composite.y;

% Scale the polygon down to its original size.
projPoly = (1/VERTS_SCALE_FACTOR) .* double([xComp,yComp]);

% Close the plane of projection polygon.
if ~isequal(projPoly(end,:),projPoly(1,:))
    projPoly = [projPoly; projPoly(1,:)];
end

% Truncte Cartesian coordinate values to nSigFig significant digits.
projPoly = matroundsf(projPoly,nSigFig);

end


% ----------------------------------------------------------------------- %
% Union two polygons. The first polygon, ClipperStruct, must be a struct
% (clipper requires polygons provided as structs. See clipper.m for more
% info). The second polygon is provided as x2, y2. Each is a column array
% of coordinates. x2 and y2 are then stored in a struct so that clipper can
% union the two polygons.
% Output is converted to int.
function ClipperOut = unionPolygons(Polygon1,Polygon2)

UNION_IDENTIFIER = 3;

ClipperOut = clipper(Polygon1,Polygon2,UNION_IDENTIFIER);

for k=1:length(ClipperOut);
    ClipperOut(k).x = int64(ClipperOut(k).x);
    ClipperOut(k).y = int64(ClipperOut(k).y);
end

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

% Get (x,y,z) vectors from p0->pA and p0->pB. Append a z-component of 0.
v0A = [pA-p0,0];
v0B = [pB-p0,0];

% Get norm of each vector. Check length to ensure points are not ~equal.
norm_v0A = norm(v0A);
norm_v0B = norm(v0B);

% Calculate the two unit vectors.
uvA = v0A/norm_v0A;
uvB = v0B/norm_v0B;

if any(isnan(uvA)) || any(isnan(uvB)) % NaN indicates identical points.
    isCollinear = true;
elseif norm_v0A < COLLINEAR_TOL || norm_v0B < COLLINEAR_TOL
    isCollinear = true; % Check whether 2 points are nearly identical.
else
    isCollinear = norm(cross(uvA,uvB)) < COLLINEAR_TOL;
end

end