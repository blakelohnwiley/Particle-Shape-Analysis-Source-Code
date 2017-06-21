function varargout = createDipyramidalTrigonalPrism(xl1,xl2)

% xl1 is the height of the pyramid, and xl2 is the length of the prism body

x0 = 0; dx1 = xl1; dx2 = xl2;
y0 = 0; dy = 1;
z0 = 0; dz = 1;

nodes = [ x0 y0+(.5)*dy z0+(.5)*dz ; x0+dx1 y0+(.5)*dy z0+dz ; ...
    x0+dx1 y0 z0 ; x0+dx1 y0+dy z0 ; x0+2*dx1+dx2 y0+(.5)*dy z0+(.5)*dz ;...
    x0+dx1+dx2 y0+(.5)*dy z0+dz ; x0+dx1+dx2 y0 z0 ; x0+dx1+dx2 y0+dy z0 ];

edges = [ 1 2 ; 1 3 ; 1 4 ; 2 4 ; 4 3 ; 3 2 ; 2 6 ; 4 8 ; 3 7 ; 6 8 ; 8 7 ; 7 6 ; 5 6 ; 5 8 ; 5 7 ];

faces = {[1 2 4], [ 1 4 3], [1 3 2], [ 2 6 8 4], [ 4 8 7 3], [ 3 7 6 2], [ 5 6 7], [ 5 8 6], [5 7 8]};

% format output
varargout = formatMeshOutput(nargout, nodes, edges, faces);  