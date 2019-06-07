function[varargout] = scaleColorMap( cmap, x0, ax, clim, setVals )
%% Scales a colormap to a diverging dataset.
% 
% scaleColorMap( cmap, x0 )
% Scales a colormap about the centering value, x0, for the data on the
% current axis. If the centering value is not within the color limits,
% expands the color limits to include the centering value. Changes the
% colormap and color limits on the current axis to match the scaled colormap.
%
% scaleColorMap( cmap, x0, ax )
% Operates on the specified axes. If multiple axes are specified, scales
% the color map to the minimum color limit and maximum color limit of the
% entire set of axes. Use ax = [] to operate on the current axis. 
%
% scaleColorMap( cmap, x0, ax, clim )
% Scales a colormap to match the specified color limits. If the centering
% value is not within the color limits, expands the color limits to include
% the centering value.
%
% cmap = scaleColorMap( ... )
% Returns the scaled colormap.
%
% cmap = scaleColorMap( cmap, x0, ax, clim, setVals )
% Specifies whether to cahnge the colormap and color limits of the relevant
% axes. By default, setVals = true, change it to false to leave the axes
% unaltered.
%
%
% ----- Inputs -----
%
% cmap: A colormap. This is a 3 column, RGB matrix of values between 
%       0 and 1. (nColors x 3)
%
% x0: The centering value for the map. A scalar. This is the divergence
%     point for a diverging dataset. (1 x 1)
%
% ax: A set of axes handles.
%
% clim: User-specified color limits. A 2 element vector of real numbers
%       whose first element is smaller than the second element. (2 x 1) or (1 x 2)
%
% setVals: A scalar logical. True or False. (1 x 1)
%
% 
% ----- Outputs -----
%
% cmap: The scaled colormap. A 3 column, RGB matrix of values between 
%       0 and 1. (nColors x 3)

% ----- Written By -----
% Jonathan King, University of Arizona, 2019
%
% ----- License -----
%


% Error checking and setup


% Get the deviation of each color limit from the centering value
dev = clim - x0;

% If the centering value is not within the color limits
if all(dev > 0) || all(dev < 0)
    
    % Get the color limit that is closest to the centering value
    closeLim = find( abs(clim)==min(abs(clim)) );
    
    % Change this color limit to the centering value
    clim( closeLim ) = x0;
    
    % Update the deviation
    dev( closeLim ) = 0;
end

% Get the maximum absolute deviation from the centering value
maxDev = max( abs( dev ) );

% Get the percent of the maximum deviation associated with each limit
percDev = dev ./ max(dev);

% Get the number of color points on each half of the colormap
halfStep = floor( size(cmap,1) / 2 );

% Trim the bottom (maximum values) of the colormap
nTrim = halfStep - round( percDev(2)*halfStep );
cmap( end-nTrim+1:end, : ) = [];

% Trim the top (minimum values) of the colormap
nTrim = halfStep - round( percDev(1)*halfStep );
cmap( 1:nTrim, : ) = [];


% Set the values on the axes if desired
if setVals
    for a = 1:numel(ax)
        set( ax(a), 'clim', clim );
        set( ax(a), 'Colormap', cmap );
    end
end

% Return the colormap if desired as output
varargout = {};
if nargout == 1
    varargout = {cmap};
end

end
