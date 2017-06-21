function varargout = createHexagonPyramid()

% This function creates an hexagonal pyramid. Works.


x0 = 0; dx = 1;
y0 = 0; dy = 1;
z0 = 0; dz = 1;

nodes = [x0+(.5)*dx y0+(.5)*dy z0+dz ; x0+dx y0+(.5)*dy z0 ;...
    x0+(2/3)*dx y0+dy z0 ; x0+(1/3)*dx y0+dy z0 ; x0 y0+(.5)*dy z0 ;...
    x0+(1/3)*dx y0 z0 ; x0+(2/3)*dx y0 z0 ];

edges = [ 1 2 ; 1 3 ; 1 4 ; 1 5 ; 1 6 ; 1 7 ; 2 3 ; 3 4 ; 4 5 ; 5 6 ; 6 7 ; 7 2 ];

faces = { [ 2 3 4 5 6 7 ], [ 1 2 3 ], [ 1 3 4 ], [ 1 4 5 ], [ 1 5 6 ], [ 1 6 7 ], [ 1 7 2 ] }; 


% format output
varargout = formatMeshOutput(nargout, nodes, edges, faces);