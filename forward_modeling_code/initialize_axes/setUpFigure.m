function hFig = setUpFigure(figNum,xSize,ySize,varargin)
%{
    generate a figure handle, size, position and set background color for 
    the window, which will hold the subplots
%}

numVarArgs = length(varargin);
if numVarArgs > 2
    error(  'myfuns:setUpFigure:TooManyInputs'    ,   ...
            'this function takes at most 2 optional inputs');
end
if numVarArgs > 1 && ~isa(varargin{1},'double')
    error(  'myfuns:setUpFigure:vararginType'    ,   ...
            'varargin must have type: double');
end
if numVarArgs > 1 && ~isa(varargin{2},'double')
    error(  'myfuns:setUpFigure:vararginType'    ,   ...
            'varargin must have type: double');
end

optArgs = {20,110};                 % set defaults
optArgs(1:numVarArgs) = varargin;   % overwrite defaults with optargs
[xPos,yPos] = optArgs{:};           % give args var names

hFig = figure(figNum);
clf(hFig);

set(    hFig        ,                               ...
        'Position'  ,   [xPos yPos xSize ySize]     );
set(    gcf         ,                               ...
        'color'     ,   'w'                         );
