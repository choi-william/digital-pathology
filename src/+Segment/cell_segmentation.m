% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Main entry point into the cell segmentation process. The result of this
% is a setting of the internal properties of dpimage to reflect the new
% information gathered about the cells.

% The critical parameters that must be modified are the calls to 
% Segment.Soma.extract_soma() below

function [ cell_list ] = cell_segmentation( dpimage, visual )
%CELL_SEGMENTATION Summary of this function goes here
%   Handles cell segmentation; soma segmentation followed by processes
%   segmentation of the cells
%

    if (nargin == 1) visual = 0; end

    % Soma Segmentation
    [cell_list,dp] = Segment.Soma.extract_soma(dpimage);
    
    length = size(cell_list,2);

    im = dp.image;
    
    if (visual)
        hFig = figure('Color',[0.6 0.6 0.6],'units','normalized','outerposition',[0 0 1 1]);
        
        set(hFig,'menubar','none')
        set(hFig,'NumberTitle','off');
        
        tit = suptitle('Microglia Analysis');
        
        P = get(tit,'Position');
        set(tit,'Position',[P(1) P(2)+0.025]);
        set(tit,'FontSize',20,'FontWeight','bold');
        
        hold on;
        
        placeholder = zeros(10,10);
        subplot(6,9,[5,15]), imshow(placeholder), title('Original Image');
        subplot(6,9,[23,33]), imshow(placeholder), title('Quantized Image');
        subplot(6,9,[41,51]), imshow(placeholder), title('Final Binarized Image');
        subplot(6,9,[34,54]), imshow(placeholder);
        subplot(6,9,[7,27]), imshow(placeholder);
    end 
    
    %Colour all blue;
    if (visual)
        for i=1:length
            im = Tools.colour_overlay(im,cell_list{i}.pixelList,'blue');
            subplot(6,9,[1,49]), imshow(im);
            pause(0.00001);
        end
    end
    
    
    % Process Segmentation
    
    microglia = cumsum(ones(1,length));
    for k=1:length
        
        
        i = microglia(ceil(rand()*size(microglia,2)));
        microglia = microglia(find(microglia~=i));
        
        if (visual)
            im = Tools.colour_overlay(im,cell_list{i}.pixelList,'red');
            subplot(6,9,[1,49]), imshow(im);
            pause(0.01);
        end
        
        %  binaryIm = extract_processes(cell_list{i}.subImage, struct('fastmarching', true));
        % TODO: cell centroid should be adjusted to have coordinates in the
        % subimage       
        binaryIm = Segment.Processes.process_segmentation(cell_list{i}.subImage, cell_list{i}.rCentroid);
        cell_list{i}.binaryIm = binaryIm;
        
        if (visual)
           
%            set(0,'CurrentFigure',h);
            im = Tools.colour_overlay(im,cell_list{i}.pixelList,'green');
            subplot(6,9,[1,49]); imshow(im);
            pause(0.01);
        end
    end

end

