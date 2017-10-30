% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Saves false positive and true positive cell images in distinct folders

% Takes a specificed training set of the annotated images, uses a very
% sensitive version of our automated algorithm to compare against the annotated data set.
% Uses this to generate classes of false positive and true positive cell identifications

global dataPath;
out_path = uigetdir('../data/formatted/','Choose output folder');

tp_class = 'truePositives';
fp_class = 'falsePositives';

mkdir(out_path,tp_class);
mkdir(out_path,fp_class);

path_tp = strcat(out_path,strcat('/',tp_class));
path_fp = strcat(out_path,strcat('/',fp_class));
meta_path = strcat(out_path,strcat('/','meta.mat'));

data=[];
dpids=[];
load('+Annotation/annotation_data.mat');

found_dpids = [];
files = dir('../data/train/');
k= 1;
while k <= length(files)
    if endsWith(files(k).name,'.tif')
        filename = strip(files(k).name,'left','0');
        num = str2num(filename(1:end-4));
        found_dpids = [found_dpids num];
    end
    k = k + 1;
end

dpids = intersect(found_dpids,dpids);
data = data(ismember(data(:,1),found_dpids),:);

%create a training/testing split in dpids
training_percentage = 0.7;
setlength = randperm(size(dpids,1));

training_dpids = dpids(setlength(1:floor(size(setlength,2)*training_percentage)),:);

save(meta_path,'training_dpids');

count = 1;
for i=1:size(training_dpids,1)
    dpid = training_dpids(i);
    dpim = DPImage(dpid); 
    
    found_soma = Segment.Soma.extract_soma(dpim,1,0,0.3,0);

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
                if (d < 10 || inside_mask)
                   fp(j) = 0;
                   break;                 
                end
            end
        end
    end

    for j=1:size(found_soma,2)
        soma = found_soma{j};      

        newim = Tools.get_block(dpim.image,soma.centroid);

        image_name = strcat(num2str(count),'.tif');
        count = count+1;
        
        if (fp(j) == 1)
            imwrite(newim,strcat(path_fp,'/',image_name));
        else
            imwrite(newim,strcat(path_tp,'/',image_name));
        end
    end
end




 