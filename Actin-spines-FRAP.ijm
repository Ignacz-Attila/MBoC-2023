directory = getDirectory("Folder with the images");
filelist = getFileList(directory);
run("Options...", "iterations=1 count=1 black");

for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], "segmented.tif")) {
    	
    }
    else {
	    if (endsWith(filelist[i], "8bit.tif")) {
    	
    }
    else {
    	if (endsWith(filelist[i], "_segmented.tif")) {
    	
    }
    else {
	    if (endsWith(filelist[i], "registered.tif")) {
    	
    }
        
    else {

    if (endsWith(filelist[i], ".tif")) {
        open(directory + File.separator + filelist[i]);
        
    Currentfile = getTitle();
	Segmentedfile = replace(Currentfile, ".tif", "_8bit_segmented.tif");
	ROIfile = replace(Currentfile, ".tif", ".zip");
	Tablefile = replace(Currentfile, ".tif", ".csv");
	
	open(directory + File.separator + ROIfile);

	Exist = File.exists(directory + File.separator + Segmentedfile);
	if (Exist == 1) {

	open(directory + File.separator + Segmentedfile);
	}
	else {
	Segmentedfile = replace(Currentfile, ".tif", "_segmented.tif");
	open(directory + File.separator + Segmentedfile);
	}
	
	roiManager("remove slice info");


SpineROI = newArray();
ReferenceROI = newArray();
BackgroundROI = newArray();

selectImage(Currentfile);
run("Split Channels");
close("C2-"+Currentfile);


//  Spine roi processing
selectImage(Segmentedfile);
getDimensions(width, height, channels, slices, frames);

run("Duplicate...", "title=Segmented duplicate");
roiManager("select", 0);
setBackgroundColor(0, 0, 0);
run("Clear Outside", "stack");

run("Select None");

for (j = 1; j <= frames; j++) {

	selectImage("Segmented");
    Stack.setFrame(j);
    run("Create Selection");
    
    if (selectionType() <0) {
    selectImage("C1-"+Currentfile);
    Stack.setFrame(j);
    roiManager("select", 0);
	SpineResult = getValue("Mean");
	SpineROI = Array.concat(SpineROI,SpineResult);
	run("Select None");
	roiManager("deselect");
    	}
	else {
    roiManager("add");
    selectImage("C1-"+Currentfile);
    Stack.setFrame(j);
    roiManager("select", 3);
	SpineResult = getValue("Mean");
	SpineROI = Array.concat(SpineROI,SpineResult);
	roiManager("select", 3);
	roiManager("delete");
	roiManager("deselect");
	run("Select None");
}
}
close("Segmented");

//  Reference roi processing
selectImage(Segmentedfile);
run("Select None");
run("Duplicate...", "title=Segmented duplicate");

getDimensions(width, height, channels, slices, frames);

roiManager("select", 1);
setBackgroundColor(0, 0, 0);
run("Clear Outside", "stack");

run("Select None");

for (k = 1; k <= frames; k++) {

	selectImage("Segmented");
    Stack.setFrame(k);
    run("Create Selection");
    
    if (selectionType() <0) {
    selectImage("C1-"+Currentfile);
    roiManager("select", 0);
    Stack.setFrame(k);
	ReferenceResult = getValue("Mean");
	ReferenceROI = Array.concat(ReferenceROI,ReferenceResult);
	run("Select None");
	roiManager("deselect");
    }
    
	else {
    roiManager("add");
    selectImage("C1-"+Currentfile);
    roiManager("select", 3);
    Stack.setFrame(k);
	ReferenceResult = getValue("Mean raw");
	ReferenceROI = Array.concat(ReferenceROI,ReferenceResult);
	roiManager("select", 3);
	roiManager("delete");
	run("Select None");
	roiManager("deselect");
	}
	}
close("Segmented");

//  Background roi processing

selectImage("C1-"+Currentfile);

roiManager("select", 2);

for (l = 1; l <= frames; l++) {
	
    Stack.setFrame(l);
    roiManager("select", 2);
	Result = getValue("Mean");
	BackgroundROI = Array.concat(BackgroundROI,Result);
	run("Select None");

}
roiManager("reset");

Table.create("Final");
Table.setColumn("Spine", SpineROI);
Table.setColumn("Reference", ReferenceROI);
Table.setColumn("Background", BackgroundROI);

Table.save(directory + File.separator + Tablefile);

close("Final");
close("*");
    }
}
}
}
}
}
