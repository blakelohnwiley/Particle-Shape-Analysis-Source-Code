function roundedMat = matroundsf(mat,nSig)
% MATROUNDSF Truncate all numerical values in a matrix.
% 
% roundMat = matroundsf(mat,nSig) rounds all elements of the matrix mat to 
% nSig significant figures.
% 
% Author: B. Hannan
% Written with MATLAB Student 2012a.
% Updated 22 July 2014

roundedMat = arrayfun(@roundsf, mat, nSig.*ones(size(mat)));

end

% ----------------------------------------------------------------------- %
function roundedNum = roundsf(number,nSig)
% Round number to nSig significant figures.
roundedNum = round(number*10^(nSig-1))/10^(nSig-1);
end