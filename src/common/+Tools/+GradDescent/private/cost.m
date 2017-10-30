% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% The cost function by which the gradient descent operates

function [score] = cost( dps, P )
    score = 0;
    
    %TESTING FUNCTION
    %score = sin(P(1)*pi/2)*sin(P(2)*pi/2) - 1; 
    
    for i=1:size(dps,2)
        [a,addedScore] = Verify.evaluate_soma(Segment.Soma.extract_soma(dps(i),2,P(1),round(P(2))),0);
        score = score + addedScore;
    end
    score = score/size(dps,2);
end

