//Automated Sholl analysis macro
//Before use, check filepath in line 36!

waitForUser("Select input folder", "Select Input folder, that contains the images");
directory = getDirectory("Choose a Directory");


filelist = getFileList(directory) 
for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], "Sholl.tif")) { 
        open(directory + File.separator + filelist[i]);
CurrentFile = getTitle();
        
rename("original");

Dialog.create("Channels");
Dialog.addNumber("EGFP channel number", "2");
Dialog.show();

ChNum = Dialog.getNumber();

run("Z Project...", "projection=[Sum Slices]");
run("Split Channels");


selectImage("C"+ChNum+"-SUM_original");
close("\\Others");
run("Brightness/Contrast...");

waitForUser("8-bit conversion", "Please set the min-max value of the display curve, \nthen press OK");

run("8-bit");
waitForUser("Manual correction", "Please correct the image to only contain \nthe dendritic tree, then press OK");

//Here the "projectfilename" has to be modified to the location of the .ilp file!
run("Run Pixel Classification Prediction", "projectfilename=[D:\\actin labeling comparison\\Sholl-foreground.ilp] inputimage=C"+ChNum+"-SUM_original pixelclassificationtype=Probabilities");
rename("Probabilities");

run("Split Channels");

close("C2-Probabilities");
close("C3-Probabilities");


selectImage("C1-Probabilities");

run("Threshold...");
waitForUser("Set Threshold", "Please set the desired threshold value, \nthen press OK");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Open");

imageCalculator("Multiply create", "C"+ChNum+"-SUM_original","C1-Probabilities");
selectWindow("Result of C"+ChNum+"-SUM_original");
rename(CurrentFile);
saveAs("Tiff", directory + CurrentFile + "_Sholl.tif");

setTool("line");
waitForUser("Sholl setup", "Please draw a line from the nucleus to the edge \nof the longest dendrite, then press OK");

run("Sholl Analysis...");


Table.deleteColumn("Radius (norm)Area");
Table.deleteColumn("Inters./Area");
Table.deleteColumn("log(Radius )");
Table.deleteColumn("log(Inters./Area)");

waitForUser("Save data", "Please save the appropriate data, \nthen press OK");

close("*");
close("Sholl results");
close("Threshold");
close(CurrentFile + "_Sholl_Sholl-Profiles");

    }
}