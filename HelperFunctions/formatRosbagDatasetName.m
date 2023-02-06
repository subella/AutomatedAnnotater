function filename = formatRosbagDatasetName(folder, bagPath)
    splitArray = split(bagPath, "/");
    bagName = splitArray(length(splitArray));
    splitBag = split(bagName, ".");
    bagName = splitBag(1);
    filename = folder + '/' + bagName;
end