function pointWrtTag = transformPixelsToTagFrame(px, py, z, intrinsics, ...
                                                 gridWrtCam_R, gridWrtCam_t, ...
                                                 tagWrtGrid_R, tagWrtGrid_t)
    undistortedPoints = undistortPoints([px py], intrinsics);
%     undistortedPoints = [px py];
    pointWrtGrid = transformPixelsToGridFrame(undistortedPoints(1), undistortedPoints(2), z, intrinsics, gridWrtCam_R, gridWrtCam_t);
    tagWrtGrid = makeHomo(tagWrtGrid_R', tagWrtGrid_t);
    pointWrtTag = inv(tagWrtGrid) * pointWrtGrid;
    pointWrtTag = pointWrtTag(1:3)';
end