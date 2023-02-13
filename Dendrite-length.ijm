//Dendritic endpoints and dendrite length measurements
//Before use, check filepath in line 36!

waitForUser("Select input folder", "Select Input folder, that contains the images");
directory = getDirectory("Choose a Directory");


filelist = getFileList(directory) 
for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], "_Sholl.tif")) { 
        open(directory + File.separator + filelist[i]);
CurrentFile = getTitle();
Savedfile = replace(CurrentFile,".tif","");		 
    getDimensions(width, height, channels, slices, frames);
	getPixelSize(unit, pixelWidth, pixelHeight);
	FrameInterval = Stack.getFrameInterval();
rename("original");

run("Select None");
run("Remove Overlay");

run("Run Autocontext Prediction", "projectfilename=[D:\\actin labeling comparison\\actin-Ilastik models\\Dendrite Ilastik model\\Ilastik_dendrite.ilp] inputimage=original autocontextpredictiontype=Segmentation");
rename("Result");
run("Properties...", "channels="+channels+" slices="+slices+" frames="+frames+" pixel_width="+ pixelWidth +" pixel_height="+ pixelHeight + " voxel_depth=1 frame="+FrameInterval+"");
	Stack.setXUnit(unit);
	
run("Duplicate...", "title=Result-endpoints");
setAutoThreshold("Default dark");
setThreshold(2, 2);
setOption("BlackBackground", true);
run("Convert to Mask");
run("Options...", "iterations=1 count=2 black do=Open");


run("Merge Channels...", "c1=original c2=Result-endpoints create keep");
rename("Raw-Endpoints");

waitForUser("Endpoint correction", "Please correct endpoints if needed, \nthen press OK");

save(directory + SavedFile +"_endpoints.tif");
rename("Raw-Endpoints");

run("Split Channels");

selectImage("C2-Raw-Endpoints");
run("Analyze Particles...", "size=7-Infinity pixel show=Overlay display");

EndpointNumber = getValue("results.count");

close("C1-Raw-Endpoints");
print(CurrentFile);
print(EndpointNumber);

selectImage("Result");
run("Duplicate...", "title=Result-skeleton");
setAutoThreshold("Default dark");
setThreshold(1, 1);
setOption("BlackBackground", true);
run("Convert to Mask");

run("Merge Channels...", "c1=original c2=Result-skeleton create keep");
rename("Raw-skeleton");
waitForUser("Skeleton correction", "Please correct skeleton if needed, \nthen press OK");

save(directory + Savedfile +"_skeleton.tif");
rename("Raw-skeleton");

run("Split Channels");
close("C1-Raw-Endpoints");
selectImage("C2-Raw-skeleton");
run("Skeletonize");
run("Analyze Skeleton (2D/3D)", "prune=none show");

selectWindow("Branch information");
Table.deleteColumn("V1 x");
Table.deleteColumn("V1 y");
Table.deleteColumn("V1 z");

Table.deleteColumn("V2 x");
Table.deleteColumn("V2 y");
Table.deleteColumn("V2 z");

Table.deleteColumn("Euclidean distance");
Table.deleteColumn("running average length");
Table.deleteColumn("average intensity (inner 3rd)");

Table.deleteColumn("average intensity");


waitForUser("Save data", "Please save data, \nthen press OK");

close("*");
run("Close All");

    }
}