//In this section we correct the errors in Sholl image

waitForUser("Select folder", "Select folder that contains the Stage1 images");
directory = getDirectory("Choose a Directory");

filelist = getFileList(directory);
for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], "Sholl.czi")) {       //Be careful to use the right post-fix!
//open(directory + File.separator + filelist[i]);
run("Bio-Formats Importer", "open=["+directory + File.separator + filelist[i]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");

OriginalTitle = getTitle();

CurrentFile = replace(OriginalTitle,"Sholl.czi","Sholl.tif");


open(directory + CurrentFile);

run("Tile");
run("Color Picker...");

waitForUser("Correct image", "Please correct the image, \nthen press OK");

selectImage(CurrentFile);
save(directory + "\\" + CurrentFile);
close("*");
    }
}
waitForUser("Stage done", "Correction is done.");
