function [ output_args ] = analyze_image( handles, xCoord, yCoord )
%ANALYZE_IMAGE Summary of this function goes here
%   Detailed explanation goes here
    global out_path;
    if (isempty(out_path))
        out_path = '../../data';
    end
    vis_path = strcat(out_path, '/analysis.mat');

    load(vis_path,'outputData1','outputData2','im','blockSize', 'DPslide');
    
    save_path = '../../data/subImage_test'
    
    axes(handles.axes2);
    
    ySize = size(outputData1,1);
    linInd = (xCoord-1)*ySize +yCoord;
    currentIm = imcrop(im,[DPslide(linInd).Pos{1}(1), DPslide(linInd).Pos{1}(2),... 
                                DPslide(linInd).Pos{2}(1)-DPslide(linInd).Pos{1}(1), DPslide(linInd).Pos{2}(2)-DPslide(linInd).Pos{1}(2)]);

    if outputData1(yCoord,xCoord) >= 0
        imwrite(currentIm,strcat(save_path,['/s' num2str(xCoord) num2str(yCoord) '.tif']));
    else
        imshow('../anoush.png');
    end

end

