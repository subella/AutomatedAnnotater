classdef ManualAligningController < BaseAlignedVisibleAnnotatedUIController
    %% Properties
    properties
        newTargetWrtCam;
        newTargetWrtTarget;

        x;
        y;
        z;
        roll;
        pitch;
        yaw;
    end
    %% Constructor
     methods
         function obj = ManualAligningController(baseParams, ...
                                                 inputParams, ...
                                                 visibilityParams)

            obj@BaseAlignedVisibleAnnotatedUIController(baseParams, ...
                                                        inputParams, ...
                                                        visibilityParams)
            if ~obj.isReady
                return;
            end

            if isempty(obj.annotatedPoints)
                obj.statusHandler.disp(StatusMessage("No CAD frame found! Run the annotating tab to make an initial CAD frame first!", 2));
                obj.isReady = false;
                return;
            end

            obj.statusHandler.disp(StatusMessage("Created!", 0));

            obj.newTargetWrtTarget = eye(4, 4);
            obj.newTargetWrtTarget(1:3, 4) = mean(obj.annotatedPoints)';
            obj.x = 0;
            obj.y = 0;
            obj.z = 0;
            obj.roll = 0;
            obj.pitch = 0;
            obj.yaw = 0;

        end

     end
    %% Overrides
    methods (Access = protected)

    end
    %% Helper Functions
    methods

        function updateState(obj)
            if obj.calibrationTargetHandler.isValid
                eulZYX = rotm2eul(obj.newTargetWrtTarget(1:3, 1:3));
                obj.roll = eulZYX(1);
                obj.pitch = eulZYX(2);
                obj.yaw = eulZYX(3);
                obj.updateNewTargetWrtCam();
                obj.x = obj.newTargetWrtCam(1, 4);
                obj.y = obj.newTargetWrtCam(2, 4);
                obj.z = obj.newTargetWrtCam(3, 4);
                
            end
        end

        function updateNewTargetWrtCam(obj)
            targetWrtGrid = makeHomo(obj.targetWrtGrid_R', obj.targetWrtGrid_t);
            newTargetWrtGrid = targetWrtGrid * obj.newTargetWrtTarget;
            obj.newTargetWrtCam = obj.calibrationTargetHandler.gridWrtCam * newTargetWrtGrid;
        end

        function updateAnnotatedPoints(obj)

            targetWrtGrid = makeHomo(obj.targetWrtGrid_R', obj.targetWrtGrid_t);
            
            newTargetWrtGrid = targetWrtGrid * obj.newTargetWrtTarget;
            obj.newTargetWrtCam = obj.calibrationTargetHandler.gridWrtCam * newTargetWrtGrid;
            obj.newTargetWrtCam(1, 4) = obj.x;
            obj.newTargetWrtCam(2, 4) = obj.y;
            obj.newTargetWrtCam(3, 4) = obj.z;
%             obj.newTargetWrtCam(1:3, 1:3) = eul2rotm(eulZYX);

            newTargetWrtGrid = inv(obj.calibrationTargetHandler.gridWrtCam) * obj.newTargetWrtCam;

            eulZYX = [obj.roll obj.pitch obj.yaw];
            obj.newTargetWrtTarget(1:3, 1:3) = eul2rotm(eulZYX);
            disp(obj.newTargetWrtTarget);
            targetWrtGrid = newTargetWrtGrid * inv(obj.newTargetWrtTarget);
            obj.targetWrtGrid_R = targetWrtGrid(1:3, 1:3)';
            obj.targetWrtGrid_t = targetWrtGrid(1:3, 4)';

            if obj.isRunning
                obj.updateAndDisplayCurrentImage();
            end
            
        end

    end
    %% Input Handler Functions
    methods        
        
        function handleSubtractX(obj)
            if obj.calibrationTargetHandler.isValid
                obj.updateState();
                obj.x = obj.x - 1;
                obj.updateAnnotatedPoints();
            end      
        end

        function handleSetX(obj, value)
            if obj.calibrationTargetHandler.isValid
                obj.updateState();
                obj.x = value;
                obj.updateAnnotatedPoints();
            end      
        end

        function handleAddX(obj)
            if obj.calibrationTargetHandler.isValid
                obj.updateState();
                obj.x = obj.x + 1;
                obj.updateAnnotatedPoints();
            end      
        end

        function handleSubtractY(obj)
            if obj.calibrationTargetHandler.isValid
                obj.updateState();
                obj.y = obj.y - 1;
                obj.updateAnnotatedPoints();
            end      
        end

        function handleSetY(obj, value)
            if obj.calibrationTargetHandler.isValid
                obj.updateState();
                obj.y = value;
                obj.updateAnnotatedPoints();
            end      
        end

        function handleAddY(obj)
            if obj.calibrationTargetHandler.isValid
                obj.updateState();
                obj.y = obj.y + 1;
                obj.updateAnnotatedPoints();
            end      
        end

        function handleSubtractZ(obj)
            if obj.calibrationTargetHandler.isValid
                obj.updateState();
                obj.z = obj.z - 1;
                obj.updateAnnotatedPoints();
            end      
        end

        function handleSetZ(obj, value)
            if obj.calibrationTargetHandler.isValid
                obj.updateState();
                obj.z = value;
                obj.updateAnnotatedPoints();
            end      
        end

        function handleAddZ(obj)
            if obj.calibrationTargetHandler.isValid
                obj.updateState();
                obj.z = obj.z + 1;
                obj.updateAnnotatedPoints();
            end      
        end

        function handleSubtractRoll(obj)
            if obj.calibrationTargetHandler.isValid
                obj.updateState();
                obj.roll = obj.roll - .1;
                obj.updateAnnotatedPoints();
            end      
        end

        function handleSetRoll(obj, value)
            if obj.calibrationTargetHandler.isValid
                obj.updateState();
                obj.roll = value;
                obj.updateAnnotatedPoints();
            end      
        end

        function handleAddRoll(obj)
            if obj.calibrationTargetHandler.isValid
                obj.updateState();
                obj.roll = obj.roll + .1;
                obj.updateAnnotatedPoints();
            end      
        end
        function handleSubtractPitch(obj)
            if obj.calibrationTargetHandler.isValid
                obj.updateState();
                obj.pitch = obj.pitch - .1;
                obj.updateAnnotatedPoints();
            end      
        end

        function handleSetPitch(obj, value)
            if obj.calibrationTargetHandler.isValid
                obj.updateState();
                obj.pitch = value;
                obj.updateAnnotatedPoints();
            end      
        end

        function handleAddPitch(obj)
            if obj.calibrationTargetHandler.isValid
                obj.updateState();
                obj.pitch = obj.pitch + .1;
                obj.updateAnnotatedPoints();
            end      
        end

        function handleSubtractYaw(obj)
            if obj.calibrationTargetHandler.isValid
                obj.updateState();
                obj.yaw = obj.yaw - .1;
                obj.updateAnnotatedPoints();
            end      
        end

        function handleSetYaw(obj, value)
            if obj.calibrationTargetHandler.isValid
                obj.updateState();
                obj.yaw = value;
                obj.updateAnnotatedPoints();
            end      
        end

        function handleAddYaw(obj)
            if obj.calibrationTargetHandler.isValid
                obj.updateState();
                obj.yaw = obj.yaw + .1;
                obj.updateAnnotatedPoints();
            end      
        end

    end

    %% Getters/Setters Functions
    methods

        function x = get.x(obj)
            x = obj.x;
        end

        function setX(obj, value)
            if obj.calibrationTargetHandler.isValid
                obj.x = value;
                obj.updateAnnotatedPoints();
                if obj.isRunning
                    obj.updateAndDisplayCurrentImage();
                end
            else
                obj.x = 0;
            end
        end
        
    end
    
end