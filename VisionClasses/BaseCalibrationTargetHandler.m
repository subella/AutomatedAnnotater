classdef BaseCalibrationTargetHandler < handle
    properties

        statusHandler;
        intrinsics;

        origImagePoints;
        imagePoints;
        worldPoints;
        reprojectedPoints;

        gridWrtCam;
        R;
        t;

        isValid;
        
    end

    methods

        function obj = BaseCalibrationTargetHandler(statusHandler, intrinsics)
            obj.statusHandler = statusHandler;
            obj.intrinsics = intrinsics;
            obj.R = nan;
            obj.t = nan;
        end

        function annotatedImage = annotateImage(obj, image)
            if ~obj.isValid
                annotatedImage = image;
                return;
            end

%             worldPoints = [obj.worldPoints zeros(size(obj.worldPoints, 1), 1)];
%             reprojectedPoints = worldToImage(obj.intrinsics, obj.R, ...
%                                              obj.t, worldPoints, 'ApplyDistortion',true);

            nanFreeReprojectedPoints = obj.reprojectedPoints(sum(isnan(obj.reprojectedPoints),2)==0,:);
            markerPosition = [nanFreeReprojectedPoints, repmat(2, size(nanFreeReprojectedPoints, 1),1)];
            annotatedImage = insertShape(image, "FilledCircle", ...
                                         markerPosition, "Color", "red", "Opacity", 1);

            nanFreeImagePoints = obj.origImagePoints(sum(isnan(obj.origImagePoints),2)==0,:);
            markerPosition = [nanFreeImagePoints, repmat(2, size(nanFreeImagePoints, 1),1)];
            annotatedImage = insertShape(annotatedImage, "FilledCircle", ...
                                         markerPosition, "Color", "blue", "Opacity", 1);
        end

    end

    methods (Abstract)
        updateExtrinsics(obj, undistortedImage);
    end

    %% Getters/Setters
    methods
        function gridWrtCam = get.gridWrtCam(obj)
            gridWrtCam = obj.gridWrtCam;
        end
    end

end