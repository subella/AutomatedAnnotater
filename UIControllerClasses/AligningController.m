classdef AligningController < BaseAnnotatedUIController
    %% Properties
    properties

        tagWrtGridRotations;
        tagWrtGridTranslations;
        singleTagDetector;

        numDetectionsMissed;

    end
    %% Constuctor
    methods
        function obj = AligningController(statusHandler, ...
                                          calibrationTargetHandler, ...
                                          rosbagParser, ...
                                          frameSkips, ...
                                          tagParams)
            obj@BaseAnnotatedUIController(statusHandler, ...
                                          calibrationTargetHandler, ...
                                          rosbagParser, ...
                                          frameSkips);
            if ~obj.isReady
                return;
            end

            obj.singleTagDetector = SingleTagTargetHandler(statusHandler, ...
                                                           obj.intrinsics, ...
                                                           tagParams);


            obj.tagWrtGridRotations = nan;
            obj.tagWrtGridTranslations = nan;

            obj.statusHandler.disp(StatusMessage("Successfully initialized Aligning Controller :)", 0));
        end

    end
    %% Protected Main Loop Functions
    methods (Access = protected)

        function updatePoseEstimate(obj)
            updatePoseEstimate@BaseAnnotatedUIController(obj);
            obj.singleTagDetector.updateExtrinsics(obj.undistortedImage);
        end

        function annotateCurrentImage(obj)
            annotateCurrentImage@BaseAnnotatedUIController(obj);
            obj.annotatedImage = obj.singleTagDetector.annotateImage(obj.annotatedImage);
        end

    end
    
    %% Input Handler Functions
    methods

        function handleAverage(obj, app)
            while obj.currentFrame < obj.numFrames
                obj.updateAndDisplayCurrentImage();
                obj.updatePoses();
            
                obj.currentFrame = obj.currentFrame + obj.frameSkips;
                CurrentFrameEditField = findall(app.currentTab, 'Tag', 'CurrentFrame');
                CurrentFrameEditField.Value = obj.currentFrame;
                drawnow;
            end
            
        end

        function updatePoses(obj)

            if (sum(isnan(obj.calibrationTargetHandler.R)) + sum(isnan(obj.calibrationTargetHandler.t))) == 0
                if (sum(isnan(obj.singleTagDetector.R)) + sum(isnan(obj.singleTagDetector.t))) == 0

                    tagWrtCam = makeHomo(obj.singleTagDetector.R', obj.singleTagDetector.t);
                    gridWrtCam = makeHomo(obj.calibrationTargetHandler.R', obj.calibrationTargetHandler.t);
                    tagWrtGrid = inv(gridWrtCam) * tagWrtCam;

                    disp("tagWrtCam: ")
                    disp(tagWrtCam)
                    disp("gridWrtCam: ")
                    disp(gridWrtCam)
                    disp("tagWrtGrid: ")
                    disp(tagWrtGrid)
                    disp("Norm: ")
                    disp(norm(obj.singleTagDetector.t - obj.calibrationTargetHandler.t))


                    if isnan(obj.tagWrtGridRotations)
                        obj.tagWrtGridRotations = quaternion(tagWrtGrid(1:3, 1:3), 'rotmat', 'point');
                        obj.tagWrtGridTranslations = tagWrtGrid(1:3, 4)';
                    else
                        obj.tagWrtGridRotations = [obj.tagWrtGridRotations; quaternion(tagWrtGrid(1:3, 1:3), 'rotmat', 'point')];
                        obj.tagWrtGridTranslations = [obj.tagWrtGridTranslations; tagWrtGrid(1:3, 4)'];
                    end

                end
            else
                obj.numDetectionsMissed = obj.numDetectionsMissed + 1;
                obj.statusHandler.disp(StatusMessage(num2str(obj.numDetectionsMissed) + ...
                    " Tag Detections missed!", 1));
            end
        end
        
    
    end

    methods (Access = public)

        function handleFinish(obj)
            handleFinish@BaseUIController(obj);

            mkdir Transform
            filename = formatRosbagFilename("Transform", "transform", ...
                obj.rosbagParser.bagName);

            
            tagWrtGridRotationAvg = quat2rotm(meanrot(obj.tagWrtGridRotations));
            tagWrtGridTranslationAvg = mean(obj.tagWrtGridTranslations);
%             disp(tagWrtGridRotationAvg);
%             disp(tagWrtGridTranslationAvg);
            tagWrtGridRotations = obj.tagWrtGridRotations;
            tagWrtGridTranslations = obj.tagWrtGridTranslations;
            tagWrtGrid = makeHomo(tagWrtGridRotationAvg, tagWrtGridTranslationAvg);

            save(filename, 'tagWrtGridRotations', 'tagWrtGridTranslations','tagWrtGrid');
        end

    end
end