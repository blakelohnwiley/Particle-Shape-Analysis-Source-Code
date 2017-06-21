function Graph_NSides_Histogram(Text1,f_NPoints,f_increment,FigureN,m)
%GRAPH_NSIDES_HISTOGRAM Generates 'Number of Sides on Intersection Polygon' graph
%   This replicates the concept in Hull and Houk, 1953, Figure 6.
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
Text12 = 'Number of Sides on Plane of Section';
Text13 = 'Frequency';
Text14 = 'Number of sides on Plane of Section versus Freuency for a ';
[counts1, bins1] = hist(m(:));
bar(bins1, counts1);
grid on
title({[Text14,Text1];[Text3,'    ',Text2]})
xlabel(Text12);
ylabel(Text13);
hold off
