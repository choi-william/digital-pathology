% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

set1 = load('+Annotation/annotation_data_asma.mat');
data1=set1.data;
dpids1=set1.dpids;

set2 = load('+Annotation/annotation_data_tom.mat');
data2=set2.data;
dpids2=set2.dpids;

common_dpids = intersect(dpids1,dpids2);

fprintf('%d images not common\n',size(length(dpids1)+length(dpids2)-2*length(common_dpids)));

total_I = 0;
total_U1 = 0;
total_U2 = 0;

for k=1:size(common_dpids,1)
    dpid = common_dpids(k);
    
    dpid_data1 = data1(data1(:,1) == dpid, :);
    dpid_data2 = data2(data2(:,1) == dpid, :);

    dpid_data1 = dpid_data1(:,2:end);
    dpid_data2 = dpid_data2(:,2:end);

    unique_to_1 = ones(size(dpid_data1,1),1);
    unique_to_2 = ones(size(dpid_data2,1),1);

    for i=1:size(unique_to_1,1)
        point1 = round(dpid_data1(i,:));
        for j=1:size(unique_to_2,1) 
            if (unique_to_2(j) == 0)
                continue
            end
            point2 = round(dpid_data2(j,:));     
            
            d = Helper.CalcDistance(point1,point2);
            if (d < 15)
               unique_to_1(i) = 0;
               unique_to_2(j) = 0;
               break;                 
            end
        end
    end
    
    I = sum(unique_to_1==0);
    U1 = sum(unique_to_1==1);
    U2 = sum(unique_to_2==1);
    
    total_I = total_I + I;
    total_U1 = total_U1 + U1;
    total_U2 = total_U2 + U2;
    
    fprintf('done %d of %d\n',k,size(common_dpids,1));
end

total_I
total_U1
total_U2





 