classdef CadFrameController < BaseManualAligningController
    % This whole file is a complete mess and needs redone.
    %% Properties
    properties
        annotatedPointsNew;
    end

    %% Constructor
    methods

        function obj = CadFrameController(baseParams, ...
                                          inputParams, ...
                                          visibilityParams)
        
            obj@BaseManualAligningController(baseParams, ...
                                             inputParams, ...
                                             visibilityParams)
            if ~obj.isReady
                return;
            end

        end

    end

    %% Overrides
    methods (Access = protected)

        function updateState(obj)
            % I think this is terribly bugged
            if obj.calibrationTargetHandler.isValid
                newerTargetWrtNewTarget = eye(4,4);
                newerTargetWrtNewTarget(1,4) = obj.x;
                newerTargetWrtNewTarget(2,4) = obj.y;
                newerTargetWrtNewTarget(3,4) = obj.z;
                eulZYX = [obj.yaw obj.pitch obj.roll];
                newerTargetWrtNewTarget(1:3, 1:3) = eul2rotm(eulZYX);
                obj.newTargetWrtTarget = obj.newTargetWrtTarget * newerTargetWrtNewTarget;
                % Reset vars to 0
                obj.x = 0;
                obj.y = 0;
                obj.z = 0;
                obj.roll = 0;
                obj.pitch = 0;
                obj.yaw = 0;
                obj.recenterCadFrame();
                
            end
        end

         function annotateCurrentImage(obj)
            annotateCurrentImage@BaseManualAligningController(obj);
            if obj.calibrationTargetHandler.isValid
                axisPoints = [0 0 0; 100 0 0; 0 100 0; 0 0 100];
                imagePoints = obj.transformTargetFrameToPixels(axisPoints);
                obj.annotatedImage = insertShape(obj.annotatedImage, ...
                    "Line",[imagePoints(1,:) imagePoints(2,:); ...
                    imagePoints(1,:) imagePoints(3,:); ...
                    imagePoints(1,:) imagePoints(4,:)], ...
                    "Color",["red","green","blue"],"LineWidth",7);
            end
         end
    end

    %% Helper Functions
    methods
%         function pixels = transformgTargetFrameToPixels(obj, pointsWrtTargetFrame)
%             pointsWrtTarget = transformPointsFrames(pointsWrtTargetFrame, obj.targetWrtGrid);
%             pixels = obj.transformTargetFrameToPixels(pointsWrtTarget);
%         end

%         function recenterCadFrame(obj)
%             targetWrtNewTarget = inv(obj.newTargetWrtTarget);
%             obj.annotatedPointsWrtNewTarget = transformPointsFrames(obj.annotatedPoints, targetWrtNewTarget);
%             obj.targetWrtGrid = obj.targetWrtGrid * obj.newTargetWrtTarget;
%         end
    end
    %% Input Handler Functions
    methods (Access = public)

        function handleCenter(obj)
            obj.targetWrtGrid(1:3, 4) = mean(obj.annotatedPoints)';
%             obj.newTargetWrtTarget(1:3, 4) = mean(obj.annotatedPoints)';
            obj.updateAndDisplayCurrentImage();
        end

        function handleFlipZ(obj)
            obj.targetWrtGrid(:,1) = -obj.newTargetWrtTarget(:,1);
            obj.targetWrtGrid(:,3) = -obj.newTargetWrtTarget(:,3);
%             obj.newTargetWrtTarget(:,1) = -obj.newTargetWrtTarget(:,1);
%             obj.newTargetWrtTarget(:,3) = -obj.newTargetWrtTarget(:,3);
            obj.updateAndDisplayCurrentImage();
        end

        function handleFinish(obj)
            handleFinish@BaseAnnotatedUIController(obj);
            mkdir("Data" + "/" + obj.rosbagParser.folder + "/" + "CadFrame");
            filename = filenameFromRosbag(obj.rosbagParser.folder, ...
                                          "CadFrame", ...
                                          "cad_frame");
            annotatedPointsWrtTarget = transformPointsFrames(obj.annotatedPoints, inv(obj.targetWrtGrid));
%             annotatedPoints = obj.annotatedPointsNew;
%             annotatedPoints_R = obj.annotatedPoints_R;
%             annotatedPoints_t = obj.annotatedPoints_t;
            save(filename, 'annotatedPointsWrtTarget');
            writematrix(annotatedPointsWrtTarget, filename + ".csv");
        end
    end

    %% Getters / Setters
    methods

    end
end
