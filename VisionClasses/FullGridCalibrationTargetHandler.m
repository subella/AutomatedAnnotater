classdef FullGridCalibrationTargetHandler < BaseCalibrationTargetHandler
    properties
        squareSize;
        validIds;
        imagePointsArray;
    end

    methods

        function obj = FullGridCalibrationTargetHandler(statusHandler, ...
                                                        rosbagParser, ...
                                                        squareSize)

            filename = filenameFromRosbag(rosbagParser.folder, ...
                                          "Calibrations", ...
                                          rosbagParser.bagName);

            try
                calibration = load(filename);
                intrinsics = calibration.intrinsics;
                validIds = calibration.validIds;
                imagePoints = calibration.imagePoints;
                statusHandler.disp(StatusMessage("Loading existing calibration from file :" + ...
                                                     filename, 0));
            catch
                statusHandler.disp(StatusMessage("No existing calibration for this bag found! Searched for file :" + ...
                                                     filename, 1));
                % TODO: don't hardcode board size.
                imagePoints = NaN(8*13, 2, rosbagParser.numImages);
                validIds = nan;
                statusHandler.disp(StatusMessage("Beginning offline grid detection..", 0));
                k = 1;
                while k <= rosbagParser.numImages
                    str = sprintf("Starting image %d of %d", k, rosbagParser.numImages);
                    statusHandler.disp(StatusMessage(str, 0));
                    [rgbImage, ~] = rosbagParser.parseRGBDImage(k);
                    [singleImagePoints, boardSize] = detectCheckerboardPoints(rgbImage, 'MinCornerMetric',0.35);

                    if all(all(boardSize == [9,14])) %&& sum(isnan(singleImagePoints(:))) == 0
                        statusHandler.disp(StatusMessage("Adding image!",0));
                        imagePoints(:, :, k) = singleImagePoints;
                        if isnan(validIds)
                            validIds = [k];
                        else
                            validIds = [validIds k];
                        end
                        k = k + 1;
                    else
                        statusHandler.disp(StatusMessage("No detections! Skipping next 0 images",0));
                        k = k + 1;
                    end
                end
                worldPoints = generateCheckerboardPoints([9,14], squareSize);
                intrinsics = estimateCameraParameters(imagePoints(:,:,validIds), worldPoints, ...
                    'NumRadialDistortionCoefficients', 3, ...
                    'EstimateTangentialDistortion', true);
                mkdir("Data" + "/" + rosbagParser.folder + "/" + "Calibrations")
                save(filename, "intrinsics", "validIds", "imagePoints");
                disp(intrinsics.MeanReprojectionError);

            end

            
            obj@BaseCalibrationTargetHandler(statusHandler, intrinsics);
            rosbagParser.intrinsics = obj.intrinsics;
            obj.imagePointsArray = imagePoints;
            obj.validIds = validIds;
            obj.worldPoints = intrinsics.WorldPoints;
             
        end

        function updateExtrinsics(obj, id)
            intrinsicsId = find(obj.validIds==id);

            obj.R = nan;
            obj.t = nan;
            obj.gridWrtCam = nan;
            obj.isValid = false;

            if ~isempty(intrinsicsId) && mean(sqrt(sum((obj.intrinsics.ReprojectionErrors(:,:,intrinsicsId)).^2,2))) < 0.5
                obj.R = obj.intrinsics.RotationMatrices(:,:,intrinsicsId);
                obj.t = obj.intrinsics.TranslationVectors(intrinsicsId, :);
                obj.gridWrtCam = makeHomo(obj.R', obj.t);
                obj.isValid = true;
                obj.origImagePoints = obj.imagePointsArray(:,:,id);
                obj.reprojectedPoints = obj.intrinsics.ReprojectedPoints(:,:,intrinsicsId);
            end


%             [obj.origImagePoints, boardSize] = detectCheckerboardPoints(rgbImage, 'PartialDetections', false);
% 
%             undistortedImage = undistortImage(rgbImage, obj.intrinsics);
% 
%             [obj.imagePoints, boardSize] = detectCheckerboardPoints(undistortedImage, 'PartialDetections', false); % 0.4
% %             disp(obj.imagePoints)
%             % Filter out misdetections
%             if sum(isnan(obj.imagePoints(:))) || ...
%                boardSize(1) ~= 9 || ...
%                boardSize(2) ~= 14
%                 obj.R = nan;
%                 obj.t = nan;
%                 obj.gridWrtCam = nan;
%                 obj.isValid = false;
%                 return;
%             end

%             obj.worldPoints = generateCheckerboardPoints(boardSize, obj.squareSize);
%             [obj.R, obj.t] = extrinsics(obj.imagePoints, obj.worldPoints, obj.intrinsics);
%             worldPoints = [obj.worldPoints zeros((size(obj.worldPoints, 1)), 1)];
%             reprojectedPoints = worldToImage(obj.intrinsics, obj.R, obj.t, worldPoints, 'ApplyDistortion',true);
%             if size(obj.origImagePoints, 1) ~= size(reprojectedPoints, 1)
%                 obj.R = nan;
%                 obj.t = nan;
%                 obj.gridWrtCam = nan;
%                 obj.isValid = false;
%                 return;
%             end
%             reprojectionError = mean(sqrt(sum((obj.origImagePoints - reprojectedPoints).^2,2)));
%             disp(reprojectionError)
%             if reprojectionError > 0.75
%                 obj.R = nan;
%                 obj.t = nan;
%                 obj.gridWrtCam = nan;
%                 obj.isValid = false;
%                 return;
%             end
% 
%             obj.gridWrtCam = makeHomo(obj.R', obj.t);
%             obj.isValid = true;
        end

    end


end