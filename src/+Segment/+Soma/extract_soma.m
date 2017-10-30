% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi
% 
% The main acting algorithm that actually segments the cell bodies.
%
% dpimage - image object
% alg - algorithm type parameter. 0 for opening and closing by
% reconstruction. 1 for mumford-shah, 2 for multithresholding (untested)
%
function [list,dp] = extract_soma( dpimage, alg, lsb, th, useDeepFilter, th_alpha)

    if ~exist('alg','var')
        alg = 1;
    end
    if ~exist('lsb','var')
        lsb = 80;
    end
    if ~exist('th_alpha','var')
        th_alpha = 0.3;
    end    
    if ~exist('th','var')
        th = (dpimage.avInt*th_alpha+25)/100;
        th = 0.3;
    end
    if ~exist('useDeepFilter','var')
        useDeepFilter=1;
    end
    
    if alg == 0
        %EXTRACTSOMA Summary of this function goes here
        %   Detailed explanation goes here

        % converting image to grayscale
        %grayIm = rgb2gray(dpimage.image);
        grayIm = dpimage.image;
        grayIm = grayIm(:,:,3);
        %grayIm = imadjust(grayIm);
        %adjusted = imadjust(grayIm,[0; 0.5],[0; 1]);
        %adjusted = imsharpen(adjusted);

        adjusted = grayIm + (255-mean(grayIm(:)));
        %figure, imshow(adjusted);

        % open and close by reconstruction

        Iobrcbr = Tools.smooth_ocbrc(adjusted,2);
        dpimage.preThresh = Iobrcbr;

        %THRESHOLD RESULT%
        somaIm = imbinarize(Iobrcbr,th);
        
        dpimage.rawThresh = somaIm;

        %Filter Image
        somaIm = Helper.sizeFilter(somaIm,lsb,100000000);

    elseif alg == 1
        input_image = dpimage.image;
        
        % Converting image to grayscale, increasing contrast.
        grayIm = rgb2gray(input_image);
%         grayIm = input_image(:,:,1);
        grayIm = imadjust(grayIm);
        grayIm = imsharpen(grayIm);
        
        % Mumford-Shah smoothing
        mumfordIm = smooth_ms(grayIm, 0.3, 300);
%         figure, imshow(mumfordIm);

        % Global Thresholding 
        bwIm = imbinarize(mumfordIm, th);
        
        dpimage.preThresh = mumfordIm;
        dpimage.rawThresh = bwIm;

        % Filtering by object size
        somaIm = Helper.sizeFilter(bwIm,lsb, 1000000);

        % Resulting binary image of the soma
%         figure, imshow(somaIm);

        % Soma image overlayed with the original grayscale image
        finalIm = imoverlay(grayIm, imcomplement(somaIm),'yellow');
%         figure, imshow(finalIm);
% 
%         figure;
%         subplot(2,2,1), imshow(input_image);
%         subplot(2,2,2), imshow(mumfordIm);
%         subplot(2,2,3), imshow(bwIm);
%         subplot(2,2,4), imshow(finalIm);
        
    elseif alg == 2
        
        grayIm = rgb2gray(dpimage.image);
        adjusted = grayIm + (255-mean(grayIm(:)));
        manipulated = Tools.smooth_mt(adjusted,10);
        dpimage.preThresh = manipulated; 
        
        %THRESHOLD RESULT%
        somaIm = imbinarize(manipulated,th);
        
        dpimage.rawThresh = somaIm;

        %Filter Image
        somaIm = Helper.sizeFilter(somaIm,lsb,100000);
    else
        error('Incorrect Parameter: Specify 0 or 1 or 2 for the alg parameter.');
    end
    
    dpimage.somaMask = somaIm;
    comp = bwconncomp(imcomplement(somaIm));

    if (useDeepFilter)
        file = load('+ML/deep_learning_model.mat'); 
        classifier = file.classifier;
        decision_threshold = file.decision_threshold;
    end
    
    list = {};
    for i=1:comp.NumObjects
        [row,col] = ind2sub(comp.ImageSize,comp.PixelIdxList{i});
        
        prepared = prepare_soma(DPCell([col,row],dpimage)); 
        % Loop through the cells since there could be multiple detected
        % from resolving clumps
        for j=1:size(prepared,2)
            dpcell = prepared{j};            

            if (useDeepFilter)
                if (~predict_valid(classifier,decision_threshold,dpcell))
                    dpcell.isFalsePositive = 1;
                end
            end
            list{end+1} = dpcell;
        end
    end    
    dp = dpimage;
end

