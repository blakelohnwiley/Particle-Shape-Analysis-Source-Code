function varargout = selecting(x,points)

if x == 1
    xl = input('Select maximum size of the rectangle in the x direction: ');
    yl = input('Select maximum size of the rectangle in the y direction: ');
    zl = input('Select maximum size of the rectangle in the z direction: ');
    [nodes edges faces] = createRectangle(xl, yl, zl); 
    fig = input('What figure window would you like this displayed in?  ');
    figure(fig)
    hold on
    title({['Rectangular Prism'];['Dimensions : x=',num2str(xl), ', y=', num2str(yl),', & z=',num2str(zl)];['Points : ',num2str(points)]})
    figure(fig+1)
    title({['2D Ocurrence Frequency of a Rectangular Prism'];['Dimensions : x=',num2str(xl), ', y=', num2str(yl),', z=',num2str(zl)];['Points : ',num2str(points)]})
elseif x == 2
    xl = input('Select maximum extension in the x direction: ');
    yl = input('Select maximum extension in the y direction: ');
    zl = input('Select maximum extension in the z direction: ');
    [nodes edges faces] = createTetrahedron(xl, yl, zl); 
    fig = input('What figure window would you like this displayed in?  ');
    figure(fig)
    hold on
    title({['Tetrahedron'];['Dimensions : x=',num2str(xl), ', y=', num2str(yl),', & z=',num2str(zl)];['Points : ',num2str(points)]})
    figure(fig+1)
    title({['2D Ocurrence Frequency of a Tetrahedron'];['Dimensions : x=',num2str(xl), ', y=', num2str(yl),', & z=',num2str(zl)];['Points : ',num2str(points)]})
elseif x == 3
    disp('Sorry, no control over inputs with this one.')
    [nodes edges faces] = createCubeOctahedron; 
    hold on
    fig = input('What figure window would you like this displayed in?  ');
    figure(fig)
    title({['Cube Octahedron'];['Points : ',num2str(points)]})
    figure(fig+1)
    title({['2D Ocurrence Frequency of a Cube Octahedron'];['Points : ',num2str(points)]})
elseif x == 4 
    disp('Sorry, no control over inputs with this one.')
    [nodes edges faces] = createDodecahedron; 
    hold on
    fig = input('What figure window would you like this displayed in?  ');
    figure(fig)
    title({['Dodecahedron'];['Points : ',num2str(points)]}) 
    figure(fig+1)
    title({['2D Ocurrence Frequency of a Dodecahedron'];['Points : ',num2str(points)]})
elseif x == 5
    disp('Sorry, no control over inputs with this one.')
    [nodes edges faces] = createOctahedron; 
    hold on
    fig = input('What figure window would you like this displayed in?  ');
    figure(fig)
    title({['Octahedron'];['Points : ',num2str(points)]})
    figure(fig+1)
    title({['2D Ocurrence Frequency of an Octahedron'];['Points : ',num2str(points)]})
elseif x == 6
    disp('Sorry, no control over inputs with this one.')
    [nodes edges faces] = createIcosahedron; 
    hold on
    fig = input('What figure window would you like this displayed in?  ');
    figure(fig)
    title({['Icosahedron'];['Points : ',num2str(points)]}) 
    figure(fig+1)
    title({['2D Ocurrence Frequency of an Icosahedron'];['Points : ',num2str(points)]})
elseif x == 7
    disp('Sorry, no control over inputs with this one.')
    [nodes edges faces] = createRhombododecahedron; 
    hold on
    fig = input('What figure window would you like this displayed in?  ');
    figure(fig)
    title({['Rhombododecahedron'];['Points : ',num2str(points)]})
    figure(fig+1)
    title({['2D Ocurrence Frequency of a Rhombododecahedron'];['Points : ',num2str(points)]})
elseif x == 8 
    disp('Sorry, no control over inputs with this one.')
    [nodes edges faces] = createTetrakaidecahedron; 
    hold on
    fig = input('What figure window would you like this displayed in?  ');
    figure(fig)
    title({['Tetrakaidecahedron'];['Points : ',num2str(points)]})
    figure(fig+1)
    title({['2D Ocurrence Frequency of a Tetrakaidecahedron'];['Points : ',num2str(points)]})
elseif x == 9 
    w = input('Select width of the pyramid base : ');
    h = input('Select height of the pyramid : ');
    [ nodes edges faces ] = createPryamid(w,h); 
    hold on
    fig = input('What figure window would you like this displayed in?   ');
    figure(fig)
    title({['Pyramid'];['Points : ',num2str(points)]})
    figure(fig+1)
    title({['2D Ocurrence Frequency of a Pyramid'];['Points : ',num2str(points)]})
elseif x == 10
    xl1 = input('Select the width of the top : ');
    xl2 = input('Select the width of the bottom : ');
    yl = input('Select the length of the base : ');
    zl = input('Select the height of the top : ');
    [ nodes edges faces ] = createTrapezoidal(xl1,xl2,yl,zl);
    hold on
    fig = input('What figure window would you like this displayed in?   ');
    figure(fig)
    title({['Right Trapezoidal Prism'];['Points : ',num2str(points)]})
    figure(fig+1)
    title({['2D Ocurrence Frequency of a Right Trapezoidal Prism'];['Points : ',num2str(points)]})
elseif x == 11
    xl = input('Select the maximum length in the x direction : ');
    yl = input('Select the maximum length in the y direction : ');
    zl = input('Select the maximum length in the z direction : ');
    [ nodes edges faces ] = createSymTrapezoidal(xl,yl,zl);
    hold on
    fig = input('What figure window would you like this displayed in?   ');
    figure(fig)
    title({['Symmetric Trapezoidal Prism'];['Points : ',num2str(points)]})
    figure(fig+1)
    title({['2D Ocurrence Frequency of a Symmetric Trapezoidal Prism'];['Points : ',num2str(points)]})
end

varargout = formatMeshOutput(nargout, nodes, edges, faces, fig);