% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi
% 
% Separates a large clump of cells into its constituent cells
%
function [ flag, somas ] = resolve_clump( dpcell )

    somas = 0;
    flag = 0;

    Iobrcbr = dpcell.oImage;

    rgbIm = dpcell.subImage;
    

    adjusted = imadjust(rgb2gray(rgbIm),[0; Config.get_config('CLUMP_ADJUST_THRESHOLD')],[0; 1]);
    
    mumfordIm = smooth_ms(adjusted, Config.get_config('CLUMP_MUMFORD_SHAH_LAMBDA'), Inf);
    
    out = imbinarize(mumfordIm,Config.get_config('CLUMP_THRESHOLD'));
    
    %find the mask of the actual cell clump
    dim = size(adjusted);
    mask = false(dim(1:2));          
    for i=1:size(dpcell.pixelList,1)
        A = dpcell.pixelList(i,:);
        A = round(A-dpcell.TL)+[1,1]; %adjust for soma image
        mask(round(A(2)),round(A(1))) = 1;                
    end  
   
    out = ~((~out) .* mask);



% FOR MULTITHRESHOLDING STUFF

    
%     adjusted = imadjust(rgb2gray(rgbIm),[0;get_av_soma_intensity(dpcell)/255],[0;1]);
    
%     dim = size(adjusted);
%     mask = false(dim(1:2));
%     for i=1:size(dpcell.pixelList,1)
%         A = dpcell.pixelList(i,:);
%         A = round(A-dpcell.TL)+[1,1]; %adjust for soma image
%         mask(round(A(2)),round(A(1))) = 1;                
%     end
%     adjusted(imcomplement(mask)) = 255;
    
%     mumfordIm = smooth_ms(adjusted, 0.005, 300);    
%     out = imbinarize(mumfordIm);
%     comp = bwconncomp(~out); 
    
    % Multi-Thresholding
    % IMAGE QUANTIZATION using Otsu's mutilevel iamge thresholding
%     N = 10; % number of thresholds % temporary changed to 13 from 20
%     thresh = multithresh(adjusted, N);
%     quantIm = imquantize(adjusted, thresh);
%     
%     % SOMA DETECTION
%     minSomaSize = 60;
%     newQuantIm = zeros(size(adjusted));
% 
%     addedObjects = zeros(size(adjusted));
%     numCountedObjects = zeros(1, N+1);
%     testIm = zeros(size(adjusted));
%     for i = 1:N+1
%         levelIm = quantIm <= i;
% 
%         countedObjects = bwareaopen(levelIm,minSomaSize);
%         CC = bwconncomp(countedObjects);
%         if CC.NumObjects ~= 0 
%             for j = 1:CC.NumObjects
%                 componentIm = false(size(adjusted));
%                 componentIm(CC.PixelIdxList{j}) = 1;
%                 overlapIm = and(testIm,componentIm);
%                 if sum(overlapIm(:)) > 0
%                     countedObjects(componentIm) = 0;
%                 end
%             end
%             testIm = or(testIm, countedObjects);
%         end
%     end
%     
%     figure;
%     imshow([rgb2gray(rgbIm); adjusted; 255*mask; mumfordIm; 255*out;]);
%         
    %MULTITHRESHOLDING STUFF
%     comp = bwconncomp(testIm);  

    comp = bwconncomp(~out);

    somas = {};
    for i=1:comp.NumObjects
        [row,col] = ind2sub(comp.ImageSize,comp.PixelIdxList{i}); 
        
        row = row + dpcell.TL(2)-1; %convert to image coordinates
        col = col + dpcell.TL(1)-1; %convert to image coordinates

        if (size(row,1) < Config.get_config('CLUMP_THRESHOLD_MIN_SIZE'))
           continue;  %vtoo small- discard
        end
        
        centr = round(sum([col,row],1)/size(row,1)); %x-y coordinates
        good = pixelListBinarySearch(round(dpcell.pixelList),round(centr));
        
        if (good == 0)
           continue; %not part of original soma
        end
        
        soma = DPCell([col,row],dpcell.referenceDPImage);
        
        soma.isClump = 1;
        soma = prepare_soma(soma);
        somas{end+1} = soma{1};
    end
    
    r = dpcell.area/size(somas,1); %average area per soma
    if (r < 150) %probably too small
        somas = 0;
        return;
    end
    
    if (size(somas,1) > 0)
       flag = 1; 
    end
end

