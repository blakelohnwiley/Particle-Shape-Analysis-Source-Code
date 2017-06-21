function varargout = createTrapezoidal(xl1,xl2,yl,zl)

% This function creates a trapezoidal prism as determined by the sizes of
% xl1, xl2, yl, and zl. xl1 is the width of the base and xls is the width
% of the topNote: if xl1=xl2, this is just a rectangular prism, and should
% all 3 equal, this should produce a cube.

x0 = 0; dx1= xl1; dx2 = xl2;
y0 = 0; dy= yl;
z0 = 0; dz= zl;

nodes = [ x0+.5*dx1 y0 z0 ; x0-.5*dx1 y0 z0 ; x0-.5*dx1 y0+dy z0 ; x0+.5*dx1 y0+dy z0 ; ...
    x0+.5*dx2 y0+dy z0+dz ; x0-.5*dx2 y0+dy z0+dz ; x0-.5*dx2 y0 z0+dz ; x0+.5*dx2 y0 z0+dz ];

edges = [1 2 ; 1 4 ; 1 8 ; 2 3 ; 2 7 ; 3 4 ; 3 6 ; 4 5; 5 6; 5 8 ; 6 7 ; 7 8 ];

faces = {[1 2 7 8], [ 3 6 5 4], [ 1 4 5 8], [ 2 3 4 1], [ 2 7 6 3], [ 7 8 5 6];};

% format output
varargout = formatMeshOutput(nargout, nodes, edges, faces);