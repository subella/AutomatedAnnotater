classdef BaseManualAligningController < BaseAlignedVisibleAnnotatedUIController
    %% Properties
    properties
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
         function obj = BaseManualAligningController(baseParams, ...
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

         function updateState(obj)

         end

    end
    %% Helper Functions
    methods
        
    end
    %% Input Handler Functions
    methods        
        
        function handleSubtractX(obj)
            if obj.calibrationTargetHandler.isValid
                obj.x = obj.x - 1;
                obj.updateState();
                obj.updateAndDisplayCurrentImage();
            end      
        end

        function handleSetX(obj, value)
            if obj.calibrationTargetHandler.isValid
                obj.x = value;
                obj.updateState();
                obj.updateAndDisplayCurrentImage();
            end      
        end

        function handleAddX(obj)
            if obj.calibrationTargetHandler.isValid
                obj.x = obj.x + 1;
                obj.updateState();
                obj.updateAndDisplayCurrentImage();
            end      
        end

        function handleSubtractY(obj)
            if obj.calibrationTargetHandler.isValid
                obj.updateState();
                obj.y = obj.y - 1;
                obj.updateAndDisplayCurrentImage();
            end      
        end

        function handleSetY(obj, value)
            if obj.calibrationTargetHandler.isValid
                obj.y = value;
                obj.updateState();
                obj.updateAndDisplayCurrentImage();
            end      
        end

        function handleAddY(obj)
            if obj.calibrationTargetHandler.isValid
                obj.y = obj.y + 1;
                obj.updateState();
                obj.updateAndDisplayCurrentImage();
            end      
        end

        function handleSubtractZ(obj)
            if obj.calibrationTargetHandler.isValid
                obj.z = obj.z - 1;
                obj.updateState();
                obj.updateAndDisplayCurrentImage();
            end      
        end

        function handleSetZ(obj, value)
            if obj.calibrationTargetHandler.isValid
                obj.updateState();
                obj.z = value;
                obj.updateAndDisplayCurrentImage();
            end      
        end

        function handleAddZ(obj)
            if obj.calibrationTargetHandler.isValid
                obj.updateState();
                obj.z = obj.z + 1;
                obj.updateAndDisplayCurrentImage();
            end      
        end

        function handleSubtractRoll(obj)
            if obj.calibrationTargetHandler.isValid
                obj.roll = obj.roll - .1;
                obj.updateState();
                obj.updateAnnotatedPoints();
            end      
        end

        function handleSetRoll(obj, value)
            if obj.calibrationTargetHandler.isValid
                obj.roll = value;
                obj.updateState();
                obj.updateAndDisplayCurrentImage();
            end      
        end

        function handleAddRoll(obj)
            if obj.calibrationTargetHandler.isValid
                obj.roll = obj.roll + .1;
                obj.updateState();
                obj.updateAndDisplayCurrentImage();
            end      
        end
        function handleSubtractPitch(obj)
            if obj.calibrationTargetHandler.isValid
                obj.pitch = obj.pitch - .1;
                obj.updateState();
                obj.updateAndDisplayCurrentImage();
            end      
        end

        function handleSetPitch(obj, value)
            if obj.calibrationTargetHandler.isValid
                obj.pitch = value;
                obj.updateState();
                obj.updateAndDisplayCurrentImage();
            end      
        end

        function handleAddPitch(obj)
            if obj.calibrationTargetHandler.isValid
                obj.pitch = obj.pitch + .1;
                obj.updateState();
                obj.updateAndDisplayCurrentImage();
            end      
        end

        function handleSubtractYaw(obj)
            if obj.calibrationTargetHandler.isValid
                obj.yaw = obj.yaw - .1;
                obj.updateState();
                obj.updateAndDisplayCurrentImage();
            end      
        end

        function handleSetYaw(obj, value)
            if obj.calibrationTargetHandler.isValid
                obj.yaw = value;
                obj.updateState();
                obj.updateAndDisplayCurrentImage();
            end      
        end

        function handleAddYaw(obj)
            if obj.calibrationTargetHandler.isValid
                obj.yaw = obj.yaw + .1;
                obj.updateState();
                obj.updateAndDisplayCurrentImage();
            end      
        end

    end

    %% Getters/Setters Functions
    methods

    end
    
end