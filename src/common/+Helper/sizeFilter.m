% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Only keeps the components in the binary image that are between the two
% size bounds


function [ out ] = sizeFilter( in, L, U )
        compIm = imcomplement(in);
        lb_pixel = L;
        ub_pixel = U;
        boundedIm = xor(bwareaopen(compIm,round(lb_pixel)),bwareaopen(compIm,round(ub_pixel)));
        out = imcomplement(boundedIm);
end

