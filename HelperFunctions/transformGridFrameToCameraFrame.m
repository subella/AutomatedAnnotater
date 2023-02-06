function pointsWrtCam = transformGridFrameToCameraFrame(pointsWrtGrid, gridWrtCam_R, gridWrtCam_t)
    camWrtGrid = inv(makeHomo(gridWrtCam_R',gridWrtCam_t));
    pointsWrtCam = zeros(size(pointsWrtGrid));
    for id=1:size(pointsWrtGrid, 1)
        pointWrtGrid = pointsWrtGrid(id, :);
        pointWrtCam = inv(camWrtGrid) * [pointWrtGrid 1]';
        pointsWrtCam(id, :) = pointWrtCam(1:3, :)';
    end
end