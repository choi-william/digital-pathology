function show(img)
%function show(img) displays an image on the screen
%
%Inputs:    img - image to be displayed
%
%Outputs:   figure to screen
%
%
%10/25/04 - Leo Grady

figure
imagesc(img)
colormap(gray)
axis equal
axis tight
colorbar
axis off