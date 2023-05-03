Original developer : Fumihiro Kano


[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7890386.svg)](https://doi.org/10.5281/zenodo.7890386)



# head_orientation_calibration_app

Reconstruct 3D object from 2D images (structure from motion).

You can reconstruct 3D object from 4 images using this app.

The blief procedure

1. Take a checkerboard pattern from 10-20 angles to get camera parameters.
2. Take images of the target object from 4 angles. A length reference has to be attached to it. Calibration points need to be captured in all frames.
3. Start 'head_orientation_calibration_app.mlapp'.
4. Click points.


This app has two processes.
First, it estimates the position and orientation of the cameras in the global coordinates (called ‘sfm-calibration’) from calibration points (captured in all flames). Second, it reconstructs other points (does not need to be captured in all flames).
