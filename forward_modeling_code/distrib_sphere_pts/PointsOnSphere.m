function [x,y,z] = PointsOnSphere( NPoints )
%POINTSONSPHERE Generate NPoints distributed approximately uniformly on the surface of a sphere.
%
% Generate an Approximately Uniform Distribution of Points on a Sphere 
% Algorithm based on "Distributing many points on a sphere" by E.B. Saff and A.B.J. Kuijlaars,
%     Mathematical Intelligencer 19.1 (1997) 5--11.
%     as expressed by Dirk Laurie (dlaurie@na-net.ornl.gov) in
%     newsgroup sci.math.num-analysis 24 Apr 1997.
%   See also http://sitemason.vanderbilt.edu/page/hmbADS#code
%
%   Function by D. Rickman, using code created by Josh Knicely, Blake Lohn-Wiley.
%   D. Rickman, Jan 22, 2014

k=1:NPoints;
   k=fliplr(k);
   hk=-1+(2.*(k-1))./(NPoints-1);
   Thetak=acos(hk);
   Thetak=fliplr(Thetak);
   Phik(1)=0;
   for n=2:NPoints-1;
       Phik(n)=mod((Phik(n-1)+(3.6./sqrt(NPoints)).*1/sqrt(1-hk(n).^2)),2*pi);
   end
   Phik(1)=0;
   Phik(NPoints)=2*pi;
   R=ones(size(Thetak));
   
   x = cos(Phik).*sin(Thetak);
   x = transpose(x); 

   y = sin(Phik).*sin(Thetak);
   y = transpose(y);

   z = cos(Thetak);
   z = transpose(z); 

end
