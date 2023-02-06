function I = plotAnnotatedPoints(I, depthImage, intrinsics, annotatedPoints, ...
                                 gridWrtCam_R, gridWrtCam_t, ...
                                 tagWrtGrid_R, tagWrtGrid_t, ...
                                 isVisible, showKeypointNumbers)
    if isnan(gridWrtCam_R)
        return;
    end
    if ~isnan(annotatedPoints)
        
%         imagePoints = worldToImage(intrinsics, R, t, annotatedPoints);
        imagePoints = tagToImage(annotatedPoints, intrinsics, ...
                                 gridWrtCam_R, gridWrtCam_t, ...
                                 tagWrtGrid_R, tagWrtGrid_t);

        disp("image points");
        disp(imagePoints);

%         isVisible = visibilityDetector.isVisible(depthImage, annotatedPoints, R, t);

        visiblePoints = imagePoints(isVisible == 2, :);
        nonVisiblePoints = imagePoints(isVisible == 1, :);

        markerPosition = [visiblePoints, repmat(1.5, size(visiblePoints, 1),1)];
        I = insertShape(I,"FilledCircle",markerPosition,"Color","green","Opacity",1);

        markerPosition = [nonVisiblePoints, repmat(1.5, size(nonVisiblePoints, 1),1)];
        I = insertShape(I,"FilledCircle",markerPosition,"Color","red","Opacity",1);

        if showKeypointNumbers
            indices = linspace(1, size(imagePoints, 1), size(imagePoints, 1));
            I = insertText(I, imagePoints, string(indices));
        end
    end
end