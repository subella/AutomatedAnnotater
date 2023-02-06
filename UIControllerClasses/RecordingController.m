classdef RecordingController < BaseAlignedVisibleAnnotatedUIController
    %% Properties
    properties
        cocoAnnotater;
    end
    %% Constuctor
    methods
        function obj = RecordingController(baseParams, ...
                                           inputParams, ...
                                           visibilityParams)
            
            obj@BaseAlignedVisibleAnnotatedUIController(baseParams, ...
                                                        inputParams, ...
                                                        visibilityParams);
            if ~obj.isReady
                return;
            end

            obj.cocoAnnotater = CocoAnnotater(obj.intrinsics, obj.rosbagParser.bagName, obj.rosbagParser.folder, ...
                                              obj.annotatedPoints);
        end

    end
    %% Protected Main Loop Functions
    methods (Access = protected)

%         function updateCurrentImage(obj)
%             [obj.rgbImage, obj.depthImage] = obj.rosbagParser.parseRGBDImage(obj.currentFrame);
%             obj.undistortedImage = undistortImage(obj.rgbImage, obj.intrinsics);
% %             imwrite(obj.rgbImage, "CalibrationImagesD455Large/image_" + num2str(obj.imageCounter) + ".png");
%             [obj.current_R, obj.current_t] = obj.calibrationTargetHandler.computeExtrinsics(obj.undistortedImage);
%             if (sum(isnan(obj.current_R)) + sum(isnan(obj.current_t))) == 0
%                 obj.pointsVisibility = obj.visibilityDetector.isVisible(obj.depthImage, obj.annotatedPoints, ...
%                                                                      obj.current_R, obj.current_t);
%                 obj.annotatedImage = obj.calibrationTargetHandler.plotAnnotatedTarget(obj.undistortedImage, ...
%                                                                                      obj.current_R, ...
%                                                                                      obj.current_t);
%                 
%                 obj.annotatedImage = plotAnnotatedPoints(obj.annotatedImage, obj.depthImage, obj.intrinsics, ...
%                                                          obj.annotatedPoints, obj.current_R, obj.current_t, ...
%                                                          obj.pointsVisibility, obj.showKeypointNumbers);
%             end
%         end

        

    end
    
    %% Input Handler Functions
    methods

        function handleStartRecording(obj)
            while obj.currentFrame < obj.numFrames
                obj.statusHandler.disp(StatusMessage("Recording frame: " + obj.currentFrame, 0));
%                 obj.updateAndDisplayCurrentImage();
%                 drawnow;
                if obj.calibrationTargetHandler.isValid
                    obj.cocoAnnotater.addData(obj.rgbImage, ...
                                              obj.depthImage, ...
                                              obj.pointsVisibility, ...
                                              obj.calibrationTargetHandler.R, obj.calibrationTargetHandler.t, ...
                                              obj.targetWrtGrid_R, obj.targetWrtGrid_t);
                end
                obj.currentFrame = obj.currentFrame + 1;
            end
            obj.cocoAnnotater.save();
            obj.statusHandler.disp(StatusMessage("Done recording!", 0));
        end
    
    end
end