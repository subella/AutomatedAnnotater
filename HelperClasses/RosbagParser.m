classdef RosbagParser
    properties (Access = public)
        statusHandler;
        bagName;
        bag;
        rgbImageMessages;
        depthImageMessages;
        numImages;
        imageSize;
        intrinsics;
        folder;

        isReady;
    end
    
    methods
        function obj = RosbagParser(statusHandler, bagName, ...
                                    rgbImageTopic, depthImageTopic, ...
                                    cameraInfoTopic, localCameraCalibrationFile, ...
                                    useLocalCameraCalibration, folder)
            obj.isReady = false;
            obj.statusHandler = statusHandler;
            obj.bagName = bagName;
            obj.folder = folder;
            try
                bag = rosbag(bagName);
                obj.statusHandler.disp(StatusMessage("Successfully opened rosbag.", 0));
            catch e
                obj.statusHandler.disp(StatusMessage(e.message, 2));
                return;
            end
            
           
            rgbImageSelect = select(bag, 'Topic', rgbImageTopic);
            obj.rgbImageMessages = readMessages(rgbImageSelect, 'DataFormat', 'struct');
            
            if isempty(obj.rgbImageMessages)
                obj.statusHandler.disp(StatusMessage("No RGB images found. Is the topic correct?", 2));
                return;
            else
                obj.statusHandler.disp(StatusMessage("Successfully parsed RGB images.", 0));
            end
            
            
            depthImageSelect = select(bag, 'Topic', depthImageTopic);
            obj.depthImageMessages = readMessages(depthImageSelect, 'DataFormat', 'struct');
            if isempty(obj.depthImageMessages)
                obj.statusHandler.disp(StatusMessage("No depth images found. Is the topic correct?", 2));
                return;
            else
                obj.statusHandler.disp(StatusMessage("Successfully parsed depth images.", 0));
            end

            
            obj.numImages = min(length(obj.rgbImageMessages), length(obj.depthImageMessages));
            obj.imageSize = size(rosReadImage(obj.rgbImageMessages{1}));

            if useLocalCameraCalibration
                try
                    params = load(localCameraCalibrationFile);
                    obj.intrinsics = params.cameraParams.Intrinsics;
                    obj.statusHandler.disp(StatusMessage("Successfully loaded intrinsics.", 0));
                catch
                    obj.statusHandler.disp(StatusMessage("Couldn't load intrinsics. " + ...
                                             "Ensure the path is correct " + ...
                                             "and the variable is named 'cameraParams'", 2));
                    return;
                end
            else
                obj.intrinsics = obj.parseIntrinsics(cameraInfoTopic);
            end

            obj.isReady = true;
        end

        function [rgbImage, depthImage] = parseRGBDImage(obj, index)
            assert(index >= 1 && index <= obj.numImages);
            rgbImage = rosReadImage(obj.rgbImageMessages{index});
            depthImage = rosReadImage(obj.depthImageMessages{index});  
        end

        % TODO: Parse from actual topic.
        function intrinsics = parseIntrinsics(obj, cameraInfoTopic)
%                  SDrone D455 PARAMS
            imageSize = [720 1280];
            intrinsicMatrix = [635.2426147460938, 0.0, 643.0897216796875;
                               0.0, 634.5845336914062, 370.1532592773437;
                               0.0, 0.0, 1.0];
            distortionCoefficients = [-0.05738002806901932, 0.07048306614160538,...
                                      -0.00013681600103154778, 6.35993346804753e-05,...
                                      -0.022797999903559685];
            intrinsics = cameraIntrinsicsFromOpenCV(intrinsicMatrix,distortionCoefficients,imageSize);
% %             D455 PARAMS
%             imageSize = [720 1280];
%             intrinsicMatrix = [629.1040649414062, 0.0, 637.203369140625; 
%                                0.0, 628.583251953125, 380.56463623046875; 
%                                0.0, 0.0, 1.0];
%             distortionCoefficients = [-0.05645526200532913, 0.066578209400177, ...
%                                       0.001121381763368845, 0.00026904564583674073, ...
%                                       -0.021052714437246323];
%             intrinsics = cameraIntrinsicsFromOpenCV(intrinsicMatrix,distortionCoefficients,imageSize);
%             AZURE PARAMS
%             imageSize = [720 1280];
%             intrinsicMatrix = [615.221435546875, 0.0, 638.0890502929688; 
%                                0.0, 615.3164672851562, 368.7926025390625; 
%                                0.0, 0.0, 1.0];
% %             intrinsicMatrix = [984.3543090820312, 0.0, 1021.2424926757812; 0.0, 984.50634765625, 782.3681640625; 0.0, 0.0, 1.0]
% 
%             distortionCoefficients = [0.06807911, -0.02809412,  0.00466678,  0.00043785, 0];
%             intrinsics = cameraIntrinsicsFromOpenCV(intrinsicMatrix,distortionCoefficients,imageSize);
%             disp(intrinsics.RadialDistortion)
%             disp(intrinsics.TangentialDistortion)

        end
   end
end