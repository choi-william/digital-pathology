load('+Annotation/annotation_data.mat');

dpid = dpids(randi(length(dpids)));

points = data(data(:,1)==dpid,:);
points = points(:,2:end);


image_name = ['../data/train/', num2str(dpid),'.tif']
image = imread(image_name);
imshow([image image],'InitialMagnification',400);
hold on;

for j=1:size(points,1)
    plot(points(j,1),points(j,2),'.','color','blue','MarkerSize',40);
end