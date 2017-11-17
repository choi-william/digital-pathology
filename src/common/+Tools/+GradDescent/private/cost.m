% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% The cost function by which the gradient descent operates

function [cost,TP,FP,FN] = cost(P)
    Config.set_config('LOWER_SIZE_BOUND',P(1));
    Config.set_config('MUMFORD_SHAH_LAMBDA',P(2));
    Config.set_config('DEEP_FILTER_THRESHOLD',P(3));

    %[GT,TP,FP,FN] = Verify.evaluate_all('union','algorithm','train');
    %cost = FP + 3*FN;
    cost = randi(100);
    TP=randi(30);
    FP=randi(30);
    FN=randi(30);
end

