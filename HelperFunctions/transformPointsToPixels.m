function pxpyzs = transformPointsToPixels(pointsWrtCam, intrinsics)
    pxpyzs = zeros(size(pointsWrtCam));
    for k=1:size(pxpyzs, 1)
        pointWrtCam = pointsWrtCam(k,:);
        K = intrinsics.IntrinsicMatrix;
        fx = K(1,1);
        fy = K(2,2);
        cx = K(3,1);
        cy = K(3,2);
        px = round((fx * pointWrtCam(1)) / pointWrtCam(3) + cx);
        py = round((fy * pointWrtCam(2)) / pointWrtCam(3) + cy);
        z = pointWrtCam(3);
        pxpyzs(k,:) = [px, py, z];
    end    
end