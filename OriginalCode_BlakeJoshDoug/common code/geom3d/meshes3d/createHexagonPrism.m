function varargout = createHexagonPrism()

% This function creates an hexagonal prism. 



x0 = 0; dx = 1;
y0 = 0; dy = 1;
z0 = 0; dz = 1;

nodes = [ x0 y0+(.5)*dy z0+dz ; x0 y0+dy z0+(2/3)*dz ; x0 y0+dy z0+(1/3)*dz ;...
    x0 y0+(.5)*dy z0 ; x0 y0 z0+(1/3)*dz ; x0 y0 z0+(2/3)*dz ;...
    x0+dx y0+(1/2)*dy z0+dz ; x0+dx y0+dy z0+(2/3)*dz ;...
    x0+dx y0+dy z0+(1/3)*dz ; x0+dx y0+(.5)*dy z0 ; x0+dx y0 z0+(1/3)*dz ;...
    x0+dx y0 z0+(2/3)*dz ];

edges = [ 1 2 ; 2 3 ; 3 4 ; 4 5 ; 5 6 ; 6 1 ; 7 8 ; 8 9 ; 9 10 ; 10 11 ;...
    11 12 ; 12 7 ; 1 7 ; 2 8 ; 3 9 ; 4 10 ; 5 11 ; 6 12 ];

faces = { [ 1 2 3 4 5 6 ], [ 7 8 9 10 11 12 ], [ 1 2 8 7 ], [ 2 3 9 8 ],...
    [ 3 4 10 9 ], [ 4 5 11 10 ], [ 5 6 12 11 ], [ 6 1 7 12 ] };



% format output
varargout = formatMeshOutput(nargout, nodes, edges, faces);