% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% The cost function by which the gradient descent operates

function [cost,TP,FP,FN] = cost(P,label_set, prediction_set,set_type)
% 
    Config.set_config('LOWER_SIZE_BOUND',P(1));
    Config.set_config('MUMFORD_SHAH_LAMBDA',P(2));

    [GT,TP,FP,FN] = Verify.evaluate_all(label_set, prediction_set,set_type);
    cost = FP + 8*FN;
%     P = TP/(TP+FP);
%     R = TP/(TP+FN);   
%     cost = -2*P*R/(P+R);
end

