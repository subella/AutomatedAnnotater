classdef SingleTagTargetHandler < BaseCalibrationTargetHandler
    properties

        tagSize;
        tagId;
        tagFamily;

    end

    methods

        function obj = SingleTagTargetHandler(statusHandler, ...
                                              intrinsics, ...
                                              tagParams)
            obj@BaseCalibrationTargetHandler(statusHandler, intrinsics);
            obj.tagSize = tagParams.tagSize;
            obj.tagId = tagParams.tagId;
            obj.tagFamily = tagParams.tagFamily;  
        end

        function updateExtrinsics(obj, undistortedImage)

            [id,~,pose] = readAprilTag(undistortedImage, obj.tagFamily, ...
                                       obj.intrinsics, obj.tagSize);

            try
                singleTagPose = pose(id==obj.tagId);
                obj.R = singleTagPose.Rotation;
                obj.t = singleTagPose.Translation;
            catch
                obj.statusHandler.disp(StatusMessage("Could not find desired tag id!", 1));
                obj.R = nan;
                obj.t = nan;
            end
            
        end

        function annotatedImage = annotateImage(obj, image)
            if sum(isnan(obj.R(:))) || sum(isnan(obj.t(:)))
                annotatedImage = image;
                return;
            else
                worldPoints = [0 0 0; obj.tagSize/2 0 0; 0 obj.tagSize/2 0; 0 0 obj.tagSize/2];
                imagePoints = worldToImage(obj.intrinsics, obj.R, obj.t ,worldPoints);

                annotatedImage = insertShape(image, "Line", ...
                                             [imagePoints(1,:) imagePoints(2,:); ...
                                             imagePoints(1,:) imagePoints(3,:); ...
                                             imagePoints(1,:) imagePoints(4,:)], ...
                                             "Color",["red","green","blue"],"LineWidth",7);
            end
        end

    end


end