classdef AnnotatingController < BaseAlignedVisibleAnnotatedUIController
    %% Properties
    properties

        lastKeypoint;
        addedKeypoint = false;

    end
    %% Constructor
     methods
         function obj = AnnotatingController(baseParams, ...
                                             inputParams, ...
                                             visibilityParams)

            obj@BaseAlignedVisibleAnnotatedUIController(baseParams, ...
                                                        inputParams, ...
                                                        visibilityParams);
            if ~obj.isReady
                return;
            end

            obj.lastKeypoint = size(obj.annotatedPoints, 1);

        end

     end
    %% Overrides
    methods (Access = protected)

    end
    %% Input Handler Functions
    methods

        function handleAddKeypoint(obj)
            obj.statusHandler.disp(StatusMessage("Zoom to where you would like to place the keypoint " + ...
                 "and then press 'Enter'", 0));
            zoom on;
            pause();
            zoom off;
            obj.statusHandler.disp(StatusMessage("Now left click on the pixel you would like to place the keypoint, " + ...
                "or press any other key to go back", 0));
            [px, py, button] = ginput(1);
            px = round(px);
            py = round(py);
            obj.addedKeypoint = false;
            if button == 1
                obj.statusHandler.disp(StatusMessage("Keypoint placed at x: " + num2str(px) + " y: " + num2str(py), 0));

                z = cast(obj.depthImage(py, px), 'double');
                % TODO: Check for if z is 0
                if z == 0
                    z = 600;
                end
                pointWrtTag = transformPixelsToTagFrame(px, py, z, obj.intrinsics, ...
                                                        obj.calibrationTargetHandler.R, obj.calibrationTargetHandler.t, ...
                                                        obj.targetWrtGrid_R, obj.targetWrtGrid_t);

                if isempty(obj.annotatedPoints)
                    obj.annotatedPoints = pointWrtTag;
                    obj.annotatedPoints_R = obj.calibrationTargetHandler.R;
                    obj.annotatedPoints_t = obj.calibrationTargetHandler.t;
                else
                    obj.annotatedPoints = [obj.annotatedPoints; pointWrtTag];
                    obj.annotatedPoints_R = cat(3, obj.annotatedPoints_R, obj.calibrationTargetHandler.R);
                    obj.annotatedPoints_t = cat(3, obj.annotatedPoints_t, obj.calibrationTargetHandler.t);
                end

                obj.lastKeypoint = obj.lastKeypoint + 1;
                obj.addedKeypoint = true;
            end
            obj.updateAndDisplayCurrentImage();
        end

        function handleSubtractDepth(obj, keypoint)
            obj.deltaKeypointDepth(keypoint, -1);
            obj.updateAndDisplayCurrentImage();
        end

        function handleSetDepth(obj, keypoint, value)
            obj.setKeypointDepth(keypoint, value);
            obj.updateAndDisplayCurrentImage();
        end

        function handleAddDepth(obj, keypoint)
            obj.deltaKeypointDepth(keypoint, 1);
            obj.updateAndDisplayCurrentImage();
        end

        function handleFinish(obj)
            handleFinish@BaseAnnotatedUIController(obj);
            mkdir("Data" + "/" + obj.rosbagParser.folder + "/" + "AnnotatedPoints");
            filename = filenameFromRosbag(obj.rosbagParser.folder, ...
                                          "AnnotatedPoints", ...
                                          obj.rosbagParser.bagName);
            annotatedPoints = obj.annotatedPoints;
            annotatedPoints_R = obj.annotatedPoints_R;
            annotatedPoints_t = obj.annotatedPoints_t;
            save(filename, 'annotatedPoints', 'annotatedPoints_R', 'annotatedPoints_t');
        end
        
    end

    %% Helper Functions
    methods
        
        function deltaKeypointDepth(obj, keypoint, delta_z)
            [px, py, z] = obj.getKeypointPosWrtCam(keypoint);
            z = z + delta_z;
            obj.updateKeypoint(keypoint, px, py, z);
        end

        function setKeypointDepth(obj, keypoint, z)      
            [px, py, ~] = obj.getKeypointPosWrtCam(keypoint);
            obj.updateKeypoint(keypoint, px, py, z);
        end

        function updateKeypoint(obj, keypoint, px, py, z)
            keypoint_R = obj.annotatedPoints_R(:, :, keypoint);
            keypoint_t = obj.annotatedPoints_t(:, :, keypoint);
            pointWrtTag = transformPixelsToTagFrame(px, py, z, obj.intrinsics, ...
                                                    keypoint_R, keypoint_t, ...
                                                    obj.targetWrtGrid_R, obj.targetWrtGrid_t);
            obj.annotatedPoints(keypoint,:) = pointWrtTag(1:3)';
        end

        function [px, py, z] = getKeypointPosWrtCam(obj, keypoint)
            keypoint_R = obj.annotatedPoints_R(:, :, keypoint);
            keypoint_t = obj.annotatedPoints_t(:, :, keypoint);
            [px, py, z] = transformTagFrameToPixels(obj.annotatedPoints(keypoint, :), ...
                                                     obj.intrinsics, ...
                                                     keypoint_R, keypoint_t, ...
                                                     obj.targetWrtGrid_R, obj.targetWrtGrid_t);
        end

        function z = getDepth(obj, keypoint)
            [~, ~, z] = obj.getKeypointPosWrtCam(keypoint);
        end
        
    end
    
end