//In this section we correct the errors in Stage 1

waitForUser("Select folder", "Select folder that contains the Stage1 images");
directory = getDirectory("Choose a Directory");

filelist = getFileList(directory);
for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], "Sholl.czi")) { 
//open(directory + File.separator + filelist[i]);
run("Bio-Formats Importer", "open=["+directory + File.separator + filelist[i]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");

OriginalTitle = getTitle();
run("Z Project...", "projection=[Max Intensity]");
close(OriginalTitle);
CurrentFile = replace(OriginalTitle,"Sholl.czi","Sholl.tif");


open(directory + CurrentFile);
setMinAndMax(0, 1);
run("Tile");
run("Color Picker...");

waitForUser("Correct image", "Please correct the image, \nthen press OK");

selectImage(CurrentFile);
save(directory + "\\" + CurrentFile);
close("*");
    }
}
waitForUser("Stage done", "Stage 1 correction is done. \nNext step is Stage 2");
