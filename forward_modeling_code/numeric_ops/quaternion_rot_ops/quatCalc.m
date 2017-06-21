function q = quatCalc(vec1, vec2, varargin)
% q = quatCalc(vec1,vec2,varargin) calculates the quaternion for rotation 
% of vec2 onto vec1 about the axis  defined by cross(v,w).
% Quaternion returned in [qscalar, qi, qj, qk] form.
% 
% Inputs
%   vec1, vec2  1x3 row vector
%   rotSense    Optional input to determine rotational sense. If 'reverse',
%               verts are rotated by negative angle about rotation axis.
% Output
%     q         1x4 quaternion
% 
% B. Hannan 2014

numVarArgs = length(varargin);
if numVarArgs > 1
    error(  'myfuns:quatCalc:TooManyInputs'    ,   ...
            'this function takes at most 1 optional input');
end
if numVarArgs>0 && ~ischar(varargin{1})
    error(  'myfuns:rotateSolidAndPlot:vararginType'    ,   ...
            'varargin (rotSense) must be a string');
end
optArgs = {'forward'};
optArgs(1:numVarArgs) = varargin;
rotSense = optArgs{:};

% Get axis of rotation.
axRot = cross(vec1, vec2);
axRot = axRot./norm(axRot);
angRot = acos(dot(vec1,vec2)/(norm(vec1)*norm(vec2)));

if strcmp(rotSense,'reverse')
    angRot = -angRot;
end

% Calculate unit quaternion q in vector notation.
halfAng = angRot/2;
qSc  = cos(halfAng);
qVec = sin(halfAng)*axRot./norm(axRot);
q = [qSc, qVec];