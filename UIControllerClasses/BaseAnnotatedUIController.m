classdef BaseAnnotatedUIController < BaseUIController
    %% Properties
    properties
        annotatedImage;
    end

    %% Constructor
    methods

        function obj = BaseAnnotatedUIController(baseParams)
            obj@BaseUIController(baseParams);
            if ~obj.isReady
                return;
            end
            
            obj.annotatedImage = nan;
            
        end

    end

    %% Overrides
    methods (Access = protected)

        function annotateCurrentImage(obj)
            obj.annotatedImage = obj.calibrationTargetHandler.annotateImage(obj.rgbImage);
        end

        function displayCurrentImage(obj)
            obj.annotateCurrentImage();
            imshow(obj.annotatedImage, 'Parent', obj.axes);
        end
    
    end

end