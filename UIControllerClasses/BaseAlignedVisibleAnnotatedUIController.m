classdef BaseAlignedVisibleAnnotatedUIController < BaseVisibleAnnotatedUIController
    %% Properties
    properties
        targetWrtGrid_R;
        targetWrtGrid_t;

        targetWrtGrid;
    end

    %% Constructor
    methods

        function obj = BaseAlignedVisibleAnnotatedUIController(baseParams, ...
                                                               inputParams, ...
                                                               visibilityParams)
            obj@BaseVisibleAnnotatedUIController(baseParams, ...  
                                                 inputParams, ...
                                                 visibilityParams);
            if ~obj.isReady
                return;
            end

            filename = formatRosbagFilename("Transform", "transform", ...
                                            baseParams.rosbagParser.bagName);

            try
                transform = load(filename);
                % TODO: Refactor everything to just use T, make these
                % transposes consistent.
                targetWrtGrid = transform.targetWrtGrid;
                obj.targetWrtGrid = targetWrtGrid;
                obj.targetWrtGrid_R = targetWrtGrid(1:3, 1:3)';
                obj.targetWrtGrid_t = targetWrtGrid(1:3, 4)';
                obj.statusHandler.disp(StatusMessage("Loading target wrt grid transform from file :" + ...
                                                     filename, 0));
            catch
                obj.statusHandler.disp(StatusMessage("No target wrt grid transform found! Searched for file :" + ...
                                                     filename + "Defaulting to the identity", 1));
                obj.targetWrtGrid = eye(4);
                obj.targetWrtGrid_R = eye(3);
                obj.targetWrtGrid_t = zeros(1, 3);
            end
            
        end

    end

    %% Overrides
    methods (Access = protected)

        function annotateCurrentImage(obj)
            annotateCurrentImage@BaseAnnotatedUIController(obj);
            if obj.calibrationTargetHandler.isValid && ~isempty(obj.annotatedPoints)
                % Don't update visibility if the frame never changed.
                if obj.updatedFrame ~= obj.currentFrame
                    updateTemporalFilter = true;
                else
                    updateTemporalFilter = false;
                end
    
                obj.pointsVisibility = obj.visibilityDetector.isVisible(obj.depthImage, obj.annotatedPoints, ...
                                                                        obj.calibrationTargetHandler.R, obj.calibrationTargetHandler.t, ...
                                                                        obj.targetWrtGrid_R, obj.targetWrtGrid_t, ...
                                                                        updateTemporalFilter);
                
                
                obj.plotAnnotatedPoints();
            end
        end
        
    end

    %% Helper Functions
    methods

        function plotAnnotatedPoints(obj)
            imagePoints = tagToImage(obj.annotatedPoints, obj.intrinsics, ...
                                     obj.calibrationTargetHandler.R, obj.calibrationTargetHandler.t, ...
                                     obj.targetWrtGrid_R, obj.targetWrtGrid_t);

            visiblePoints = imagePoints(obj.pointsVisibility == 2, :);
            nonVisiblePoints = imagePoints(obj.pointsVisibility == 1, :);

            markerPosition = [visiblePoints, repmat(1.5, size(visiblePoints, 1),1)];
            obj.annotatedImage = insertShape(obj.annotatedImage,"FilledCircle",markerPosition,"Color","green","Opacity",1);

            markerPosition = [nonVisiblePoints, repmat(1.5, size(nonVisiblePoints, 1),1)];
            obj.annotatedImage = insertShape(obj.annotatedImage,"FilledCircle",markerPosition,"Color","red","Opacity",1);

            if obj.showKeypointNumbers
                indices = linspace(1, size(imagePoints, 1), size(imagePoints, 1));
                obj.annotatedImage = insertText(obj.annotatedImage, imagePoints, string(indices));
            end
        end

        function pixels = transformTargetFrameToPixels(obj, pointsWrtTarget)
            pointsWrtGrid = transformPointsFrames(pointsWrtTarget, obj.targetWrtGrid);
            pointsWrtCamera = transformPointsFrames(pointsWrtGrid, obj.calibrationTargetHandler.gridWrtCam);
            pxpyzs = transformPointsToPixels(pointsWrtCamera, obj.intrinsics);
            pixels = pxpyzs(:,1:2);
        end
    end

    %% Getters / Setters
    methods
        
        
    end

end