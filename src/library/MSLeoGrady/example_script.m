%Script used to demonstrate the Mumford-Shah code using an image in the
%publication:
%Leo Grady and Christopher Alvino, "The Piecewise Smooth Mumford-Shah
%Functional on an Arbitrary Graph", IEEE Trans. on Image Processing, Vol.
%18, No. 11, Nov. 2009.
%
%
%5/14/12 - Leo Grady

clear
close all

%Gradient image
img=im2double(imread('pwsmoothshapes.bmp'));
img=img(:,:,1);

%Initialization
[X Y]=size(img);
initial=zeros(X,Y);
initial(round(X/20):round(19*X/20),round(Y/20):round(19*Y/20))=1;

%Apply Mumford-Shah code
[f g segment recon timeVec costsTally]=combinatorial_mumford_shah(img,.01,.0025,1,initial);
[imgMasks,segOutline,imgMarkup]=segoutput(img,initial);
show(imgMarkup)
title('Initialization')
[imgMasks,segOutline,imgMarkup]=segoutput(img,segment);
show(imgMarkup)
title('Final segmentation')
show(recon)
title('Reconstructed (filtered) image')

disp('Press any key for same execution with intermediate steps.')
pause
[f g segment recon timeVec costsTally]=combinatorial_mumford_shah(img,.01,.0025,1,initial,1);