function [f_ARHF_triangle] = ARHF_Triangle(  )
%USERSHAPESELECTION Create a user selected solid.
%   Prompt for which basic shape is desired.  Also prompt for those shapes with adjustable dimensions.
% 
%   Function by D. Rickman, Feb 14, 2014

% For all isoceles triangles with theta <= 60.  S1 = S2 = 1.
P1          = [0,0];
AR          = zeros(1,100);
HF          = zeros(1,100);
P2          = [1,0];

% Iterate over angles of theta
i = 0;
for theta = 0.00001 : (60-0.00001)/99 : 60
    % Create 100 intervals so the data can be merged easily with that for
    % ellipse and rectangle.
    i         = i + 1;
    Angle     = degtorad(theta);
    % x(i)  = cos(Angle)
    % y(i)  = sin(Angle)   
    P3        = [cos(Angle),sin(Angle)];
    Tri_Area  = triangle_area(P1, P2, P3);
    S3        = sqrt((P3(1)-1)^2 + (P3(2))^2);
    Perim     = 2 + S3;
    AR(i) = sin(Angle);
    radius     = sqrt(Tri_Area/pi);
    circumf    = 2*pi*radius; 
    HF(i)    = 1 /(Perim/circumf); 
end % for theta
f_ARHF_triangle = [AR(:) HF(:)];
end

% Turn this on for checkout
% figure(1);
% hold on
% axis([0 1 0 1]);
% axis square;
% xlabel('Aspect Ratio');
% ylabel('Heywood Factor');
% plot(f_ARHF_triangle(:,1),f_ARHF_triangle(:,2),'bo')
% hold off


% The following was used to investigate triangles.
% It was found that all scalene triangles have higher Heywood factors 
% than isoceles triangles! 
%
%  1. Shortest side of triangle, S1, is defines as having length 1.
%  2. One end of S1 sits at the center of a semicircle of radius 1.
%  3. Side S2 is on the diamter of the semicircle.  
%  4. Given 1 above S2 > S1.  Where S1 = S2 it is an isoceles triangle.
%  5. The length of S2 = 1 + ExtraLength
%  6. The angle between S1 and S2 defines theta.  
%  7. The length of S3 is found from the relationships of S1, S2, and theta.
%  8. The area of the triangle is obtained from Heron's formula.
%  9. Given the area, the Height of the triangle is obtained from A = 1/2 * Base * Height
% 10. The Base is the greater of S2 and S3.
% 
% fig         = 2; % Figure number for a plot.
% 
% P1          = [0,0];
% S1          = 1;
% AR          = zeros(1,179);
% HF          = zeros(1,179);
% 
% for ExtraLength = 0:0.1:2
% P2          = [1+ExtraLength,0];
% S2          = 1+ExtraLength;
%     % Iterate over angles of theta
%     for theta = 1 : 179
%         Angle     = degtorad(theta);
%         % x(theta)  = cos(Angle)
%         % y(theta)  = sin(Angle)   
%         P3        = [cos(Angle),sin(Angle)];
%         Tri_Area  = triangle_area(P1, P2, P3);
%         S3        = sqrt((P3(1)-P2(1))^2 + (P3(2))^2);
%         Perim     = S1 + S2 + S3;
%         if S2 > S3
%             Height    = (Tri_Area * 2)/S2;
%             AR(theta) = Height/S2;
%         else % S2 <= S3
%             Height    = (Tri_Area * 2)/S3;
%             AR(theta) = Height/S3;
%         end % if S2 > S3
% 
%         % calculate the Heywood Factor   
%         radius     = sqrt(Tri_Area/pi);
%         circumf    = 2*pi*radius; 
%         HF(theta)    = 1 /(Perim/circumf); 
%     end % for theta
% 
%     ARHF_triangle = [AR(:) HF(:)];
% 
% % The following will plot the values.  
%     if ishandle(fig) % If the window exists close it.
%         % close(fig)
%     end   
%     figure(fig);
%     hold on
%     axis([0 1 0 1]);
%     axis square;
%     xlabel('Aspect Ratio');
%     ylabel('Heywood Factor');
% 
%     if ExtraLength == 0 
%         % Use a blue line for isoceles triangles.
%         plot(ARHF_triangle(1:60,1),ARHF_triangle(1:60,2),'bo')
%     else
%         % Use a red line for all other triangles.
%         plot(ARHF_triangle(:,1),ARHF_triangle(:,2),'r-','Markersize',3.0)
%     end
%     hold off
% 
%  end % for ExtraLength
% 
% end

