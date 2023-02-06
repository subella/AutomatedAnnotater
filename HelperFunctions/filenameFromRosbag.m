function filename = filenameFromRosbag(mainFolder, subFolder, bagPath)
    folder = folderFromRosbag(mainFolder, subFolder, bagPath);
    filename = folder + ".mat";
end