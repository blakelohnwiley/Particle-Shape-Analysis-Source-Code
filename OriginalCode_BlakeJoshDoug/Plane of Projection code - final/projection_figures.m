figure(1)
clf
plot(arhf(:,1),arhf(:,2),'k.','Markersize',0.5)
hold on
grid on
axis square
axis([0 1 0 1])
rec
ellipse_projection
xlabel('Aspect Ratio')
ylabel('Heywood Factor')
title({['Plane of Projection'];['Cube : Dataset'];['100000 Points']});
figure(2)
clf
title({['Plane of Projection'];['Cube : PDF'];['100000 Points']});
xlabel('Aspect Ratio')
ylabel('Heywood Factor')
hold on
grid on
axis square
axis([0 1 0 1])
rec
ellipse_projection
x = ( 0 : 0.01 : 1 ); % controls where N plots on the X axis, and the 'sizes' of the bin
y = ( 0 : 0.01 : 1 ); % controls where N plots on the Y axis, and the 'sizes' of the bin10000
N = hist3(arhf,'Edges',{x y}); 
N = transpose(N./100000);
contour(x,y,N,[0:0.005:1])