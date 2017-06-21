function [GeomStruct,matFileName] = off2geomstruct(filename,secOrProj,nSphPts,varargin)
% OFF2GEOMSTRUCT Create a data structure containing a mesh and plane of
% section or projection parameters from OFF file.
% 
% off2geomstruct(filename,isSec,isPix,nSphPts,varargin) Creates a new MAT file 
% for the off OFF file 'filename'.
% 
% Inputs:
% 
% Required inputs:
%   filename        The name of the OFF file. Do not include the '.off'
%                   extension.
%   secOrProj       'sec' or 'section' to generate plane of section data.
%                   'proj' or 'projection' to generate plane of projection
%                   data. Case-insensitive.
%   nSphPts         The integer number of sphere points to be distributed
%                   on the sphere.
% 
% 
% Optional inputs:
% Note: all optional inputs are parameter name-value pairs and therefore
% must be input in the form 'ParamName',value
%   NumSlices       Number of sections per normal (plane of sec. only).
%   Directory       Directory containing the OFF files. This is also the
%                   file output directory.
%   Pixelate        Boolean. If true, pixelated data is geneated. Note that
%                   in off2arhf.m, 'Pixelate' is input as a flag with no
%                   value to follow it. The 'Pixelate',isPix name-value 
%                   pair is used here to simplify optional input argument
%                   format.
%   PixMaxArea      The maximum area, in pixels, for a polygon. This is an
%                   approximate value and is used to determine the relative
%                   size between the mesh dimensions and binarization grid
%                   spacing. See polybitmask.m for more info.
%   MinNumPix       If polygons are pixelated, remove any polygon if its 
%                   area is fewer than minNumPix pixels.
%   
%                   Note: If only one directory is specified, this dir 
%                   is treated as both input and output dir.
% 
% Outputs:
%   filename        String containing name of newly created MAT file.
%   GeomStruct      A data structure containing the following fields.
%       verts       Vertices matrix.
%       faces       Faces matrix.
%       edges       Edges matrix.
%       shapeName   A string that names the shape.
%       isSec       Boolean indicating whether projection or section data
%                   is to be calculated.
%       nSphPts     Number of normals (no. points distributed on sphere).
%       cSteps      Number of sections for each normal (section only).
%       xs, ys, zs  x, y, z coordinates of the sphere points.
%
% Example:
% To generate plane of section dat for block.off, located in the 
% main/3D_drawings dir, and output the resulting MAT file to the
% data_output_files dir, use:
% myDir = '/Documents/MATLAB/projection_section_modeling/main/3d_drawings'
% off2geomstruct('block.off','sec',1000,'NumSlices',50,'Directory',myDir);
% 
% Author: B. Hannan
% Written with MATLAB 2014a.
% Last edited on 19 Dec 2014.


%%% ------------------------------------------------------------------- %%%
% Parse, validate input arguments and parse optional inputs.

validSecOrProjVals = {'sec','section','proj','projection'};
if ~any(strcmpi(secOrProj,validSecOrProjVals))
    error(  'myfuns:off2geomstruct:propertyNameValPair'            ,   ...
            'Input arg secOrProj must be equal to ''sec'' or ''proj''.');
end
% The 1st 2 entries of validSecOrProjVals denote section. If provided
% string is found in either of these locations, set isSec to true.
if any(strcmpi(secOrProj,validSecOrProjVals(1:2)))
    isSec = true;
else
    isSec = false;
end

% Count args. If pl of proj, expect 0 varargin or single prop/val pair.
numVarArgs = length(varargin);
if round(numVarArgs/2)~=numVarArgs/2
   error(   'myfuns:off2geomstruct:propertyNameValPair'            ,   ...
            ['Number of inputs for propertyName/propertyValue '     ...
            'pairs is not even.']);
end

% Create structure for the prop/val pair optional inputs.
options = struct(...
    'NumSlices' ,   50      ,   ...
    'Pixelate'  ,   false   ,   ...
    'PixMaxArea',   15E3    ,   ...
    'Directory' ,   ''      ,   ... % in/out directory
    'MinNumPix' ,   -1          ...
);

% Read the acceptable names.
optionNames = fieldnames(options);

% Overwrite options.
if length(varargin) > 1
    for pair = reshape(varargin,2,[])
        inputName = pair{1};
        if any(strcmpi(inputName,optionNames))
            options.(inputName) = pair{2};
        else
            error('%s is not a recognized parameter name.', inputName);
        end
    end
end

% Check input variable type.
% Is PixMaxArea value numeric?
if ~isnumeric(options.PixMaxArea)
    error(  'myfuns:off2geomstruct:propertyNameValPair'  ,   ...
            'PixMaxArea property value must be numeric.');
end
if options.PixMaxArea<100
    warning(    'myfuns:off2geomstruct:propertyNameValPair' ,   ...
                ['PixMaxArea < 100. Low maximum area value may result ' ...
                'in poor results.']);
end
if ~isnumeric(options.NumSlices)
    error(  'myfuns:off2geomstruct:propertyNameValPair'  ,   ...
            'NumSlices property value must be numeric.');
end

isPix = options.Pixelate;
pixMaxArea = options.PixMaxArea;
minNumPix = options.MinNumPix;
nSlices = options.NumSlices;
directory = options.Directory;
%%% ------------------------------------------------------------------- %%%


% Store user input in struct.
GeomStruct.offDirectory = directory;
GeomStruct.offFileName = filename;
GeomStruct.isSec = isSec;
GeomStruct.nSphPts = nSphPts;
if isSec
    GeomStruct.cSteps = nSlices;
end

solidName = strrep(filename,'.off','');
if isPix % Append 'pix' to solid name if polygons are to be pixelated.
    solidName = [solidName,'_pix'];
end
GeomStruct.shapeName = solidName;


% Generate triangular mesh data.
[GeomStruct.verts, GeomStruct.faces] = readMesh_off(fullfile(directory,...
                                                                filename));
                                                            
% Arrange face vertices such that normal orientation is uniform.
GeomStruct.faces = unifyMeshNormals(GeomStruct.faces,GeomStruct.verts);
                                                            
GeomStruct.edges = meshEdges(GeomStruct.faces);
GeomStruct.minVertDist = mindist(GeomStruct.verts);

% [GeomStruct.xs, GeomStruct.ys, GeomStruct.zs] = ...
%                             PointsOnSphereEqually(GeomStruct.nSphPts);

[GeomStruct.xs, GeomStruct.ys, GeomStruct.zs] = ...
                                PointsOnSphere(GeomStruct.nSphPts);
cent = centroid(GeomStruct.verts);
GeomStruct.verts = trans2origin(GeomStruct.verts,cent);

% Add isPix Boolean and the pixelated polygon maximum area value to the
% structure.
GeomStruct.isPix = isPix;
GeomStruct.pixMaxArea = pixMaxArea;
GeomStruct.minNumPix = minNumPix;

% Calculate concavity and solidity values for the mesh.
GeomStruct.convy3d = convexity3d(GeomStruct.verts,GeomStruct.faces);
GeomStruct.soly3d = solidity3d(GeomStruct.verts,GeomStruct.faces);

% Append 'proj'/'sec', num. normals, slices to file name.
if isSec
    matFileName = sprintf('%s_sec_%dnorms_%dslices', solidName, nSphPts,...
                                                                nSlices);
else
    matFileName = sprintf('%s_proj_%dnorms', solidName, nSphPts);
end

% Add file name string to the struct. It will be used to title PDS figures.
GeomStruct.matFileName = matFileName;

end % main
