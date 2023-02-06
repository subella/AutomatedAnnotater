classdef CheckerBoardExtrinsicsSolver < BaseExtrinsicsSolver
    properties
        squareSize;
    end

    methods

        function obj = CheckerBoardExtrinsicsSolver(BaseExtrinsicsSolver_args, squareSize)
            obj@BaseExtrinsicsSolver(BaseExtrinsicsSolver_args);
            obj.squareSize = squareSize;
        end
        
        function [R, t] = computeExtrinsics(rgbImage)
            [imagePoints, boardSize] = detectCheckerboardPoints(rgbImage);
            if sum(isnan(imagePoints(:))) || sum(isnan(boardSize(:))) || prod(boardSize) == 0
                R = nan;
                t = nan;
                return;
            end
            worldPoints = generateCheckerboardPoints(boardSize, obj.squareSize);
            [R, t] = extrinsics(imagePoints, worldPoints, intrinsics);
        end

    end

end