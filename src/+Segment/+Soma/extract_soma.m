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
function [list,dp] = extract_soma( dpimage )
    
    %%%%SEGMENTATION%%%%%

    input_image = dpimage.image;

    % Converting image to grayscale, increasing contrast.
    grayIm = rgb2gray(input_image);
    % grayIm = input_image(:,:,1);
    grayIm = grayIm + (255-mean(grayIm(grayIm<200)));

    % Mumford-Shah smoothing
    mumfordIm = smooth_ms(grayIm, Config.get_config('MUMFORD_SHAH_LAMBDA'), -1);

    %quantize so imregionalmin is more robust
    tolerance = 5;
    ths = tolerance:tolerance:(255-tolerance);
    values = round((tolerance/2):tolerance:255);
    mumfordIm = uint8(imquantize(mumfordIm,ths,values));
    
    bwIm = ~imregionalmin(imadjust(mumfordIm,[0; Config.get_config('WHITE_DISCARD_THRESHOLD')],[0; 1]));

    dpimage.preThresh = mumfordIm;
    dpimage.rawThresh = bwIm;

    % Filtering by object size
    somaIm = Helper.sizeFilter(bwIm,Config.get_config('LOWER_SIZE_BOUND'), 10000000);

    %%%%%%
    
    dpimage.somaMask = somaIm;
    comp = bwconncomp(imcomplement(somaIm));

    if (Config.get_config('USE_DEEP_FILTER'))
        file = load('+ML/deep_learning_model_all.mat'); 
        classifier = file.classifier;
        decision_threshold = file.decision_threshold;
    end
    
    list = {};
    for i=1:comp.NumObjects
        [row,col] = ind2sub(comp.ImageSize,comp.PixelIdxList{i});
        
        prepared = prepare_soma(DPCell([col,row],dpimage)); 
        % Loop through the cells since there could be multiple detected
        % from resolving clumpsg
        for j=1:size(prepared,2)
            dpcell = prepared{j};            

            if (Config.get_config('USE_DEEP_FILTER'))
                if (~predict_valid(classifier,decision_threshold,dpcell))
                    dpcell.isFalsePositive = 1;
                end
            end
            list{end+1} = dpcell;
        end
    end    
    dp = dpimage;
end

