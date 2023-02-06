classdef StatusMessage
    properties (Access = public)
        statusString;
        statusType;
    end
    
    methods
        function obj = StatusMessage(statusString, statusType)
            obj.statusString = statusString;
            obj.statusType = statusType;
        end
    end

end