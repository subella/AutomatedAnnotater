classdef BaseUIController < handle
    %% Properties
    properties
        statusHandler;
        calibrationTargetHandler;
        
        rosbagParser;
        intrinsics;

        currentFrame;
        updatedFrame;
        frameSkips;
        numFrames;

        isReady;
        isRunning;

        rgbImage;
        depthImage;
        undistortedImage;
        undistortedDepthImage;
        undistortedToDistortedMapping;

        fig;
        axes;
    end

    %% Constructor
    methods

        function obj = BaseUIController(baseParams)
            obj.isReady = false;
            if ~baseParams.rosbagParser.isReady
                statusHandler.disp(StatusMessage("Invalid Rosbag Parser. Did you run the setup tab?", 2));
                return
            end

            obj.statusHandler = baseParams.statusHandler;
            obj.calibrationTargetHandler = baseParams.calibrationTargetHandler;
            
            obj.rosbagParser = baseParams.rosbagParser;
%             obj.intrinsics = obj.rosbagParser.intrinsics;
            obj.intrinsics = obj.calibrationTargetHandler.intrinsics;
            obj.numFrames = obj.rosbagParser.numImages;

            obj.currentFrame = baseParams.currentFrame;
            obj.updatedFrame = nan;
            obj.frameSkips = baseParams.frameSkips;

            obj.isRunning = false;
            obj.isReady = true; 
           
        end

    end

    %% Helper Functions
    methods

    end
    %% Overrides
    methods (Access = protected)
        
        function updateAndDisplayCurrentImage(obj)
            if obj.updatedFrame ~= obj.currentFrame
                obj.updateCurrentImage();
                obj.updatePoseEstimate(); 
            end
            obj.displayCurrentImage();
            obj.updatedFrame = obj.currentFrame;
        end

        function updateCurrentImage(obj)
            [obj.rgbImage, obj.depthImage] = obj.rosbagParser.parseRGBDImage(obj.currentFrame);
            % TODO: if undistortion shifts the origin, we need to translate all points
            % See https://www.mathworks.com/help/vision/ref/extrinsics.html
%             obj.undistortedImage = undistortImage(obj.rgbImage, obj.intrinsics);
%             obj.rgbImage = obj.undistortedImage;
%             obj.undistortedImage = obj.rgbImage;
%             obj.undistortedDepthImage = undistortImage(obj.depthImage, obj.intrinsics);
        end

        function updatePoseEstimate(obj)
            obj.calibrationTargetHandler.updateExtrinsics(obj.currentFrame);
        end

        function displayCurrentImage(obj)
            imshow(obj.rgbImage, 'Parent', obj.axes);
        end
    end

    %% Input Handler Functions
    methods (Access = public)

        function handleBegin(obj)
            obj.fig = figure;
            obj.axes = gca;
            obj.isRunning = true;
            obj.updateAndDisplayCurrentImage();
        end

        function handleSubtractFrames(obj)
            obj.currentFrame = obj.currentFrame - obj.frameSkips;
        end

        function handleAddFrames(obj)
            obj.currentFrame = obj.currentFrame + obj.frameSkips;
        end      

        function handleFinish(obj)
            obj.isRunning = false;
            close(obj.fig);
        end
    end

    %% Getters / Setters
    methods

        function currentFrame = get.currentFrame(obj)
            currentFrame = obj.currentFrame;
        end

        function set.currentFrame(obj, value)
            obj.currentFrame = clamp(value, 1, obj.numFrames);
            if obj.isRunning
                obj.updateAndDisplayCurrentImage();
            end
        end

        function frameSkips = get.frameSkips(obj)
            frameSkips = obj.frameSkips;
        end

        function set.frameSkips(obj, value)
            obj.frameSkips = value;
        end

    end
end
