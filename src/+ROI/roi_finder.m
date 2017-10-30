% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi
% 
% Entry point into ROI finding algorithm. This was original another group's
% capstone project which is why it doesn't fit the same format as the rest.
% It was just shoved into +ROI and called its own package. This file serves
% as the interface.
%

function [dpslide] = roi_finder( file_path )

    global TEST_PATH  RESULTS_PATH; 
    
    TEST_PATH    = file_path;
    
    Run;
    
    % InterfaceOutput within Run creates DPslide 
    dpslide = DPslide;
    
    clearvars -except dpslide
    close all
end

