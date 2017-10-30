function [img, imgCurves, imgPoints] = SLgetSeparationTestImage(Npoints)


% generating artificial test image with points and curves
% N : the number of points;
% sigma : gaussian noise level 

% Written by Wang-Q Lim on May 5, 2010. 
% Copyright 2010 by Wang-Q Lim. All Right Reserved.

% generates random points 
x = rand(Npoints,2);
x = floor(250*x);

img = zeros(257,257);
imgCurves = zeros(257,257);
imgPoints = zeros(257,257);

% generates a circle

for i = 1:256
    for j = 1:256
        r = sqrt((i/256-1/2)^2+(j/256-1/2)^2); 
        if r > 0.35 && r < 0.36
            imgCurves(i,j) = 255;
        end
    end
end
            


% generates lines 
for j = 1:256
    
    imgCurves(min(round(1/2*j+10),257),j) = 255;
    imgCurves(min(round(1/2*j+11),257),j) = 255;
    
    imgCurves(min(round((257-j)+10),257),j) = 255;
    imgCurves(min(round((257-j)+11),257),j) = 255;
    
    
    imgCurves(min(round(2*j+132),257),j) = 255;
    imgCurves(min(round(2*j+133),257),j) = 255;
    
    
    imgCurves(j,min(round(1/2*j+150),257)) = 255;
    imgCurves(j, min(round(1/2*j+151),257)) = 255;
    
    imgCurves(j,min(round(1/3*j+80),257)) = 255;
    imgCurves(j,min(round(1/3*j+81),257)) = 255;
    
    imgCurves(j,min(round(1/3*(257-j)+50),257)) = 255;
    imgCurves(j, min(round(1/3*(257-j)+51),257)) = 255;
    
    imgCurves(j,80) = 255;
    imgCurves(j,79) = 255;
    
    imgCurves(120,j) = 255;
    imgCurves(121,j) = 255;
     
end

            


for j = 1:Npoints
    imgPoints(max([x(j,1),1]),max([x(j,2),1])) = 255;
    imgPoints(max([x(j,1),1]),max([1,x(j,2)])) = 255;
    imgPoints(max([x(j,1)+1,1]),max([x(j,2),1])) = 255;
    imgPoints(max([x(j,1),1]),max([x(j,2)-1,1])) = 255;
    imgPoints(max([x(j,1),1]),max([x(j,2)+1,1])) = 255;
end

imgPoints = re_weight_band(imgPoints,[1 0]);
imgPoints = 255*(imgPoints > 20);
img = imgPoints + imgCurves;

img = img(1:256,1:256);
img = min(img,255);

imgPoints = imgPoints(1:256,1:256);
imgCurves = imgCurves(1:256,1:256);
