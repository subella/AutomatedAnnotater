classdef GeometricAligningController < AnnotatingController
    %% Properties
    properties
        alignmentPoints;
        oldAnnotatedPoints;
        targetWrtGrid_R_2;
        targetWrtGrid_t_2;
    end
    %% Constructor
     methods
         function obj = GeometricAligningController(baseParams, ...
                                                    inputParams, ...
                                                    visibilityParams)

            obj@AnnotatingController(baseParams, ...
                                     inputParams, ...
                                     visibilityParams);
            if ~obj.isReady
                return;
            end

            obj.alignmentPoints = obj.annotatedPoints;
            obj.oldAnnotatedPoints = [];
            obj.annotatedPoints = [];
            obj.lastKeypoint = size(obj.annotatedPoints, 1);

        end

     end

    %% Input Handler Functions
    methods
% 
%         function handleSubtractFrames(obj)
%             handleSubtractFrames@AnnotatingController(obj);
%             disp(obj.targetWrtGrid_R);
%         end
% 
%         function handleAddFrames(obj)
%             handleAddFrames@AnnotatingController(obj);
%             obj.annotatedPoints = obj.oldAnnotatedPoints;
%         end
% 
%         function handleAddKeypoint(obj)
%             handleAddKeypoint@AnnotatingController(obj);
%             obj.oldAnnotatedPoints = obj.annotatedPoints;
%         end
% 
%         function handleSubtractDepth(obj, keypoint)
%             obj.deltaKeypointDepth(keypoint, -1);
%             obj.updateAndDisplayCurrentImage();
%             obj.oldAnnotatedPoints = obj.annotatedPoints;
%         end
% 
%         function handleSetDepth(obj, keypoint, value)
%             obj.setKeypointDepth(keypoint, value);
%             obj.updateAndDisplayCurrentImage();
%             obj.oldAnnotatedPoints = obj.annotatedPoints;
%         end
% 
%         function handleAddDepth(obj, keypoint)
%             obj.deltaKeypointDepth(keypoint, 1);
%             obj.updateAndDisplayCurrentImage();
%             obj.oldAnnotatedPoints = obj.annotatedPoints;
%         end

        function handleAlign(obj)
%             obj.annotatedPoints = obj.oldAnnotatedPoints;

%             alignmentIndices = [1, 2, 3, 4, 36, 23];
            alignmentIndices = [5,6,7,8,33,29,20];

            [transform,inlier] = estimateGeometricTransform3D(obj.alignmentPoints(alignmentIndices, :), ...
                                                              obj.annotatedPoints, 'rigid', 'MaxDistance', 5);


            targetWrtCad = makeHomo(transform.Rotation',transform.Translation);
            obj.targetWrtGrid_R_2 = transform.Rotation;
            obj.targetWrtGrid_t_2 = transform.Translation;
            targetWrtGrid = makeHomo(obj.targetWrtGrid_R_2', obj.targetWrtGrid_t_2);
%             obj.handleFinish();
%             disp(targetWrtGrid)
%             pointsWrtTarget = zeros(size(obj.alignmentPoints));
%             for id=1:size(pointsWrtTarget, 1)
%                 pointWrtCad = obj.alignmentPoints(id, :);
%                 pointWrtTarget = inv(targetWrtCad) * [pointWrtCad 1]';
%                 pointsWrtTarget(id, :) = pointWrtTarget(1:3, :)';
%             end

            disp (obj.annotatedPoints);
%             disp(pointsWrtTarget(alignmentIndices,:))

            obj.targetWrtGrid_R = transform.Rotation;
            obj.targetWrtGrid_t = transform.Translation;
            obj.oldAnnotatedPoints = obj.annotatedPoints;
            obj.annotatedPoints = obj.alignmentPoints;
            obj.updateAndDisplayCurrentImage();
            obj.annotatedPoints = obj.oldAnnotatedPoints;
            obj.targetWrtGrid_R = eye(3,3);
            obj.targetWrtGrid_t = zeros(1,3);
            disp(obj.annotatedPoints);

            mkdir Transform
            filename = formatRosbagFilename("Transform", "transform", ...
                                            obj.rosbagParser.bagName);

            targetWrtGrid = makeHomo(obj.targetWrtGrid_R_2', obj.targetWrtGrid_t_2);
            save(filename, 'targetWrtGrid');
        end

        function handleFinish(obj)
            handleFinish@BaseAnnotatedUIController(obj);
            mkdir Transform
            filename = formatRosbagFilename("Transform", "transform", ...
                                            obj.rosbagParser.bagName);

            targetWrtGrid = makeHomo(obj.targetWrtGrid_R_2', obj.targetWrtGrid_t_2);
            save(filename, 'targetWrtGrid');
        end

    end
end