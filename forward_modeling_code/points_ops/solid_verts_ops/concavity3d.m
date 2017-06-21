function conv3d = concavity3d(verts, faces)
% CONCAVITY3D Calculate the concavity of a 3D mesh.

% Find the 3D convex hull (minConvexHull cell output must be converted to 
% matrix). Convert to triangular mesh.
facesCH = triangulateFaces(cell2mat(minConvexHull(verts)'));

% Create 'triVerts' matrices. These mats have dims 3*[no. faces] X 3. Rows
% 1:3 contain the x,y,z coordinates of the first face, 2:6 the 2nd, etc.
triVertsCH = verts(reshape(facesCH',[],1), :);
triVertsObs = verts(reshape(faces',[],1), :);

% Convert to cells. Each cell contains 3 rows of the triVerts matrix.
trisCHCell = mat2cell(triVertsCH,   ...
            3*ones(1, size(triVertsCH, 1)/3), size(triVertsCH, 2));
trisObsCell = mat2cell(triVertsObs, ...
            3*ones(1, size(triVertsObs, 1)/3), size(triVertsObs, 2));

triArea =@(x) 0.5*norm(abs(cross(x(2,:) - x(1,:), x(3,:) - x(1,:))));

% Convexity is convex hull area divided by observed area.
conv3d = sum(cell2mat(cellfun(triArea,trisCHCell,'UniformOutput',0)))/...
    sum(cell2mat(cellfun(triArea, trisObsCell, 'UniformOutput', 0)));