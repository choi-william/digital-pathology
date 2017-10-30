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

    adjusted = imadjust(rgb2gray(rgbIm),[0; 1],[0; 1]);

    mumfordIm = smooth_ms(adjusted, 0.05, 2000);
    
%     mumfordIm = imadjust(mumfordIm,[0; 0.3],[0; 1]);

%     blurred = imgaussfilt(mumfordIm);
%     a = Tools.smooth_ocbrc(adjusted,2);

      out = imregionalmin(mumfordIm);
%     out = imbinarize(mumfordIm);
      out = imerode(out,strel('disk',1));
%     out = imcomplement(out);
%     
    comp = bwconncomp(imcomplement(out));  
    
%     imshow([adjusted; mumfordIm; 255*imregionalmin(mumfordIm); 255*out;]);
    
%     subplot(1,2,2);
%     imshow(out);

    somas = {};
    for i=1:comp.NumObjects
        [row,col] = ind2sub(comp.ImageSize,comp.PixelIdxList{i}); 
        
        row = row + dpcell.TL(2)-1; %convert to image coordinates
        col = col + dpcell.TL(1)-1; %convert to image coordinates

        if (size(row,1) < 100)
           continue;  %too small- discard
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

