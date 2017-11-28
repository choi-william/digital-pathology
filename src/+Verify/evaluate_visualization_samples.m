% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Samples that are saved from the brain visualization interface are
% automatically collected and have their cell segmentation displayed by
% this file

close all;
found_dpids = {};
files = dir('../data/subImage_test/');
k= 1;
while k <= length(files)
    if endsWith(files(k).name,'.tif')
        filename = strip(files(k).name,'left','0');
        name = filename(1:end-4);
        found_dpids{end+1} = name;
    end
    k = k + 1;
end

for i = 1:5
    Verify.evaluate_image_performance(found_dpids{i},2);
end