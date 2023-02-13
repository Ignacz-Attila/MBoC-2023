directory = getDirectory("Folder with the images");
filelist = getFileList(directory);
FilenameArray = newArray(0);
IntensityArray = newArray(0);
BackgroundArray = newArray(0);


for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], "intensity.czi")) { 
    	//open(directory + File.separator + filelist[i]);
    	run("Bio-Formats Importer", "open=["+directory + File.separator + filelist[i]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
    Currentfile = getTitle();
	Savedfile = replace(Currentfile, "intensity.czi", "segmented.tif");
	
	FilenameArray = Array.concat(FilenameArray,Currentfile);
	ROIFile = replace(Currentfile, ".czi", ".zip");
	
  rename("czi_image");
  run("Z Project...", "projection=[Max Intensity]");
  run("Duplicate...", "title=Thresholded");
  
  setAutoThreshold("Yen dark");
  setOption("BlackBackground", true);
  run("Convert to Mask");
  
  run("Options...", "iterations=1 count=5 black do=Open");
  
  run("Create Selection");
  roiManager("Add");
  selectImage("MAX_czi_image");
  roiManager("Select", 0);
  
  Intensity = getValue("Mean");
  IntensityArray = Array.concat(IntensityArray,Intensity);
  

  roiManager("Select", 0);
  run("Scale... ", "x=4 y=4 centered");
  run("Fit Circle");
  roiManager("Add");
  
  roiManager("deselect");
  roiManager("XOR");
  
  Background = getValue("Mean");

  roiManager("Add");

  selectImage("MAX_czi_image");
  roiManager("Select", 1);
  
  Background = getValue("Mean");
  BackgroundArray = Array.concat(BackgroundArray,Background);
  run("Select None");
  
  roiManager("save", directory + File.separator + ROIFile);
  roiManager("reset");
  
  close("*");
  
    }
    }
    
Table.create("Cell body intensities");
Table.setColumn("Filename", FilenameArray);
Table.setColumn("GFP_intensity", IntensityArray);
Table.setColumn("Background_intensity", BackgroundArray);

Table.applyMacro("Net_intensity = GFP_intensity - Background_intensity ", "Cell body intensities");

Table.save(directory + File.separator + "Cell_body_intensities.csv");

close("*");