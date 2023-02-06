function [px, py, z] = transformGridFrameToPixels(pointWrtGrid, intrinsics, R, t)
    camWrtGrid = inv(makeHomo(R',t));
    pointWrtCam = inv(camWrtGrid) * [pointWrtGrid 1]';
    [px, py, z] = transformCameraFrameToPixels(pointWrtCam, intrinsics);
end