function I = plotCheckerboardProjection(I, intrinsics, squareSize, R, t)
    [imagePoints, boardSize] = detectCheckerboardPoints(I);
    if sum(isnan(imagePoints(:))) || sum(isnan(boardSize(:))) || prod(boardSize) == 0
        return;
    end

    worldPoints = generateCheckerboardPoints(boardSize, squareSize);

    worldPoints = [worldPoints zeros(size(worldPoints, 1), 1)];
    
    reprojectedPoints = worldToImage(intrinsics, R, ...
                      t, worldPoints);
    markerPosition = [reprojectedPoints, repmat(2, size(reprojectedPoints, 1),1)];
    I = insertShape(I,"FilledCircle",markerPosition,"Color","red","Opacity",1);
    
    markerPosition = [imagePoints, repmat(2, size(imagePoints, 1),1)];
    I = insertShape(I,"FilledCircle",markerPosition,"Color","blue","Opacity",1);

end