% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi
% 
% Displays border around cells in dpimage
%

function [] = displayOverlay(dp)
    boundaries = bwperim(dp.somaMask);
    boundaries = imdilate(boundaries,strel('disk',1));
    
    overlay = dp.image;

    r = overlay(:,:,1);
    g = overlay(:,:,2);
    b = overlay(:,:,3);
    r(boundaries) = 0;
    g(boundaries) = 255;
    b(boundaries) = 0;
    overlay(:,:,1) = r;
    overlay(:,:,2) = g;
    overlay(:,:,3) = b;
    
    figure; imshow(overlay);
end

