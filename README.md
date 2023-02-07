# AutomatedAnnotator
A toolkit to rapidly annotate keypoints. Requires the user to have a calibration target in the frame of the target. 
RGB images and depth images should be recorded in a rosbag.


# Demo
https://user-images.githubusercontent.com/51061739/217097173-bc0f6411-596f-48cd-99e1-a939f751c383.mp4

# Usage
Simply add all folders to matlab path and run `AutomatedAnnotater.mlapp`

## Setup Tab
* `Rosbag Path` is the absolute path of your rosbag.

* `RGB Image Topic` is the topic of the RGB images.

* `Depth Image Topic` is the topic of the depth images.

* `Camera Info Topic` is the topic of the camera intrinsics for when using camera calibration from ROS. (not used currently)

* `Calibration File` is a .mat file of your camera calibration if you don't want to use the camera info topic. (not used currently)

* `Data Folder` is where the data will be written.

* Right now, only grid calibration targets are fully supported. Enter the square size in mm of your grid.

* Hit `Apply Parameters`. The script will run bundle adjustment on all the images to find the best intrinsics and the best extrinics for each image.

## Annotating Tab

* Hit `Begin` to start annotating.

* Navigate through the video using the `Controller` box.

* Hit `Add Keypoint` to add a keypoint. Zoom to where you would like to place the keypoint, then press enter to lock the zoom, then click on desired location.

* View the keypoint at different angles to see if depth was accurate. You can click on a keypoint in the list and adjust its depth manually.

* If you don't hit `Finish`, your annotations won't be saved.

## Recording Tab

* Hit `Begin`.

* Hit `Start Recording` and it will loop through the video saving the keypoint locations in coco format. If there is no/poor grid detection, that frame is skipped.
