function Graph_Perimeter_vs_Area(Text1,f_NPoints,f_increment,FigureN,perm,area)
%GRAPH_PERIMETER_VS_AREA Generates a 'Number of Sides on Intersection Polygon' graph
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

Text9 =  'Perimeter of the cross-sections';
Text10 =  'Area of the cross-sections';
Text11 =  'Perimeter versus Area for a ';
scatter(perm,area)
xlabel(Text9)
ylabel(Text10)
title({[Text11,Text1];[Text3,'    ',Text2]})
grid on
