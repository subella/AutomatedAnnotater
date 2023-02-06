classdef VisibilityDetector < handle
    properties

        intrinsics;

        useVisibilityDetector;
        temporalFilter;
        updateTemporalFilter;
        useTemporalFilter;
        slidingWindowSize;
        useSpatialFilter;
        blockSize;
        tolerance;

        lastDetection;

    end

    methods
        function obj = VisibilityDetector(intrinsics, ...
                                          numKeypoints, ...
                                          visibilityParams)
            
            obj.intrinsics = intrinsics;

            if ~isfield(visibilityParams, 'useVisibilityDetector')
                obj.useVisibilityDetector = false;
            else
                obj.useVisibilityDetector = visibilityParams.useVisibilityDetector;
            end

            if ~isfield(visibilityParams, 'updateTemporalFilter')
                obj.updateTemporalFilter = false;
            else
                obj.updateTemporalFilter = visibilityParams.updateTemporalFilter;
            end

            if ~isfield(visibilityParams, 'useTemporalFilter')
                obj.useTemporalFilter = false;
            else
                obj.useTemporalFilter = visibilityParams.useTemporalFilter;
            end

            % useTemporalFilter should never be set without update too
            if obj.useTemporalFilter
                obj.updateTemporalFilter = true;
            end

            if ~isfield(visibilityParams, 'slidingWindowSize')
                obj.slidingWindowSize = 20;
            else
                obj.slidingWindowSize = visibilityParams.slidingWindowSize;
            end
            obj.temporalFilter = MultidimensionalQueue(numKeypoints, ...
                                                       obj.slidingWindowSize);
            obj.lastDetection = zeros(numKeypoints, 1);

            if ~isfield(visibilityParams, 'useSpatialFilter')
                obj.useSpatialFilter = true;
            else
                obj.useSpatialFilter = visibilityParams.useSpatialFilter;
            end

            if obj.useSpatialFilter
                if ~isfield(visibilityParams, 'blockSize')
                    obj.blockSize = 3;
                else
                    obj.blockSize = visibilityParams.blockSize;
                end
            else
                obj.blockSize = 0;
            end
            
            if ~isfield(visibilityParams, 'tolerance')
                obj.tolerance = 30;
            else
                obj.tolerance = visibilityParams.tolerance;
            end
            
        end

        function visibleKeypoints = isVisible(obj, depthImage, annotatedPoints, R, t, tagWrtGrid_R, tagWrtGrid_t, shouldUpdate)
            if obj.useVisibilityDetector

                currentVisibleKeypoints = isVisibleSingleFrame(obj, depthImage, annotatedPoints, R, t, tagWrtGrid_R, tagWrtGrid_t);
                if obj.updateTemporalFilter && shouldUpdate
                    obj.temporalFilter.add(currentVisibleKeypoints);
                end

                if obj.useTemporalFilter
                   averagedVisibleKeypoints = mode(obj.temporalFilter.queue, 2);
%                     visibleKeypoints = isVisibleAveragedFrames(obj, depthImage, annotatedPoints, R, t, tagWrtGrid_R, tagWrtGrid_t);
                    visibleKeypoints = averagedVisibleKeypoints;
                else
                    visibleKeypoints = currentVisibleKeypoints;
                end
            else
                visibleKeypoints = 2 * ones(size(annotatedPoints, 1), 1);
            end
        end

%         function visibleKeypoints = isVisibleAveragedFrames(obj, depthImage, annotatedPoints, R, t, tagWrtGrid_R, tagWrtGrid_t)
% 
%             if isnan(annotatedPoints)
%                 visibleKeypoints = nan;
%                 return;
%             end
% 
%             currentVisibleKeypoints = isVisibleSingleFrame(obj, depthImage, annotatedPoints, R, t, tagWrtGrid_R, tagWrtGrid_t);
%             obj.temporalFilter.add(currentVisibleKeypoints);
%             visibleKeypoints = mode(obj.temporalFilter.queue, 2);
% 
%         end

        function visibleKeypoints = isVisibleSingleFrame(obj, depthImage, annotatedPoints, R, t, tagWrtGrid_R, tagWrtGrid_t)

            if isnan(annotatedPoints)
                visibleKeypoints = nan;
                return;
            end
            visibleKeypoints = zeros(size(annotatedPoints, 1), 1);
            for k = 1:size(annotatedPoints,1)

                [px, py, z] = transformTagFrameToPixels(annotatedPoints(k,:), ...
                                                         obj.intrinsics, R, t, tagWrtGrid_R, tagWrtGrid_t);
                % If its off screen, set visibility to 0.
                undistortionBuffer = 30;
                if py > size(depthImage, 1) - undistortionBuffer || py < 1  + undistortionBuffer || ...
                   px > size(depthImage, 2) - undistortionBuffer || px < 1 + undistortionBuffer
                    visibleKeypoints(k) = 0;
                else
                    % Queried the depth in a square of half-length block
                    % size around the keypoint center.
                    minX = max(1, py - obj.blockSize);
                    maxX = min(size(depthImage, 1), py + obj.blockSize);
                    minY = max(1, px - obj.blockSize);
                    maxY = min(size(depthImage, 2), px + obj.blockSize);
                    queriedZ = double(depthImage(minX:maxX, minY:maxY));
                    
                    % If every pixel is zero (hole in the depth image),
                    % default to its last predicted state.
                    if all(~queriedZ, 'all')
                        disp("All points zero for: " + num2str(k));
                        if obj.useTemporalFilter && obj.updateTemporalFilter
                            prevVisible = mode(obj.temporalFilter.queue, 2);
                        else
                            prevVisible = obj.lastDetection;
                        end
                        visibleKeypoints(k) = prevVisible(k);
                    else 
                        % If number of visible keypoints in the square is 
                        % greater than number of occluded, it is visible.
%                         numOccluded = length(find(z ./ nonzeros(queriedZ) - 1 > obj.tolerance));
%                         numVisible = length(find(z ./ nonzeros(queriedZ) - 1 <= obj.tolerance));
                        numOccluded = length(find(z - nonzeros(queriedZ) > obj.tolerance));
                        numVisible = length(find(z - nonzeros(queriedZ) <= obj.tolerance));
                        if numVisible > numOccluded
                            visibleKeypoints(k) = 2;
                        else
                            visibleKeypoints(k) = 1;
                        end
                        visibleKeypoints(k) = 2;
                    end
                end
            end
            obj.lastDetection = visibleKeypoints;
        end
    end

    %% Getters / Setters
    methods
       function useTemporalFilter = get.useTemporalFilter(obj)
            useTemporalFilter = obj.useTemporalFilter;
        end

        function set.useTemporalFilter(obj, value)
            obj.useTemporalFilter = value;
        end

        function slidingWindowSize = get.slidingWindowSize(obj)
            slidingWindowSize = obj.slidingWindowSize;
        end

        function set.slidingWindowSize(obj, value)
%             obj.slidingWindowSize = value;
        end

        function useSpatialFilter = get.useSpatialFilter(obj)
            useSpatialFilter = obj.useSpatialFilter;
        end

        function set.useSpatialFilter(obj, value)
            obj.useSpatialFilter = value;
        end

        function blockSize = get.blockSize(obj)
            blockSize = obj.blockSize;
        end

        function set.blockSize(obj, value)
            obj.blockSize = value;
        end

        function tolerance = get.tolerance(obj)
            tolerance = obj.tolerance;
        end

        function set.tolerance(obj, value)
            obj.tolerance = value;
        end
    end
end