function volume = meshvol(v,f)
    % MESHVOL Calculate volume enclosed by a triangulated surface. The surface
    % may be concave and may contain holes.
    % 
    % volume = meshvol(verts,faces) returns the volume enclosed by a triangle 
    % mesh. verts is a [no. vertices] X 3 matrix containing the Cartesian
    % coordinates of all mesh vertices. faces is a [no. triangular faces] X 3
    % matrix that points to the vertices that form each triangular face.
    % 
    % This function uses Sven Holcombe's inpolyhedron.m. It can be found at 
    % blogs.mathworks.com/pick/2013/09/06/inpolyhedron/.
    % 
    % Also see: rotate2xy.m, quatRotVerts.m, quatRotVec.m, quatCalc.m,
    % polynormal.m
    % 
    % B. Hannan

    % The divergence theorem states that the volume integral of the divergence
    % of a vector field F equals the flux of F across the volume boundary. 
    % Therefore, when F has unit divergince, the flux of F across a boundary 
    % provides the magnitude of the volume that it encloses. 
    % 
    % Provided that you are given a mesh AND outward-pointing normal vectors
    % for each face, this is a very simple calculation. However, if you are
    % starting with the verts and faces matrices only, the normals must be
    % identified in order to distinguish between the outer and inner sides of
    % each face. This is accomplished by calculating each face normal,
    % defining a point a small, perpendicular distance from the face centroid,
    % and then checking whether the point is inside or outside of the mesh.
    % Inward-pointing normals are flipped.
    % 
    % This method is an approximation in that flux is approximated by
    % calculating the flux through the triangle centroid. Uncertainty increases
    % as triangle area increases with respect to total mesh surface area.

    % Distance traveled to either side of a face to identify in/out direction.
    DELTA = 1E-4;
    % If face area is below this value, the vertices are considered collinear.
    ZERO_AREA_TOL = 1E-9;
    % If face area is above SMALL_AREA_THRESH*[total mesh surface area], the 
    % face will be broken into smaller triangles to improve integral approx.
    SMALL_AREA_THRESH = 0.05;

    % Remove very small faces formed by 3 ~collinear points.
    triCell = mat2cell(v(reshape(f',numel(f),1), :), 3*ones(1,numel(f)/3), 3);
    triArea = @(M) 0.5*norm(cross(M(2,:)-M(1,:), M(3,:)-M(1,:)));
    triAreaMat = cell2mat(cellfun(triArea, triCell, 'UniformOutput', 0));
    f = f(triAreaMat > ZERO_AREA_TOL, :);
    
    % Calculate triangle centroids.
    % Each entry of triCell, a column cell array, is a 3x3 matrix containing
    % the Cartesian coordinates of the 3 vertices that define a face. 
    % triCell{k} is equal to v(f(k,:).
    triCell = mat2cell(v(reshape(f',numel(f),1), :), 3*ones(1,numel(f)/3), 3);
    % triCent is an anonymous function used to calculate triangle centriod.
    triCent =@(M) [mean(M(:,1)), mean(M(:,2)), mean(M(:,3))];
    % Each row of triCentMat contains Cartesian coords of the face centroid.
    triCentMat = cell2mat(cellfun(triCent, triCell, 'UniformOutput', 0));

    % Identify "outward" direction for each face.
    % This anonymous function calculates a normal unit vector for each face. 
    % These vectors are not necessarily outward-facing.
    normCalc = @(M) cross(M(2,:)-M(1,:), M(3,:)-M(1,:))./...
                        norm(cross(M(2,:)-M(1,:), M(3,:)-M(1,:)));
    % Row k of normMat is a unit vector perpendicular to face k.
    normMat = cell2mat(cellfun(normCalc, triCell, 'UniformOutput', 0));
    % Add a vector DELTA*normal from each face centroid.
    testPointsMat = triCentMat + DELTA.*normMat;
    % Are the points at the end of these vectors are inside the mesh?
    tfFlip = inpolyhedron(f,v,testPointsMat);
    % If normal points in, swap points 2 and 3 so that the normal vector, 
    % calculated according to normCalc, produces an outward-pointing normal.
    swapVerts =@(M,tf) ~tf*M + tf*[M(1,:); M(3,:); M(2,:)];
    triCell = cellfun(swapVerts,triCell,num2cell(tfFlip),'UniformOutput',0);
    % If any normals point inward, re-calculate normMat.
    if any(tfFlip)
        normMat = cell2mat(cellfun(normCalc, triCell, 'UniformOutput', 0));
    end

    triAreaMat = triAreaMat(triAreaMat>ZERO_AREA_TOL,:);
    areaTot = sum(triAreaMat);
    fluxMat = zeros(size(triAreaMat));

    % Calculate the flux through each face. If face area is sufficiently small 
    % or if the face normal is equal to +/-x, +/-y, or +/-z (in which case the
    % flux is exact), immediately calculate flux. Otherwise, break up the face
    % into smaller triangles before calculating flux.
    for nTri = 1:numel(triAreaMat)
        if triAreaMat(nTri) <= SMALL_AREA_THRESH*areaTot || ...
                                            any(abs(normMat(nTri,:))==1)
            fluxMat(nTri) = triAreaMat(nTri)*triCentMat(nTri,3)*normMat(nTri,3);
        else
            % Triangle area is too large for this approximation. Break it up
            % into smaller triangles.
            fluxMat(nTri) = largetriflux(triCell{nTri});
        end
    end
    volume = sum(abs(fluxMat));
end % main


function flux = largetriflux(P)
    % Break up a triangle defined by the 3x3 matrix of Cartesian points P
    % before calculating the net flux of the vector field F through the
    % triangular area. F = {0,0,z} is rotated with P as P is rotated to the XY
    % plane.

    % Rotate tri to XY. Capture quaternion for rotation of the vector field.
    [pointsXY, q] = rotate2xy(P);
    % Place 9 points along each triangle edge. Calculate triangle centroid.
    numPts = 10;
    scale = linspace(0,0.9,numPts)';
    fTriPoints = [ 
        repmat(pointsXY(1,:),numPts,1) + scale*(pointsXY(2,:)-pointsXY(1,:));
        repmat(pointsXY(1,:),numPts,1) + scale*(pointsXY(3,:)-pointsXY(1,:));
        repmat(pointsXY(2,:),numPts,1) + scale*(pointsXY(3,:)-pointsXY(2,:));
        mean(pointsXY)
    ];
    % Remove duplicate points before triangulating.
    fTriPoints = unique(fTriPoints,'rows');
    % Triangulate the points.
    tri = delaunay(fTriPoints(:,1:2));
    % Put each tri's verts into a single cell element. Num. cells = num. tris.
    fTriCell = mat2cell(fTriPoints(reshape(tri',numel(tri),1), :), ...
                                                3*ones(1,numel(tri)/3), 3);
    % Re-define the anonymous function created above.
    triArea = @(M) 0.5*norm(cross(M(2,:)-M(1,:), M(3,:)-M(1,:)));
    fTriAreaMat = cell2mat(cellfun(triArea, fTriCell, 'UniformOutput', 0));
    % Rotate the vector field and calculate flux across each z-normal triangle.
    flux = sum(abs(fTriAreaMat .* dot(quatRotVec(q,[0,0,1]), [0,0,1])));
end