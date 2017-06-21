function [f_ARHF_ellipse] = ARHF_Ellipse()
% Curve for all possible ellipses in AR - HF space

AR = zeros(1,100);
HF = zeros(1,100);

a = 1; 
i = 0;
for b = 0.01:0.01:1
    i       = i + 1;
    AR(i)   = b/a;
    h       = (a-b)^2/(a+b)^2;
    Perim   = pi * (a+b) * (1+(1/4)*h + (1/64)*h^2 + (1/256)*h^3 + (25/16384)*h^4 + (49/65536)*h^5 + (441/1048576)*h^6);
    Area    = pi*a*b; 
    radius  = sqrt(Area/pi);
    circumf = 2*pi*radius; 
    HF(i)   = 1 /(Perim/circumf);   
end
f_ARHF_ellipse = [AR(:) HF(:)];

end