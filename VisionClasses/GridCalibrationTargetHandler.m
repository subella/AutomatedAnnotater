classdef GridCalibrationTargetHandler < BaseCalibrationTargetHandler
    properties
        squareSize;
    end

    methods

        function obj = GridCalibrationTargetHandler(statusHandler, ...
                                                    intrinsics, ...
                                                    squareSize)
            obj@BaseCalibrationTargetHandler(statusHandler, intrinsics);
            obj.squareSize = squareSize;
        end

        function updateExtrinsics(obj, rgbImage)
            [obj.origImagePoints, boardSize] = detectCheckerboardPoints(rgbImage, 'PartialDetections', false);
            disp(size(rgbImage))

            undistortedImage = undistortImage(rgbImage, obj.intrinsics);

            [obj.imagePoints, boardSize] = detectCheckerboardPoints(undistortedImage, 'PartialDetections', false); % 0.4
%             disp(obj.imagePoints)
            % Filter out misdetections
            if sum(isnan(obj.imagePoints(:))) || ...
               boardSize(1) ~= 9 || ...
               boardSize(2) ~= 14
                obj.R = nan;
                obj.t = nan;
                obj.gridWrtCam = nan;
                obj.isValid = false;
                return;
            end

            obj.worldPoints = generateCheckerboardPoints(boardSize, obj.squareSize);
            [obj.R, obj.t] = extrinsics(obj.imagePoints, obj.worldPoints, obj.intrinsics);
            worldPoints = [obj.worldPoints zeros((size(obj.worldPoints, 1)), 1)];
            reprojectedPoints = worldToImage(obj.intrinsics, obj.R, obj.t, worldPoints, 'ApplyDistortion',true);
            if size(obj.origImagePoints, 1) ~= size(reprojectedPoints, 1)
                obj.R = nan;
                obj.t = nan;
                obj.gridWrtCam = nan;
                obj.isValid = false;
                return;
            end
            reprojectionError = mean(sqrt(sum((obj.origImagePoints - reprojectedPoints).^2,2)));
            disp(reprojectionError)
            if reprojectionError > 0.75
                obj.R = nan;
                obj.t = nan;
                obj.gridWrtCam = nan;
                obj.isValid = false;
                return;
            end

            obj.gridWrtCam = makeHomo(obj.R', obj.t);
            obj.isValid = true;
        end

    end


end