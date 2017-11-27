% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi
% 
% 
function [rotated_image_list] = rotate_image(image)
    angle_interval = 90; % degrees
    number_of_images = 360/angle_interval;
    
    rotated_image_list = cell(number_of_images,1);
    for i=1:number_of_images
        rotated_image_list{i} = imrotate(image,(i-1)*angle_interval);
    end
end

