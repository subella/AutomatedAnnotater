function pointsWrtCam = transformTargetFrameToCameraFrame(pointsWrtTarget, ...
                                                          gridWrtCam_R, gridWrtCam_t, ...
                                                          targetWrtGrid_R, targetWrtGrid_t)

    pointsWrtGrid = transformTargetFrameToGridFrame(pointsWrtTarget, targetWrtGrid_R, targetWrtGrid_t);
    pointsWrtCam = transformGridFrameToCameraFrame(pointsWrtGrid, gridWrtCam_R, gridWrtCam_t);
end