function varargout = initSubplotAxes(figHandle,spstyle)
% [ h1 h2 h3 ] = initSubplotAxes(figHandle)
% return axes handles for subplots of the figure with handle figHandle
% figHandle is cleared on call
% inputs
%   figHandle   handle of parent figure
%   spstyle     '1l2s' 2x2, one large plot in [1,3], other two on RHS
%               '2row' row of 2 subplots
%               '3row' row of 3 subplots
% outputs
%   h1, h2, h3  1l2s: h1 is large plot, h2 is top right, h3 is bottom right
%               nrow: subplots labeled left to right

spstylelist = {'1l2s', '2row', '3row'};
stlIx = find(strcmp(spstylelist,spstyle),1);
if isempty(stlIx)
    error(  'myfuns:initSubplotAxes:subplotStyleName'    ,   ...
            'spstyle must be ''1l2s'', ''2row'' or ''3row''');
end
clf(figHandle)

stlvals = {
    3,  2,  2,  [1,3],  2,  4
    2,  1,  2,  1    ,  2,  'null'
    3,  1,  3,  1    ,  2,  3
    };
[nargout, sprows, spcols, locsp1, locsp2, locsp3] = stlvals{stlIx,:};

h1 = subplot( sprows, spcols, locsp1,   ...
              'Parent'  , figHandle     );
h2 = subplot( sprows, spcols, locsp2,   ...
              'Parent'  , figHandle     );
h3 = 'null';
if nargout==3
    h3 = subplot( sprows, spcols, locsp3,   ...
                  'Parent'  , figHandle );
end

handles = {h1, h2, h3};
varargout = handles(1:nargout);