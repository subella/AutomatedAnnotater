function pointWrtGrid = transformPixelsToGridFrame(px, py, z, intrinsics, R, t)
    pointWrtCam = transformPixelsToCameraFrame(px, py, z, intrinsics);
    camWrtGrid = inv(makeHomo(R',t));
    pointWrtGrid = camWrtGrid * [pointWrtCam 1]';
end