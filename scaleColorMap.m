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
% entire set of axes. If ax = [], operates on the current axis. 
%
% scaleColorMap( cmap, x0, ax, clim )
% Scales a colormap to match the specified color limits. If the centering
% value is not within the color limits, expands the color limits to include
% the centering value. If clim = [], scales the colormap to the minimum
% and maximum values in the set of specified axes. Use NaN to manually set
% one limit, and automatically scale the other. For example, clim = [NaN, 2]
% sets the upper color limit to 2 and the lower color limit to the minimum
% value in the set of axes.
%
% cmap = scaleColorMap( ... )
% Returns the scaled colormap.
%
% cmap = scaleColorMap( cmap, x0, ax, clim, setVals )
% Specifies whether to change the colormap and color limits of the relevant
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
%       whose first element is smaller than the second element. Use NaN
%       and a number to manually set one limit, but automatically set the
%       other. (1 x 2)
%
% setVals: A scalar logical. True or False. (1 x 1)
%
% 
% ----- Outputs -----
%
% cmap: The scaled colormap. A 3 column, RGB matrix of values between 
%       0 and 1. (nColors x 3)

% ----- Written By -----
% Jonathan King, University of Arizona, 2018

% Initialize unset input arguments
if ~exist('ax','var')
    ax = gca;
end
if ~exist('clim', 'var')
    clim = [];
end
if ~exist('setVals','var')
    setVals = true;
end

% Do some error checking and get the color limits
[clim, ax] = setup( cmap, x0, ax, clim, setVals, nargout );

% Get the deviation of each color limit from the centering value
dev = clim - x0;

% If the center is outside the color limits, find the closest color limit
% and change the centering value to that limit
if all(dev > 0) || all(dev < 0)    
    closeLim = find( abs(dev)==min(abs(dev)) );    
    clim( closeLim ) = x0;    
    dev( closeLim ) = 0;
end

% Get the maximum absolute deviation from the center and the percent max
% deviation associated with each color limit
maxDev = max( abs( dev ) );
percDev = abs(dev) ./ maxDev;

% Get the number of color points on each half of the colormap. Trim each
% half a percent of color points matching the percent max deviation
halfStep = floor( size(cmap,1) / 2 );

nTrim = halfStep - round( percDev(2)*halfStep );
cmap( end-nTrim+1:end, : ) = [];

nTrim = halfStep - round( percDev(1)*halfStep );
cmap( 1:nTrim, : ) = [];

% Optionally set the values on the axis
if setVals
    for a = 1:numel(ax)
        caxis( ax(a), clim );
        colormap( ax(a), cmap );
    end
end

% Return the colormap if requested as output
varargout = {};
if nargout == 1
    varargout = {cmap};
end

end

%% Helper function to do error checking and get the color limits
function[clim, ax] = setup( cmap, x0, ax, clim, setVals, nOut )

% Check that the colormap is allowed
if ~ismatrix(cmap) || size(cmap,2)~=3 || ~isnumeric(cmap) || ~isreal(cmap)
    error('cmap must be a three-column matrix of real, numeric values.');
elseif any( isnan(cmap(:)) )
    error('cmap may not contain NaN.');
elseif any( cmap(:)<0 | cmap(:)>1 )
    error('The values in cmap must be between 0 and 1.');
end

% Check that the centering value is allowed
if ~isscalar(x0) || ~isnumeric(x0) || ~isreal(x0)
    error('x0 must be a real, numeric, scalar value.');
end

% Check that ax is a set of axes
if isempty(ax)
    ax = gca;
elseif ~isa(ax, 'matlab.graphics.axis.Axes')
    error('ax must be a set of axes handles.');
end

% If color limits are unspecified, automatically determine both
if isempty(clim)
    setUpper = true;
    setLower = true;

% Otherwise, error check user color limits
else
    if ~isvector(clim) || numel(clim)~=2 || ~isnumeric(clim) || ~isreal(clim)
        error('clim must be a 2 element vector of real, numeric values.');
    elseif any( isinf(clim) )
        error('clim cannot be infinite.');
    elseif clim(1)>=clim(2)
        error('The first element in clim must be smaller than the second element of clim.');
    end
    
    % Check to determine any color limits automatically
    setLower = false;
    setUpper = false;
    if isnan(clim(1))
        setLower = true;
    end
    if isnan(clim(2))
        setUpper = true;
    end
end

% Initialize unset color limits
if setLower
    clim(1) = Inf;
end
if setUpper
    clim(2) = -Inf;
end

% If setting color limits, cycle through the axes and find the min and/or
% max values
if any(isinf(clim))
    for a = 1:numel(ax)
        axclim = get(ax(a), 'clim');
        
        % Ensure color limits are finite
        if any(isinf(axclim))
            axStr = sprintf('Axis %.f', a);
            if isequal( ax(a), gca )
                axStr = 'The current axis';
            end
            error('%s has infinite color limits. Please set them to finite values.', axStr);
        end
        
        % Update the color limit if the limit for the axis is smaller/larger
        if setLower && axclim(1)<clim(1)
            clim(1) = axclim(1);
        end
        if setUpper && axclim(2)>clim(2)
            clim(2) = axclim(2);
        end
    end
end

% Ensure that setVals is a scalar logical
if ~isscalar(setVals) || ~islogical(setVals)
    error('setVals must be a scalar logical.');
end

% Check that the user did not request too many outputs
if nOut > 1
    error('Too many outputs.');
end

end
