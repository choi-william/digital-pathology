% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Runs evaluate_image_performance with a random image

close all;
found_dpids = [];
files = dir('../data/v3/');
k= 1;
while k <= length(files)
    if endsWith(files(k).name,'.tif')
        filename = strip(files(k).name,'left','0');
        num = str2num(filename(1:end-4));
        found_dpids = [found_dpids num];
    end
    k = k + 1;
end

for i = 1:5
    Verify.evaluate_image_performance(found_dpids(randi(length(found_dpids))),2);
end