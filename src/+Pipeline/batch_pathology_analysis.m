% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% batch_pathology_analysis - a batch processing script to perform analysis on multiple
%   brain slides

function [ output_args ] = batch_pathology_analysis( analysis_type )
%RUN_ALL_FILES Summary of this function goes here
%   Detailed explanation goes here

    filePath = uigetdir('','Choose the folder containing the images to be analyzed.');
    
    cd(filePath);
    imageList = dir('**/*.tif');
    
    global srcPath;
    cd(srcPath);
    
    outPath = uigetdir('','Choose the folder to output the results.');
    
    for i=1:size(imageList,1)
        [pathstr,name,ext] = fileparts(imageList(i).name);
        saveDir = strcat(outPath,'/','analysis_',name);
        pathology_analysis(analysis_type, strcat(imageList(i).folder,'/',imageList(i).name), saveDir);
    end
end

