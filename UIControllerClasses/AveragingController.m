classdef AveragingController < BaseAveragingController
    %% Properties
    properties

        rgbImagesAvg;
        depthImagesAvg;

        rgbImagesTotal;
        depthImagesTotal;
        numImages;

    end
    %% Constuctor
    methods
        function obj = AveragingController(statusHandler, ...
                                           calibrationTargetHandler, ...
                                           rosbagParser, ...
                                           frameSkips, ...
                                           numFramesToAverage)
            obj@BaseAveragingController(statusHandler, ...
                                        calibrationTargetHandler, ...
                                        rosbagParser, ...
                                        frameSkips, ...
                                        numFramesToAverage);
            if ~obj.isReady
                return;
            end

            obj.rgbImagesAvg = nan;
            obj.depthImagesAvg = nan;

            dimension = obj.rosbagParser.imageSize;
            obj.rgbImagesTotal = zeros(dimension(1), dimension(2), dimension(3), 'uint64');
            obj.depthImagesTotal = zeros(dimension(1), dimension(2), 'uint64');
            obj.numImages = 0;

            obj.statusHandler.disp(StatusMessage("Successfully initialized Averaging Controller :)", 0));
            
        end

    end

    %% Overrides
    methods (Access = protected)
        
        function addFrame(obj)
            addFrame@BaseAveragingController(obj);
            obj.rgbImagesTotal = obj.rgbImagesTotal + uint64(obj.rgbImage);
            obj.depthImagesTotal = obj.depthImagesTotal + uint64(obj.depthImage);
            obj.numImages = obj.numImages + 1;     
        end

        function computeAverage(obj)
            computeAverage@BaseAveragingController(obj);
            rgbImageAvg = obj.rgbImagesTotal ./ obj.numImages;
            if isnan(obj.rgbImagesAvg)
                obj.rgbImagesAvg = rgbImageAvg;
            else
                obj.rgbImagesAvg = cat(4, obj.rgbImagesAvg, rgbImageAvg);
            end

            depthImageAvg = obj.depthImagesTotal ./ obj.numImages;
            if isnan(obj.depthImagesAvg)
                obj.depthImagesAvg = depthImageAvg;
            else
                obj.depthImagesAvg = cat(3, obj.depthImagesAvg, depthImageAvg);
            end
        end

        function reset(obj)
            reset@BaseAveragingController(obj);
            dimension = obj.rosbagParser.imageSize;
            obj.rgbImagesTotal = zeros(dimension(1), dimension(2), dimension(3), 'uint64');
            obj.depthImagesTotal = zeros(dimension(1), dimension(2), 'uint64');
            obj.numImages = 0;
        end

    end
    
    methods (Access = public)

        function handleFinish(obj)
            handleFinish@BaseAveragingController(obj);
            obj.rgbImagesAvg = uint8(obj.rgbImagesAvg);
            obj.depthImagesAvg = uint16(obj.depthImagesAvg);

            mkdir Averages
            filename = formatRosbagFilename("Averages", "averages", ...
                obj.rosbagParser.bagName);
            rgbImagesAvg = obj.rgbImagesAvg;
            depthImagesAvg = obj.depthImagesAvg;
            gridTranslationsAvg = obj.gridTranslationsAvg;
            gridRotationsAvg = obj.gridRotationsAvg;

            save(filename, 'rgbImagesAvg', 'depthImagesAvg', ...
                'gridTranslationsAvg', 'gridRotationsAvg');
        end

    end
end