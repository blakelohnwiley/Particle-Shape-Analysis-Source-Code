function Graph_Area_vs_MaxArea(Text1,f_NPoints,f_increment,FigureN,area)
%GRAPH_AREA_VS_MAXAREA Generates 'Intersection Polygon Area vs. Max. Possible Area' graph
%   This replicates the concept in Hull and Houk, 1953, Figure 10.
%
%   Code based on Plane_ofSection code written by Blake Lohn-Wiley, summer 2013.
%   Function created by D. Rickman, Jan 22, 2014

% If the window exists close it.
if ishandle(FigureN)
   close(FigureN)
end

figure(FigureN)
hold on

Text2 = ['Number of Surface Normals : ',num2str(f_NPoints)];
Text3 = ['Slice Spacing : ', num2str(f_increment)];
Text15 = 'A/A_m';
Text16 = 'Frequency, F(A)';
Text17 = 'Plane distribution curve of areas for a '; 
Tarea = area;
Tmax = max(Tarea);
A = Tarea./Tmax;
[counts7, bins7] = hist(A,17);
bar(bins7,counts7)
grid on
xlabel(Text15);
ylabel(Text16);
title({[Text17,Text1];[Text3,'    ',Text2]})
hold off

