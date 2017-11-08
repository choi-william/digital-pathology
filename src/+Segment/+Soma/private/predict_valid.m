% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi
% 
% A function that classifies the cell based on the passed in model
%

function [ good ] = predict_valid(classifier,dth, cell)   
    I = cell.cnnBox;
    score = predict(classifier, I);
    Yclass = score(:,1) > Config.get_config('DEEP_FILTER_THRESHOLD');
    for i=1:length(Yclass)
        if Yclass(i) == 1
            good = 0;
        elseif Yclass(i) ==0
            good = 1;
        end
    end
end

