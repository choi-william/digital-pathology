% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi
% 
% Visualizes the segmentation process (untested in later builds)

function [ output_args ] = display_soma_seg( dpims )

    for k=1:size(dpims,2)
        close all;
        hFig = figure('Color',[0.6 0.6 0.6],'units','normalized','outerposition',[0 0 1 1]);

        set(hFig,'menubar','none')
        set(hFig,'NumberTitle','off');

        tit = suptitle('Cell Body Segmentation');
        P = get(tit,'Position');
        set(tit,'Position',[P(1)+0.01 P(2)+0.01]);
        set(tit,'FontSize',20,'FontWeight','bold');
        
        orig = dpims(k).image;
        
        subplot(1,2,1);
        imshow(orig);

        subplot(1,2,2);

        imshow(orig);
        pause(0.5);

        gray = rgb2gray(orig);
        imshow(gray);
        pause(0.5);

        maxNum = 3;
        for i=1:maxNum
            imshow(smooth_ocbrc(gray,i));
            pause(0.01);        
        end

        smoothed = smooth_ocbrc(gray,maxNum);

        numseconds2 = 1;
        maxNum2 = 20;
        for i=1:maxNum2
            imshow(imadjust(smoothed,[0,1-0.5*i/maxNum2],[0,1]));
            pause(numseconds2/maxNum2);        
        end    

        adjusted = imadjust(smoothed,[0,0.5],[0,1]);

        pause(1);

        binary = imbinarize(adjusted,0.8);
        reject = double(cat(3, binary, binary, binary));
        imshow(binary);

        comp = bwconncomp(imcomplement(binary));
        %figure, imshow(somaIm);

        pause(1);

        for i=1:comp.NumObjects
            [row,col] = ind2sub(comp.ImageSize,comp.PixelIdxList{i});


            if (size(row,1) < 100)
                reject = Tools.colour_overlay(reject,[col,row],'red');
            end
        end    
        imshow(reject);
        pause(1);

        filtered = Helper.sizeFilter(binary,100,100000);
        imshow(uint8(255*filtered));

        pause(1);
        finalIm = getOverlay(orig,filtered);
        imshow(finalIm(3:end-2,3:end-2,:));
        
        pause(1);
        
    end
 
    close all;
    function [ out ] = smooth_ocbrc( in, s )
        se = strel('disk', s);

        %OPEN BY RECONSTRUCTION%
        Ie = imerode(in, se);
        Iobr = imreconstruct(Ie, in);

        %CLOSE BY RECONSTRUCTION%
        Iobrd = imdilate(Iobr, se);
        Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
        out = imcomplement(Iobrcbr);
    end


    function [out] = getOverlay(im,bin)
        boundaries = bwperim(bin);
        boundaries = imdilate(boundaries,strel('disk',1));

        overlay = im;

        r = overlay(:,:,1);
        g = overlay(:,:,2);
        b = overlay(:,:,3);
        r(boundaries) = 0;
        g(boundaries) = 255;
        b(boundaries) = 0;
        overlay(:,:,1) = r;
        overlay(:,:,2) = g;
        overlay(:,:,3) = b;

        out = overlay;
    end

end

