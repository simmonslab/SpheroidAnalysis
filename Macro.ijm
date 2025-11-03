#@ String inputPath

// Open input image
open(inputPath + File.separator + "ImageBeforeMacro.tiff");

// Apply processing step
run("Sharpen");

// Save processed image
saveAs("Tiff", inputPath + File.separator + "ImageAfterMacro.tiff");

// Close the image
close();
