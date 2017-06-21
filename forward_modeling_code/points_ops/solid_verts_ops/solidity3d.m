function soly = solidity3d(verts,faces)
% SOLIDITY3D Calculate the solidity of a 3D mesh.
% 
% Author: B. Hannan
% Written with Matlab R2012a.

% Find the 3D convex hull (minConvexHull cell output must be converted to 
% matrix). Conversion to triangular mesh is completed within meshVolume.
facesCH = cell2mat(minConvexHull(verts)');

% Solidity equals observed volume divided by convex hull volume.
soly = meshvol(verts,faces)/meshvol(verts,facesCH);