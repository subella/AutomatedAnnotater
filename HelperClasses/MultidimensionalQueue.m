classdef MultidimensionalQueue < handle
    properties
        numEntries = 1;
        queueSize = 10;
        queue;
    end
    
    methods
        function obj = MultidimensionalQueue(numEntries, queueSize)
            if nargin > 0
                obj.numEntries = numEntries;
                obj.queueSize = queueSize;
            end
            obj.queue = NaN(obj.numEntries, 1);
        end

        function obj = add(obj, column)
            if isnan(obj.queue)
                obj.queue = column;
            elseif size(obj.queue, 2) < obj.queueSize
                obj.queue = [obj.queue column];
            else
                obj.queue(:, 1) = [];
                obj.queue = [obj.queue column];
            end
        end
   end
end