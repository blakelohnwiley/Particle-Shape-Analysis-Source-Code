function fig = Graph_AspectRatio_vs_HeywoodFactor(Text1,f_NPoints,f_increment,f_BinInterval,arhf)
%GRAPH_ASPECTRATIO_VS_HEYWOODFACTOR Generates Aspect Ratio vs Heywood Factor graph
%   This replicates the concept in Hull and Houk, 1953, Figure 10.
%
%   Code based on Plane_ofSection code written by Blake Lohn-Wiley, summer 2013.
%   Function created by D. Rickman, Jan 22, 2014

fig = input('Enter an integer for the 1st graph''s window: ');
if ishandle(fig) % If the window exists close it.
  close(fig)
end

Text = ['Binning Interval = ', num2str(f_BinInterval)];
Text2 = ['Number of Surface Normals : ',num2str(f_NPoints)];
Text3 = ['Slice Spacing : ', num2str(f_increment)];
Text8 = 'Heywood Factor versus Aspect Ratio for a ';

figure(fig)
hold on

axis([0 1 0 1]);
axis square;
set(gca,'FontWeight','bold','FontSize',14);
title({Text8;Text1;[Text3,'    ',Text2];Text});
xlabel('Aspect Ratio');
ylabel('Heywood Factor');

grid on

ARHF_ellipse = ARHF_Ellipse();
plot(ARHF_ellipse(:,1),ARHF_ellipse(:,2),'k-')

ARHF_rectangle = ARHF_Rectangle();
plot(ARHF_rectangle(:,1),ARHF_rectangle(:,2),'m-')

ARHF_triangle = ARHF_Triangle(  );
plot(ARHF_triangle(:,1),ARHF_triangle(:,2),'b:.','LineWidth',2)

plot(arhf(:,1),arhf(:,2),'ro','Markersize',3.0)

hold off

