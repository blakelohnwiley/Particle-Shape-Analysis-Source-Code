% Algorithm Description
% N points are uniformly (approximately) distributed on the surface of a sphere centered at the origin.  
% Each point, with the origin, (0,0,0), defines a normal to plane, P.  
% 
% The user specified solid is allocated and shifted to have its center of mass at (0,0,0). 
% 
% The plane P is repeatedly advanced along each normal by distance 1/increment, where increment is a user 
% specified value.  At each slice the plane - soid intersection is found.  The area and Heywood
% factor are computed for all polygons.  Then DropSmallPolygons() is used to drop polygons with area 
% smaller than minFraction of the maximum polygon area.  For retained polygons aspect ratio is computed.
% Note, the slicing logic means a needle shaped solid will have many slices on one axis and few on two axis.
% A plate shaped solid will have many slices on two axes and few on one axis.
%
% Heywood factor and aspect ratio for each polygon is binned.  The binned data, bins which cumulatively
% have more than 95% and 50% and the HF and AR values for each polygon are written to a file.  A script 
% file to run gnuplot and the output file is created. both files are written to the MATLAB directory.
%
% Original author Blake Lohn-Wiley, summer 2013.
% Edits by D.Rickman and Blake Lohn-Wiley Dec-Feb, 2014.

% DLR, Feb 14, 2014 - For some reason the data plotted in graph 2 is rotated.  I
% don't know why and don't have time to fix it, or care, as the main output
% is now to gnuplot. 
%
% Figures 2 - 5 are turned off and on below.  
%    Fig 2 - contoured abundance of Aspect Ration vs Heywood factor
%    Fig 3 - 'Periemter Versus Area' graph
%    Fig 4 - 'Number of Sides on Plane Section' graph
%    Fig 5 - 'Intersection Polygon Area vs. Max. Possible Area' graph

clear all

%% Hard coded variables
minFraction = 0.05; % Polygons with an area smaller than this fraction of the maximum polygon area are deleted.
                    % Set to 0 to keep all polygons.
BinInterval = 0.01; % This is the interval used for binning the aspect ratio and Heywood factor data.
FigureN     = 1   ; % Default number for first graph.  This can be overridden in Graph_AspectRatio_vs_HeywoodFactor().
Graph1      = 0   ; % if Graph1 = 1 then the Aspect Ratio vs. Heywood Factor plot is made.
Graph2      = 0   ; % if Graph2 = 1 then the binned AR vs. Heywood data are plotted as contours.
Graph3      = 0   ; % if Graph3 = 1 then the perimeter vs. area plot is made.
Graph4      = 0   ; % if Graph4 = 1 then the number of sides histogram is made.
Graph5      = 0   ; % if Graph5 = 1 then the area/maxArea histogram is made.

%% Begin user interaction
% Prompts for slice spacing increment.  
increment = input('Enter the maximum number of slices per normal (an integer number)?  ');
disp(' ')

% Prompt for number of Surface Normals, NPoints.
NPoints = input('How many surface normals would you like to generate?  ');
disp(' ')
[x,y,z] = PointsOnSphere(NPoints);

% Get the solid
[v,e,f, Text1] = UserShapeSelection( );

%% Begin Modeling

N_p = [ x y z ];                               % N_p contains all the Euclidean coordinates in triplets of (x,y,z)
plane=createPlane([10^-14 10^-14 10^-14],N_p); % For each surface normal create a plane through the origin

% Find the solid's center of mass; then translate it to (0,0,0).  This
% logic only works for shapes that are symetric through the origin.
X = mean(v(:,1));
Y = mean(v(:,2));
Z = mean(v(:,3));
centroid = [ X Y Z ]; 
% subtracts 'distance' points are from center to translate the shape to the origin
for i = 1:size(v,1)
    v(i,:) = v(i,:) - centroid; 
end

%% Setup the slice spacing
% Find the maximum distance between the solid's vertices.  A symmetric solid with a convex hull is presumed. 
% The maximum distance along a single normal is 1/2 the maximum distance between two vertices.
%
% The spacing of slices is computed by dividing 1/2 of the maximum distance
% by the users specified number of normals. This spacing is used for all normals.
% Note, the two extreme points of the solid will not be intersected unless the points are a multiple of 
% approximatly 0.000000001 units from the centroid.  This avoids the artifact of a
% highly improbable event, specifically the intersection of a plane with a point, from happening in all cases.
% 
d = zeros(length(v),length(v)); % Preallocate memory
for i=1:length(v)
    for j=1:length(v)
        d(i,j) = distancePoints3d(v(i,:),v(j,:));
    end
end
Max_Distance = max(d(:));
Max_Distance = (Max_Distance/2) + 0.000000001;
SliceSpacing = Max_Distance/increment;

tic % starts the timer

%% Intersect slices with solid to obtain intersection polygon
% Preallocate memory for the following variables 
indices = 0:SliceSpacing:Max_Distance; % Make a column vector using "Npoints" times "indices". 
NumberofPossibleRows = NPoints*length(indices);
poly2   = cell(NumberofPossibleRows,1);
counter = zeros(NumberofPossibleRows,2);
index   = zeros(NumberofPossibleRows,2);
plane3  = zeros(NPoints,9);

% For each surface normal create normal planes spaced SliceSpacing apart. 
% For each plane obtain the plane - solid intersection. 
for j=1:NPoints
    plane1=plane(j,:);
    for k=1:length(indices)
        % Based on the slice distance generate a plane that is parallel to the previous one. 
        plane2=parallelPlane(plane1,indices(k));
        % plane3 captures all of the parallel planes produced
        plane3=vertcat(plane3,plane2);
        % poly1 stores the vertices for the intersection of the plane and the solid.
        poly1=intersectPlaneMesh(plane2,v,f);
        % poly2 vertically concatenates the vertices generated from the plane and the shape.
        poly2=vertcat(poly2,poly1);
        % s records the size of each intersection
        s = size(poly2,1);
        % index associates which planes, and what size the intersection that was generated. 
        index = [j s];
        % vertically concatenate each output so it can be used for troubling shooting. 
        counter = vertcat(counter,index);
    end
end

% Delete rows with any empty cells
poly2(any(cellfun(@isempty,poly2),2),:) = [];
% Removes the unneeded values from counter, otherwise the program blows up. 
counter=snip(counter,'0');

%% Calculate the Perimeter and Area and Heywood Factor
% Preallocated memory for the following variables
NumberOfRows = length(poly2);
m    = zeros(NumberOfRows,1);
Perm = zeros(NumberOfRows,1);
Area = zeros(NumberOfRows,1);
HF   = zeros(NumberOfRows,1);
for i=1:length(poly2)
    rec           = poly2{i};
    m(i)          = size(rec,1);
    rec(size(rec,1)+1,:) = rec(1,:);
    xcoordinates  = rec(:,1);
    ycoordinates  = rec(:,2);
    zcoordinates  = rec(:,3);
    Perm(i)       = perimetr(xcoordinates,ycoordinates,zcoordinates);
    Area(i)       = polygonArea3d(rec);
    Radius        = sqrt(Area(i)/pi);
    Circumference = 2*pi*Radius;
    HF(i)         = Circumference/Perm(i);
end

if minFraction ~= 0
    % Drop polygons smaller than cut off fraction.
    [poly2,Area,Perm,HF] = DropSmallPolygons(minFraction,poly2,Area,Perm,HF);
end

NumberOfRows = length(poly2);

%% Calculate the maximum Feret distance
% Preallocating memory for the variables
int1  = cell(NumberOfRows,1);
F_max = zeros(NumberOfRows,3);
for ii=1:length(poly2)
    Poly=poly2{ii};
    if isempty(Poly)==0
        Poly(size(Poly,1)+1,:) = Poly(1,:);
    end
    Feret_max=[ 0 NaN NaN ]; % initialize
    Q = size(Poly,1)-1;
    for j = 1:Q
        for k = 1:Q
            % Calculates the distance between points
            d_n = sqrt( (Poly(j,1)-Poly(k,1))^2 + (Poly(j,2)-Poly(k,2))^2 + (Poly(j,3)-Poly(k,3))^2); 
            % Store the maximum distance. 
            if d_n > Feret_max(1)
                Feret_max = [ d_n j k ]; 
                % i & j are indices in rec of the most distant vertices, ie if i=2 & j = 5,
                % then rec(2,:) & rec(5,:) are the most distant
            end
        end
    end
    
    int = NaN(0,3);
    F_max=vertcat(F_max,Feret_max);
    %     The purpose of these 5 'int'  is to remove the points used for
    %     the maximum feret diameter
    for j = 1:Q
        if j~=Feret_max(2) && j~=Feret_max(3)
            int = union(int,Poly(j,:),'rows');
            int1{ii}=int;
        end
    end
end

% Remove uneeded values from counter, otherwise the program blows up.
F_max=snip(F_max,'0');

%% Calculate the orthogonal Feret diameter and Aspect Ratio.
% Preallocating memory for the variables
AR  = zeros(NumberOfRows,1);

for ii=1:length(poly2)
    int=int1{ii};
    Poly = poly2{ii};
    Fmax = F_max(ii,:,:);
    L = size(int,1);
    p1 = Fmax(2);
    p2 = Fmax(3);
    P1 = Poly(p1,:);
    P2 = Poly(p2,:);
    m1 = P2 - P1; % creates the vector for the line of the maximum Feret
    % diameter. The normal (AKA cross product) of this with the normal to
    % the plane will give the normal for an imaginary plane that cuts the
    % points in half. Now that I have the imaginary plane, all of the
    % points above it get put into one group, and those below it into
    % another.
    k=counter(ii,1);
    N_p1=N_p(k,:);
    N_image = cross(N_p1, m1);
    
    above_s = zeros(1,2);
    below_s = zeros(1,2);
    
    for j = 1:L
        if (dot(N_image,(int(j,:)-P1)) > 0)
            % store the distance and the iteration of 'int' that it was obtained from.
            above = [distancePointLine3d(int(j,:), [P1 m1]) j];
            above_s = union(above_s,above,'rows'); 
        else
            below = [distancePointLine3d(int(j,:), [P1 m1]) j];
            below_s = union(below_s,below,'rows');
        end
    end
    
    % The following 2 lines retain only the maximum value above and below the line
    above = max(above_s(:,1));
    below = max(below_s(:,1));
    Feret_orthogonal = above(1)+below(1);
    AR(ii) = Feret_orthogonal/Fmax(1); % calculates the aspect ratio
    
end

time_arhf = toc;

%% Bin Aspect Ration and Heywood Factor data 
% Blake's Plane of Section code has AR and HF as row vectors.  The following needs column vectors.
AR   = AR(:);
HF   = HF(:);
Area = Area(:);
Perm = Perm(:);

arhf = [ AR HF ]; 

% Bin the Aspect Ratio and Heywood Factor data into frequency of occurrence bins
xBins  = ( 0 : BinInterval : 1 ); 
yBins  = ( 0 : BinInterval : 1 ); 
Nxbins = length(xBins);
Nybins = length(yBins);

% bins the data into the matrix BinnedRawCounts according to the edges x and y
BinnedRawCounts        = hist3(arhf,'Edges',{xBins yBins}); 
sumBinnedRawCounts     = sum(sum(BinnedRawCounts));   % Find the number of slice and solid intersections
BinnedNormalizedCounts = (BinnedRawCounts./sumBinnedRawCounts);

%% Make graphs as directed.
if Graph1 == 1
    FigureN = Graph_AspectRatio_vs_HeywoodFactor(Text1,NPoints,increment,BinInterval,arhf);
end
if Graph2 == 1 
    Graph_Contour_Binned(Text1,NPoints,increment,BinInterval,FigureN+1,xBins,yBins,BinnedNormalizedCounts)
end
if Graph3 == 1 
    Graph_Perimeter_vs_Area(Text1,NPoints,increment,FigureN+2,Perm,Area)
end
if Graph4 == 1 
    Graph_NSides_Histogram(Text1,NPoints,increment,FigureN+3,m)
end
if Graph5 == 1 
    Graph_Area_vs_MaxArea(Text1,NPoints,increment,FigureN+4,Area)
end

%% Output for gnuPLOT
[FreqData,CumFreqAtCI] = ContourLimits(Nxbins*Nybins,BinnedNormalizedCounts,sumBinnedRawCounts);

ElapsedTime = toc;
TxtFile = write_gnuPLOT_data(2,Text1,NPoints,increment,FreqData,CumFreqAtCI,minFraction, ...
                                sumBinnedRawCounts,Nxbins,Nybins,BinInterval, ...
                                BinnedNormalizedCounts,arhf,ElapsedTime);

write_gnuPLOT_file(2,TxtFile,Text1,sumBinnedRawCounts,FreqData,BinInterval,NPoints,increment,minFraction);


return