# Fundus Vasculature Analysis
This repository contains two MATLAB functions designed to analyze fundus images and compute vessel diameter:

*1. **fundusDiameter.m**
*2. **multipleFundus.m**

## Requirements

These functions require the following MATLAB toolboxes:

* Image Processing Toolbox
* RF Toolbox
* Financial Toolbox
* Statistics and Machine Learning Toolbox

In addition, the following custom functions should be present in your MATLAB path:

* hline
* vline

## Usage
### 1. fundusDiameter.m
This function calculates the vessel diameter for a given fundus image at a specific distance from the optic disc center.
```
[vesselDiameter, orderedCoords] = fundusDiameter(filename, multiplier, optic_disc_radius, optic_disc_center, img, display_results)
```
#### Parameters:

* filename: The name of the fundus image file (e.g., 'example_image.tif').
* multiplier: A number between 1 and 2 that determines the radius multiplier (e.g., 1.3).
* optic_disc_radius: The radius of the optic disc in pixels.
* optic_disc_center: A 1x2 array containing the x and y coordinates of the optic disc center.
* img: The input fundus image.
* display_results: A boolean flag that, if set to true, displays the analysis results as images.


#### Returns:

vesselDiameter: The computed vessel diameter around the optic disc.
orderedCoords: The ordered coordinates of the fundus image.

### 2. multipleFundus.m
This function analyzes a fundus image and computes the vessel diameter around the optic disc for various radii.

matlab
Copy code
multipleFundus()

#### Usage:

Run the multipleFundus() function.
Provide the required inputs in the dialog prompt that appears.
The script will perform the analysis and display the results as plots.
Example
To run the fundusDiameter.m function, provide the required parameters (eg.):

```
Enter filename:'2020-06-03_10-10-16-94.tif'
Enter skew from between 1 and 0: 0.15
Enter maximum 2x radius multiplier: 1.3
Enter num_of_radiuses of radii: 30
Do you want to view all photos? [Y/N]:'N'
```

To run the multipleFundus.m function, simply call the function and provide the required inputs in the dialog prompt that appears:
```
multipleFundus();
```