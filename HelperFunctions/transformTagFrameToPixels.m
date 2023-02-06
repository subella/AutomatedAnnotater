function [px, py, z] = transformTagFrameToPixels(pointWrtTag, intrinsics, ...
                                                 gridWrtCam_R, gridWrtCam_t, ...
                                                 tagWrtGrid_R, tagWrtGrid_t)

    tagWrtGrid = makeHomo(tagWrtGrid_R',tagWrtGrid_t);
    pointWrtGrid = tagWrtGrid * [pointWrtTag 1]';
    [px, py, z] = transformGridFrameToPixels(pointWrtGrid(1:3)', intrinsics, gridWrtCam_R, gridWrtCam_t);
end