function [f_ARHF_rectangle] = ARHF_Rectangle()
% All possible AR - HF values for a Rectangle
% 1. One side of the rectangle, S1, has a length of 1.
% 2. The lenght of the other side, S2, is varied between 1 and 0.01 in steps of 0.01.
%    Coarser steps show when plotted against the triangle data.
%
% Doug Rickman, Feb 14, 2014

AR = zeros(1,100);
HF = zeros(1,100);

i  = 0;
for S2 = 0.01:0.01:1
    i         = i+1;
    Perim     = 2 + 2*S2;
    FeretDia  = sqrt(1 + S2^2); 
    phi       = atan(S2);
    OrthoDia  = 2*(sin(1.57079633-phi) * S2); % 90 degrees in radians
    AR(i)     = OrthoDia/FeretDia;  
    radius    = sqrt(S2/pi);
    circumf   = 2*pi*radius; 
    HF(i)     = 1 /(Perim/circumf);   
end
f_ARHF_rectangle = [AR(:) HF(:)];

end