IlastikFile = File.openDialog("Select Ilastik model");
directory = getDirectory("Folder with the images");
filelist = getFileList(directory);


for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], "stage1.tif")) { 
        //open(directory + File.separator + filelist[i]);
        run("Bio-Formats Importer", "open=["+directory + File.separator + filelist[i]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
    Currentfile = getTitle();
	Savedfile = replace(Currentfile, "stage1.tif", "skeleton.tif");
	//run("Z Project...", "projection=[Max Intensity]");			If you have images that need to be simplified
	//run("Duplicate...", "title=GFP duplicate channels=1");		These lines can be used for that
	rename("GFP");

	selectImage("GFP");
	
	getDimensions(width, height, channels, slices, frames);
	getPixelSize(unit, pixelWidth, pixelHeight);
	FrameInterval = Stack.getFrameInterval();
	//setOption("ScaleConversions", true);
	//run("8-bit");
	
	run("Run Autocontext Prediction", "projectfilename=["+IlastikFile+"] inputimage=GFP autocontextpredictiontype=Segmentation");
    rename("VirtualPrediction");
	run("Duplicate...", "title=Prediction duplicate");
    close("VirtualPrediction");
    selectImage("Prediction");
    
    
	//setAutoThreshold("Default dark");							If you need binary images for the next steps, these lines do that
	//run("Threshold...");
	//setThreshold(0, 1);
	//setOption("BlackBackground", true);
	//run("Convert to Mask", "method=Default background=Dark black");
	
	
	run("Properties...", "channels="+channels+" slices="+slices+" frames="+frames+" pixel_width="+ pixelWidth +" pixel_height="+ pixelHeight + " voxel_depth=1 frame="+FrameInterval+"");
	Stack.setXUnit(unit);
	
	save(directory + File.separator + Savedfile);
	close("*");
    }
}