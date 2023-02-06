function folder = folderFromRosbag(mainFolder, subFolder, bagPath)
    splitArray = split(bagPath, "/");
    bagName = splitArray(length(splitArray));
    splitBag = split(bagName, ".");
    bagName = splitBag(1);
    folder = "Data" + '/' + mainFolder + '/' + subFolder + '/' + bagName;
end