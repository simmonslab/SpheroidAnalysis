# CellProfiler pipeline for SpheroidAnalysis — instructions and manuscript details

This README includes the pipeline details from our manuscript and step-by-step instructions for editing and committing the CellProfiler pipeline used for spheroid analysis.

Reference (manuscript excerpt)
- Post-printing analysis of spheroids was done using CellProfiler version 4.2.7. CellProfiler is an open-source cell image analysis software (https://cellprofiler.org/, REF), that allows high throughput quantitative analysis of images. CellProfiler performs quantitative image analysis by helping the user construct pipelines that consist of assembling any number of modules to perform specific tasks to measure unique features in the images of choice.
- In our spheroid analysis pipeline, the 4 input modules (Images, Metadata, NamesAndTypes, Groups) are supplemented with 7 other modules (ColorToGray, RunImageJMacro, GaussianFilter, EnhanceEdges, IdentifyPrimaryObjects, MeasureObjectSizeShape, ExportToSpreadsheet). The pipeline modifies the input data into a mask that allows for the border of the spheroids to be easily identifiable and measures the physical characteristics of the spheroids.
- The Groups module was not used in this pipeline.

Overview
- CellProfiler version: 4.2.7 (this pipeline was developed and validated with 4.2.7).
- Purpose: Convert brightfield spheroid images into a mask that clearly identifies spheroid borders and extract morphological measurements (area, perimeter, solidity, major axis length, etc.) for downstream analysis.
- Key idea: Pre-process to enhance contours (sharpen → blur → edge enhancement), segment with IdentifyPrimaryObjects using minimum cross-entropy thresholding, and export measurements to CSV.

Pipeline modules (ordered)
1. Images (input)
2. Metadata (input)
3. NamesAndTypes (input) — `TRANS` used in our figures
4. Groups (input) — note: not used in this pipeline
5. ColorToGray (pre-processing)
6. RunImageJMacro (pre-processing; optional but used here to sharpen)
7. GaussianFilter (pre-processing; blur after sharpening)
8. EnhanceEdges (pre-processing; Sobel edge enhancement)
9. IdentifyPrimaryObjects (segmentation)
10. MeasureObjectSizeShape (quantification)
11. ExportToSpreadsheet (output)

Details and recommended settings from the manuscript

Image import (Images, Metadata, NamesAndTypes)
- Images module:
  - Purpose: load and specify files to analyze.
  - If the analysis folder contains mixed file types, set the selection criterion to only include `.tiff` files. If the folder contains only desired images, set "Filter Images" to "No-filtering".
- Metadata module:
  - Purpose: extract metadata from filenames using a regular expression.
  - Example filename format used in the manuscript: `Experiment_SpheroidID_Channel.tiff`.
  - Example regex used to extract metadata (modify to suit your filenames):
    (?P<Experiment>.*)_(?P<SpheroidID>.*(_\d+)?)__(?P<Channel>TRANS).tiff
  - Note: Adapt the regex to match your naming convention exactly.
- NamesAndTypes:
  - Purpose: assign names to image channels that other modules will reference. In our pipeline the channel name `TRANS` was used (see Fig 1A).
- Groups:
  - Not used in this pipeline (leave blank/unconfigured).

Pre-processing (ColorToGray, RunImageJMacro, GaussianFilter, EnhanceEdges)
- ColorToGray:
  - Convert images to grayscale.
  - Rationale: Equalizes channel weights across images and ensures compatibility with modules that require grayscale inputs (even for brightfield images).
- RunImageJMacro:
  - Purpose: execute an ImageJ/FIJI macro to perform an image sharpening step (CellProfiler lacks a single built-in sharpening module).
  - Requirements: ImageJ or FIJI must be installed on the system where CellProfiler runs. In the module, point to:
    - The application executable (e.g., FIJI)
    - The macro file (path to `.ijm` or `.py` macro) that performs sharpening or other operations
  - Typical action: sharpen to emphasize object contours and contrast prior to smoothing.
- GaussianFilter:
  - Purpose: smooth image and reduce high-frequency noise to assist thresholding/segmentation.
  - Rationale: Blurring after sharpening reduces background noise while keeping object boundaries crisp.
  - Recommended sigma: 1.5–2.0 (pixel units).
- EnhanceEdges:
  - Method: Sobel edge detection.
  - Output: produces a mask with bright objects on a dark background so spheroid borders are prominent (see Fig 1B).

Segmentation (IdentifyPrimaryObjects)
- IdentifyPrimaryObjects is responsible for locating spheroids in the mask.
- Key settings (as used in the manuscript):
  - Typical diameter (minimum, maximum) in pixel units: 250 — 3000
    - Adjust these values to match imaging magnification and spheroid size changes over time.
  - Discard objects touching the image border: ON for early timepoints (when objects are unlikely to extend beyond the frame). Turn OFF if later-timepoint spheroids extend to the frame edge.
  - Thresholding method: Minimum cross-entropy (empirically provided the best segmentation in our image sets).
  - Threshold smoothing scale: 0
  - Correction factor: 0.7
  - Threshold lower bound / upper bound: 0.02 — 1.0
    - Note: Lower bound is set small because inputs are masks from EnhanceEdges. If spheroids develop thin projections or “spikes”, consider reducing the lower bound to 0.015 to capture thinner structures.
  - Distinguish clumped objects by: Intensity
  - Method to draw lines between clumped objects: Shape
  - These settings (Intensity + Shape) yielded the most accurate separation of clumped spheroids in our tests.

Quantification and output (MeasureObjectSizeShape, ExportToSpreadsheet)
- MeasureObjectSizeShape:
  - Purpose: compute morphological features such as area, perimeter, solidity, major axis length, eccentricity, etc.
  - Select the measurements required for downstream analysis and reporting.
- ExportToSpreadsheet:
  - Specify a destination folder/filename for the output CSV.
  - Choose which measurements/columns to include (select all required measurements from MeasureObjectSizeShape and any relevant metadata fields).
  - The exported CSV is the primary output used for downstream statistical analysis and figure generation.

Editing the pipeline inside CellProfiler (step-by-step)
1. Open CellProfiler (version 4.2.7 recommended).
2. Build or open the pipeline in the GUI.
3. Use the Images module to point to the folder containing your images and set filtering criteria (.tiff or No-filtering as appropriate).
4. Configure Metadata with an appropriate regex to extract experiment, spheroid ID, channel, or other metadata from filenames.
   - Test the regex with the sample filenames shown in the module to ensure fields are parsed correctly.
5. Set NamesAndTypes so downstream modules reference the correct image name (e.g., `TRANS`).
6. If using RunImageJMacro, ensure the path to ImageJ/FIJI and the macro file are correct on your machine and test the macro on a small subset.
7. Run Test mode on a representative subset of images to verify pre-processing, segmentation, and measurement steps work as expected.
8. Tweak IdentifyPrimaryObjects settings (diameter, threshold method, bounds, clump separation) as needed for different imaging timepoints or magnifications.
9. Inspect segmentation overlays (mask vs. original image) to ensure accurate object detection and boundary delineation.
10. Save/export the pipeline:
    - File → Save pipeline... (or File → Export pipeline...) → name it `CellProfiler_pipeline.cppipe`.


```
