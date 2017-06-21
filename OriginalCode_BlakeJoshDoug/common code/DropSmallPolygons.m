function [ f_poly2,f_Area,f_Perm,f_HF ] = DropSmallPolygons(f_minFraction,f_poly2,f_Area,f_Perm,f_HF )
%DROPSMALLPOLYGONS Drop polygons smaller than specified fraction of the maximum polygon.
% Delete all polygons with size less than X% of maximum polygon.  This
% partially addresses the effect of pixelation in real measurements, where
% particles that are too small are ignored.
%
% Doug Rickman, Jan 31, 2014

minArea = max(f_Area)*f_minFraction; % Smallest area fraction of maximum area that will be retained.

AreaSorted = sort(f_Area,'descend');
NPolygons = find(AreaSorted < minArea,1,'first') - 1;

% Preallocate arrays
poly2Temp{NPolygons}         = 0;
PermTemp(NPolygons)          = 0;
AreaTemp(NPolygons)          = 0;
HFTemp(NPolygons)            = 0;

j = 0;
for i=1:length(f_poly2)
    if f_Area(i) >= minArea
        j=j+1;
        poly2Temp{j}         = f_poly2{i};
        PermTemp(j)          = f_Perm(i);
        AreaTemp(j)          = f_Area(i);
        HFTemp(j)            = f_HF(i);
    end
end

% disp(['Max polygon area, minArea = ',num2str(AreaSorted(1)),' , ',num2str(minArea)]);
% disp(['NPolygons, j = ',num2str(NPolygons),' , ',num2str(j)]);

clear f_poly2;
clear f_Perm;
clear f_Area;
clear f_HF;

f_poly2         = poly2Temp;
f_Perm          = PermTemp;
f_Area          = AreaTemp;
f_HF            = HFTemp;

clear poly2Temp;
clear PermTemp;
clear AreaTemp;
clear HFTemp;
end