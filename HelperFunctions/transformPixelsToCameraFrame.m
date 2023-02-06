function pointWrtCam = transformPixelsToCameraFrame(px, py, z, intrinsics)
    K = intrinsics.IntrinsicMatrix;
    fx = K(1,1);
    fy = K(2,2);
    cx = K(3,1);
    cy = K(3,2);
    x = (px - cx) * z / fx;
    y = (py - cy) * z / fy; 
    pointWrtCam = [x, y, z];
end