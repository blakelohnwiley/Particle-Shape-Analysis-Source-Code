function varargout = createTriangularPrism(x,y,z)

% This function creates an triangular prism. x and y are the width of the
% base, z is the height

x0 = 0; dx = x;
y0 = 0; dy = y;
z0 = 0; dz = z;

nodes = [ x0 y0 z0 ; x0 y0+(.5)*dy z0+dz ; x0 y0+dy z0 ; x0+dx y0 z0 ;...
    x0+dx y0+(.5)*dy z0+dz ; x0+dx y0+dy z0 ];

edges = [ 1 3 ; 1 2 ; 1 4 ; 2 3 ; 3 6 ; 2 5 ; 4 5 ; 5 6 ; 4 6 ];

faces = {[1  2 3], [1 4 5 2], [ 3 6 4 1], [ 2 5 6 3], [ 4 6 5]};

% format output
varargout = formatMeshOutput(nargout, nodes, edges, faces);