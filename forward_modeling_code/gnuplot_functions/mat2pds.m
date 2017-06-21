function mat2pds(directoryString)
% MAT2PDS Create C-S gnuplot files for all .mat files in a directory. 
% 
% MAT2PDS(directoryString) Identifies all .mat files in the directory 
% directoryString (must be a string in single quotes). If concavity, 
% solidity data are not present in the .mat file, these data are
% calculated from the polygons in the .mat file.
% 
% gnuplot files are ouptut to the directory directoryString.
% 
% 
% Author: B. Hannan
% Written with MATLAB Student 2012a.
% Created on 5 September 2014.

BIN_INTERVAL = 0.01;
% Ignore planes of section with area < MIN_FRACTION * [max polygon area].
MIN_FRACTION = 0.05;

% Is directoryString a valid directory?
if ~ischar(directoryString)
    error(  'myfuns:off2pds:argInType'  ,  ...
            'Input argument must have type char.'      );
end
if exist(directoryString,'dir') ~= 7
    error(  'myfuns:off2pds:badDirectory',  ...
            'Input must be a valid path to a directory.');
end

% Get all .mat files in the directory.
DirContents = dir(fullfile(directoryString,'*.mat'));
% Chec if blabla.mat is directory?

if ~numel(DirContents)
    fprintf('No .mat files found in directory: \n%s\n', directoryString);
else
    fprintf('%d .mat files were found in the directory\n%s\n\n', ...
                                    numel(DirContents), directoryString);
end

for nFile = 1:numel(DirContents)
    clear GeomStruct
    load(fullfile(directoryString,DirContents(nFile).name));
    if exist('GeomStruct','var') ~= 1
        % If the data structure GeomStruct is not present in the .mat file,
        % continue to next file.
        fprintf(['\nData structure ''GeomStruct'' NOT found in '    ...
            'file %s.\nSkipping this file.\n'], DirContents(nFile).name);
    elseif isfield(GeomStruct,'convy') && isfield(GeomStruct,'soly')
        % If C, S data exists, make the gnuplot files now.
        fprintf(['Existing C-S data found in file %s.' ...
            '\nCreating gnuplot files.\n'], DirContents(nFile).name);
        createGnuplotFiles(GeomStruct,directoryString,BIN_INTERVAL, ...
                                                    MIN_FRACTION,'C-S');
    else
        % C, S data was not found. Calculate it using existing polygons.
        fprintf(['No C-S data found in file %s.\nCalculating ' ...
                    'C-S data from polygons.\n'],DirContents(nFile).name);
        if GeomStruct.isSec
            % Plane of section concavity, solidity.
            concavityCell = cell(1,GeomStruct.cSteps*length(GeomStruct.xs));
            solidityCell = cell(1,GeomStruct.cSteps*length(GeomStruct.xs));
            for nSect = 1:numel(GeomStruct.intPts)
                if GeomStruct.tfInt(nSect)
                    % Get the polygon(s) from one intersection.
                    intPointsCellNow = GeomStruct.intPts{nSect};
                    numSectionsNow = length(intPointsCellNow);
                    solidityMatAtSecNow = NaN(1,numSectionsNow);
                    concavityMatAtSecNow = NaN(1,numSectionsNow);
                    % Calculate C, S for (all) polygon(s).
                    for nPlSecNow = 1:numSectionsNow
                        planeSecNow = intPointsCellNow{nPlSecNow};
                        concavityNow = concavity(planeSecNow);
                        solidityNow = solidity(planeSecNow);
                        concavityMatAtSecNow(nPlSecNow) = concavityNow;
                        solidityMatAtSecNow(nPlSecNow) = solidityNow;
                        concavityCell{nSect} = concavityMatAtSecNow;
                        solidityCell{nSect} = solidityMatAtSecNow;
                    end
                end
            end
            % Place C, S data in the struct.
            GeomStruct.convy = concavityCell;
            GeomStruct.soly = solidityCell;
            % Save data to .mat file.
            save(fullfile(directoryString,DirContents(nFile).name),...
                                                    'GeomStruct', '-mat');
            % Make the C-S gnuplot .txt, .plt files.
            createGnuplotFiles(GeomStruct,directoryString,BIN_INTERVAL, ...
                                                    MIN_FRACTION,'C-S');
        else
            % Plane of projection concavity, solidity.
            concavityCell = cell(1, length(GeomStruct.prjVts));
            solidityCell = cell(1, length(GeomStruct.prjVts));
            for nw = 1:numel(GeomStruct.prjVts)
                % Get polygon vertices
                projVertsNow = GeomStruct.prjVts{nw};
                projVertsNow3d = [projVertsNow, ...
                                            zeros(size(projVertsNow,1),1)];
                concavityCell{nw} = concavity(projVertsNow3d);
                solidityCell{nw} = solidity(projVertsNow3d);
            end
            % Place C, S data in the struct.
            GeomStruct.convy = concavityCell;
            GeomStruct.soly = solidityCell;
            % Save data to .mat file.
            save(fullfile(directoryString,DirContents(nFile).name),...
                                                    'GeomStruct', '-mat');
            % Make the C-S gnuplot .txt, .plt files.
            createGnuplotFiles(GeomStruct,directoryString,BIN_INTERVAL, ...
                                                    MIN_FRACTION,'C-S');
        end
    end
end

end