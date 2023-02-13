
//This is the concluding macro for spine segmentation.
//Please be aware that if color settings are not default white-black, problems might appear

waitForUser("Select folder", "Select folder that contains the images");
directory = getDirectory("Choose a Directory");

filelist = getFileList(directory);
for (a = 0; a < lengthOf(filelist); a++) {
    if (endsWith(filelist[a], "_stage1.tif")) {
        open(directory + File.separator + filelist[a]);

Stage1Title = getTitle();
rename("Stage1");
Stage2Title = replace(Stage1Title,"stage1.tif","stage2.tif");
						//Stage1 colors: 1-spine, 2-shaft, 3-edge, 4-background

open(directory + File.separator + Stage2Title);
rename("Stage2");
						//Stage2 colors: 1-head, 2-neck, 3-base, 4-shaft, 5-background

SaveTitle = replace(Stage1Title,"_stage1.tif",".tif");

SkeletonTitle = replace(Stage1Title,"stage1.tif","skeleton.tif");

open(directory + File.separator + SkeletonTitle);
rename("Skeleton");
						//Skeleton colors: 1-spine skeleton, 2-shaft skeleton, 3-spine other, 4-shaft other, 5-background

						//Creation of different channels from different Ilastik segmentations
selectImage("Stage1");
run("Duplicate...", " ");
rename("SpineMask");
setThreshold(0, 1);
setOption("BlackBackground", true);
run("Convert to Mask");

selectImage("Stage2");
run("Duplicate...", " ");
rename("HeadMask");
setThreshold(0, 1);
setOption("BlackBackground", true);
run("Convert to Mask");

selectImage("Stage2");
run("Duplicate...", " ");
rename("BaseMask");
setThreshold(3, 3);
setOption("BlackBackground", true);
run("Convert to Mask");

selectImage("Skeleton");
run("Duplicate...", " ");
rename("SpineSkeletonMask");
setThreshold(0, 1);
setOption("BlackBackground", true);
run("Convert to Mask");

selectImage("Skeleton");
run("Duplicate...", " ");
rename("ShaftSkeletonMask");
setThreshold(2, 2);
setOption("BlackBackground", true);
run("Convert to Mask");

run("Merge Channels...", "c1=SpineMask c2=HeadMask c3=BaseMask c4=SpineSkeletonMask c5=ShaftSkeletonMask create");


rename("Composite");

close("Skeleton");
close("Stage2");
close("Stage1");

selectImage("Composite");

							//Creation of arrays for the later measurements
FilenameArray = newArray(0);
FilenameArray = Array.concat(FilenameArray,SaveTitle);

SpineIDArray = newArray(0);
BranchLengthArray = newArray(0);
HeadDiameterArray = newArray(0);
BaseDiameterArray = newArray(0);
SpineLengthArray = newArray(0);

							//Skeletonize length measurement images and get rid of individual pixels

Stack.setChannel(5);
run("Options...", "iterations=1 count=8 black do=Open slice");

Stack.setChannel(4);
run("Options...", "iterations=1 count=8 black do=Open slice");

Stack.setChannel(5);
run("Options...", "iterations=1 count=1 black do=Skeletonize slice");

Stack.setChannel(4);
run("Options...", "iterations=1 count=1 black do=Skeletonize slice");

Stack.setChannel(1);
run("Options...", "iterations=1 count=8 black do=Open slice");

Stack.setChannel(1);
run("Options...", "iterations=1 count=1 black do=Fill holes slice");

Stack.setChannel(2);
run("Options...", "iterations=1 count=8 black do=Open slice");

Stack.setChannel(2);
run("Options...", "iterations=1 count=1 black do=Fill holes slice");

Stack.setChannel(3);
run("Options...", "iterations=1 count=8 black do=Open slice");

save(directory + File.separator + SaveTitle);
rename("Composite");

						//Measure dendritic length
Stack.setChannel(5);
run("Create Selection");
BranchPerimeter = getValue("Perim.");
BranchLength = BranchPerimeter/2;
BranchLengthArray = Array.concat(BranchLengthArray,BranchLength);

run("Select None");


						//Spine ROI identification and renaming the ROI-s

selectImage("Composite");
Stack.setChannel(1);
run("Analyze Particles...", "size=40-Infinity pixel add slice");
	n = roiManager('count');
	for (j = 0; j < n; j++) {
    roiManager('select', j);
    roiManager("rename", "Spine_"+(j+1));
	roiManager("update");
	}
RoiSaveTitle = replace(SaveTitle, ".tif", ".zip");	
roiManager("save", directory + File.separator + RoiSaveTitle);



							//ROI processing
n = roiManager('count');
for (k = 0; k < n; k++) {
    roiManager('select', k);
    spineID = Roi.getName;
	
	run("Duplicate...", "duplicate");
	rename(spineID);
	SpineIDArray = Array.concat(SpineIDArray,spineID);
	run("Clear Outside", "stack");
	run("Select None");

						//Head diameter - if there is no head pixel, we simply use the whole spine as head
	Stack.setChannel(2);
	MaxIntensity = getValue("Max");
	if (MaxIntensity>250) {
	
	run("Create Selection");
	run("Fit Circle");
	HeadPerimeter = getValue("Perim.");
	HeadDiameter = HeadPerimeter/3.14;
	HeadDiameterArray = Array.concat(HeadDiameterArray,HeadDiameter);
	}
	
	else {
	roiManager('select', k);
	HeadPerimeter = getValue("Perim.");
	HeadDiameter = HeadPerimeter/3.14;
	HeadDiameterArray = Array.concat(HeadDiameterArray,HeadDiameter);
	}

	selectImage(spineID);
	run("Select None");
	
						//Base diameter
	Stack.setChannel(3);
	run("Create Selection");
	BaseDiameter=getValue("Feret");
	BaseDiameterArray = Array.concat(BaseDiameterArray,BaseDiameter);

	selectImage(spineID);
	run("Select None");

						//Spine length
	Stack.setChannel(4);
	run("Create Selection");
	SpinePerimeter = getValue("Perim.");
	SpineLength = SpinePerimeter/2;
	SpineLengthArray = Array.concat(SpineLengthArray,SpineLength);

	selectImage(spineID);
	run("Select None");

						//Close the current small window
	close(spineID);	
}

//Table with the spine parameters
Table.create("Final");
Table.setColumn("Filename", FilenameArray);
Table.setColumn("Branch_length", BranchLengthArray);
Table.setColumn("Spine_ID", SpineIDArray);
Table.setColumn("Head_diameter", HeadDiameterArray);
Table.setColumn("Neck_diameter", BaseDiameterArray);
Table.setColumn("Spine_length", SpineLengthArray);
Table.applyMacro("H_N_index = Head_diameter/Neck_diameter ");

MorphotypeArray = newArray(0);
RoiNumber = roiManager('count');

StubbyNumber = 0;
MushroomNumber = 0;
ThinNumber = 0;

for (l = 0; l < RoiNumber; l++) {
	Spine_length = Table.get("Spine_length", l);
	H_N_index = Table.get("H_N_index", l);

	if (Spine_length < 0.4) {
	MorphotypeArray = Array.concat(MorphotypeArray,"");
	
	}
	else {
	if (Spine_length < 0.8) {
	MorphotypeArray = Array.concat(MorphotypeArray,"stubby");
	StubbyNumber = StubbyNumber + 1;
	}
	else {
	if (H_N_index > 1.5) {
	MorphotypeArray = Array.concat(MorphotypeArray,"mushroom");
	MushroomNumber = MushroomNumber + 1;
	}
	else {
	MorphotypeArray = Array.concat(MorphotypeArray,"thin");
	ThinNumber = ThinNumber + 1;
	}
	}
	}
}

StubbyDensity = StubbyNumber / BranchLength;
MushroomDensity = MushroomNumber / BranchLength;
ThinDensity = ThinNumber / BranchLength;

StubbyArray = newArray(1);
Array.fill(StubbyArray, StubbyDensity);
MushroomArray = newArray(1);
Array.fill(MushroomArray, MushroomDensity);
ThinArray = newArray(1);
Array.fill(ThinArray, ThinDensity);


Table.setColumn("Morphotype", MorphotypeArray);
Table.setColumn("Stubby_per_micron", StubbyArray);
Table.setColumn("Thin_per_micron", ThinArray);
Table.setColumn("Mushroom_per_micron", MushroomArray);

waitForUser("Save table", "Please save the results!");
close("*");
close("Final");
roiManager("reset");

    }

}

waitForUser("Analysis complete", "Done!");