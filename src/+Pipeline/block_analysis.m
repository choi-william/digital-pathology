% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% block_analysis - performs microglia analysis on a particular DPImage
% Return 0 for average_fractal if the analysis type is 1.

function [cell_count, average_fractal] = block_analysis( dpimage, analysis_type, visual )
%PATHOLOGY_ANALYSIS Summary of this function goes here
%   analysis_type = 0 cell count & cell morphology
%   analysis_type = 1 cell count

    if (Tools.is_edge_image(dpimage))
        cell_count = -1;
        average_fractal = -1;
        return
    end
    
    if (nargin == 1) visual = 0; end

    cell_list = Segment.cell_segmentation(dpimage,visual);
    cell_count = size(cell_list,2);
    
    if (analysis_type == 0)
        cell_list = Analysis.feature_analysis(cell_list);

        % Any visualization stuff goes here
        fracDim = zeros(cell_count,1);

        for i =1:cell_count
            fracDim(i) = cell_list{i}.fractalDim;
        end
        average_fractal = mean(fracDim(i));
    else
        average_fractal = 0;
    end
end

