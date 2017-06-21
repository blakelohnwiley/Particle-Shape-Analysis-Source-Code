function  write_gnuPLOT_file(f_Mode,f_TxtFile,f_Text1,f_NPoints,...
                f_FreqData,f_BinInterval,NNormals,f_increment,f_minFraction,outputDirectory)
%WRITE_GNUPLOT_FILE Create the file needed to run gnuPLOT and generate the contoured data grasp.
%   Mary had a little lamb. And the doctor fainted.
%
%   Write the .PLT file needed to run gnuPLOT for the data contained in the
%   corresponding .txt file.  
%   D. Rickman, Jan 27, 2014
%   Mod: Jul 3, 2014, Aug 8, 2014, Nov 25, 2014
%
% Mode = 1 for Plane of Projection.
% Mode = 2 for Plane of Section.

Ftxt{500} = 'a'; % Preallocate the array

% Remove any .mat references and replace with a single space. 
f_Text1 = strrep(f_Text1,'.mat', '');

% ========================================================================
% Recover the name of the source .OFF file.  Use this in making plot title
% and the name of an associated .png file.

% Indexes where the specific words 'sec' or 'proj' are foound
% within the title string
sec_location_within_title           = strfind(f_Text1,'sec');
proj_location_within_title          = strfind(f_Text1,'proj');
if_sec_is_found_in_title_string     = ~isempty(sec_location_within_title);
if_proj_is_found_in_title_string    = ~isempty(proj_location_within_title);

% If found, then remove them and following characters.
if if_sec_is_found_in_title_string == true
    SourceFile = f_Text1(1:sec_location_within_title-2);
elseif if_proj_is_found_in_title_string == true
    SourceFile = f_Text1(1:proj_location_within_title-2);
end

% Define the names of the .plt, .pdf files.
if f_Mode == 1
    FTxt0 = 'Plane of Projection Model Results';
    FTxt6 = '_PofProj.plt';
    FTxt8 = '_PofProj.pdf'; 
%     FTxt6 = '.plt';
%     FTxt8 = '.pdf'; 
else % f_Mode ==2
    FTxt0 = 'Plane of Section Model Results';
    FTxt6 = '_PofSect.plt';
    FTxt8 = '_PofSect.pdf';
%     FTxt6 = '.plt';
%     FTxt8 = '.pdf'; 
end

pltFileName = [f_Text1,FTxt6];
pltFileName = strrep(pltFileName,' ', '_');
fileID    = fopen(fullfile(outputDirectory,pltFileName),'w');

pdfFileName = [f_Text1,FTxt8];
pdfFileName = strrep(pdfFileName,' ', '_');


TLine = 0;
LLine = 0;
TLine = TLine+1;
Ftxt{TLine}  = '# - - - - - Introduction - - -  - - - - - - - - - - - - - - - - ';
TLine = TLine+1;
Ftxt{TLine}  = ['# ',FTxt0,'For the solid ',f_Text1];
TLine = TLine+1;
Ftxt{TLine}  = '# Graph Relative Frequency of Aspect Ratio vs Heywood Factor using gnuplot.';
TLine = TLine+1;
Ftxt{TLine}  = '# This script designed by Doug Rickman, Jan 30, 2014, mod: July 3, 2014';
TLine = TLine+1;
Ftxt{TLine}  = '# set terminal pdf enhanced dashed dl 3 size 7,7 ';            % This is included to make it easier for others to use this command file.
TLine = TLine+1;
Ftxt{TLine}  = 'set terminal pdfcairo enhanced color dashed dashlength 3 size 7,7   # The size affects the dimensions of the plot.';

TLine = TLine+1;
Ftxt{TLine}  = ' ';  % Insert a blank line in the .PLT file.
TLine = TLine+1;
Ftxt{TLine}  =  '# - - - - - Define Macro Terms. Set Input and Output Files - -  ';
TLine = TLine+1;
Ftxt{TLine}  =  'set macros';
TLine = TLine+1;
Ftxt{TLine}  =  'dquote    = ''"''';
TLine = TLine+1;
% Ftxt{TLine}  =  'path1     = "/Users/doug2/Documents/"';
% TLine = TLine+1;
% Ftxt{TLine}  =  'path2     = "MATLAB/"';
Ftxt{TLine}  =  sprintf('path1     = "%s"',outputDirectory);
TLine = TLine+1;
Ftxt{TLine}  = ['outfile   = "',pdfFileName,'"'];
TLine = TLine+1;
Ftxt{TLine}  = ['infile    = "',f_TxtFile,'"'];

TLine = TLine+1;
Ftxt{TLine}  = ['imagefile = "',SourceFile,'.png','"'];

TLine = TLine+1;
Ftxt{TLine} = 'set output @dquote@path1@outfile@dquote';

TLine = TLine+1;
Ftxt{TLine}  = ' ';  % Insert a blank line in the .PLT file.
TLine = TLine+1;
Ftxt{TLine}  = '# - - - - - Define Line Styles -- - - - - - - - - - - - - - - -  ';
TLine = TLine+1;
Ftxt{TLine}= 'set style line 1  lt 0  lw 3  lc rgbcolor ''black''   # dot';
TLine = TLine+1;
Ftxt{TLine}= 'set style line 2  lt 1  lw 3  lc rgbcolor ''black''   # solid';
TLine = TLine+1;
Ftxt{TLine}= 'set style line 3  lt 2  lw 10 lc rgbcolor ''grey70''  # long dash';
TLine = TLine+1;
Ftxt{TLine}= 'set style line 4  lt 3  lw 10 lc rgbcolor ''grey50''  # short dash';
TLine = TLine+1;
Ftxt{TLine}= 'set style line 5  lt 4  lw 3  lc rgbcolor ''black''   # long short long short';
TLine = TLine+1;
Ftxt{TLine}= 'set style line 6  lt 5  lw 3  lc rgbcolor ''black''   # long short short long';
TLine = TLine+1;
Ftxt{TLine}= 'set style line 13 lt 2  lw 12 lc rgbcolor ''black''   # long dash';
TLine = TLine+1;
Ftxt{TLine}= 'set style line 14 lt 3  lw 11 lc rgbcolor ''black''   # short dash';

TLine = TLine+1;
Ftxt{TLine}  = ' ';  % Insert a blank line in the .PLT file.
TLine = TLine+1;
Ftxt{TLine}  = '# - - - - - Set General Controls - - - - - - - - - - - - - - -  ';
TLine = TLine+1;
Ftxt{TLine}= 'set grid                        # grid and cntrparam are used with contours';
TLine = TLine+1;
Ftxt{TLine}= 'set cntrparam bspline';
TLine = TLine+1;
Ftxt{TLine}= 'set cntrparam order 10';

TLine = TLine+1;
Ftxt{TLine}= 'set view equal xyz              # View establishes the orientation and visual geometry of the plot';
TLine = TLine+1;
Ftxt{TLine}= 'set view 0,0,1.5,1              # This affects the dimensions of the plot.';
TLine = TLine+1;
Ftxt{TLine}= 'unset xlabel                    # Remove any existing X, Y, Z axes labels';      
TLine = TLine+1;
Ftxt{TLine}= 'unset ylabel';      
TLine = TLine+1;
Ftxt{TLine}= 'unset zlabel';
TLine = TLine+1;
Ftxt{TLine}= 'unset key                       # Do not display a key';
TLine = TLine+1;
Ftxt{TLine}= 'unset zrange                    # Free the range of Z values';
TLine = TLine+1;
Ftxt{TLine}= 'unset colorbox                  # Turn off the color box';
TLine = TLine+1;
Ftxt{TLine}= 'set xrange [0:1]                # Set the X range of the plot';
TLine = TLine+1;
Ftxt{TLine}= 'set yrange [0:1]                # Set the Y range of the plot';
TLine = TLine+1;
Ftxt{TLine}= 'set zrange [0:100]              # Set the Z range of the plot';
TLine = TLine+1;
Ftxt{TLine}= 'unset ztics                     # Turn off tics on the Z axis';
TLine = TLine+1;
Ftxt{TLine}= 'set mxtics 2                    # Define minor tics frequency on X axis';
TLine = TLine+1;
Ftxt{TLine}= 'set mytics 2                    # Define minor tics frequency on Y axis';
TLine = TLine+1;
Ftxt{TLine}= 'set multiplot                   # Allow multiple plots in the same space';
TLine = TLine+1;
Ftxt{TLine}= 'set size 0.95, 0.95             # Set the size of the plot';
TLine = TLine+1;
Ftxt{TLine}= 'set origin 0.0, 0.01            # Set the starting location of the plot';

TLine = TLine+1;
Ftxt{TLine}  = ' ';  % Insert a blank line in the .PLT file.
TLine = TLine+1;
Ftxt{TLine}  = '# - - - - - Define the Labels - - - - - - - - - - - - - - - - -  ';
% =========================================================================
% Create the plot's title. If the title is greater than 40 characters in 
% length it is split it in half, making an upper and lower line. 
% Otherwise, use it as is. 
if  (length(SourceFile) > 40)
    Title  = {SourceFile(1:40);SourceFile(41:end)};
    TLine = TLine+1;
    LLine = LLine+1;
    Ftxt{TLine}= ['set label ',num2str(LLine),' ''',Title{1},'''            font ''Helvetica,30'' at  0.5 ,  1.10 , 0 center'];
    TLine = TLine+1;
    LLine = LLine+1;
    Ftxt{TLine}= ['set label ',num2str(LLine),' ''',Title{2},'''            font ''Helvetica,30'' at  0.5 ,  1.04 , 0 center'];
else
    TLine = TLine+1;
    LLine = LLine+1;
    Ftxt{TLine}= ['set label ',num2str(LLine),' ''',SourceFile,'''            font ''Helvetica,30'' at  0.5 ,  1.1 , 0 center'];
end

% Create the Number of Points and the Bin Size labels
TLine = TLine+1;
LLine = LLine+1;
Ftxt{TLine}= ['set label ',num2str(LLine),' ''n Total   {\\011}= ',num2str(f_NPoints),'''           font ''Helvetica,20'' at  0.15,  0.28 , 0']; % Note escaping of \\ to insert a tab
TLine = TLine+1;
LLine = LLine+1;
Ftxt{TLine}= ['set label ',num2str(LLine),' ''Bin Size  {\\011}= ',num2str(f_BinInterval),'''       font ''Helvetica,17'' at  0.15,  0.23']; % Note escaping of \\ to insert a tab

% Create the Number of Normals and the Number of Slices if this is for Plane of Section.
if f_Mode == 2 % Add labels for number of surface normals and number of slices.
TLine = TLine+1;
LLine = LLine+1;
Ftxt{TLine}= ['set label ',num2str(LLine),' ''N Normals{\\011}= ',num2str(NNormals),'''            font ''Helvetica,17'' at  0.15,  0.19'];
TLine = TLine+1;
LLine = LLine+1;
Ftxt{TLine}= ['set label ',num2str(LLine),' ''N Slices  {\\011}= ',num2str(f_increment),'''         font ''Helvetica,17'' at  0.15,  0.15'];
end

% Create the X and Y axes labels
TLine = TLine+1;
LLine = LLine+1;
Ftxt{TLine}= ['set label ',num2str(LLine),' ''Aspect Ratio''                   font ''Helvetica,28'' at  0.5 ,  -0.09, 0 center'];
TLine = TLine+1;
LLine = LLine+1;
Ftxt{TLine}= ['set label ',num2str(LLine),' ''Heywood Factor''                 font ''Helvetica,28'' at -0.05 ,  0.5 , 0 center rotate by 90'];

% Create the "fine print" labels along the bottom of the plot
TLine = TLine+1;
LLine = LLine+1;
Ftxt{TLine}= ['set label ',num2str(LLine),' ''Normalized Frequency''           font ''Helvetica,12'' at screen 0.10,  0.02, 0 left'];
if f_minFraction ~=0
    TLine = TLine+1;
    LLine = LLine+1;
    Ftxt{TLine}= ['set label ',num2str(LLine),' ''Polygons < ',num2str(f_minFraction),' of max area dropped'' font ''Helvetica,12'' at screen 0.45,  0.02, 0 center'];
else
    TLine = TLine+1;
    LLine = LLine+1;
    Ftxt{TLine}= ['set label ',num2str(LLine),' ''All polygons kept regardless of size'' font ''Helvetica,12'' at screen 0.45,  0.02, 0 center'];   
end
TLine = TLine+1;
LLine = LLine+1;
Ftxt{TLine}= ['set label ',num2str(LLine),' ''',FTxt0,''' font ''Helvetica,12'' at screen 0.64,  0.02, 0 left']; % Plane of Section or Plane of Projection

TLine = TLine+1;
Ftxt{TLine}  = ' ';  % Insert a blank line in the .PLT file.
TLine = TLine+1;
Ftxt{TLine}= '# - Create grid lines and tics every 0.2 intervals on both axes -  ';
TLine = TLine+1;
Ftxt{TLine}= 'set xtics 0.2 format "%%.1f" font ''Helvetica,20'' offset -0.35,-0.3'; % Note the escaping of %
TLine = TLine+1;
Ftxt{TLine}= 'set ytics 0.2 format "%%.1f" font ''Helvetica,20'' offset -0.35,-0.3'; % Note the escaping of %

TLine = TLine+1;
Ftxt{TLine}  = ' ';  % Insert a blank line in the .PLT file.
TLine = TLine+1;
Ftxt{TLine}= 'set surface                     # Show the data as a surface';      
TLine = TLine+1;
Ftxt{TLine}= 'unset contour                   # Do not show the data as contours';

TLine = TLine+1;
Ftxt{TLine}  = ' ';  % Insert a blank line in the .PLT file.
TLine = TLine+1;
Ftxt{TLine}= '# - - - - - Choose Which Data To Plot And How - - - - - - - - - -  ';
TLine = TLine+1;
Ftxt{TLine}= '# - Later Plots Overwrite Earlier Plots BUT DO NOT ERASE THEM - -  ';
TLine = TLine+1;
Ftxt{TLine}= '# - -  - Plots may be reordered by changing their sequence. - - -  ';

TLine = TLine+1;
Ftxt{TLine}  = ' ';  % Insert a blank line in the .PLT file.
TLine = TLine+1;
Ftxt{TLine}= '# To plot the individual data points turn on the following line. ';
TLine = TLine+1;
Ftxt{TLine}= '# splot @dquote@path1@infile@dquote  index 5 using 1:2:3 with points pointtype 7 lc rgbcolor ''dark-green''  pointsize 0.2 # filled circles';

TLine = TLine+1;
Ftxt{TLine}  = ' ';  % Insert a blank line in the .PLT file.
TLine = TLine+1;
Ftxt{TLine}= '# In the 95, 75 and 50%% plots, the data are plotted twice, to create an outline effect.';
TLine = TLine+1;
Ftxt{TLine}= '# The bins are plotted as points using a hollow square symbol!!!';
TLine = TLine+1;
Ftxt{TLine}= '# The point size of each of a pair of plots is scaled to match the bin size used and the dimensions of the plot.';
TLine = TLine+1;
Ftxt{TLine}= '# The first plot of a pair is larger and creates an black outline effect for the data cloud.';
TLine = TLine+1;
Ftxt{TLine}= '# The plotted symbols are shifted so they align graphically on the bins in the plot.';
TLine = TLine+1;
Ftxt{TLine}= '# If something changes the dimensions of the plot, the size of the symbols must be changed.';

pointsize_outer = (f_BinInterval/0.01)*0.78;
pointsize_inner = (f_BinInterval/0.01)*0.60;

TLine = TLine+1;
Ftxt{TLine}  = ' ';  % Insert a blank line in the .PLT file.
TLine = TLine+1;
Ftxt{TLine}= '# To plot the bins containing 95%% of the data.';
TLine = TLine+1;
Ftxt{TLine}= ['splot @dquote@path1@infile@dquote  index 2 using ($1+',num2str(f_BinInterval/2),'):($2+',num2str(f_BinInterval/2),'):($3) with points pointtype 5 lc rgbcolor ''black''  pointsize ',num2str(pointsize_outer),'    # Hollow squares, used to outline'];
TLine = TLine+1;
Ftxt{TLine}= ['splot @dquote@path1@infile@dquote  index 2 using ($1+',num2str(f_BinInterval/2),'):($2+',num2str(f_BinInterval/2),'):($3) with points pointtype 5 lc rgbcolor ''lemonchiffon''  pointsize ',num2str(pointsize_inner),'    # solid squares'];

TLine = TLine+1;
Ftxt{TLine}  = ' ';  % Insert a blank line in the .PLT file.
TLine = TLine+1;
Ftxt{TLine}= '# To plot the bins containing 75%% of the data';
TLine = TLine+1;
Ftxt{TLine}= ['splot @dquote@path1@infile@dquote  index 3 using ($1+',num2str(f_BinInterval/2),'):($2+',num2str(f_BinInterval/2),'):($3) with points pointtype 5 lc rgbcolor ''royalblue''  pointsize ',num2str(pointsize_outer),' # solid squares'];
TLine = TLine+1;
Ftxt{TLine}= ['splot @dquote@path1@infile@dquote  index 3 using ($1+',num2str(f_BinInterval/2),'):($2+',num2str(f_BinInterval/2),'):($3) with points pointtype 5 lc rgbcolor ''grey60''  pointsize ',num2str(pointsize_inner),' # solid squares'];

TLine = TLine+1;
Ftxt{TLine}  = ' ';  % Insert a blank line in the .PLT file.
TLine = TLine+1;
Ftxt{TLine}= '# To plot the bins containing 50%% of the data';
TLine = TLine+1;
Ftxt{TLine}= ['splot @dquote@path1@infile@dquote  index 4 using ($1+',num2str(f_BinInterval/2),'):($2+',num2str(f_BinInterval/2),'):($3) with points pointtype 5 lc rgbcolor ''light-red''  pointsize ',num2str(pointsize_outer),' # solid squares'];
TLine = TLine+1;
Ftxt{TLine}= ['splot @dquote@path1@infile@dquote  index 4 using ($1+',num2str(f_BinInterval/2),'):($2+',num2str(f_BinInterval/2),'):($3) with points pointtype 5 lc rgbcolor ''grey20''  pointsize ',num2str(pointsize_inner),' # solid squares'];

TLine = TLine+1;
Ftxt{TLine}  = ' ';  % Insert a blank line in the .PLT file.
TLine = TLine+1;
Ftxt{TLine}= '# To plot the binned data as contours turn on the following 9 lines. ';
TLine = TLine+1;
Ftxt{TLine}= '# unset surface';
TLine = TLine+1;
Ftxt{TLine}= '# set contour'; 
CI     = (f_FreqData(1)-f_FreqData(2))/5;                                 % Determine the contour interval
FTxtCI = [num2str(f_FreqData(2),3),', ',num2str(CI,3),', ',num2str(f_FreqData(1),3)];
TLine = TLine+1;
Ftxt{TLine}= ['# set cntrparam levels incremental ',FTxtCI];
TLine = TLine+1;
Ftxt{TLine}= ['# set cbrange [0.0:',num2str(f_FreqData(1)),']'];
TLine = TLine+1;
Ftxt{TLine}= '# set palette defined (  0 "black", 0.1 "black", 0.1 "dark-magenta", 1 "blue", 2 "forest-green", 3 "orange", 4 "red", 5 "black")';
LLine = LLine+1;
Ftxt{TLine}= ['# set label ',num2str(LLine),' ''Contour (B,I,E)= ',FTxtCI,'''   font ''Helvetica,17'' at  0.15,  0.06']; % Note escaping of \\ to insert a tab
TLine = TLine+1;
Ftxt{TLine}= ['# splot @dquote@path1@infile@dquote  index 1 using ($1+',num2str(f_BinInterval/2),'):($2+',num2str(f_BinInterval/2),'):($3) w l lw 3 palette'];
TLine = TLine+1;
Ftxt{TLine}= '# set surface';
TLine = TLine+1;
Ftxt{TLine}= '# unset contour';

TLine = TLine+1;
Ftxt{TLine}  = ' ';  % Insert a blank line in the .PLT file.
TLine = TLine+1;
Ftxt{TLine}= '# To plot the normalized, binned data as a greyscale or a colored surface first turn on 1 of the following 2 lines.';
TLine = TLine+1;
Ftxt{TLine}= '# set palette defined (  0 "white", 0.1 "grey", 5 "black")   # Use this line for a greyscale plot.';
TLine = TLine+1;
Ftxt{TLine}= '# set palette defined (  0 "white", 0.1 "light-magenta", 0.1 "dark-magenta", 1 "blue", 2 "forest-green", 3 "orange", 4 "red", 5 "black") # Use this line for colored plot.';
TLine = TLine+1;
Ftxt{TLine}= '# Second, turn on the  turn on the following 5 lines. ';
TLine = TLine+1;
Ftxt{TLine}= '# set colorbox horizontal user origin 0.18,0.17 size 0.28,0.03';
TLine = TLine+1;
cbrangeMax = f_FreqData(1)*1.05;
cbticInt   = cbrangeMax/4;
Ftxt{TLine}= ['# set cbrange [0.0:',num2str(cbrangeMax),']']; 
TLine = TLine+1;
Ftxt{TLine}= ['# set cbtics ',num2str(cbticInt),' format "%%.3f" # Adjust the tic interval from 0.002 as needed']; % Note the escaping of %
TLine = TLine+1;
Ftxt{TLine}= ['# splot @dquote@path1@infile@dquote  index 1 using ($1+',num2str(f_BinInterval/2),'):($2+',num2str(f_BinInterval/2),'):($3>0.00000 ? $3 : NaN) with points pointtype 5 lc rgbcolor "black"  pointsize ',num2str(pointsize_outer)];  % 0.88
TLine = TLine+1;
Ftxt{TLine}= ['# splot @dquote@path1@infile@dquote  index 1 using ($1+',num2str(f_BinInterval/2),'):($2+',num2str(f_BinInterval/2),'):($3>0.00000 ? $3 : NaN) with points pointtype 5 palette  pointsize ',num2str(pointsize_inner)];  % 0.68


TLine = TLine+1;
Ftxt{TLine}  = ' ';  % Insert a blank line in the .PLT file.
TLine = TLine+1;
Ftxt{TLine}= '# - - - - - Do the Ellipse, Rectange and Triangle Lines - -  - -  ';
TLine = TLine+1;
Ftxt{TLine}= '# To plot the lines for ellipses, rectangles and triangles turn on the following lines. ';
TLine = TLine+1;
Ftxt{TLine}= 'set format xy""';
TLine = TLine+1;
Ftxt{TLine}= 'set xtics 0.1';
TLine = TLine+1;
Ftxt{TLine}= 'set ytics 0.1';
TLine = TLine+1;
Ftxt{TLine}= 'splot @dquote@path1@infile@dquote   index 0 using 1:2:7 w l ls 2  # Ellipse';
TLine = TLine+1;
Ftxt{TLine}= 'splot @dquote@path1@infile@dquote   index 0 using 3:4:7 w l ls 13 # Rectangle';
TLine = TLine+1;
Ftxt{TLine}= 'splot @dquote@path1@infile@dquote   index 0 using 3:4:7 w l ls 3  # Rectangle';
TLine = TLine+1;
Ftxt{TLine}= 'splot @dquote@path1@infile@dquote   index 0 using 5:6:7 w l ls 14 # Isoceles triangle';
TLine = TLine+1;
Ftxt{TLine}= 'splot @dquote@path1@infile@dquote   index 0 using 5:6:7 w l ls 4  # Isoceles triangle';

TLine = TLine+1;
Ftxt{TLine}  = ' ';  % Insert a blank line in the .PLT file.
TLine = TLine+1;
Ftxt{TLine}= '# - - - - - Insert an image into the plot - - - - - - -- -  - -  ';
TLine = TLine+1;
Ftxt{TLine}= '# Only .JPG and .PNG files may be used. ';
TLine = TLine+1;
Ftxt{TLine}= '# The image is assumed to be approximately 1000 pixels wide by approx. 800 pixels high.';
TLine = TLine+1;
Ftxt{TLine}= '# Edit the path and file name at the start of this script.';
TLine = TLine+1;
Ftxt{TLine}= '# To insert the image, uncomment the next four lines.';
TLine = TLine+1;
Ftxt{TLine}= '# set style rectangle back fc rgb "white" fs solid border';
TLine = TLine+1;
Ftxt{TLine}= '# set object 101 rectangle from screen 0.48, 0.2, 0 to screen 0.78, 0.45, 0';
TLine = TLine+1;
Ftxt{TLine}= '# set cbrange [*:*]';
TLine = TLine+1;
Ftxt{TLine}= '# splot @dquote@path1@imagefile@dquote binary filetype=auto origin=(0.48,0.1,0) dx=0.0005 dy=0.0005 with rgbimage';
TLine = TLine+1;

TLine = TLine+1;
Ftxt{TLine}  = ' ';  % Insert a blank line in the .PLT file.
TLine = TLine+1;
Ftxt{TLine}= 'unset multiplot                  # This causes all of the plots defined above to be rendered into the output file.';
TLine = TLine+1;
Ftxt{TLine}= 'exit';

% Write all of the lines created so far.
for i = 1:TLine;
    fprintf(fileID,[Ftxt{i},'\n']);
end
fclose(fileID);

end

