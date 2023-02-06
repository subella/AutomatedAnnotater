function [R, t] = getPoseFromCheckerboard(image, intrinsics, squareSize)
    [imagePoints, boardSize] = detectCheckerboardPoints(image);
    if sum(isnan(imagePoints(:))) || sum(isnan(boardSize(:))) || prod(boardSize) == 0
        R = nan;
        t = nan;
        return;
    end
    worldPoints = generateCheckerboardPoints(boardSize, squareSize);
    [R, t] = extrinsics(imagePoints, worldPoints, intrinsics);
end