IlastikFile = File.openDialog("Select Ilastik model");
directory = getDirectory("Folder with the images");
filelist = getFileList(directory);

for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], "63x.czi")) { 
        //open(directory + File.separator + filelist[i]);
        run("Bio-Formats Importer", "open=["+directory + File.separator + filelist[i]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
    Currentfile = getTitle();
    Savedfile = replace(Currentfile, ".czi", "_EGFP-mask.tif");
    run("8-bit");
    run("Split Channels");
    close("C1-"+Currentfile+"");
    
    selectWindow("C2-"+Currentfile+"");
    rename("EGFP");
    selectWindow("C3-"+Currentfile+"");
    rename("Phalloidin");
    //run("Rotate 90 Degrees Right"); // Here is the negative control - turned image that shows random coloc.
    
    selectWindow("EGFP");
	run("Z Project...", "projection=[Max Intensity]");
	
	run("Run Autocontext Prediction", "projectfilename=["+IlastikFile+"] inputimage=MAX_EGFP autocontextpredictiontype=Segmentation");
	rename("Segmented");
	
	close("MAX_EGFP");
	selectWindow("Segmented");
	setThreshold(0, 1);
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Divide...", "value=255");
	
	selectWindow("EGFP");
	run("Duplicate...", "title=EGFP-mask duplicate");
	run("Gaussian Blur...", "sigma=1 stack");
	run("Convert to Mask", "method=Otsu background=Dark calculate black");
	imageCalculator("Multiply stack", "EGFP-mask","Segmented");
	
	selectWindow("EGFP-mask");
	run("Divide...", "value=255 stack");
	
	imageCalculator("Multiply stack", "EGFP","EGFP-mask");
	//imageCalculator("Multiply stack", "Phalloidin","EGFP-mask");
	
	
	run("Coloc 2", "channel_1=EGFP channel_2=Phalloidin roi_or_mask=<None> threshold_regression=Costes manders'_correlation psf=4 costes_randomisations=50");
	print(Currentfile);
	
	save(directory + File.separator + Savedfile);
	close("*");
    }
}
	