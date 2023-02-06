function pointsWrtGrid = transformTargetFrameToGridFrame(pointsWrtTarget, ...
                                                         targetWrtGrid_R, targetWrtGrid_t)
    pointsWrtGrid = zeros(size(pointsWrtTarget));
    targetWrtGrid = makeHomo(targetWrtGrid_R', targetWrtGrid_t);
    for k=1:size(pointsWrtTarget, 1)
        pointWrtTarget = pointsWrtTarget(k, :);
        pointWrtGrid = targetWrtGrid * [pointWrtTarget 1]';
        pointsWrtGrid(k, :) = pointWrtGrid(1:3, :)';
    end
end