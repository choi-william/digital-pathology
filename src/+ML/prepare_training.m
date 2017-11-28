% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Saves false positive and true positive cell images in distinct folders

% Takes a specificed training set of the annotated images, uses a very
% sensitive version of our automated algorithm to compare against the annotated data set.
% Uses this to generate classes of false positive and true positive cell identifications

out_path = uigetdir('../data/','Choose output folder');

tp_class = 'truePositives';
fp_class = 'falsePositives';

mkdir(out_path,tp_class);
mkdir(out_path,fp_class);

path_tp = strcat(out_path,strcat('/',tp_class));
path_fp = strcat(out_path,strcat('/',fp_class));
meta_path = strcat(out_path,strcat('/','meta.mat'));

data=[];
dpids=[];
load('+Annotation/annotation_data_union.mat');

found_dpids = Tools.find_dpids('train');
dpids = intersect(found_dpids,dpids);
data = data(ismember(data(:,1),found_dpids),:);

%create a training/testing split in dpids
training_percentage = 1.0;
setlength = randperm(size(dpids,1));

training_dpids = dpids(setlength(1:floor(size(setlength,2)*training_percentage)),:);

save(meta_path,'training_dpids');

Config.set_config('USE_DEEP_FILTER',0);

count = 1;
for i=1:size(training_dpids,1)
    dpid = training_dpids(i);
    dpim = DPImage(dpid); 
    
    found_soma = Segment.Soma.extract_soma(dpim);

    ground_truth = data(data(:,1) == dpid, :);
    ground_truth = ground_truth(:,2:end);

    fp = ones(size(found_soma,2),1);
    for i=1:size(ground_truth,1)
        true_point = round(ground_truth(i,:));
        for j=1:size(found_soma,2) 
            soma = found_soma{j};      
            d = Helper.CalcDistance(true_point,soma.centroid);
            if (d < soma.maxRadius)
                inside_mask = pixelListBinarySearch(round(soma.pixelList),round(true_point));
                if (d < 15 || inside_mask)
                   fp(j) = 0;
                   break;                 
                end
            end
        end
    end

    for j=1:size(found_soma,2)
        soma = found_soma{j};      

        newim = Tools.get_block(dpim.image,soma.centroid);

        
        if (fp(j) == 1)
            image_name = strcat(num2str(count),'.tif');
            count = count+1;
            imwrite(imrotate(newim,0),strcat(path_fp,'/',image_name));
            
            image_name = strcat(num2str(count),'.tif');
            count = count+1;
            imwrite(imrotate(newim,90),strcat(path_fp,'/',image_name));
            
            image_name = strcat(num2str(count),'.tif');
            count = count+1;
            imwrite(imrotate(newim,180),strcat(path_fp,'/',image_name));
            
            image_name = strcat(num2str(count),'.tif');
            count = count+1;
            imwrite(imrotate(newim,270),strcat(path_fp,'/',image_name));

        else
            image_name = strcat(num2str(count),'.tif');
            count = count+1;            
            imwrite(imrotate(newim,0),strcat(path_tp,'/',image_name));
            
            image_name = strcat(num2str(count),'.tif');
            count = count+1; 
            imwrite(imrotate(newim,90),strcat(path_tp,'/',image_name));
            
            image_name = strcat(num2str(count),'.tif');
            count = count+1; 
            imwrite(imrotate(newim,180),strcat(path_tp,'/',image_name));
            
            image_name = strcat(num2str(count),'.tif');
            count = count+1; 
            imwrite(imrotate(newim,270),strcat(path_tp,'/',image_name));
        end
    end
end

size_tp = 0;
k= 1;
files_tp = dir(path_tp);
while k <= length(files_tp)
    if endsWith(files_tp(k).name,'.tif')
        size_tp = size_tp + 1;
    end
    k = k + 1;
end

size_fp = 0;
k= 1;
files_fp = dir(path_fp);
while k <= length(files_fp)
    if endsWith(files_fp(k).name,'.tif')
        size_fp = size_fp + 1;
    end
    k = k + 1;
end       

number_to_delete = size_fp - size_tp;

rand_index = randperm(size(files_fp,1));
mixed_files = files_fp(rand_index);

k= 1;
l= 1;
while l <= number_to_delete
    if endsWith(mixed_files(k).name,'.tif')
        delete([path_fp,'/',mixed_files(k).name]);
        l = l+1;
    end
    k = k + 1;
end       










 