% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

function [GT,TP,FP,FN] = compare_data(dpids,label_data,prediction_data)  

    GT = 0;
    TP = 0;
    FN = 0;
    FP = 0;
    
    for k=1:size(dpids,1)
        dpid = dpids(k);

        dpid_label_data = label_data(label_data(:,1) == dpid, :);
        dpid_prediction_data = prediction_data(prediction_data(:,1) == dpid, :);
        
        dpid_label_data = dpid_label_data(:,2:end);
        dpid_prediction_data = dpid_prediction_data(:,2:end);

        dpid_FN = ones(size(dpid_label_data,1),1);
        dpid_FP = ones(size(dpid_prediction_data,1),1);

        for i=1:size(dpid_label_data,1)
            point1 = round(dpid_label_data(i,:));
            for j=1:size(dpid_prediction_data,1) 
                point2 = round(dpid_prediction_data(j,:));     

                if (dpid_FP(j) == 0)
                    continue
                end

                d = Helper.CalcDistance(point1,point2);
                if (d < 20)
                   dpid_FN(i) = 0;
                   dpid_FP(j) = 0;
                   break;                 
                end
            end
        end

        TP = TP + sum(~dpid_FN);
        FN = FN + sum(dpid_FN);
        FP = FP + sum(dpid_FP);
    end
    GT = FN + TP;
end




 