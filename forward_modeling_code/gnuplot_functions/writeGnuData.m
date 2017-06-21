function [txtFileName,pltFileName] = writeGnuData(              ...
                            DataStruct       ,  isArhf      ,   ...
                            f_freqData       ,  cumFreqAtCI ,   ...
                            f_minFraction    ,  totalPoints ,   ...
                            numXbins         ,  numYbins    ,   ...
                            binInterval      ,  binNormCounts,  ...
                            outDirectory                        ...
                            )
% WRITEGNUDATA Write data to ASCII file in format needed by 
% gnuPLOT to produce AR-HF, C-S figures.
% D. Rickman, Jan 24, 2014
% Edited 29 Jan. 2015.
% 
% dataMat must be a Nx2 matrix. If AR-HF, col 1 is AR, col 2 is HF. If C-S,
% col 1 is C, col 2 is S.


% 1. Write normalized binned data to the file in manner suitable to make
% contour plots.
% 2. Write those bins that cumulatively have 95% of the data.
% 3. Write those bins that cumulatively have 50% of the data.
% 4. Write the Aspect Ratio and Heywood Factor or Concavity and Solidity
% data to the file.

% Get data from struct.
isSec = DataStruct.isSec;
isPix = DataStruct.isPix;
pixMaxArea = DataStruct.pixMaxArea;
numPolygonsRemoved = DataStruct.nPolysRemoved;
f_toc = DataStruct.runTime;
f_NPoints = DataStruct.nSphPts;
if isSec
    f_increment = DataStruct.cSteps;
else
    f_increment = NaN;
end
% The matFileName field may not be present in the data structure if the
% file was created with an older version of off2arhf.m. If matFileName is
% not found, create this variable before proceeding.
if isfield(DataStruct,'matFileName');
    matFileName = DataStruct.matFileName;
else
    if DataStruct.isSec
        matFileName = sprintf('%s_sec_%dnorms_%dslices', shapeName, ...
                                    DataStruct.nSphPts, DataStruct.cSteps);
    else
        matFileName = sprintf('%s_proj_%dnorms', shapeName, ...
                                                    DataStruct.nSphPts);
    end
end

% Create AR-HF or C-S matrix.
if isArhf
    dataMat = [cell2mat(DataStruct.ar)', cell2mat(DataStruct.hf)'];
else
    dataMat = [cell2mat(DataStruct.convy)', cell2mat(DataStruct.soly)'];
end

% Preallocate the cell array.
fTxt = cell(1,100);

txtL = 0;
if ~isSec
    txtL = txtL+1;
    fTxt{txtL} = ['Plane of Projection Model Results  ' ...
                                '-  Formatted for gnuPLOT'];
    if isArhf
        string1 = '_ARHF_PofProj.txt';
        string2 = '_ARHF_PofProj.plt';
    else
        string1 = '_CS_PofProj.txt';
        string2 = '_CS_PofProj.plt';
    end
else
    txtL = txtL+1;
    fTxt{txtL} = ['Plane of Section Model Results  ' ...
                                '-  Formatted for gnuPLOT'];
    if isArhf
        string1 = '_ARHF_PofSect.txt';
        string2 = '_ARHF_PofSect.plt';
    else
        string1 = '_CS_PofSect.txt';
        string2 = '_CS_PofSect.plt';
    end
end

% Remove '_sec' or '_proj'. string1 will label the file as proj or sect.
txtFileName = [regexprep(matFileName,{'_sec','_proj'},''), string1];
txtFileName = strrep(txtFileName,' ','_');
fileID = fopen(fullfile(outDirectory,txtFileName),'w');
if fileID < 3 
    disp(['fileID: ', num2str(fileID)]);
    if fileID == -1
        disp(['An output file named ',txtFileName,' could not be '      ...
            'created in the default directory "',pwd,'". Check your '   ...
            'write permissions in the directory.']);
    else
        disp(['An output file named ',txtFileName,' could not be '      ...
            'created for unknown reason in the default '                ...
            'directory "',pwd,'"']);
    end
end

pltFileName = [matFileName,string2];
pltFileNameAndPath = strrep(fullfile(outDirectory,pltFileName),' ', '_');

txtL = txtL+1;
fTxt{txtL} = ['Corresponding gnuPLOT script file = "', ...
                                                pltFileNameAndPath,'"'];
txtL = txtL+1;
fTxt{txtL} = ' ';

txtL = txtL+1;
fTxt{txtL} = matFileName; % A description of the solid.
txtL = txtL+1;
fTxt{txtL} = ['Model execution time = ',num2str(f_toc),' seconds'];

if isSec 
    txtL = txtL+1;
    fTxt{txtL} = ['Number of Surface Normals : ',num2str(f_NPoints)];
    txtL = txtL+1;
    fTxt{txtL} = ['Slice Spacing : ', num2str(f_increment)];
end
if f_minFraction ~= 0
    txtL = txtL+1;
    fTxt{txtL} = ['Polygons smaller than ',num2str(f_minFraction), ...
                                ' of the largest polygon are dropped.'];
end

txtL = txtL+1;
fTxt{txtL} = ['Number of data points = ',num2str(totalPoints)];
txtL = txtL+1;
fTxt{txtL} = ['Binning Interval = ', num2str(binInterval)];
txtL = txtL+1;
fTxt{txtL} = ['Max frequency in a bin                      = ', ...
                                                num2str(f_freqData(1))];
txtL = txtL+1;
fTxt{txtL} = ['Frequency at which cumulative ~50% occurs   = ', ...
                                                num2str(f_freqData(5))];
txtL = txtL+1;
fTxt{txtL} = ['Frequency at which cumulative ~75% occurs   = ', ...
                                                num2str(f_freqData(4))];
txtL = txtL+1;
fTxt{txtL} = ['Frequency at which cumulative ~95% occurs   = ', ...
                                                num2str(f_freqData(2))];
txtL = txtL+1;
fTxt{txtL} = ['Cum Freq for all bins with 5 or more points = ', ...
                                                num2str(f_freqData(3))];
    
txtL = txtL+1;
fTxt{txtL} = ' ';

for i = 1:5
    txtL = txtL+1;
    fTxt{txtL} = ['Cumulative Frequency within frequency '          , ...
                    num2str(cumFreqAtCI(i,2)),', which is contour ' , ...
                    num2str(i),' = ',num2str(cumFreqAtCI(i,1))];
end

txtL = txtL+1;
fTxt{txtL} = ' ';

txtL = txtL+1;
fTxt{txtL} = ['# Number of polygons dropped after filtering by polygon area = ',numPolygonsRemoved];

txtL = txtL+1;
fTxt{txtL} = ' ';

txtL = txtL+1;
if isPix 
   fTxt{txtL} = ['# Data are pixelated, parameter PixMaxArea = ' pixMaxArea];
else
   fTxt{txtL} = ['# Data are not pixelated.'];

txtL = txtL+1;
fTxt{txtL} = ' ';

txtL = txtL+1;
fTxt{txtL} = 'Data Block 1: Ellipse, rectangle and triangle lines';
txtL = txtL+1;
fTxt{txtL} = ['Data Block 2: Binned and normalized data, structured ' ...
                                                        'for contouring'];
txtL = txtL+1;
fTxt{txtL} = ['Data Block 3: Binned and normalized data with ' ...
                                            'cumulative frequency >= 95%'];
txtL = txtL+1;
fTxt{txtL} = ['Data Block 4: Binned and normalized data with ' ...
                                            'cumulative frequency >= 75%'];
txtL = txtL+1;
fTxt{txtL} = ['Data Block 5: Binned and normalized data with ' ...
                                            'cumulative frequency >= 50%'];
txtL = txtL+1;
if isArhf
    fTxt{txtL} = ['Data Block 6: Individual Aspect Ratio and Heywood ' ...
                                                        'Factor points.'];
else
    fTxt{txtL} = ['Data Block 6: Individual Concavity and Solidity ' ...
                                                            'points.'];
end
txtL = txtL+1;
fTxt{txtL} = ' ';

formatSpec = '%s \n';
for i = 1:txtL;
    fprintf(fileID,formatSpec,['# ',fTxt{i}]);
end

% Data Block 1: The ellipse, rectangle and triangle lines
% Get the values for ellipses, rectangles and triangles
ARHF_ellipse   = ARHF_Ellipse();
ARHF_rectangle = ARHF_Rectangle();
ARHF_triangle  = ARHF_Triangle();


% Write header lines.
fprintf(fileID,['#     Ellipse        Rectangle       ' ...
                        'Triangle         ','\n']); 
fprintf(fileID,['# _____________   _____________   ' ...
                    '_____________  Dummy','\n']);
if isArhf
    fprintf(fileID,['#   AR     HF       AR     HF       AR     ' ...
                                'HF      Z   ','\n']);
else
    fprintf(fileID,['#   C      S        C      S        C      ' ...
                                'S       Z   ','\n']);
end
formatSpec = '  %6.4f %6.4f   %6.4f %6.4f   %6.4f %6.4f    0\n';

% Ixs of ellips, rectangle, triangle lines to be plotted.
ertIxs = [6, 7, 8, 9, 10, 12, 14, 16, 18, 21, 24, ...
                26, 30, 34, 38, 43, 47, 51, 58, 69, 80, 90, 100];

% data = [                                  % B. Hannan commented these 
%     ARHF_ellipse(ertIxs,:)  ,   ...       % lines to omit tri., rec., 
%     ARHF_rectangle(ertIxs,:),   ...       % ell. lines in C-S plots.
%     ARHF_triangle(ertIxs,:)     
%     ];

for k = ertIxs
    data = [ARHF_ellipse(k,1), ARHF_ellipse(k,2), ...
        ARHF_rectangle(k,1), ARHF_rectangle(k,2), ...
        ARHF_triangle(k,1), ARHF_triangle(k,2)
        ];
    if ~isArhf                  % Data above are only relevant to AR-HF. 
        data = nan(size(data)); % If writing C-S file, write NaN.
    end
    fprintf(fileID,formatSpec,data);
end
fprintf(fileID,'\n\n'); % 2 blank lines denote end of a data set in gnuplot


% Data Block 2: The binned and normalized data
% Write header lines
if isArhf
    fprintf(fileID,['# AR     HF      freq','\n']);
else
    fprintf(fileID,['# C      S       freq','\n']);
end

formatSpec = '%6.4f %6.4f %8.5f\n';
for i = 1:numXbins
   for j = 1:numYbins
      fprintf(fileID,formatSpec,0+((i-1)*binInterval),...
                        0+((j-1)*binInterval),binNormCounts(i,j));
   end
fprintf(fileID,'\n');   
end
fprintf(fileID,'\n'); % Insert blank line to denote end of data set.


% Data Block 3: Binned and normalized data with cumulative freq. >= 95%.
% Write header lines.
fprintf(fileID,['# ','Bins with cumulative frequency >= 95%% ','\n']); 
if isArhf
    fprintf(fileID,['# AR     HF      freq','\n']);
else
    fprintf(fileID,['# C     S      freq','\n']);
end
formatSpec = '%6.4f %6.4f %8.5f\n';
for i = 1:numXbins
   for j = 1:numYbins
       if binNormCounts(i,j) >= f_freqData(2)
       fprintf(fileID,formatSpec,0+((i-1)*binInterval),...
                    0+((j-1)*binInterval),binNormCounts(i,j));
       end
   end
end
fprintf(fileID,'\n\n'); % Insert two blank lines to denote end of data set.


% Data Block 4: The binned and normalized data with cumulative frequency 
% >= 75%
% Write header lines.
fprintf(fileID,['# ','Bins with cumulative frequency >= 75%% ','\n']); 
if isArhf
    fprintf(fileID,['# AR     HF      freq','\n']);
else
    fprintf(fileID,['# C      S       freq','\n']);
end
formatSpec = '%6.4f %6.4f %8.5f\n';
for i = 1:numXbins
   for j = 1:numYbins
       if binNormCounts(i,j) >= f_freqData(4)
           fprintf(fileID,formatSpec,0+((i-1)*binInterval), ...
                        0+((j-1)*binInterval),binNormCounts(i,j));
       end
   end
end
fprintf(fileID,'\n\n'); % Insert two blank lines to denote end of data set.


% Data Block 5: The binned and normalized data with cumulative frequency 
% >= 50%
% Write header lines.
fprintf(fileID,['# ','Bins with cumulative frequency >= 50%% ','\n']);
if isArhf
    fprintf(fileID,['# AR     HF      freq','\n']); 
else
    fprintf(fileID,['# C      S       freq','\n']);
end
formatSpec = '%6.4f %6.4f %8.5f\n';
for i = 1:numXbins
   for j = 1:numYbins
       if binNormCounts(i,j) >= f_freqData(5)
           fprintf(fileID,formatSpec,0+((i-1)*binInterval),...
                        0+((j-1)*binInterval),binNormCounts(i,j));
       end
   end
end
% Insert two blank lines. 2 blank lines denote end of a data set.
fprintf(fileID,'\n\n');


% Data Block 6: The individual concavity and solidity points.
% Write header lines.
fprintf(fileID,['# All of the data points','\n']);
if isArhf
    fprintf(fileID,['# AR     HF','\n']);
else
    fprintf(fileID,['# C      S','\n']);  
end
for i = 1:totalPoints
      fprintf(fileID,'%6.4f %6.4f %6.4f \n',dataMat(i,1),dataMat(i,2),0);
end
% Insert two blank lines. 2 blank lines denote end of a data set.
fprintf(fileID,'\n\n'); 

%% Data Block 7: Information related to neglected polygons.
%fprintf(fileID,['# numPolygonsRemoved is the total number of polygons ',...
%            'that were \n# dropped after filtering by polygon area','\n']);
%fprintf(fileID,sprintf('numPolygonsRemoved = %d\n',numPolygonsRemoved));
%% Insert two blank lines. 2 blank lines denote end of a data set.
%fprintf(fileID,'\n\n'); 
%
%% % Data Block 8: Pixelation parameters.
%fprintf(fileID,'# Pixelation parameters\n');
%fprintf(fileID,'# Pix. Bool.    pixMaxArea\n');
%fprintf(fileID,sprintf('%d               %d\n',isPix,pixMaxArea));
%% Insert two blank lines. 2 blank lines denote end of a data set.
%fprintf(fileID,'\n\n');
%
fclose(fileID);

end