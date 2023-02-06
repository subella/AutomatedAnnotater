classdef BaseAveragingController < BaseUIController
    %% Properties
    properties

        gridTranslationsAvg;
        gridRotationsAvg;

        gridTranslationsTotal;
        gridRotationsTotal;
        numGridPoses;
        numGridDetectionsMissed;
        computeGridPoseInterval;

        numFramesToAverage;

    end
    %% Constuctor
    methods
        function obj = BaseAveragingController(statusHandler, ...
                                               calibrationTargetHandler, ...
                                               rosbagParser, ...
                                               frameSkips, ...
                                               numFramesToAverage)
            obj@BaseUIController(statusHandler, ...
                                 calibrationTargetHandler, ...
                                 rosbagParser, ...
                                 frameSkips);
            if ~obj.isReady
                return;
            end

            obj.gridTranslationsAvg = nan;
            obj.gridRotationsAvg = nan;

            obj.gridTranslationsTotal = 0;
            obj.gridRotationsTotal = nan;
            obj.numGridPoses = 0;
            obj.computeGridPoseInterval = 5;
            
            obj.numFramesToAverage = numFramesToAverage;        
        end

    end

    %% Input Handler Functions
    methods (Sealed)

        function handleAverage(obj, app)
            targetFrame = clamp(obj.currentFrame + obj.numFramesToAverage, 1, obj.rosbagParser.numImages);
            while obj.currentFrame < targetFrame
                obj.addFrame();
                obj.updateAndDisplayCurrentImage();
                obj.currentFrame = obj.currentFrame + 1;
                CurrentFrameEditField = findall(app.currentTab, 'Tag', 'CurrentFrame');
                CurrentFrameEditField.Value = obj.currentFrame;
                drawnow;
            end
            obj.computeAverage();
            obj.reset();
        end

    end

    %% Overrides
    methods (Access = protected)
      
        function addFrame(obj)          
            if mod(obj.currentFrame, obj.computeGridPoseInterval) == 0
                if sum(isnan(obj.calibrationTargetHandler.R(:))) || sum(isnan(obj.calibrationTargetHandler.t(:)))
                    obj.numGridDetectionsMissed = obj.numGridDetectionsMissed + 1;
                    obj.statusHandler.disp(StatusMessage(num2str(obj.numGridDetectionsMissed) + ...
                                           " Grid Detections missed!",1));
                else
                    obj.gridTranslationsTotal = obj.gridTranslationsTotal + obj.calibrationTargetHandler.t;

                    if isnan(obj.gridRotationsTotal)
                        obj.gridRotationsTotal = quaternion(obj.calibrationTargetHandler.R, 'rotmat', 'point');
                    else
                        obj.gridRotationsTotal = [obj.gridRotationsTotal; quaternion(obj.calibrationTargetHandler.R, 'rotmat', 'point')];
                    end
                    obj.numGridPoses = obj.numGridPoses + 1;
                end
            end            
        end

        function computeAverage(obj)
            gridTranslationAvg = obj.gridTranslationsTotal ./ obj.numGridPoses;
            if isnan(obj.gridTranslationsAvg)
                obj.gridTranslationsAvg = gridTranslationAvg;
            else
                obj.gridTranslationsAvg = cat(3, obj.gridTranslationsAvg, gridTranslationAvg);
            end

            gridRotationAvg = quat2rotm(meanrot(obj.gridRotationsTotal));
            if isnan(obj.gridRotationsAvg)
                obj.gridRotationsAvg = gridRotationAvg;
            else
                obj.gridRotationsAvg = cat(3, obj.gridRotationsAvg, gridRotationAvg);
            end
        end

        function reset(obj)
            obj.gridTranslationsTotal = 0;
            obj.gridRotationsTotal = nan;
            obj.numGridPoses = 0;
            obj.numGridDetectionsMissed = 0;
        end

    end
end