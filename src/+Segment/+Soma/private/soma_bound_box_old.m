% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi
% 
% Sets the 'subimage' property of the cell by dynamically determining a
% bounding box around the cell based on its size.
%

function [soma] = soma_bound_box_old( soma, basicOrAdvanced )

    %0 is basic, 1 is advanced
    bigImage = soma.referenceDPImage.image;
    ocbrcImage = soma.referenceDPImage.preThresh;
    
    [maxh,maxw] = size(bigImage);

    factor = 2.5;
    newTL = soma.centroid - round(ones(1,2)*soma.maxRadius*factor); %x,y
    newBR = soma.centroid + round(ones(1,2)*soma.maxRadius*factor); %x,y
    
    TL = [-1 -1];
    BR = [-1 -1];
    
    if newTL(1) < 1
        newTL(1) = 1;
    end
    if newTL(2) < 1
        newTL(2) = 1;
    end    
    if newBR(1) > maxw
        newBR(1) = maxw;
    end    
    if newBR(2) > maxh
        newBR(2) = maxh;
    end 
    numIter = 1;
    while (~isequal(TL,newTL) || ~isequal(BR,newBR))
        
        if (numIter == 5)
            soma.subImage = imcrop(bigImage,[TL, C(1), C(2)]);
            soma.oImage = oim;
            soma.rCentroid = relCentroid;
            soma.TL = TL;
            return;
        end
        TL = newTL;
        BR = newBR;
        C = round(BR-TL);
        relCentroid = soma.centroid - TL + [1,1];
        oim = imcrop(ocbrcImage,[TL, C(1), C(2)]);

        if (basicOrAdvanced == 0)
           soma.subImage = imcrop(bigImage,[TL, C(1), C(2)]);
           soma.oImage = oim;
           soma.rCentroid = relCentroid;
           soma.TL = TL;
           return; %basic mode
        end
        
        se = strel('disk', 3);
        
        %OPEN BY RECONSTRUCTION%
        bb = imbinarize(oim,0.5);

        %close all;
        %imshow(bb);
        %hold on;
        %plot(relCentroid(1),relCentroid(2),'.','MarkerSize',10,'color','blue');
        
        comp = bwconncomp(imcomplement(bb));  
        part = -1;
        for i=1:comp.NumObjects
            [row,col] = ind2sub(comp.ImageSize,comp.PixelIdxList{i});
            list = [row col];
            for j=1:size(list,1)
                if (list(j,1) == round(relCentroid(2)) && list(j,2) == round(relCentroid(1)))
                    part = i;
                    break;
                end
            end
            if (part ~= -1)
                break;
            end
        end    
        if (part == -1)
           %not good
           soma.subImage = imcrop(bigImage,[TL, C(1), C(2)]);
           soma.oImage = oim;
           soma.rCentroid = relCentroid;
           soma.TL = TL;
           return;
        end

        [row,col] = ind2sub(comp.ImageSize,comp.PixelIdxList{part});

        newTL = TL;
        newBR = BR;
        if any(row==1) || any(row==C(2))
            newTL = newTL - [0 soma.maxRadius]; %expand upwards
            newBR = newBR + [0 soma.maxRadius]; %expand downwards
        end
        if any(col==1) || any(col==C(1))
            newTL = newTL - [soma.maxRadius 0]; %expand leftwards
            newBR = newBR + [soma.maxRadius 0]; %expand rightwards               
        end
        if newTL(1) < 1
            newTL(1) = 1;
        end
        if newTL(2) < 1
            newTL(2) = 1;
        end    
        if newBR(1) > maxw
            newBR(1) = maxw;
        end    
        if newBR(2) > maxh
            newBR(2) = maxh;
        end 
        
        numIter = numIter+1;
    end
    
    soma.subImage = imcrop(bigImage,[TL, C(1), C(2)]);
    soma.oImage = oim;
    soma.rCentroid = relCentroid;
    soma.TL = TL;
end

