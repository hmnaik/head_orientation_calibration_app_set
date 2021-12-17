# head_orientation_calibration_app

Reconstruct 3D object from 2D images (structure from motion).

You can reconstruct 3D object from 4 images using this app.

The blief procedure

Take a checkerboard pattern from 10-20 angles to get camera parameters.
Take images of the target object from 4 angles. A length reference has to be attached to it. Calibration points need to be captured in all frames.
Start 'gaze_calibration_app.mlapp'.
Click points.
This app has two processes.
First, it estimates the position and orientation of the cameras in the global coordinates (called ‘sfm-calibration’) from calibration points (captured in all flames). Second, it reconstructs other points (does not need to be captured in all flames).
