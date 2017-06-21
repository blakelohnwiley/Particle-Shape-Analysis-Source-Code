function Graph_Contour_Binned(Text1,f_NPoints,f_increment,f_BinInterval,FigureN,x,y,BinnedNormalizedCounts)
%GRAPH_CONTOUR_BINNED Generates a contoured binned data graph
%
%   Code based on Plane_ofSection code written by Blake Lohn-Wiley and Josh Knicely, summer 2013.
%   Function created by D. Rickman, Jan 22, 2014

% If the window exists close it.
if ishandle(FigureN)
   close(FigureN)
end

figure(FigureN)
hold on

Text = ['Binning Interval = ', num2str(f_BinInterval)];
Text2 = ['Number of Surface Normals : ',num2str(f_NPoints)];
Text3 = ['Slice Spacing : ', num2str(f_increment)];
Text4 =  'Frequency of Ocurrence for an ';

title({[Text4,Text1];[Text3,'    ',Text2];[Text]})
contour(x,y,BinnedNormalizedCounts,[0:0.05:1])

ARHF_ellipse = ARHF_Ellipse();
plot(ARHF_ellipse(:,1),ARHF_ellipse(:,2),'k-')

ARHF_rectangle = ARHF_Rectangle();
plot(ARHF_rectangle(:,1),ARHF_rectangle(:,2),'m-')

ARHF_triangle = ARHF_Triangle(  );
plot(ARHF_triangle(:,1),ARHF_triangle(:,2),'b:.','LineWidth',2)

axis square
grid on
hold off
