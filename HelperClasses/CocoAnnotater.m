classdef CocoAnnotater < handle

    properties
        cocoData
        dataCounter;
        globalDataCounter;

        keypoints;

        dataFolders;
        intrinsics;
    end

    methods
        function obj = CocoAnnotater(intrinsics, bagName, folder, keypoints)

            cocoData = struct();
            cocoData.info.description = "D455 Keypoint Dataset.";
            cocoData.info.data = date;
            cocoData.licenses = [];
            keypointLabels = 1:size(keypoints,1);
            cocoData.categories = {struct('id', 0, 'name', "Target", 'supercategory', "Target", ...
                                          'skeleton', [[0,0]], 'keypoints', keypointLabels)};
            cocoData.keypointFrame.localKeypoints = keypoints;


%             obj.cocoData = [cocoData cocoData];
            obj.cocoData = [cocoData];
            obj.dataCounter = [1 1];
            obj.globalDataCounter = 1;

            obj.keypoints = keypoints;
            

            obj.intrinsics = intrinsics;
            datasetName = folderFromRosbag(folder, "Datasets/Training", bagName) + "/";
            trainingFolder = datasetName + "Training/";
            validationFolder = datasetName + "Validation/";
%             obj.dataFolders = [trainingFolder validationFolder];
%             obj.dataFolders = [datasetName datasetName];
            obj.dataFolders = [datasetName];
    
            for id=1:length(obj.dataFolders)
                folder = obj.dataFolders(id);
                status = rmdir(folder);
                mkdir(folder);
            end
            
        end
        
        function addData(obj, rgbImage, depthImage, keypointsVisibility, R, t, tagWrtGrid_R, tagWrtGrid_t)
            
            if mod(obj.globalDataCounter, 5) == 0
                datasetId = 2;
            else
                datasetId = 1;
            end

            % Get rid of validation for now
            datasetId = 1;

            image = struct();
            image.file_name = "rgb_image_" + num2str(obj.dataCounter(datasetId)) + ".png";   
            image.id = obj.dataCounter(datasetId);
            image.height = size(rgbImage, 1);
            image.width = size(rgbImage, 2);            

            annotation = struct();
            annotation.depth_file_name = "depth_image_" + num2str(obj.dataCounter(datasetId)) + ".png";
            annotation.image_id = obj.dataCounter(datasetId);
            annotation.id = obj.dataCounter(datasetId);
            annotation.category_id = 0;
            annotation.iscrowd = 0;
            pixelKeypoints = obj.transformTargetFrameKeypointsToPixels(obj.keypoints, R, t, tagWrtGrid_R, tagWrtGrid_t);
            annotation.keypoints = obj.formatKeypoints(pixelKeypoints, keypointsVisibility);
            annotation.num_keypoints = size(obj.keypoints, 1);
            annotation.bbox = obj.computeBBox(pixelKeypoints);
            annotation.area = obj.computeBBoxArea(annotation.bbox);

            targetWrtGrid = makeHomo(tagWrtGrid_R', tagWrtGrid_t);
            gridWrtCam = makeHomo(R', t);
            targetWrtCam = gridWrtCam * targetWrtGrid;
            annotation.localPosition = targetWrtCam(1:3,4)';
            annotation.localRotation = rotm2quat(targetWrtCam(1:3,1:3));
            annotation.groundTruthKeypoints = transformTargetFrameToCameraFrame(obj.keypoints, R, t, tagWrtGrid_R, tagWrtGrid_t);
            annotation.groundTruthPixelKeypoints = pixelKeypoints;
            

            obj.cocoData(datasetId).images(obj.dataCounter(datasetId)) = image;
            obj.cocoData(datasetId).annotations(obj.dataCounter(datasetId)) = annotation;

            imwrite(rgbImage, obj.dataFolders(datasetId) + image.file_name);
            imwrite(depthImage, obj.dataFolders(datasetId) + annotation.depth_file_name);
            obj.save();
            
            
            obj.dataCounter(datasetId) = obj.dataCounter(datasetId) + 1;
            obj.globalDataCounter = obj.globalDataCounter + 1;
        end

        function pixelKeypoints = transformTargetFrameKeypointsToPixels(obj, keypoints, R, t, tagWrtGrid_R, tagWrtGrid_t)
            pixelKeypoints = zeros(size(keypoints, 1), 2);
            for k=1:size(keypoints, 1)
                [px, py, ~] = transformTagFrameToPixels(keypoints(k, :), obj.intrinsics, R, t, tagWrtGrid_R, tagWrtGrid_t);
                pixelKeypoints(k,:) = [px, py];
            end
        end

        function cocoKeypoints = formatKeypoints(obj, pixelKeypoints, keypointsVisibility)
            cocoKeypoints = [pixelKeypoints keypointsVisibility];
            cocoKeypoints = reshape(cocoKeypoints', 1, []);
        end

        function bbox = computeBBox(obj, pixelKeypoints)
            minX = min(pixelKeypoints(:,1));
            minY = min(pixelKeypoints(:,2));
            maxX = max(pixelKeypoints(:,1));
            maxY = max(pixelKeypoints(:,2));
            width = maxX - minX;
            height = maxY - minY;
            bbox = [minX minY width height];
        end

        function area = computeBBoxArea(obj, bbox)
            area = bbox(3) * bbox(4);
        end

        function save(obj)
            for id=1:length(obj.cocoData)
                cocoString = jsonencode(obj.cocoData(id));
                fid = fopen(obj.dataFolders(id) + "metadata.json", 'w');
                fprintf(fid, '%s', cocoString);
                fclose(fid);
            end
        end
    end

end