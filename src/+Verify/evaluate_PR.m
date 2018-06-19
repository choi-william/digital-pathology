% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Evaluate precision recall curve of the automated algorithm by running
% evaluate_all with varying neural network decision thresholds

function [] = evaluate_PR(set_type)
%     X = linspace(0,1,20);
%     precisions = [];
%     recalls = [];
%     for i = 1:length(X);
%         thresh = X(i);
%         Config.set_config('DEEP_FILTER_THRESHOLD',thresh);
%         [GT,TP,FP,FN] = Verify.evaluate_all('union', 'algorithm', set_type);
% 
%         P = TP/(TP+FP);
%         R = TP/(TP+FN);     
% 
%         if isnan(P)
%             P = 1;
%         end
%         
%         precisions = [precisions; P];
%         recalls = [recalls; R];
%         fprintf('Done %d of %d of evaluate_PR',i,length(X));
%     end
%     save('+Verify/evaluate_PR_intermediate.mat','precisions','recalls');
    load('+Verify/evaluate_PR_intermediate.mat','precisions','recalls');
    
    plot(recalls,precisions,'LineWidth',4);
    title({'Cell Detection Accuracy'},'FontSize',20);
    xlabel('Recall','FontSize',15);
    ylabel('Precision','FontSize',15);
    
    ylim([0.5, 1]); 
    xlim([0, 1]);
    [precisions recalls]

    grid on;
end

