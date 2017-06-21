function GeomStruct = off2pds(dirStr,secOrProj,nSphPts,varargin)
% OFF2PDS Calculate probability density surface data (aspect ratio, Heywood
% factor and concavity, solidity) from a closed triangle mesh stored in 
% .off format.
% 
% Returns a data structure containing the resulting data. Data structure is
% also saved to a .mat file.
% 
% Required Inputs:
% 
%   dirStr          A string containing the full path to a directory. This 
%                   must be the first input argument.
%   secOrProj       A string equal to 'sec' if plane of section data is to 
%                   be generated or equal to 'proj' if plane of projection. 
%                   This must be the second input argument.
%   nSphPts         The integer number of points to be distributed on the
%                   sphere (equal to the number of normal vectors). This 
%                   must be the third input argument.
%   nSlices         The integer number of slices. This input is required 
%                   for plane of section only. If plane of section, this   
%                   must be the fourth input argument.
% 
% 
% OptionalInputs:
% 
%   Flags:
% 
%   'OutputGnu'     When the string 'OutputGnu' is provided as an input
%                   argument, PLT and TXT files will be generated for 
%                   gnuplot figure generation.
%   'Pixelate'      When the 'Pixelate' flag is supplied, all polygons 
%                   will be pixleated before AR and HF values are 
%                   calculated.
% 
%   Parameter name/value pairs:
% 
%   'FileName'      The 'FileName',fNameStr parameter name/value pair 
%                   directs off2ahrf to process only the specified OFF 
%                   file name instead of all OFF files in the directory.
%   'NumSigFig'     Truncate vertex coordinate values at a specified number
%                   of significant digits. The default value is 5.
%   'MinAreaFract'  The 'MinAreaFract',minFraction paramter name/value pair
%                   instructs off2pds to filter polygons by area such that 
%                   all polygons with area less than 
%                   minFraction * [max. polygon area] are dropped. When 
%                   minFract=0, no polygons are dropped. Default value is
%                   0.05. 
%   'PixMaxArea'    The approximate area (in pixels) of the largest 
%                   section or projection polygon. If 'Pixelate' is 
%                   supplied but the 'PixMaxArea' parameter name/value 
%                   pair is not specified, the default value 15,000 will
%                   be used.
%   'MinNumPix'     The 'MinNumPix' parameter name/value pair may
%                   optionally be provided if the 'Pixelate' flag is also 
%                   supplied. MinNumPix instructs off2pds to filter
%                   polygons by area in a manner that is similar to
%                   MinAreaFract. However, the value that is passed with
%                   MinNumPix must be a number of pixels. All polygons with
%                   lesser area will be neglected. 
%   
% OFF2PDS(dirStr,secOrProj,nSphPts) iterates over all OFF files contained 
% in the directory dirStr, generating a MAT file from each. Data is 
% output to this directory by appending the data structure in each 
% MAT file.
% 
% OFF2PDS(dirStr,'sec',nSphPts,nSlices) runs plane of section code with
% nSphPts normals and nSlices slices for a directory of OFF files.
% 
% OFF2PDS(dirStr,'proj',nSphPts) runs plane of projection code on the
% OFF files in the specified directory.
% 
% OFF2PDS(dirStr,secOrProj,nSphPts,...,'FileName',fNameStr) generates 
% AR-HF data for only the OFF file fNameStr. fNameStr is a string that 
% contains the -.off extension.
% 
% OFF2PDS(dirStr,secOrProj,nSphPts,...,'NumSigFig',8) will truncate vertex
% coordinate values at 8 significant figures. Default value is 6.
% 
% OFF2PDS(dirStr,secOrProj,nSphPts,...,'OutputGnu') will create
% PLT/TXT files for gnuplot after plane of section or projection
% calculations.
% 
% OFF2PDS(dirStr,secOrProj,nSphPts,...,'Pixelate') pixelates all section
% or projection polygons before calculating AR, HF values. The polygon/grid 
% scale is set such that the polygon with greatest area will have an area 
% of approximately 15,000 pixels.
% 
% OFF2PDS(dirStr,secOrProj,nSphPts,...,'Pixelate','PixMaxArea',1000) 
% pixelates all section or projection polygons. The polygon/grid scale is
% set such that the polygon with greatest area will have an area of
% approximately 1,000 pixels.
% 
% 
% Example 1: pl. of sec. data for one OFF file in the folder testfolder.
% mydir = '/Documents/MATLAB/projection_section_modeling/testfolder/';
% off2pds(mydir,'sec',100,10,'FileName','block.off');
% 
% Example 2: pl. of sec. data for all OFF files in the folder testfolder.
% mydir = '/Documents/MATLAB/projection_section_modeling/testfolder/';
% off2pds(mydir,'sec',100,10);
% 
% 
% Author: B. Hannan
% Created during summer 2012 under the direction of Doug Rickman at NASA
% MSFC.
% Written with MATLAB R2014a.
% Last edit: 24 December 2014


% Define constants.
% Data-binning parameters
BIN_INTERVAL = 0.01;
% A percentage of total processing. Print status message each UPDATE_FRACT. 
UPDATE_FRACT = 0.2;

% Is dirStr a valid directory?
if ~ischar(dirStr)
    error(  'myfuns:off2pds:argInType'  ,  ...
            'Input argument must have type char.'      );
end
if exist(dirStr,'dir') ~= 7
    error(  'myfuns:off2pds:badDirectory',  ...
            'Input must be a valid path to a directory.');
end

% Parse input arguments.
[isSec,nSlices,isOutGnu,isPix,oneFName,tfOneFile,pixMaxArea,numSigFig,...
        minAreaFract,minNumPix] = parseargs(secOrProj,varargin{:});
    
% Get directory contents. Ignore files without .off extension.
fNameCell = getdirconts(dirStr,'.off');

if ~size(fNameCell,2)
    fprintf('No OFF files found in directory: \n%s\n', dirStr);
end

for nFile = 1:size(fNameCell,2)
    % if singleFileName is this file or if all files are to be processed
    if ~tfOneFile || tfOneFile && strcmp(oneFName,fNameCell{nFile})
        try
            
            % Pass nSlices to off2geomstruct if plane of section.
            if isSec
                % off2geomstruct creates a data structure, Data, and also
                % generates a file name, matFileName, that indicates
                % projection/section, number of normals, etc.
                [GeomStruct,matFileName] = off2geomstruct(...
                    fNameCell{nFile}            ,   ...
                    'sec'       ,   nSphPts     ,   ...
                    'NumSlices' ,   nSlices     ,   ...
                    'Pixelate'  ,   isPix       ,   ...
                    'PixMaxArea',   pixMaxArea  ,   ...
                    'MinNumPix' ,   minNumPix   ,   ...
                    'Directory' ,   dirStr          ...
                    );
                % Notify user if Cartesian coord. precision is not great
                % enough to accurately represent the geometry.
                if GeomStruct.minVertDist < 10/10^numSigFig
                    warning(    ...
                        'MATLAB:CartValPrecision',                      ...
                        ['Distance between minimally-separated pair '   ...
                        'of vertices is <10/[num. sig. fig.]. Consider' ...
                        ' increasing the no. of significant digits. ',  ...
                        'Min vert. dist. = %d. Num. sig. fig. = %d'],   ...
                        GeomStruct.minVertDist, numSigFig               ...
                    );
                end
                % Calculate AR-HF, C-S data.
                fprintf(['\nCalculating AR-HF, C-S data from ' ...
                                        'file %s\n'], fNameCell{nFile});
                if isSec
                    GeomStruct = planeofsection(GeomStruct,minAreaFract,...
                                                numSigFig,UPDATE_FRACT);
                else
                    GeomStruct = planeofprojection_v2(GeomStruct, ...
                                    minAreaFract,numSigFig,UPDATE_FRACT);
                end
                % Save the data to a .mat file. Append '.mat' to ensure 
                % that the file is not saved in ascii format.
                matFilePath = fullfile(dirStr,filesep, ...
                                            strcat(matFileName,'.mat'));
                save(matFilePath, 'GeomStruct', '-mat');
                fprintf('Data structure saved to\n%s\n', matFilePath);
            else
                [GeomStruct,matFileName] = off2geomstruct(...
                    fNameCell{nFile}            ,   ...
                    'proj'      , nSphPts       ,   ...
                    'Pixelate'  , isPix         ,   ...
                    'PixMaxArea', pixMaxArea    ,   ...
                    'Directory' , dirStr            ...
                    );
                % Calculate AR-HF, C-S data.
                fprintf(['\nCalculating AR-HF, C-S data from ' ...
                                        'file %s\n'], fNameCell{nFile});
                if isSec
                    GeomStruct = planeofsection(GeomStruct,minAreaFract,...
                                                numSigFig,UPDATE_FRACT);
                else
                    GeomStruct = planeofprojection(GeomStruct, ...
                                    minAreaFract,numSigFig,UPDATE_FRACT);
                end
                % Save the data to a .mat file. Append '.mat' to ensure 
                % that the file is not saved in ascii format.
                matFilePath = fullfile(dirStr,filesep, ...
                                            strcat(matFileName,'.mat'));
                save(matFilePath, 'GeomStruct', '-mat');
                fprintf('\nData structure saved to\n%s\n', matFilePath);
            end
            
            % Generate gnuplot output if 'OutputGnu' flag is provided.
            if isOutGnu
                fprintf(['\nCreating gnuPlot files in the ' ...
                                            'directory\n%s\n'], dirStr);
                createGnuplotFiles(GeomStruct,dirStr,BIN_INTERVAL, ...
                                                            minAreaFract);
            end
            
        catch err
            % Display error message and plug on to the next file.
            fprintf('\nError: \n%s\n', getReport(err,'extended'));
        end
        
    end
end

end % main


% ----------------------------------------------------------------------- %
% Check input arguments & parse optional inputs.
function [isSec,nSlices,isOutGnu,isPix,oneFName,tfOneFile,pixMaxArea,...
        numSigFig,minAreaFract,minNumPix] = parseargs(secOrProj,varargin)
% Convert secOrProj input to Boolean isSec.
validSecOrProjVals = {'sec','section','proj','projection'};
if ~any(strcmpi(secOrProj,validSecOrProjVals))
    error(  'myfuns:off2pds:propertyNameValPair'            ,   ...
            'Input arg secOrProj must be equal to ''sec'' or ''proj''.');
end
% The 1st 2 entries of validSecOrProjVals denote section. If provided
% string is found in either of these locations, set isSec to true.
isSec = any(strcmpi(secOrProj, validSecOrProjVals(1:2)));

% Handle opt input arg nSlices. If pl. of sec., 1st varargin is nSlices.
optArgs = {NaN};
if isSec
    optArgs{1} = varargin{1};
    varargin(1) = []; % Remove 1st element of varargin (nSlices).
end
nSlices = optArgs{:};

% Check nSlices type.
if ~isnumeric(nSlices) && ~isnan(nSlices)
    error(  'myfuns:off2pds:propertyNameValPair'            ,   ...
            'Input arg nSlices must be numeric and  1st optional input.');
end

% Create structure for the prop/val pair optional inputs.
options = struct(                                   ...
                    'NumSigFig'     ,   5       ,   ...
                    'FileName'      ,   'null'  ,   ...
                    'MinAreaFract'  ,   0.05    ,   ...
                    'MinNumPix'     ,   -1      ,   ...
                    'PixMaxArea'    ,   15E3        ...
                );

% Read the acceptable field names (parameter names).
optionNames = fieldnames(options);

% Identify the OutputGnu and Pixelate flags if they are provided. Once
% identified, overwrite the isOutGnu, isPix variables and remove from
% varargin cell so that they are not mistaken for parameter name/value 
% pair elements.
% This must take place before overwriting the "options" structure, which
% only works if varargin contains only parameter name/value pairs.
isOutGnu = false;
if any(strcmpi('OutputGnu',varargin))
    isOutGnu = true;
    % Remove 'OutGnu' from varargin cell.
    varargin = varargin(~strcmpi('OutputGnu',varargin));
end
isPix = false;
if any(strcmpi('Pixelate',varargin))
    isPix = true;
    % Remove 'Pixelate' from varargin cell.
    varargin = varargin(~strcmpi('Pixelate',varargin));
end

% Count args. If pl. of proj., expect 0 varargin or single prop/val pair.
numVarArgs = length(varargin);
if ~isSec && round(numVarArgs/2)~=numVarArgs/2
   error(   'myfuns:off2pds:propertyNameValPair'            ,       ...
            ['Number of inputs for propertyName/propertyValue '     ...
            'pairs is not even.']);
end

% Overwrite options struct.
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
    error(  'myfuns:off2pds:propertyNameValPair'  ,   ...
            'PixMaxArea property value must be numeric.');
end
% Is numSigFig a reasonable number?
if ~isnumeric(options.NumSigFig) || options.NumSigFig < 3
    error(  'myfuns:off2pds:numSigFig'  ,   ...
            'NumSigFig property value must be numeric, >3.');
end
% Check minAreaFract value.
if ~isnumeric(options.MinAreaFract) || options.MinAreaFract > 1
    error(  'myfuns:off2pds:propertyNameValPair'  ,   ...
            'MinAreaFract property value must be numeric and <=1.');
end
% Is minNumPix value numeric?
if ~isnumeric(options.MinNumPix)
    error(  'myfuns:off2pds:propertyNameValPair'  ,   ...
            'MinNumPix property value must be numeric.');
end

% If a file name was supplied, store it and set tfOneFile to true to 
% indicate that only the specified file is to be processed.
oneFName = options.FileName;
if ~strcmp(oneFName,'null') && exist(oneFName,'file')~=2
    error(  'myfuns:off2pds:badFileName',  ...
            'File name not recognized.');
end

% Use struct to set variable values.
tfOneFile = ~strcmp(oneFName,'null'); % If not 'null', process 1 file only.
pixMaxArea = options.PixMaxArea;
minNumPix = options.MinNumPix;
numSigFig = options.NumSigFig;
minAreaFract = options.MinAreaFract;

end


% ----------------------------------------------------------------------- %
function fnamescell = getdirconts(directory,fileExt)
% Return cell array of contents of the directory dirStr that have the 
% extension fileExt, which must have the form '.txt', '.mat', etc.
% Use the backslash escape character because '.' matches any character.
% '$' indicates that the search string must be at the end of the string.
fileExt = strcat('\',fileExt,'$');
dircontents = dir(directory);
fnamescell = {dircontents.name};
fnamescell = fnamescell(...
    cellfun(@(s) ~isempty(regexp(s,fileExt,'ONCE')), fnamescell));
end