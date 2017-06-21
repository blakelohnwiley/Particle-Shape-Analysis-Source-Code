function [v,e,f, Text1] = UserShapeSelection(  )
%USERSHAPESELECTION Create a user selected solid.
%   Prompt for which basic shape is desired.  Also prompt for those shapes with adjustable dimensions.
% 
%   Function by D. Rickman, using code created by Josh Knicely, Blake
%   Lohn-Wiley and Doug Rickman.
%   D. Rickman, Jan 22, 2014

% Prompt for which 3D object, and where appropriate the dimensions of the shape.
disp('Select the type of shape you want from the following list: ')
disp('1. Cube')
disp('2. Rectangular Prism (also a cube if you set x, y, & z = 0)')
disp('3. Cube Octahedron - 14 faces')
disp('4. Octahedron - 8 faces')
disp('5. Clipped Octahedron - 14 faces')
disp('6. Tetrahedron - 4 faces')
disp('7. Pyramid')
disp('8. Dodecahedron - 12 faces')
disp('9. Icosahedron - 20 faces')
disp('10. Rhombododecahedron - 8 faces')
disp('11. Tetrakaidecahedron - 14 faces')
disp('12. Right Trapezoidal Prism')
disp('13. Triangular Prism')
disp('14. Ditrigonal Prism')
disp('15. Dipyramidal Trigonal Prism')
disp('16. Dipyramidal Rectangular Prism')
disp('17. Dipyramidal Pentagonal Prism')
disp('18. Dipyramidal Hexagonal Prism')

selection = input('Type in the number of your selection: ');
disp(' ')

if selection == 1
    [ v e f ] = createCube();
    Text1 = 'Cube';
elseif selection == 2
    xl = input('Select maximum size of the rectangle in the x direction: ');
    yl = input('Select maximum size of the rectangle in the y direction: ');
    zl = input('Select maximum size of the rectangle in the z direction: ');
    % lengths = [ xl yl zl ];
    [v e f] = createRectangle(xl, yl, zl); 
    Text1 = 'Rectangular Prism';
    Text1b= [' - Dimensions(x,y,z) ',num2str(xl),', ', num2str(yl),', ',num2str(zl)];
    Text1 = [Text1,Text1b];
elseif selection == 3
    [v e f] = createCubeOctahedron; 
    Text1 = 'Cube Octahedron';
elseif selection == 4
    [v e f] = createOctahedron; 
    Text1 = 'Octahedron';
elseif selection == 5
    xl = input('Select the maximum length in the x direction : ');
    yl = input('Select the maximum length in the y direction : ');
    zl = input('Select the maximum length in the z direction : ');
    [ v e f ] = createClippedOctahedron(xl,yl,zl);
    Text1 = 'Clipped Octahedron';
    Text1b= [' - Dimensions(x,y,z) ',num2str(xl),', ', num2str(yl),', ',num2str(zl)];
    Text1 = [Text1,Text1b];
elseif selection == 6
    xl = input('Select maximum extension in the x direction: ');
    yl = input('Select maximum extension in the y direction: ');
    zl = input('Select maximum extension in the z direction: ');
    % lengths = [ xl yl zl ];
    [v e f] = createTetrahedron(xl, yl, zl); 
    Text1 = 'Tetrahedron';
    Text1b= [' - Dimensions(x,y,z) ',num2str(xl),', ', num2str(yl),', ',num2str(zl)];
    Text1 = [Text1,Text1b];
elseif selection == 7 
    w = input('Select width of the pyramid base : ');
    h = input('Select height of the pyramid : ');
    [ v e f ] = createPryamid(w,h); 
    Text1 = 'Pyramid';
    Text1b= [' - Dimensions(w,h) ',num2str(w),', ', num2str(h)];
    Text1 = [Text1,Text1b];
elseif selection == 8 
    [v e f] = createDodecahedron; 
    Text1 = 'Dodecahedron'; 
elseif selection == 9
    [v e f] = createIcosahedron; 
    Text1 = 'Icosahedron';
elseif selection == 10
    [v e f] = createRhombododecahedron; 
    Text1 = 'Rhombododecahedron';
elseif selection == 11 
    [v e f] = createTetrakaidecahedron; 
    Text1 = 'Tetrakaidecahedron';
elseif selection == 12
    xl1 = input('Select the width of the bottom : ');
    xl2 = input('Select the width of the top : ');
    yl = input('Select the length of the base : ');
    zl = input('Select the height of the top : ');
    [ v e f ] = createTrapezoidal(xl1,xl2,yl,zl);
    Text1 = 'Right Trapezoidal Prism';
    Text1b= [' - Dimensions(bot,top,y,z) ',num2str(xl1),', ',num2str(xl2),', ',num2str(yl),', ',num2str(zl)];
    Text1 = [Text1,Text1b];
elseif selection == 13
    xl = input('Select the maximum length in the x direction : ');
    yl = input('Select the maximum length in the y direction : ');
    zl = input('Select the maximum length in the z direction : ');
    [v e f] = createTriangularPrism(xl,yl,zl);
    Text1 = 'Triangular Prism';
    Text1b= [' - Dimensions(x,y,z) ',num2str(xl),', ', num2str(yl),', ',num2str(zl)];
    Text1 = [Text1,Text1b];
elseif selection == 14
    [ v e f ] = createDitrigonalPrism;
    Text1 = 'Ditrigonal Prism';
elseif selection == 15
    xl1 = input('Height of the end pyramids : ');
    xl2 = input('Length of the prism body : ');
    [ v e f ] = createDipyramidalTrigonalPrism(xl1,xl2);
    Text1 = 'Dipyramidal Trigonal Prism';
    Text1b= [' - Dimensions(h,l) ',num2str(xl1),', ', num2str(xl2)];
    Text1 = [Text1,Text1b];
elseif selection == 16
    xl1 = input('Height of the end pyramids : ');
    xl2 = input('Length of the prism body : ');
    [ v e f ] = createDipyramidalRectangularPrism(xl1,xl2);
    Text1 = 'Dipyramidal Rectangular Prism';
    Text1b= [' - Dimensions(h,l) ',num2str(xl1),', ', num2str(xl2)];
    Text1 = [Text1,Text1b];  
elseif selection == 17
    xl1 = input('Height of the end pyramids : ');
    xl2 = input('Length of the prism body : ');
    [ v e f ] = createDipyramidalPentagonalPrism(xl1,xl2);
    Text1 = 'Dipyramidal Pentagonal Prism';
    Text1b= [' - Dimensions(h,l) ',num2str(xl1),', ', num2str(xl2)];
    Text1 = [Text1,Text1b];   
elseif selection == 18
    xl1 = input('Height of the end pyramids : ');
    xl2 = input('Length of the prism body : ');
    [ v e f ] = createDipyramidalHexagonalPrism(xl1,xl2);
    Text1 = 'Dipyramidal Hexagonal Prism';
    Text1b= [' - Dimensions(h,l) ',num2str(xl1),', ', num2str(xl2)];
    Text1 = [Text1,Text1b];
end

end

