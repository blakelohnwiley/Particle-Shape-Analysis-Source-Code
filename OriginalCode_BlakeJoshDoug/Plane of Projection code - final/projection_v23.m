% Algorithm Description
% N points are uniformly (approximately) distributed on the surface of a sphere centered at the origin.  
% Each point, with the center, defines a normal to plane, P.  
% 
% The user specified solid is allocated and shifted to have its center of mass at (0,0,0). 
%
% The solid is orthogonally projected onto each plane.  
% The shape of the projection is evaluated for aspect ratio and Heywood factor.  
% 
% Heywood factor and aspect ratio for each polygon is binned.  The binned data, bins which cumulatively
% have more than 95% and 50% and the HF and AR values for each polygon are written to a file.  A script 
% file to run gnuplot and the output file is created. both files are written to the MATLAB directory.
%
% Original author Joshua Knicely, summer 2013.
% Edits by D. Rickman and Josh Knicely, Dec-Jan 2014.

clear all

%% Hard coded variables
BinInterval = 0.01; % This is the interval used for binning the aspect ratio and Heywood factor data.
FigureN     = 1   ; % Default number for first graph.  This can be overridden in Graph_AspectRatio_vs_HeywoodFactor().
Graph1      = 0   ; % if Graph1 = 1 then the Aspect Ratio vs. Heywood Factor plot is made.
Graph2      = 0   ; % if Graph2 = 1 then the binned AR vs. Heywood data are plotted as contours.

% These variables are used in the Plane_Of_Section code. They are kept here to maintain consistency.
minFraction = 0   ; 
increment   = 0   ;  

%% Begin user interaction
% Prompt for number of Surface Normals, NPoints.
NPoints = input('How many surface normals would you like to generate? '); 
disp(' ')
[x,y,z] = PointsOnSphere(NPoints);

% Get the solid
[v,e,f, Text1] = UserShapeSelection( );

%% Begin Modeling

origin_plane = [5*x 5*y 5*z];

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

tic % starts the timer

%% Calculate the solid's vertices projected onto the plane
HF = zeros(size(origin_plane,1),1); % Preallocate memory
AR = zeros(size(origin_plane,1),1); % Preallocate memory
    
for i = 1:size(origin_plane,1);
    % The following for loop calculates the projection of all the vertices
    % onto the plane. This is an orthographic projection.
    N_p = origin_plane(i,:); 
    P_proj = zeros(0,3); 
    for j = 1:size(v,1)
        u = dot(N_p,(origin_plane(i,:)-v(j,:))) / dot(N_p,N_p); 
        p = v(j,:) + N_p*u; 
        P_proj(j,:) = p;
    end
    
    % vert2lcon and lcon2vert keep the convex hull.
    tolerance = 1e-7; 
    [A,b,Aeq,beq] = vert2lcon(P_proj,tolerance); 
    Pr = lcon2vert(A,b,Aeq,beq); 
    
    % NOTE : if lcon2vert is messing up, it may be due to Aeq and beq being
    % empty. If this occurs, the tolerance is not high enough. vert2lcon
    % has a default of 1e-10, which causes Aeq and beq to be empty
    % matrices. For 10,000 normals, 1e-7 works and 1e-8 returns an error. 
    
    % This set of for and if loops is unnecessary, ie it does not change
    % the outcome by much, if at all
    for j = 1:size(Pr,1)
        for k = 1:size(Pr,2)
            if abs(Pr(j,k)) < 1e-10
                Pr(j,k)=0;
            end
        end
    end
    
    Poly = angleSort3d(Pr); % Order the points

    %% Calculate the Perimeter and Area and Heywood Factor
    Poly(size(Poly,1)+1,:) = Poly(1,:);
    C = size(Poly,1);
    p_poly = 0;
    Perm   = 0;
    for j = 1:C-1
        p_poly = sqrt( (Poly(j+1,1)-Poly(j,1))^2 + (Poly(j+1,2)-Poly(j,2))^2 + (Poly(j+1,3)-Poly(j,3))^2 ); % calculates the length of each edge
        Perm = Perm + p_poly; % adds up all the edges to get the perimeter of the polygon
    end
    
    Area          = polygonArea3d(Poly); % area of the polygon
    Radius        = sqrt(Area/pi);
    Circumference = 2*pi*Radius; 
    HF(i)         = Circumference/Perm; % calculates the Heywood Factor   
    
    %% Calculate the maximum Feret distance
    Feret_max=[ 0 NaN NaN ]; % initialize
    Q = size(Poly,1)-1;
    for j = 1:Q
        for k = 1:Q
            % Calculates the distance between points
            d_n = sqrt( (Poly(j,1)-Poly(k,1))^2 + (Poly(j,2)-Poly(k,2))^2 + (Poly(j,3)-Poly(k,3))^2); 
            % Store the maximum distance
            if d_n > Feret_max(1)
                Feret_max = [ d_n j k ];
                % i & j are indices in rec of the most distant vertices, ie if i=2 & j = 5,
                % then rec(2,:) & rec(5,:) are the most distant
            end
        end
    end

    % The purpose of these 5 'int' lines is to remove the points used for
    % the maximum feret diameter
    int = NaN(0,3);
    for j = 1:Q 
        if j~=Feret_max(2) && j~=Feret_max(3)
            int = union(int,Poly(j,:),'rows');
        end
    end
    
    %% Calculate the orthogonal Feret diameter and Aspect Ratio.
    L = size(int,1); 
    P1 = Poly(Feret_max(2),:);
    P2 = Poly(Feret_max(3),:);

    m = P2 - P1; % creates the vector for the line of the maximum Feret 
    % diameter. The normal (AKA cross product) of this with the normal to
    % the plane will give the normal for an imaginary plane that cuts the
    % points in half. Now that I have the imaginary plane, all of the
    % points above it get put into one group, and those below it into
    % another.

    N_imag = cross(N_p, m); 

    above_s = zeros(1,2);
    below_s = zeros(1,2); 

    for j = 1:L
        if (dot(N_imag,(int(j,:)-P1)) > 0)
            % store the distance and the iteration of 'int' that it was obtained from.
            above = [distancePointLine3d(int(j,:), [P1 m]) j];
            above_s = union(above_s,above,'rows');
        else
            below = [distancePointLine3d(int(j,:), [P1 m]) j];
            below_s = union(below_s,below,'rows');
        end
    end

    % The following 2 lines retain only the maximum value above and below the line
    above = max(above_s(:,1));
    below = max(below_s(:,1));
    Feret_orthogonal = above(1)+below(1); 
    AR(i) = Feret_orthogonal/Feret_max(1); % calculates the aspect ratio
end

time_arhf = toc;

%% Bin Aspect Ration and Heywood Factor data 
% The following uses column vectors
arhf = [ AR HF ];

% Bin the Aspect Ratio and Heywood Factor data into frequency of occurrence bins
xBins  = ( 0 : BinInterval : 1 ); 
yBins  = ( 0 : BinInterval : 1 ); 
Nxbins = length(xBins);
Nybins = length(yBins);

% bins the data into the matrix BinnedRawCounts according to the edges x and y
BinnedRawCounts = hist3(arhf,'Edges',{xBins yBins}); 
sumBinnedRawCounts     = sum(sum(BinnedRawCounts));  % This equals NPoints for Plane of Projection.
BinnedNormalizedCounts = (BinnedRawCounts./sumBinnedRawCounts);

%% Make graphs as directed.
if Graph1 == 1
    FigureN = Graph_AspectRatio_vs_HeywoodFactor(Text1,NPoints,increment,BinInterval,arhf);
end
if Graph2 == 1 
    Graph_Contour_Binned(Text1,NPoints,increment,BinInterval,FigureN+1,xBins,yBins,BinnedNormalizedCounts)
end

%% Output for gnuPLOT
[FreqData,CumFreqAtCI] = ContourLimits(Nxbins*Nybins,BinnedNormalizedCounts,sumBinnedRawCounts);

ElapsedTime = toc;
TxtFile = write_gnuPLOT_data(1,Text1,NPoints,increment,FreqData,CumFreqAtCI,minFraction, ...
                                sumBinnedRawCounts,Nxbins,Nybins,BinInterval, ...
                                BinnedNormalizedCounts,arhf,ElapsedTime);

write_gnuPLOT_file(1,TxtFile,Text1,sumBinnedRawCounts,FreqData,BinInterval,NPoints,0,minFraction);

toc

return

%% Notes
% For 10,000 points, it takes approximately 70 seconds to run. Although it
% is unlikely, it is possible for a plane of projection to have an ARHF
% intercept that is higher than that of an ellipse. For example, a 6 sided
% polygon in 2d cartesian coordinates defined by the vertices [ 0 0 ; 1 1 ;
% 1 -1 ; 9 1 ; 9 -1 ; 10 0] has an aspect ratio of 0.2, and a Heywood
% factor of 0.69. Having a pairing that is beneath the intercept line for a
% rectangle is not possible as far as Josh Knicely knows. There are areas
% that I call odd density areas (ODA). These occur just above the ellipse
% line. The ODA for a rectangular prism occur due to the fact that the
% polygon is six sided, but the F_M and F_O are still being calculated in
% the same way as for a rectangle. These points are almost entirely
% composed of polygons that have Feret_orthogonals greater than 1.90. I
% believe this occurs as a result of polygons who still have the maximum
% feret diameter and orthogonal feret diameter between opposing corners
% like a rectangle. The addition of another side during 'rotation' results
% in a higher HF, but a similar AR. At some point, the max feret points
% switch, resulting in a drastic decrease in orthogonal feret diameter and
% a subsequent drop in AR.This gives a high aspect ratio and similar
% Heywood Factors. Once the F_M and F_O calculation switch from
% 'rectangular style' to 'squat hexagon style', there is a large drop in
% aspect ratio.

% Many points for various shapes will land on rectangle line, but not
% beneath it. Any points plotted that appear to be beneath it only
% appear that way due to alliasing effects in the computation of the ARHF
% for various rectangles, ie not using a sufficient number of points when
% calculating the line. 