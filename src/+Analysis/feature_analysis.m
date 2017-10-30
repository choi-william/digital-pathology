% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi
% 
% Extracts cell morphology features from a list of cells that have
% undergone process segmentation

function [dpcell_list] = feature_analysis( dpcell_list )
%
%   Handles cell analysis following soma segmentation
%
    
    length = size(dpcell_list,2);
    for i=1:length

        % Feature Extraction
        [endpoints, junctions, skelIm] = skeleton_analysis(dpcell_list{i}.binaryIm);
        dpcell_list{i}.skelIm = skelIm;
        dpcell_list{i}.numEndpoints = endpoints;
        dpcell_list{i}.numJunctions = junctions;
        
        dpcell_list{i}.fractalDim = hausDim(dpcell_list{i}.binaryIm);
        
    end 

end

