% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi
%
% A sandbox to experiment with different branch segmenting algorithms 
%

function bwIm = extract_processes( soma_image, options )
%EXTRACTPROCESSES Summary of this function goes here
%   Detailed explanation goes here
%
    
    default_options = struct('vesselness', false, 'kmeans', false, 'guidedfilter', false, 'mumfordshah', false, 'openclose', false, 'watershed', false, 'fastmarching', false);

    if ~exist('options','var')
        options = default_options;
    else
        tags = fieldnames(default_options);
        for i=1:length(tags)
            if (~isfield(options,tags{i}))
                options.(tags{i}) = default_options.(tags{i});
            end
        end
        if length(tags)~=length(fieldnames(options))
            warning('Extract Processes: Unknown options found.');
        end
    end
   
    % Solely using the blue channel
    grayIm = soma_image(:,:,3);
    grayIm = medfilt2(grayIm); % median filter to remove salt and pepper noise
    adjustedIm = imadjust(grayIm);
    adjustedIm = imsharpen(adjustedIm);

    if options.vesselness
        downscaledIm = double(grayIm)/255;
        fastguidedIm = fastguidedfilter(downscaledIm,downscaledIm, 4, 0.1^2, 4);
        sharpenedIm = imadjust(fastguidedIm);
        sharpenedIm = imsharpen(sharpenedIm, 'Threshold',0, 'Amount', 2);
        
        % Vesselness; frangi filter applied
        I = sharpenedIm*255;
        vesselIm = FrangiFilter2D(I);
        bwIm = imbinarize(imcomplement(vesselIm),0.75);
        
        % Size filter
        bwIm = Helper.sizeFilter(bwIm, 25, 1500);
        
        figure, 
        subplot(1,3,1), imshow(grayIm);
        subplot(1,3,2), imshow(vesselIm);
        subplot(1,3,3), imshow(bwIm);
    elseif options.kmeans
        % Kmeans on lab color space
        imsegkmeans(soma_image, 2);
    elseif options.guidedfilter
        % Anisotropic smoothing
        downscaledIm = double(grayIm)/255;
        fastguidedIm = fastguidedfilter(downscaledIm,downscaledIm, 4, 0.1^2, 4);
        sharpenedIm = imadjust(fastguidedIm);
        sharpenedIm = imsharpen(sharpenedIm, 'Threshold',0, 'Amount', 2);

        mumfordIm = fastms(sharpenedIm, 'lambda', 0.6, 'alpha', 5, 'edges', false);
        
        % Supressing regions with low gradients
        minsupress = imhmin(im2uint8(sharpenedIm), 35);
        adjustedMinIm = imadjust(minsupress,[0; 0.5],[0; 1], 1.5);
        
        enhancedIm = (downscaledIm-sharpenedIm)*3 + downscaledIm;
        figure, imshow([downscaledIm, fastguidedIm, sharpenedIm, mumfordIm, enhancedIm]);
     
        binaryIm = imbinarize(adjustedMinIm, 0.75);
        binaryIm = imcomplement(imclearborder(imcomplement(binaryIm), 4));
        figure, subplot(1,2,1), imshow([minsupress, adjustedMinIm]);
        subplot(1,2,2), imshow(binaryIm);
        
        % Dilating the binary image to fill the gaps
        se1 = strel('rectangle', [1 2]);
        se2 = strel('rectangle', [2,1]);
        bwIm = imdilate(imcomplement(binaryIm), [se1 se2]);
        bwIm = imcomplement(imfill(bwIm, 'holes'));

    elseif options.mumfordshah
        % Mumford-Shah applied to the grayscale image
        mumfordIm = fastms(adjustedIm, 'lambda', 0.01, 'alpha', 0.1);
        mumfordIm = imadjust(mumfordIm,[0; 0.6],[0; 1], 1.5); % remove the blurred regions
        figure, imshow(mumfordIm);
        
        % Increasing the contrast of the smoothed image
        mumfordIm = imadjust(mumfordIm);
        guidedIm = imguidedfilter(mumfordIm);
        bwIm = imbinarize(guidedIm, 0.9);
        figure, imshow([grayIm,guidedIm,bwIm]);
        
        % Dilating the binary image to fill the gaps
        se1 = strel('rectangle', [1 2]);
        se2 = strel('rectangle', [2,1]);
        bwIm = imdilate(imcomplement(bwIm), [se1 se2]);
        bwIm = imcomplement(imfill(bwIm, 'holes'));
        
    elseif options.openclose
        % Opening and Closing by reconstruction 
        ocbrIm = Tools.smooth_ocbrc(adjustedIm,5);
        guidedIm = imguidedfilter(ocbrIm);
        orgguidedIm = imguidedfilter(grayIm);
        bwIm = imbinarize(ocbrIm,0.35);
        figure,imshow([grayIm,ocbrIm, guidedIm, orgguidedIm]);
        figure, imshow(edge(orgguidedIm, 'Canny'));
    elseif options.watershed
        hy = fspecial('sobel');
        hx = hy';
        Iy = imfilter(double(adjustedIm), hy, 'replicate');
        Ix = imfilter(double(adjustedIm), hx, 'replicate');
        gradmag = sqrt(Ix.^2 + Iy.^2);
        bwIm = grayIm;
        figure,
        imshow([bwIm,gradmag]), title('Gradient magnitude (gradmag)');
   
    elseif options.fastmarching
        guidedIm = imguidedfilter(adjustedIm);
        points = detectHarrisFeatures(guidedIm);
        figure, imshow(grayIm);
        hold on;
        plot(points);
        
        figure, imshow(grayIm);
        [x, y] = getpts;
        mask = false(size(adjustedIm));
        mask(round([x,y])) = true;
%         mask = false(size(adjustedIm));
%         for i = 1:length(points)
%             mask(round(points(i).Location)) = true;
%         end
        W = graydiffweight(guidedIm, mask, 'GrayDifferenceCutoff', 25);
        [bwIm, D] = imsegfmm(W, mask, 0.1);
        figure, imshow(bwIm);
        figure, imshow(D);
        figure, imshow(guidedIm);
    else
        adjustedColorIm = imadjust(soma_image,[0; 0.6],[0; 1], 1.5);
        bwIm = imbinarize(rgb2gray(adjustedColorIm), 0.9);
        bwIm = Helper.sizeFilter( bwIm, 10, 3000 );
        
        % Dilating the binary image to fill the gaps
        se1 = strel('rectangle', [1 2]);
        se2 = strel('rectangle', [2,1]);
        bwIm = imdilate(imcomplement(bwIm), [se1 se2]);
        bwIm = imcomplement(imfill(bwIm, 'holes'));
    end
    
    % Outlining the original grayscale image with the binary mask.
    outline = bwperim(bwIm);
    outlinedIm = grayIm;
    outlinedIm(outline) = 255;
    
    figure, subplot(1,3,1), imshow(grayIm);
    subplot(1,3,2), imshow(bwIm);
    subplot(1,3,3), imshow(outlinedIm);

end

