function filename = formatRosbagFilename(folder, prefix, bagName)
    bagName = replace(bagName,'/','_');
    bagName = replace(bagName, ".bag", ".mat");
    filename = folder + '/' + prefix + bagName;
end