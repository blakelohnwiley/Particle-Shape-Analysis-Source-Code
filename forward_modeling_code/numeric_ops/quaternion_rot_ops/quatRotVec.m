function vecRot = quatRotVec(q,vec)
% vecRot = quatRotVec(q,vec) performs a quaternion rotation on the 1x3
% vector vec.
% Quaternions are expressed in Hamiltonian notation: x0 + x1(i) + x2(j) +
% x3(k).
% 
% Also see: quatcalc
% 
% Inputs
%   vec     Initial vector (size 1x3).
%   q       1x4 quaternion.
% 
% Output
%   vecRot  Rotated vector.
% 
% B. Hannan 2014

% quaternion scalar part
q0 = q(1);  
% quaternion vector part
qv = q(2:4);

% Perform quaternion rotation. See Stevens & Lewis, 2nd ed, eq 1.2-19.
vecRot = 2*qv*dot(qv,vec) + (q0*q0 - dot(qv,qv))*vec  - 2*q0*cross(qv,vec);


% % Alternative method. Less efficient than the method above.
% 
% % 4 matrices needed for quaternion matrix representation.
% qm1 = eye(4);
% qm2 = diag([1,0,-1], 1) + diag(-[1,0,-1], -1);
% qm3 = diag([1,1], 2) + diag(-[1,1], -2);
% qm4 = fliplr(diag([1, -1, 1, -1]));
% 
% % Get q, v matrix represetation. Scalar component (1) of v is zero.
% qMat  = q(1).*qm1 + q(2).*qm2 + q(3).*qm3 + q(4).*qm4;
% vqMat = vec(1).*qm2 + vec(2).*qm3 + vec(3).*qm4;
% 
% % Take Hamilton product v' = qvq^-1
% vMatRot = qMat*vqMat*inv(qMat);
% 
% % Get 3-space vec from rotated quaternion matrix.
% % Quaternion in vector notation is 1st row. Omit 0 component.
% vecRot = vMatRot(1, 2:4);


