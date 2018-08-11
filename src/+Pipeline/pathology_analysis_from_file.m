% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

%pathology_analysis - the main entry point for performing an analysis on a
%brain slide

function [] = pathology_analysis(analysis_type, dirPath, outPath)
    
    if(~exist('dirPath','var'))
        f = uigetdir('Select the interface output folder');
        dirPath = f;
    end
    
    if(~exist('outPath','var'))
        [file,path] = uiputfile('*.mat','Save Analysis as');
        an_path = strcat([path,file]);
    else
        an_path = outPath;
    end
    
    if(~exist('analysis_type','var'))
        analysis_type = 0;
    end
    
    % Determine the White Matter Regions    
    DPslide = load(strcat([f,'/DP_Slide.mat']));    
    DPslide = DPslide.DPslide;
    
    sizeDPslide = size(DPslide,2);
    
    blockSize = 256; % size of each image subblock, change to 128 when new data is available
    
    topleft = DPslide(1).Pos{1};
    bottomright = DPslide(sizeDPslide).Pos{2};
    
    numcols = (bottomright(1) - topleft(1)+1)/blockSize;
    numrows = (bottomright(2) - topleft(2)+1)/blockSize;
    
%   image = reshape(DPslide,[numrows, numcols]);
    
    slide = zeros(numrows,numcols);
    outputData1 = -1*ones(numrows*numcols,1);
    outputData2 = -1*ones(numrows*numcols,1);
    
    status = zeros(numrows*numcols,1);
    
    mat1 = load(Config.get_config('CELL_CLASSIFIER_PATH'));
    mat2 = load(Config.get_config('MORPHOLOGY_CLASSIFIER_PATH'));
    
    cell_classifier = mat1.classifier;
    morphology_classifier = mat2.classifier;

%     parpool;

    %necessary for displaying count due to parallel nature
    b = 0;
    for linInd=1:(numcols*numrows)
        if DPslide(linInd).Label == 1
            b = b+1;
            status(linInd) = b;
        end
    end
    total = sum(status~=0)
    
    tic
%     brainSlide = parallel.pool.Constant(imread(dirPath));
    for linInd=1:(numcols*numrows)   
        slide(linInd) = DPslide(linInd).Label;

        if slide(linInd) == -99
            outputData1(linInd) = -2;
            outputData2(linInd) = -2;
        end

        if slide(linInd) == 0
            outputData1(linInd)=-1;
            outputData2(linInd)=-1;
        end

        if (slide(linInd) == 1)
            im = DPImage('notAFile');
            im.image = imread(strcat([f,'/BlockImg/',num2str(DPslide(linInd).Id),'.tif']));         
            
            %necessary for dynamic thresholding
            %TODO, move this to extract_soma
            blue = im.image(:,:,3);
            im.avInt = mean(blue(:));
            
            [cell_count, average_morphology] = Pipeline.block_analysis( im, analysis_type,cell_classifier,morphology_classifier);
            outputData1(linInd) = cell_count;
            outputData2(linInd) = average_morphology;
            
            fprintf('%d out of %d\n',status(linInd),total);
            fprintf('cell count: %d\n',cell_count);
            fprintf('average morphology: %d\n',average_morphology);

        end
    end
    toc
    
%     delete(gcp);
    
    clearvars -except outputData1 outputData2 imagePath blockSize numrows numcols an_path file DPslide
    
    outputData1 = reshape(outputData1,[numrows, numcols]);
    outputData2 = reshape(outputData2,[numrows, numcols]);
%     im = imread(dirPath);
    im = [];
    save(an_path,'outputData1','outputData2','blockSize','im', 'DPslide');  

    disp('Analysis Complete');
end

