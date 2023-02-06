classdef BaseVisibleAnnotatedUIController < BaseAnnotatedUIController
    %% Properties
    properties

        annotatedPoints;
        annotatedPointsFrame;
        annotatedPoints_R;
        annotatedPoints_t;

        pointsVisibility;

        showKeypointNumbers;
        visibilityDetector;

    end

    %% Constructor
    methods

        function obj = BaseVisibleAnnotatedUIController(baseParams, ...
                                                        inputParams, ...
                                                        visibilityParams)
            obj@BaseAnnotatedUIController(baseParams);
            if ~obj.isReady
                return;
            end

            filename = filenameFromRosbag(obj.rosbagParser.folder, ...
                                          "AnnotatedPoints", ...
                                          obj.rosbagParser.bagName);
            try
                annotations = load(filename);
                obj.annotatedPoints = annotations.annotatedPoints;
                obj.annotatedPoints_R = annotations.annotatedPoints_R;
                obj.annotatedPoints_t = annotations.annotatedPoints_t;
                obj.statusHandler.disp(StatusMessage("Loading previous annotations from file :" + ...
                                                     filename, 0));
            catch
                obj.annotatedPoints = [];
                obj.annotatedPoints_R = [];
                obj.annotatedPoints_t = [];
                obj.statusHandler.disp(StatusMessage("No previous annotations found! Searched for file :" + ...
                                                     filename, 1));
            end
            
            obj.showKeypointNumbers = inputParams.showKeypointNumbers;
            obj.visibilityDetector = VisibilityDetector(obj.intrinsics,...
                                                        size(obj.annotatedPoints, 1), ...
                                                        visibilityParams);
            
        end

    end

    %% Overrides
    methods (Access = protected)
       
    end
    %% Helper Functions
    methods
        
    end
    

    %% Getters / Setters
    methods

        function showKeypointNumbers = get.showKeypointNumbers(obj)
            showKeypointNumbers = obj.showKeypointNumbers;
        end

        function set.showKeypointNumbers(obj, value)
            obj.showKeypointNumbers = value;
            if obj.isRunning
                obj.updateAndDisplayCurrentImage();
            end
        end

        % TODO: better way to do this?
        % Fake getters/setters (public interface to visibility detector)
        function useVisibilityDetector = getUseVisibilityDetector(obj)
            useVisibilityDetector = obj.visibilityDetector.useVisibilityDetector;
        end

        function setUseVisibilityDetector(obj, value)
            obj.visibilityDetector.useVisibilityDetector = value;
            if obj.isRunning
                obj.updateAndDisplayCurrentImage();
            end
        end

        function useTemporalFilter = getUseTemporalFilter(obj)
            useTemporalFilter = obj.visibilityDetector.useTemporalFilter;
        end

        function setUseTemporalFilter(obj, value)
            obj.visibilityDetector.useTemporalFilter = value;
            if obj.isRunning
                obj.updateAndDisplayCurrentImage();
            end
        end

        function slidingWindowSize = getSlidingWindowSize(obj)
            slidingWindowSize = obj.visiblityDetector.slidingWindowSize;
        end

        % TODO: Can't actually change sliding window size on the fly.
        function setSlidingWindowSize(obj, value)
            obj.statusHandler.disp(StatusMessage("Currently changing the window size during runtime is not supported!", 2));
%             obj.visibilityDetector.slidingWindowSize = value;
        end

        function useSpatialFilter = getUseSpatialFilter(obj)
            useSpatialFilter = obj.visibilityDetector.useSpatialFilter;
        end

        function setUseSpatialFilter(obj, value)
            obj.visibilityDetector.useSpatialFilter = value;
            if obj.isRunning
                obj.updateAndDisplayCurrentImage();
            end
        end

        function blockSize = getBlockSize(obj)
            blockSize = obj.visibilityDetector.blockSize;
        end

        function setBlockSize(obj, value)
            obj.visibilityDetector.blockSize = value;
            if obj.isRunning
                obj.updateAndDisplayCurrentImage();
            end
        end

        function tolerance = getTolerance(obj)
            tolerance = obj.visibilityDetector.tolerance;
        end

        function setTolerance(obj, value)
            obj.visibilityDetector.tolerance = value;
            if obj.isRunning
                obj.updateAndDisplayCurrentImage();
            end
        end

       
    end

end