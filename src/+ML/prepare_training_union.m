% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Saves false positive and true positive cell images in distinct folders

global dataPath;
out_path = uigetdir('../data/formatted/','Choose output folder');

tp_class = 'truePositives';
fp_class = 'falsePositives';

mkdir(out_path,tp_class);
mkdir(out_path,fp_class);

path_tp = strcat(out_path,strcat('/',tp_class));
path_fp = strcat(out_path,strcat('/',fp_class));
meta_path = strcat(out_path,strcat('/','meta.mat'));

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

set1 = load('+Annotation/annotation_data_asma.mat');
data1=set1.data;
dpids1=set1.dpids;

set2 = load('+Annotation/annotation_data_tom.mat');
data2=set2.data;
dpids2=set2.dpids;

common_dpids = intersect(dpids1,dpids2);

dpids = intersect(common_dpids,found_dpids);
data1 = data1(ismember(data1(:,1),dpids),:);
data2 = data2(ismember(data2(:,1),dpids),:);


%create a training/testing split in dpids
training_percentage = 0.7;
setlength = randperm(size(dpids,1));

training_dpids = dpids(setlength(1:floor(size(setlength,2)*training_percentage)),:);

save(meta_path,'training_dpids');

count = 1;
for i=1:size(training_dpids,1)
    dpid = training_dpids(i);
    dpim = DPImage(dpid); 
    
    found_soma = Segment.Soma.extract_soma( dpim, 1, 80, 0, 0);

    ground_truth_1 = data1(data1(:,1) == dpid, :);
    ground_truth_1 = ground_truth_1(:,2:end);

    ground_truth_2 = data2(data2(:,1) == dpid, :);
    ground_truth_2 = ground_truth_2(:,2:end);

    fp = ones(size(found_soma,2),1);

    for i=1:size(ground_truth_1,1)
        for k=1:size(ground_truth_2,1)
            true_point_1 = round(ground_truth_1(i,:));
            true_point_2 = round(ground_truth_2(k,:));

            for j=1:size(found_soma,2) 
                if fp(j) == 0
                   continue; 
                end
                soma = found_soma{j};      
                d1 = Helper.CalcDistance(true_point_1,soma.centroid);
                d2 = Helper.CalcDistance(true_point_2,soma.centroid);

                %part of set 1
                cond1 = (d1 < soma.maxRadius) && (d1<15 || pixelListBinarySearch(round(soma.pixelList),round(true_point_1)));
                
                %part of set 2
                cond2 = (d2 < soma.maxRadius) && (d2<15 || pixelListBinarySearch(round(soma.pixelList),round(true_point_2)));
               
                if (cond1 || cond2)
                    fp(j) = 0;
                end
            end
        end
    end

    for j=1:size(found_soma,2)
        soma = found_soma{j};      

        newim = Tools.get_block(dpim.image,soma.centroid);
        image_array = Tools.rotate_image(newim);
        
        for k=1:size(image_array,1)
            image_name = strcat(num2str(count),'.tif');
            count = count+1;
            if (fp(j) == 1)
                imwrite(image_array{k},strcat(path_fp,'/',image_name));
            else
                imwrite(image_array{k},strcat(path_tp,'/',image_name));
            end
        end
    end
end




 