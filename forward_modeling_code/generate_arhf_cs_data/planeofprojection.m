function GeomStruct = planeofprojection(GeomStruct,minFraction,...
                                                        numSigFig,varargin)
% PLANEOFPROJECTION Generate AR, HF plane of projection data for a 3D
% solid.
% 
% inputs
%   GeomStruct      A data structure containing geometry for one solid and
%                   parameters for plane of projection calculations.
%   minFraction     Throw away polygons that have an area less than
%                   minFraction * [area of largest polygon].
% Optional input:
%   updateFraction  Used as an input for the sub-function printprogress. If
%                   updateFraction = 1/10, a message will be printed to the
%                   work space each time a multiple of 10% of the total of
%                   "slices" is processed. Default value is 1/5.
% 
% outputs
%   GeomStruct      Appended struct.
% 
%   The following fields are added to GeomStruct:
%   hf              Cell array of Heywood factor values.
%   ar              Cell array of aspect ratio values.
%   concavityCell   Cell array of concavity values.
%   solidityCell    Cell array of solidity values.
%   verts           A cell array. Each element contains coordiates of all
%                   the solid's vertices at a particular orientation.
%   projVerts       Cell array of the plane of projection composite 
%                   polygons.
%   nPolysRemoved   Polygons may be filtered by area in order to  
%                   neglect small polygons. nPolysRemoved is the number
%                   of polygons removed by this filter.
% 
% Also see: joinfaceprojections.m
% 
% Author: B. Hannan. Incorporates work done by Brian Hannan, Blake
% Lohn-Wiley, and Josh Knicely during summer 2013 & 2014 under the
% direction of Doug Rickman.
% Written during summer 2014 
% Written with MATLAB 2014a.
% Last updated on 30 December 2014.

numVarArgs = length(varargin);
if numVarArgs > 1
    error(  'myfuns:planeofprojection:tooManyInputs'    ,   ...
            'This function takes at most 1 optional input.');
end
optArgs = {1/5};
optArgs(1:numVarArgs) = varargin;
updateFraction = optArgs{:};

xs = GeomStruct.xs;
ys = GeomStruct.ys;
zs = GeomStruct.zs;
vertsNow = GeomStruct.verts;
faces = GeomStruct.faces;
isPix = GeomStruct.isPix;
pixMaxArea = GeomStruct.pixMaxArea;
minNumPix = GeomStruct.minNumPix;

% Preallocate outputs.
isProjPolygonInvalid = false(1,length(xs));
arCell = cell(1,length(xs));
hfCell = cell(1,length(xs));
concavityCell = cell(1,length(xs));
solidityCell = cell(1,length(xs));
areaValCell = cell(1,length(xs));
solidVertsCell = cell(1,length(xs));
projVertsCell = cell(1,length(xs));

% Initialize solid orientation vector v and maximum polygon area.
v = [0,0,1];
maxArea = 0;

tic; % Start the clock.
fprintf('\nBegin caclulating AR, HF, C, S.\n');

for nw = 1:numel(xs)
    
    % Rotate the mesh.
    if ~isequal(v, [xs(nw),ys(nw),zs(nw)])
        [vertsNow,v] = quatRotVerts(v,[xs(nw),ys(nw),zs(nw)], ...
                                                    vertsNow,'forward');
    end
    
    % Store the current solid vertices.
    solidVertsCell{nw} = vertsNow;
    
    % Union all 2D faces into the composite polygon(s).
    projPolyNow = joinfaceprojections(faces,vertsNow,numSigFig);
    
    % Check joinfaceprojectoins output. Store the result.
    isProjectionValid = checkpolygon(projPolyNow);
    isProjPolygonInvalid(nw) = ~isProjectionValid;
    
    % Store the current composite plane of projection polygon.
    projVertsCell{nw} = projPolyNow;
 
    if ~isPix % If isPix is false, proceed without pixelating the polygon.

        % Heywood and aspectRatio expect Nx3 input. Append col of zeros.
        projVertsNow3d = [projPolyNow, zeros(size(projPolyNow,1), 1)];
        [hfNow,areaNow] = heywood(projVertsNow3d);
        areaValCell{nw} = areaNow;

        % Check for maximum area.
        if areaNow > maxArea
            maxArea = areaNow;
        end

        % Calculate and store AR, HF, C, S.
        arCell{nw} = aspectRatio(projVertsNow3d);
        hfCell{nw} = hfNow;
        concavityCell{nw} = concavity(projVertsNow3d);
        solidityCell{nw}  = solidity(projVertsNow3d);

    else % Pixelate the polygon.
        
        maxVertsDist = maxVerticesDist(vertsNow);
        
        mask = polybitmask([projPolyNow(:,1),projPolyNow(:,2)], ...
                                                maxVertsDist, pixMaxArea);
                                            
        [xBinPoly,yBinPoly,hfNow,areaNow] = particles8(mask);
        
        % Append col of 0s for checkpolygon, aspectRatio, etc.
        binPoly3d = [xBinPoly',yBinPoly',zeros(size(xBinPoly'))];
        
        % If areaNow (and other particles8() outputs) are NaN, there were 
        % no "polygons" greater than 1 pixel.
        if ~isnan(areaNow) && checkpolygon(binPoly3d)
            
            arNow = aspectRatio(binPoly3d);
            concavityNow = concavity(binPoly3d);
            solidityNow = solidity(binPoly3d);

            % Check for maximum area.
            if areaNow > maxArea
                maxArea = areaNow;
            end

            % Store AR, HF, C, S, area values.
            arCell{nw} = arNow;
            hfCell{nw} = hfNow;
            concavityCell{nw} = concavityNow;
            solidityCell{nw} = solidityNow;
            areaValCell{nw} = areaNow;
            
        end

    end
    
    % Display calculation progress to workspace.
    printprogress(nw,numel(xs),updateFraction,toc);
    
end % xs

% Retain AR, HF, C and S cell arrays as they are before filtering by area.
% This allows the user to access ALL particle data if it is needed.
hfCellZeroDropped = hfCell;
arCellZeroDropped = arCell;
concavityCellZeroDropped = concavityCell;
solidityCellZeroDropped = solidityCell;

% Remove AR, HF, C, S cell entry if area < area threshold.
if ~isPix
    minKeepArea = minFraction*maxArea; 
else
    % If pixelated and minNumPix value has been specified, use this value
    % as the polygon area threshold.
    if minNumPix >= 0 
        minKeepArea = minNumPix;
    else
        minKeepArea = minFraction*maxArea;
    end
end
numPolygonsRemoved = 0;
for nw = 1:numel(xs)
    areaNow = areaValCell{nw};
    if areaNow < minKeepArea
        hfCell{nSect} = NaN;
        arCell{nSect} = NaN;
        concavityCell{nw} = NaN;
        solidityCell{nw} = NaN;
        numPolygonsRemoved = numPolygonsRemoved + 1;
    end
end

GeomStruct.runTime = toc;
GeomStruct.hf = hfCell;
GeomStruct.ar = arCell;
GeomStruct.convy = concavityCell;
GeomStruct.soly = solidityCell;
GeomStruct.hfZeroDropped = hfCellZeroDropped;
GeomStruct.arZeroDropped = arCellZeroDropped;
GeomStruct.concavityZeroDropped = concavityCellZeroDropped;
GeomStruct.solidityZeroDropped = solidityCellZeroDropped;
GeomStruct.solidVerts = solidVertsCell;
GeomStruct.prjVts = projVertsCell;
GeomStruct.isProjPolygonInvalid = isProjPolygonInvalid;
GeomStruct.nPolysRemoved = numPolygonsRemoved;

end % main


% ----------------------------------------------------------------------- %
% Notify user when multiple of percentStep*100% tot. calculation completes.
function printprogress(n,N,percentStep,time)
% Loop ranges from n=1...N.
% If percentStep=0.2, function prints progress when integer multiple of 20%
% calculation completes.

if ~mod(n,round(percentStep*N))
    percentComplete = (n/round(percentStep*N))*percentStep*100;
    fprintf('%0.0f\f%% complete. Elapsed time is %0.3E sec.\n',...
                                                    percentComplete,time);
elseif n==N
    fprintf('%0.0f\f%% complete. Elapsed time is %0.3E sec.\n',100,time);
end

end


% ----------------------------------------------------------------------- %
% Data quality check on polygon vertices before AR, HF, C, S calculations.
% Check for NaN entries.
% A "bad" polygon may be produced if polygon area is approximately zero, 
% if the mesh contains interior faces, if all intersection points are 
% collinear, or if the OFF file contains a line segment that protrudes 
% from the solid's surface.
function isPolyValid = checkpolygon(points)

isEnoughPts = size(unique(points,'rows'),1) > 2;
isNanPresent = any(isnan(points(:,1)));
area = polyarea(points(:,1),points(:,2));
isPolyValid = ~isNanPresent & isEnoughPts & area>0;

end