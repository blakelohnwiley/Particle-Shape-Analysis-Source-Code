function varargout = createPentagonPrism()

% This function creates an pentagonal prism. 

x0 = 0; dx = 1;
y0 = 0; dy = 1;
z0 = 0; dz = 1;

nodes = [ x0 y0+(.5)*dy z0+dz ; x0 y0+dy z0+(.5)*dz ; x0 y0+(.75)*dy z0 ;...
    x0 y0+(.25)*dy z0 ; x0 y0 z0+(.5)*dz ; x0+dx y0+(.5)*dy z0+dz ;...
    x0+dx y0+dy z0+(.5)*dz ; x0+dx y0+(.75)*dy z0 ; x0+dx y0+(.25)*dy z0 ;...
    x0+dx y0 z0+(.5)*dz ];

edges = [ 1 2 ; 2 3 ; 3 4 ; 4 5 ; 5 1 ; 1 6 ; 2 7 ; 3 8 ; 4 9 ; 5 10 ; 6 7 ; 7 8 ; 8 9 ; 9 10 ; 10 6 ];

faces = { [ 1 2 3 4 5 ], [ 6 7 8 9 10 ], [ 1 2 7 6 ], [ 2 3 8 7 ], [ 3 4 9 8 ], [ 4 5 10 9 ], [ 1 5 10 6 ] };

% format output
varargout = formatMeshOutput(nargout, nodes, edges, faces);