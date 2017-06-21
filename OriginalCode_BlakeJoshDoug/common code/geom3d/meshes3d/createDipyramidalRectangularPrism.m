function varargout = createDipyramidalRectangularPrism(xl1,xl2)

% xl1 is the height of the pyramid, and xl2 is the length of the prism body

x0 = 0; dx1 = xl1; dx2 = xl2; 
y0 = 0; dy = 1;
z0 = 0; dz = 1;

nodes = [ x0 y0+(.5)*dy z0+(.5)*dz ; x0+dx1 y0 z0+dz ; x0+dx1 y0+dy z0+dz ;...
    x0+dx1 y0 z0 ; x0+dx1 y0+dy z0 ; x0+2*dx1+dx2 y0+(.5)*dy z0+(.5)*dz ;...
    x0+dx1+dx2 y0 z0+dz ; x0+dx1+dx2 y0+dy z0+dz ; x0+dx1+dx2 y0 z0 ; x0+dx1+dx2 y0+dy z0 ];

edges = [ 1 2 ; 1 3 ; 1 4 ; 1 5 ; 2 3 ; 3 5 ; 5 4 ; 4 2 ; 3 8 ; 5 10 ; 4 9 ;...
    2 7 ; 7 8 ; 8 10 ; 10 9 ; 9 7 ; 6 7 ; 6 8 ; 6 9 ; 6 10 ];

faces = { [1 2 3], [1 3 5], [1 5 4], [ 1 4 2 ], [2 7 8 3], [ 3 8 10 5], [5 10 9 4],...
    [ 4 9 7 2], [ 9 6 7], [ 7 6 8], [8 6 10], [10 6 9]};

% format output
varargout = formatMeshOutput(nargout, nodes, edges, faces);  