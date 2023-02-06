classdef StatusHandler < handle
    properties (Access = public)
        statusBox;
    end
    
    methods
        function obj = StatusHandler(statusBox)
            obj.statusBox = statusBox;
        end

        function disp(obj, statusMsg)
            msg = obj.statusMsgToString(statusMsg);
            obj.statusBox.Value = [obj.statusBox.Value; msg];
            scroll(obj.statusBox, "bottom");
            drawnow;
        end
    end

    methods(Static)
        function msg = statusMsgToString(statusMsg)
            if statusMsg.statusType == 0
                msg = "[INFO] " + statusMsg.statusString;
            elseif statusMsg.statusType == 1
                msg = "[WARNING] " + statusMsg.statusString;
            elseif statusMsg.statusType == 2
                msg = "[ERROR] " + statusMsg.statusString;
            else
                msg = "Unhandled message! Something is wrong.";
            end
        end

    end

end