# README #


----USING THE PROJECT----

The entry point to running the software is to call:

pathology_analysis(0) 
This will both prompt the user for a .tif or .svs, and then prompt for an analysis save location. 

run_all_files(0); 
Performs the pathology_analysis() procedure but with a batch of images in the same directory.

Once you have an analysis file, GUI/main can be run which will prompt for the file. The microglia can properties can then be visualized.

----DEVELOPER NOTES----

There are lots of files in the src/ that are not necessary for running the project, but are for behind the scenes file manipulation, classification training, etc. 

To accompany the project, there is a directory of brain slides we were given from the lab. Certain functions in src/ are programmed to pull from this data which lived in /data/output/ . These files will be uploaded to a TBD drive.

The project is organized into several modules

+Analysis - for morphology feature extraction

+Display - for visualization of some of the processes associated with cell analysis

+ML - for solving the binary classification problem associated with discarding false positive detected cells

+Pipeline - for reading in files from several different domains.

+ROI - for white matter segmentation (this is the other capstone group's project)

+Segment - The meat of the algorithm. The actual cell body and branch segmentation algorithms live here.

+Verify - for comparing our algorithm's performance with the some of the lab's labelled data

common - for common class definitions, utility functions and other tools

GUI - for visualizing the analyzed microglia data

library - for other people's code that we source into this project