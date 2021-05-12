# scaleColorMap
Scales a colormap for diverging data sets.

### Setup
To use, download this repository and add it to the Matlab active path.

### Usage
Please see the demo (located in "Demo/demo_scaleColorMap.m") for detailed instructions on using this function. The basic syntax is:

cmap = scaleColorMap(cmap, X0, axes, clim, setVals)

----- Inputs -----

cmap: A colormap to be scaled. A three column RGB matrix of values between 0 and 1.

X0: The divergence point for a plotted dataset.

axes: The axes on which to apply the scaled colormap. A vector of axes objects. If unspecified, applies the scale colormap to the current axes.

clim: The color limits. These are the minimum and maximum data values to include on the colorbar. A two element vector; the second element must be greater than the first. Use NaN to use the default value for either limit. If unspecified, uses the default value for both limits.

setVals: By default, the scaled colormap is applied to the specified axes. Set this input to false to not apply the colormap.

----- Outputs -----

cmap: The scaled colormap.
