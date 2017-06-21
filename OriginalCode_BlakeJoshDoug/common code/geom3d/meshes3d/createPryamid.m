function varargout = createPryamid(w,h)

% This function creates a pryamid as determined by the sizes of
% w(width of the base) and h(height of the pyramid).  

w0 = 0; dw = w;
h0 = 0; dh = h;

nodes = [ w0 w0 h0 ; w0 w0+dw h0 ; w0+dw w0+dw h0 ; w0+dw w0 h0 ; w0+.5*dw w0+.5*dw h0+dh ];

edges = [ 1 2 ; 1 4 ; 1 5 ; 2 3 ; 2 5 ; 3 4 ; 3 5 ; 4 5 ];

faces = { [ 1 2 3 4 ], [ 5 4 3 ], [ 5 3 2 ] , [ 5 2 1 ], [ 5 1 4 ] };

% format output
varargout = formatMeshOutput(nargout, nodes, edges, faces);