function [pointsRot, vsolRot, q] = quatRotVerts(wSph,vSol,points,varargin)
% quatRotVerts(vsol,wsph,points,varargin) rotates solid normal (vsol) to 
% sphere point (wsph). Perform an identical rotation to all solid vertices.
% 
% Inputs:
%   vSol        Initial solid orientation vector.
%   wSph        The sphere point to which vsol is rotated.
%   points      Nx3 matrix of points to be rotated about origin.
%   rotSense    Optional input. If 'reverse', verts are rotated through
%               a negative angle about the rotation axis.
% 
% Outputs:
%   pointsRot   Rotated points matrix.
%   vsolRot     The new solid orientation vector.
%   q           Quaternion used for rotation.
% 
% B. Hannan 2014

numVarArgs = length(varargin);
if numVarArgs > 1
    error(  'myfuns:quatRotVerts:TooManyInputs'    ,   ...
            'this function takes at most 1 optional input');
end
optArgs = {'forward'};
optArgs(1:numVarArgs) = varargin;
rotSense = optArgs{:};

if isnumeric(points)
    points = num2cell(points,2);
end

q = quatCalc(wSph, vSol, rotSense);
vsolRot = quatRotVec(q,wSph);
qCell = num2cell(repmat(q,size(points,1),1),2);
pointsRot = cell2mat(...
                cellfun(@quatRotVec,qCell,points,'UniformOutput',false));