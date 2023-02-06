function imagePoints = tagToImage(pointsWrtTag, intrinsics, ...
                                                 gridWrtCam_R, gridWrtCam_t, ...
                                                 tagWrtGrid_R, tagWrtGrid_t)

    imagePoints = zeros(size(pointsWrtTag, 1), 2);
    for k=1:size(pointsWrtTag, 1)
        pointWrtTag = pointsWrtTag(k, :);
        [px, py, ~] = transformTagFrameToPixels(pointWrtTag, intrinsics, ...
                                                 gridWrtCam_R, gridWrtCam_t, ...
                                                 tagWrtGrid_R, tagWrtGrid_t);
        imagePoints(k, :) = [px, py];
    end

   
end