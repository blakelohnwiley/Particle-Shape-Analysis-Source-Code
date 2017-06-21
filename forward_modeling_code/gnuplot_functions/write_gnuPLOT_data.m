function outFileName = write_gnuPLOT_data(Mode,Text1,f_NPoints,f_increment,f_FreqData,CumFreqAtCI,f_minFraction, ...
                             TotalPoints,Nxbins,Nybins,BinInterval, ...
                             BinnedNormalizedCounts,arhf,f_toc,...
                             outputDirectory)
%WRITE_GNUPLOT_DATA Write data to ASCII file in format needed by gnuPLOT.
%
%   D. Rickman, Jan 24, 2014

% 1. Write normalized binned data to the file in manner suitable to make
% contour plots.
% 2. Write those bins that cumulatively have 95% of the data.
% 3. Write those bins that cumulatively have 50% of the data.
% 4. Write the Aspect Ratio and Heywood Factor data to the file.
%
% The file is written to the ~/Documents/MATLAB/ directory.  The file name
% is derived from the solid and its dimensions.
% Mode = 1 for Plane of Projection.
% Mode = 2 for Plane of Section.
% Returns the name of the output file.

FTxt{100} = 'a'; % Preallocate the array

txtL = 0;
if Mode == 1
    txtL = txtL+1;
    FTxt{txtL} = 'Plane of Projection Model Results  -  Formatted for gnuPLOT'; % Type of model, projection or section
    String1 = '_PofProj.txt';
    String2 = '_PofProj.plt';
else % f_Mode ==2
    txtL = txtL+1;
    FTxt{txtL} = 'Plane of Section Model Results  -  Formatted for gnuPLOT'; % Type of model, projection or section
    String1 = '_PofSect.txt';
    String2 = '_PofSect.plt';
end

outFileName = [Text1,String1];
outFileName = strrep(outFileName,' ','_');
fileID    = fopen(fullfile(outputDirectory,outFileName),'w');
if fileID < 3 
    disp(['fileID: ', num2str(fileID)]);
    if fileID == -1
        disp(['An output file named ',outFileName,' could not be created in the default directory "',pwd,'". Check your write permissions in the directory.']);
    else
        disp(['An output file named ',outFileName,' could not be created for unknown reason in the default directory "',pwd,'"']);
    end
end

pltFileName = [Text1,String2];
pltFileName = strrep(fullfile(outputDirectory,pltFileName),' ', '_');

txtL = txtL+1;
FTxt{txtL} = ['Corresponding gnuPLOT script file = "',pltFileName,'"'];
txtL = txtL+1;
FTxt{txtL} = ' ';

txtL = txtL+1;
FTxt{txtL} = Text1;                                                % Description of the Solid
txtL = txtL+1;
FTxt{txtL} = ['Model execution time = ',num2str(f_toc),' seconds'];

if Mode ==2 
    txtL = txtL+1;
    FTxt{txtL} = ['Number of Surface Normals : ',num2str(f_NPoints)];  % Number of surface normals used
    txtL = txtL+1;
    FTxt{txtL} = ['Slice Spacing : ', num2str(f_increment)];       % Maximum number of slices
end
if f_minFraction ~= 0
    txtL = txtL+1;
    FTxt{txtL} = ['Polygons smaller than ',num2str(f_minFraction),' of the largest polygon are dropped.'];  % Size at which polygons were dropped.
end

txtL = txtL+1;
FTxt{txtL} = ['Number of data points = ',num2str(TotalPoints)];
txtL = txtL+1;
FTxt{txtL} = ['Binning Interval = ', num2str(BinInterval)];
txtL = txtL+1;
FTxt{txtL} = ['Max frequency in a bin                      = ',num2str(f_FreqData(1))];
txtL = txtL+1;
FTxt{txtL} = ['Frequency at which cumulative ~50% occurs   = ',num2str(f_FreqData(5))];
txtL = txtL+1;
FTxt{txtL} = ['Frequency at which cumulative ~75% occurs   = ',num2str(f_FreqData(4))];
txtL = txtL+1;
FTxt{txtL} = ['Frequency at which cumulative ~95% occurs   = ',num2str(f_FreqData(2))];
txtL = txtL+1;
FTxt{txtL} = ['Cum Freq for all bins with 5 or more points = ',num2str(f_FreqData(3))];
    
txtL = txtL+1;
FTxt{txtL} = ' ';

for i = 1:5
    txtL = txtL+1;
    FTxt{txtL} = ['Cumulative Frequency within frequency ',num2str(CumFreqAtCI(i,2)),', which is contour ',num2str(i),' = ',num2str(CumFreqAtCI(i,1))];
end
txtL = txtL+1;
FTxt{txtL} = ' ';

txtL = txtL+1;
FTxt{txtL} = 'Data Block 1: Ellipse, rectangle and triangle lines';
txtL = txtL+1;
FTxt{txtL} = 'Data Block 2: Binned and normalized data, structured for contouring';
txtL = txtL+1;
FTxt{txtL} = 'Data Block 3: Binned and normalized data with cumulative frequency >= 95%';
txtL = txtL+1;
FTxt{txtL} = 'Data Block 4: Binned and normalized data with cumulative frequency >= 75%';
txtL = txtL+1;
FTxt{txtL} = 'Data Block 5: Binned and normalized data with cumulative frequency >= 50%';
txtL = txtL+1;
FTxt{txtL} = 'Data Block 6: Individual Aspect Ratio and Heywood points.';
txtL = txtL+1;
FTxt{txtL} = ' ';

formatSpec = '%s \n';
for i = 1:txtL;
    fprintf(fileID,formatSpec,['# ',FTxt{i}]);
end

% Data Block 1: The ellipse, rectangle and triangle lines
% Get the values for ellipses, rectangles and triangles
ARHF_ellipse   = ARHF_Ellipse();
ARHF_rectangle = ARHF_Rectangle();
ARHF_triangle  = ARHF_Triangle();

counter = [ 6,  7,  8,  9, 10, 12, 14, 16, 18, 21, ...
           24, 26, 30, 34, 38, 43, 47, ...
           51, 58, 69, 80, 90,100];
    
fprintf(fileID,['#     Ellipse        Rectangle       Triangle         ','\n']); % Write header lines
fprintf(fileID,['# _____________   _____________   _____________  Dummy','\n']); % Write header lines
fprintf(fileID,['#   AR     HF       AR     HF       AR     HF      Z   ','\n']); % Write header lines
formatSpec = '  %6.4f %6.4f   %6.4f %6.4f   %6.4f %6.4f    0\n';
for i = counter
    data = [ARHF_ellipse(i,1), ARHF_ellipse(i,2), ARHF_rectangle(i,1), ARHF_rectangle(i,2), ARHF_triangle(i,1), ARHF_triangle(i,2)];
    fprintf(fileID,formatSpec,data);
end
fprintf(fileID,'\n\n'); % 2 blank lines denote end of a data set in gnuplot


% Data Block 2: The binned and normalized data
fprintf(fileID,['# AR     HF      freq','\n']); % Write header lines
formatSpec = '%6.4f %6.4f %8.5f\n';
for i = 1:Nxbins
   for j = 1:Nybins
      fprintf(fileID,formatSpec,0+((i-1)*BinInterval),0+((j-1)*BinInterval),BinnedNormalizedCounts(i,j));
   end
fprintf(fileID,'\n');   
end
fprintf(fileID,'\n'); % Insert another blank line.  2 blank lines denote end of a data set


% Data Block 3: The binned and normalized data with cumulative frequency >= 95%
fprintf(fileID,['# ','Bins with cumulative frequency >= 95%% ','\n']); % Write header line
fprintf(fileID,['# AR     HF      freq','\n']);                       % Write header lines
formatSpec = '%6.4f %6.4f %8.5f\n';
for i = 1:Nxbins
   for j = 1:Nybins
       if BinnedNormalizedCounts(i,j) >= f_FreqData(2)
       fprintf(fileID,formatSpec,0+((i-1)*BinInterval),0+((j-1)*BinInterval),BinnedNormalizedCounts(i,j));
       end
   end
end
fprintf(fileID,'\n\n'); % Insert two blank lines.  2 blank lines denote end of a data set


% Data Block 4: The binned and normalized data with cumulative frequency >= 75%
fprintf(fileID,['# ','Bins with cumulative frequency >= 75%% ','\n']); % Write header line
fprintf(fileID,['# AR     HF      freq','\n']);                       % Write header lines
formatSpec = '%6.4f %6.4f %8.5f\n';
for i = 1:Nxbins
   for j = 1:Nybins
       if BinnedNormalizedCounts(i,j) >= f_FreqData(4)
       fprintf(fileID,formatSpec,0+((i-1)*BinInterval),0+((j-1)*BinInterval),BinnedNormalizedCounts(i,j));
       end
   end
end
fprintf(fileID,'\n\n'); % Insert two blank lines.  2 blank lines denote end of a data set


% Data Block 5: The binned and normalized data with cumulative frequency >= 50%
fprintf(fileID,['# ','Bins with cumulative frequency >= 50%% ','\n']); % Write header line
fprintf(fileID,['# AR     HF      freq','\n']);                       % Write header lines
formatSpec = '%6.4f %6.4f %8.5f\n';
for i = 1:Nxbins
   for j = 1:Nybins
       if BinnedNormalizedCounts(i,j) >= f_FreqData(5)
       fprintf(fileID,formatSpec,0+((i-1)*BinInterval),0+((j-1)*BinInterval),BinnedNormalizedCounts(i,j));
       end
   end
end
fprintf(fileID,'\n\n'); % Insert two blank lines.  2 blank lines denote end of a data set


% Data Block 6: The individual Aspect Ratio and Heywood points.
fprintf(fileID,['# All of the data points','\n']);            % Write header lines
fprintf(fileID,['# AR     HF','\n']);                         % Write header lines
formatSpec = '%6.4f %6.4f %6.4f \n';
for i = 1:TotalPoints
      fprintf(fileID,formatSpec, arhf(i,1), arhf(i,2), 0);
end
fprintf(fileID,'\n\n'); % Insert two blank lines.  2 blank lines denote end of a data set

fclose(fileID);

end