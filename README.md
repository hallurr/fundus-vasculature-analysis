# Fundus Image Vasculature Analyzer - fundusDiameter
This project provides a MATLAB tool for analyzing the vasculature in fundus images of the eye. Specifically, it helps calculate and visualize the diameter of vessels in the retinal image. This tool is provided as a companion to the methods described in the Journal of Visualized Experiments (JoVE) paper: Measuring Retinal Vessel Diameter from Mouse Fluorescent Angiography Images (Published: May 19th, 2023, DOI: 10.3791/64964).

## Articles:
- García-Llorca, A., Reynisson, H., Eysteinsson, T. Measuring Retinal Vessel Diameter from Mouse Fluorescent Angiography Images. J. Vis. Exp. (195), e64964, doi:10.3791/64964 (2023).
- Daníelsson, S. B., García-Llorca, A., Reynisson, H., & Eysteinsson, T. (2022). Mouse microphthalmia-associated transcription factor (Mitf) mutations affect the structure of the retinal vasculature. Acta ophthalmologica, 100(8), 911–918.

## Requirements:

These functions require the following MATLAB toolboxes:

* Image Processing Toolbox
* RF Toolbox
* Financial Toolbox
* Statistics and Machine Learning Toolbox

In addition, the following custom functions should be present in your MATLAB path:

* hline
* vline

## Functionality
### User-guided optic disc definition: 
The tool enables the user to manually select the center and edge of the optic disc in the retinal image, providing a basis for further analysis.
### Radius determination:
The tool calculates a series of radii emanating from the optic disc center. Each radius serves as a sample line along which the vessel diameter is assessed.
### Vessel thickness assessment:
Along each radius, the tool identifies peaks in pixel intensity that correspond to blood vessels. It then measures the full-width-at-half-maximum (FWHM) of each peak, providing an estimate of vessel diameter.
### Normalization and visualization:
The tool normalizes the vessel diameter data and presents it in a series of graphs, allowing for a clear comparison of vessel thickness across the retinal image.
Data extraction: The tool also allows you to export your results as a data table, making it easy to copy your data into other applications like Excel for further analysis.


## How to Use:
Run fundusDiameter.m.
When prompted, select the image file of the fundus you wish to analyze.
Enter the desired values for threshold multiplier, maximum 2x radius multiplier, and number of radii.
Follow the prompts to select the center and edge of the optic disc in the image.
The tool will automatically calculate and display the vessel diameters.

## License
This project is licensed under the MIT License.


## Disclaimer
This tool is intended for research purposes only and should not be used for medical diagnosis.


## Author
Hallur Reynisson