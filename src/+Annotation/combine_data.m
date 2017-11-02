% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

global dataPath;

combined_data = [];

set1 = load('+Annotation/annotation_data_asma.mat');
data1=set1.data;
dpids1=set1.dpids;

set2 = load('+Annotation/annotation_data_tom.mat');
data2=set2.data;
dpids2=set2.dpids;

common_dpids = intersect(dpids1,dpids2);

data1 = data1(ismember(data1(:,1),common_dpids),:);
data2 = data2(ismember(data2(:,1),common_dpids),:);

for i=1:size(common_dpids,1)
    dpid = common_dpids(i);
    
    dpid_data1 = data1(data1(:,1) == dpid, :);
    dpid_data1 = dpid_data1(:,2:end);

    dpid_data2 = data2(data2(:,1) == dpid, :);
    dpid_data2 = dpid_data2(:,2:end);

    unique_to_1 = ones(size(dpid_data1,1),1);
    unique_to_2 = ones(size(dpid_data2,1),1);
    
    for k=1:size(unique_to_1,1)
        for j=1:size(unique_to_2,1) 
            point1 = round(dpid_data1(k,:));
            point2 = round(dpid_data2(j,:));     

            if (unique_to_2(j) == 0)
                continue
            end

            d = Helper.CalcDistance(point1,point2);
            if (d < 15)
               unique_to_1(k) = 0;
               unique_to_2(j) = 0;
               if rand(2) == 1
                  combined_data = [combined_data; dpid point1(1) point1(2)]; 
               else
                  combined_data = [combined_data; dpid point2(1) point2(2)];                   
               end
               break;                 
            end
        end
    end
    fprintf('done %d of %d\n',i,size(common_dpids,1));

end

dpids = common_dpids;
data = combined_data;
save('+Annotation/annotation_data_combined.mat','dpids','data');




 