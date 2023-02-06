classdef AprilTagCalibrationTargetHandler < BaseCalibrationTargetHandler
    properties
        tagSize;
        tagFamily;
        marginSize;
        tagArrangement;
        worldPoints3D;
    end

    methods

        function obj = AprilTagCalibrationTargetHandler(statusHandler, ...
                                                        intrinsics, ...
                                                        tagParams, ...
                                                        marginSize, ...
                                                        tagArrangement)
            obj@BaseCalibrationTargetHandler(statusHandler, intrinsics);
%             obj.tagSize = tagParams.tagSize;
%             obj.tagId = tagParams.tagId;
%             obj.tagFamily = tagParams.tagFamily;
%             obj.marginSize = marginSize;
%             obj.tagArrangement = tagArrangement;
            obj.tagSize = 36;
            obj.tagFamily = "tag36h11";
            obj.marginSize = 36;
            obj.tagArrangement = [4, 6];
            obj.generateWorldPoints();
            disp(obj.worldPoints3D)
        end

        function generateWorldPoints(obj)
            numTags = obj.tagArrangement(1) * obj.tagArrangement(2);
            effectiveTagSize = obj.tagSize + obj.marginSize;
            obj.worldPoints3D = zeros(2, 2, numTags);
            k = 1;
            for j = 0:obj.tagArrangement(1) - 1
                for i = 0:obj.tagArrangement(2) - 1
                    % Bottom left corner
                    obj.worldPoints3D(1, :, k) = [i * effectiveTagSize, j * effectiveTagSize];
                    % Bottom right corner
                    obj.worldPoints3D(2, :, k) = [i * effectiveTagSize + obj.tagSize, j * effectiveTagSize];
                    % Top right corner
                    obj.worldPoints3D(3, :, k) = [i * effectiveTagSize + obj.tagSize, j * effectiveTagSize + obj.tagSize];
                    % Top left corner
                    obj.worldPoints3D(4, :, k) = [i * effectiveTagSize, j * effectiveTagSize + obj.tagSize];
                    k = k + 1;
                end
            end
        end

        function updateExtrinsics(obj, undistortedImage)
            [id, loc, ~] = readAprilTag(undistortedImage, obj.tagFamily, ...
                                        obj.intrinsics, obj.tagSize);
            disp(id)
            if isempty(id)
                obj.R = nan;
                obj.t = nan;
                return;
            end
            imagePoints = permute(loc, [1 3 2]);
            obj.imagePoints = reshape(imagePoints, [], size(loc, 2), 1);
%             disp(obj.imagePoints);
%             disp(obj.worldPoints3D);
            usedWorldPoints = obj.worldPoints3D(:,:, id);
%             disp(usedWorldPoints);
            worldPoints = permute(usedWorldPoints, [1 3 2]);
            obj.worldPoints = reshape(worldPoints, [], size(usedWorldPoints, 2), 1);
%             disp(obj.worldPoints);
            [obj.R, obj.t] = extrinsics(obj.imagePoints, obj.worldPoints, obj.intrinsics);
        end

    end


end