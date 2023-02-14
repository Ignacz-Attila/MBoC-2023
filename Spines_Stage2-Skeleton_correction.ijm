//In this section we correct the errors in Stage 2 or Skeleton


waitForUser("Select folder", "Select folder that contains the Stage2 images");
directory = getDirectory("Choose a Directory");
filelist = getFileList(directory);
for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], "_stage2.tif")) { 				//replace to "_skeleton.tif" if skeletons are corrected
        open(directory + File.separator + filelist[i]);
		
CurrentFile = getTitle();
rename("Stage2");

//Open Stage1 and get the later spine ROIs to know where spines are going to be
Stage1Title = replace(CurrentFile,"stage2.tif","stage1.tif");	//replace stage2 to "skeleton" if skeletons are corrected
open(directory + File.separator + Stage1Title);
rename("Stage1");

setThreshold(1, 1);
setOption("BlackBackground", true);
run("Convert to Mask");


run("Options...", "iterations=1 count=6 black do=Open slice");
run("Analyze Particles...", "size=20-Infinity pixel add slice");

roiManager("Set Color", "red");
close("Stage1");

run("Color Picker...");

waitForUser("Correct image", "Please correct the image, \nthen press OK");

selectImage("Stage2");
save(directory + "\\" + CurrentFile);
close("*");
    }
}
waitForUser("Stage done", "Correction is done. \nNext step is Stage2/Skeleton or Analysis!");