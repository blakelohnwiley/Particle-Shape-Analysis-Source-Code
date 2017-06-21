function varargout = createClippedOctahedron(xl,yl,zl)

% This function creates a clipped (truncated) octahedron as determined by
% the sizes of xl, yl, and zl. xl, yl, and zl represent the max values
% possible in those dimensions.

x0 = 0; dx= xl;
y0 = 0; dy= yl;
z0 = 0; dz= zl;

nodes = [ x0 y0 z0 ; x0+(1/3)*dx y0+(2/10)*dy z0-(1/2)*dz ; ...
    x0+(2/3)*dx y0+(2/10)*dy z0-(1/2)*dz ; x0+dx y0 z0 ; x0+(2/3)*dx y0+(2/10)*dy z0+(1/2)*dz ; ...
    x0+(1/3)*dx y0+(2/10)*dy z0+(1/2)*dz ; x0 y0+dy z0 ; x0+(1/3)*dx y0+(8/10)*dy z0-(1/2)*dz ; ...
    x0+(2/3)*dx y0+(8/10)*dy z0-(1/2)*dz ; x0+dx y0+dy z0 ; x0+(2/3)*dx y0+(8/10)*dy z0+(1/2)*dz ; ...
    x0+(1/3)*dx y0+(8/10)*dy z0+(1/2)*dz ];

edges = [ 1 2 ; 1 6 ; 1 7 ; 2 3 ; 2 8 ; 3 4 ; 3 9 ; 4 5 ; 4 10 ; 5 6 ; 5 11 ; 6 12 ; 7 8 ; 7 12 ; 8 9 ; 9 10 ; 10 11 ; 11 12 ];

faces = {[1 2 3 4], [1 4 5 6], [1 6 12 7], [ 1 7 8 2], [2 8 9 3], [3 9 10 4], [4 10 11 5], [5 11 12 6], [ 7 12 11 10], [ 7 10 9 8]};

% format output
varargout = formatMeshOutput(nargout, nodes, edges, faces);  