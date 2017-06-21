function [vertsTrans, center] = trans2origin(verts, center)
% TRANS2ORIGIN Translate polygon so its centroid lies at the origin.
% 
% [verts , center] = trans2origin(verts,center) translates the polygon
% described by verts to the origin. Returns translated vertices matrix.
% 
% Inputs:
%   verts   Nx2 or Nx3 matrix of Cartesian points.
%   center  Centroid of the verts matrix.
% 
% Outputs:
%   vertsTrans  Vertices after translation.
%   center      Centroid after translation.
% 
% Author: B. Hannan
% Written with Matlab Student 2012a.
% Last updated 16 July 2014.

vertsTrans = verts - repmat(center,size(verts,1),1);
center = [0, 0, 0];