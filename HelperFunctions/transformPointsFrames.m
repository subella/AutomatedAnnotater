function pointsWrtFrameB = transformPointsFrames(pointsWrtFrameA, frameAWrtFrameB)
    pointsWrtFrameB = zeros(size(pointsWrtFrameA));
    for k=1:size(pointsWrtFrameB, 1)
        pointWrtFrameA = pointsWrtFrameA(k, :);
        pointWrtFrameBHomo = frameAWrtFrameB * toHomo(pointWrtFrameA);
        pointsWrtFrameB(k, :) = fromHomo(pointWrtFrameBHomo);
    end
end