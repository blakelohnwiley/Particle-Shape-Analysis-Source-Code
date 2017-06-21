function GeomStruct = planeofsection(GeomStruct,minFraction,nSigFig,varargin)
% PLANEOFSECTION Calculates plane of section data for one solid
% 
% planeofsection(GeomStruct) Calculates aspect ratio and Heywood factor 
% data from the parameters contained in the data strcutre, GeomStruct.
% 
% Inputs:
%   GeomStruct      A data structure containing mesh geometry for one  
%                   solid and parameters for projection or section 
%                   calculations.
%   minFraction     Throw away polygons that have an area less than
%                   minFraction * [area of largest polygon].
%   nSigFig         Truncate coordinate values to nSigFig digits.
% 
% Optional input:
%   updateFraction  Used as an input for the sub-function printprogress. If
%                   updateFraction = 1/10, a message will be printed to the
%                   work space each time a multiple of 10% of the total of
%                   "slices" is processed. Default value is 1/5.
% 
% outputs
%   GeomStruct      Appended data structure.
% 
%   The following fields are added to GeomStruct:
%       hf              Row vector containing Heywood factor vales.
%       ar              Row vector containing aspect ratio vales.
%       concavityCell   Cell array of concavity values.
%       solidityCell    Cell array of solidity values.
%       intPointsCell   Cell array of plane of section polygon vertices.
%       tfInt           Row vector, true if plane intersects solid at this 
%                       plane radius and normal.
%       cVals           Row vector of cutting plane radii.
%       planeCell       Stores cutting plane for each section.
%       nPolysRemoved   Polygons may be filtered by area in order to  
%                       neglect small polygons. nPolysRemoved is the number
%                       of polygons removed by this filter.
%
% The variable minFraction is set in off2pds.m. Its default value is
% minFraction = 0.05.
% 
% Author: B. Hannan. Incorporates work done by Brian Hannan, Blake
% Lohn-Wiley, and Josh Knicely during summer 2013 & 2014 under the
% direction of Doug Rickman.
% Written with MATLAB 2012a.
% Updated 30 December 2014.

numVarArgs = length(varargin);
if numVarArgs > 1
    error(  'myfuns:planeofsection:TooManyInputs'    ,   ...
            'This function takes at most 1 optional input.');
end
optArgs = {0.2};
optArgs(1:numVarArgs) = varargin;
updateFraction = optArgs{:};

% Get data from the struct.
xs = GeomStruct.xs;
ys = GeomStruct.ys;
zs = GeomStruct.zs;
verts = GeomStruct.verts;
faces = GeomStruct.faces;
cSteps = GeomStruct.cSteps;
isPix = GeomStruct.isPix;
pixMaxArea = GeomStruct.pixMaxArea;
minNumPix = GeomStruct.minNumPix;

% cVals holds "slice" radius values at which sections will be taken along
% each normal (vector from origin to point on sphere).
maxVertsDist = maxVerticesDist(verts);
radMax = maxVertsDist/2;
sliceSpacing = radMax/cSteps; 
cVals = 0:sliceSpacing:radMax;

% Preallocate outputs.
arCell = cell(1, cSteps*length(xs));
hfCell = cell(1, cSteps*length(xs));
concavityCell = cell(1, cSteps*length(xs));
solidityCell = cell(1, cSteps*length(xs));
planeCell = cell(1, length(xs)*length(cVals));
% voidAreaCell = cell(1, length(xs)*length(cVals));
% tfInt stores whether intersection occurs at this plane/mesh orientation.
tfInt = false(1, length(xs)*length(cVals));
intPointsCell = cell(1, length(xs)*length(cVals));
% isPlSecInvalid array stores results of polygon check, checkpolygon.
isPlSecInvalid = false(1, length(xs)*length(cVals));
% areaValCell stores area magnitude for each plane of section. It is used  
% below to discard small polygons.
areaValCell = cell(1, cSteps*length(xs));

tic; % Start the clock.

fprintf('\nBegin caclulating planes of section.\n');

% Get plane of section at each plane orientation.
for nw = 1:numel(xs)
    
    normNow = [xs(nw), ys(nw), zs(nw)];
    
    for cIx = 1:length(cVals)
        
        planeNow = createPlane(cVals(cIx).*normNow, normNow);
        planeCell{(nw-1)*length(cVals)+cIx} = planeNow;
        intPointsNowCell = xsecmesh(planeNow,verts,faces,nSigFig);
        % tfInt is false if no intersection exists here.
        tfInt((nw-1)*length(cVals)+cIx) = ~isempty(intPointsNowCell);
        intPointsCell{(nw-1)*length(cVals)+cIx} = intPointsNowCell;
        
    end
    
    % Print calculation progress to the workspace.
    printprogress(nw, numel(xs), updateFraction, toc);
    
end

% Loop over intPoints. Calculate HF, AR, C, S at every intersection.
fprintf('\nBegin caclulating AR, HF, C, S.\n');

maxArea = 0;

for nSect = 1:numel(intPointsCell)
    
    if tfInt(nSect)
        
        intPointsCellNow = intPointsCell{nSect};
        
        if numel(intPointsCellNow) > 1
            % If >1 polygons in planeSecNow, holes may be present.
            % Keep only the primary polygons. Ignore void space.
            [intPointsCellNow,~] = locateHoles(intPointsCellNow, ...
                                                        planeCell{nSect});
        end
        
        numSectionsNow = length(intPointsCellNow);
        arMatAtSecNow = NaN(1,numSectionsNow);
        hfMatAtSecNow = NaN(1,numSectionsNow);
        solidityMatAtSecNow = NaN(1,numSectionsNow);
        concavityMatAtSecNow = NaN(1,numSectionsNow);
        areaValsMatNow = NaN(1,numSectionsNow);
        
        % Loop over all planes of section.
        for nPlSecNow = 1:numSectionsNow
            
            planeSecNow = intPointsCellNow{nPlSecNow};
            
            if checkpolygon(planeSecNow)
                
                % Calculate AR, HF, C, S.
                if ~isPix
                    
                    % Calculate AR, HF, C, S.
                    [hfNow, areaNow] = heywood(planeSecNow);
                    arNow = aspectRatio(planeSecNow);
                    concavityNow = concavity(planeSecNow);
                    solidityNow = solidity(planeSecNow);
                    % Add this plane of section's AR, HF, C, S values
                    % to the following matrices. After all polygons in
                    % this plane of section have been processed, these
                    % matrices will be put into the data output cell
                    % arrays.
                    arMatAtSecNow(nPlSecNow) = arNow;
                    hfMatAtSecNow(nPlSecNow) = hfNow;
                    concavityMatAtSecNow(nPlSecNow) = concavityNow;
                    solidityMatAtSecNow(nPlSecNow) = solidityNow;
                    areaValsMatNow(nPlSecNow) = areaNow;
                        
                else
                    
                    % Pixelate polygons before calculating AR, HF.
                    mask = polybitmask( ...
                                [planeSecNow(:,1), planeSecNow(:,2)], ...
                                maxVertsDist, pixMaxArea);
                    
                    [xBinPoly,yBinPoly,hfNow,areaNow] = particles8(mask);
                    % Append col of 0s for checkpolygon, aspectRatio, etc.
                    binPoly3d = [xBinPoly',yBinPoly',zeros(size(xBinPoly'))];
                    
                    % If areaNow (and other particles8() outputs) are NaN,
                    % there were no polygons with >1 pixels.
                    if ~isnan(areaNow) && checkpolygon(binPoly3d)
                        
                        arNow = aspectRatio(binPoly3d);
                        concavityNow = concavity(binPoly3d);
                        solidityNow = solidity(binPoly3d);
                                        
                        % Check for maximum area.
                        if areaNow > maxArea
                            maxArea = areaNow;
                        end
                        
                        % Store AR, HF, C, S, area values.
                        arMatAtSecNow(nPlSecNow) = arNow;
                        hfMatAtSecNow(nPlSecNow) = hfNow;
                        concavityMatAtSecNow(nPlSecNow) = concavityNow;
                        solidityMatAtSecNow(nPlSecNow) = solidityNow;
                        areaValsMatNow(nPlSecNow) = areaNow;
                        
                    else
                        
                        tfInt(nSect-1 + nPlSecNow) = false;
                        areaNow = 0;
                        
                    end
                    
                end % if ispix
                
                if areaNow > maxArea
                    maxArea = areaNow;
                end
                
            else
                
                % If polygon is invalid, set intersection to false.
                tfInt(nSect-1 + nPlSecNow) = false;
                % Flag the invalid polygon.
                isPlSecInvalid(nSect-1 + nPlSecNow) = true;
                
            end
            
        end % for plSecNow = ...
        
        arCell{nSect} = arMatAtSecNow;
        hfCell{nSect} = hfMatAtSecNow;
        concavityCell{nSect} = concavityMatAtSecNow;
        solidityCell{nSect} = solidityMatAtSecNow;
        areaValCell{nSect} = areaValsMatNow;
        
    end % if tfint(nSect)
    
    % Print calculation progress to the workspace.
    printprogress(nSect, numel(intPointsCell), updateFraction, toc)
    
end % for nSect = ...

% Retain AR, HF, C and S cell arrays as they are before filtering by area.
% This allows the user to access ALL particle data if it is needed.
hfCellZeroDropped = hfCell;
arCellZeroDropped = arCell;
concavityCellZeroDropped = concavityCell;
solidityCellZeroDropped = solidityCell;

% Remove AR, HF, C, S cell entry if area_i < threshold area.
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
for nSect = 1:size(areaValCell,2)
    for nPolygonNow = 1:size(areaValCell{nSect},2)
        areaNow = areaValCell{nSect}(nPolygonNow);
        if areaNow < minKeepArea
            hfCell{nSect}(nPolygonNow) = NaN;
            arCell{nSect}(nPolygonNow) = NaN;
            concavityCell{nSect}(nPolygonNow) = NaN;
            solidityCell{nSect}(nPolygonNow) = NaN;
            tfInt(nSect) = false;
            numPolygonsRemoved = numPolygonsRemoved + 1;
        end
    end
end

pixStr = '';
if isPix
    pixStr = ' pixels';
end
fprintf('%d polygons with area < %0.2e%s were dropped. %d remain.\n', ...
        numPolygonsRemoved, minKeepArea, pixStr, ...
        sum(cell2mat(cellfun(@numel,hfCell,'UniformOutput',false))));
    
GeomStruct.runTime = toc;
GeomStruct.hf = hfCell;
GeomStruct.ar = arCell;
GeomStruct.convy = concavityCell;
GeomStruct.soly = solidityCell;
GeomStruct.hfZeroDropped = hfCellZeroDropped;
GeomStruct.arZeroDropped = arCellZeroDropped;
GeomStruct.concavityZeroDropped = concavityCellZeroDropped;
GeomStruct.solidityZeroDropped = solidityCellZeroDropped;
GeomStruct.intPts = intPointsCell;
GeomStruct.tfInt = tfInt;
GeomStruct.cVals = cVals;
GeomStruct.planes = planeCell;
GeomStruct.isPlSecInvalid = isPlSecInvalid;
GeomStruct.nPolysRemoved = numPolygonsRemoved;

end % main

% ----------------------------------------------------------------------- %
% Data quality check on polygon vertices before AR, HF calculations.
% Check for NaN entries.
% A "bad" polygon may be produced if polygon area is approximately zero, 
% if the mesh contains interior faces, if all intersection points are 
% collinear, or if the OFF file contains a line segment that protrudes 
% from the solid's surface.
function isValidPoly = checkpolygon(points)

if size(unique(points,'rows'),1) < 3;
    isValidPoly = false;
else
    isNormDef = ~any(isnan(polynormal(points)));
    isNanPresent = any(sum(isnan(points)));
    isValidPoly = ~isNanPresent & isNormDef;
end

end

% ----------------------------------------------------------------------- %
% Notify user when multiple of pctStep*100% total calculation is finished.
function printprogress(n,N,pctStep,time)
% Loop ranges from n=1...N.
% If pctStep=1/5, function prints progress when integer multiple of 20% 
% calculation completes.
    if ~mod(n,round(pctStep*N))
        pctComp = (n/round(pctStep*N))*pctStep*100;
        fprintf('%0.0f\f%% complete. Elapsed time is %0.3E sec.\n' , ...
                                                        pctComp, time);
    elseif n==N
        pctComp = 100;
        fprintf('%0.0f\f%% complete. Elapsed time is %0.3E sec.\n' , ...
                                                        pctComp, time);
    end
end