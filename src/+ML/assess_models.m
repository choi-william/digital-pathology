% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Compares all machine learning methods on one precision recall curve
% Prerequisites are to run: 
%ML.prepare_training.m and ML.FEATURE_EXTRACTION.get_features_nn.m

% NMethods = 5;
% 
% TH = 0:0.05:1;
% result = zeros(length(TH),2,NMethods);
%     
% [ld,ll] = ML.Logistic.logistic_train();
% fprintf('done Logistic');
% [sd,sl] = ML.SVM.svm_train();
% fprintf('done SVM');
% [rd,rl] = ML.RF.rf_train();
% fprintf('done RF');
% [ad,al] = ML.Adaboost.ada_train();
% fprintf('doe ADA');
% [nd,nl] = ML.NN.nn_train();
% fprintf('done neural network');
% 
% decisions = {ld,sd,rd,ad,nd};
% labels = {ll,sl,rl,al,nl};
% 
% for b = 1:NMethods
%     dec = decisions{b};
%     lab = labels{b};
% 
%     for k = 1:length(TH)
%         average = zeros(2,2);
%         for j = 1:size(dec,2)
%             Yclass = dec(:,j) > TH(k);
%             clear predictedLabels;
%             for i=1:length(Yclass)
%                 if Yclass(i) == 1
%                     predictedLabels(i) = "falsePositives";
%                 elseif Yclass(i) ==0
%                     predictedLabels(i) = "truePositives";
%                 end
%             end
%             confMat = confusionmat(lab(:,j), categorical(string(predictedLabels)));
%             average = average + bsxfun(@rdivide,confMat,sum(confMat,2))/size(dec,2);
%         end
% 
%         TP = average(2,2);
%         FP = average(1,2);
%         FN = average(2,1);
% 
%         precision = TP/(TP+FP);
%         recall = TP/(TP+FN);
% 
%         if isnan(precision)
%            precision = 1; 
%         end
% 
%         result(k,1,b) = precision;
%         result(k,2,b) = recall;
%     end
%     fprintf('done %d of %d\n',b,NMethods);
% end
% 
% save('+ML/assess_models_intermediate_4.mat','result');
load('+ML/assess_models_intermediate_4.mat','result');
figure;
hold on;
title('Classification Model Comparison','FontSize',20);
xlabel('Recall','FontSize',15);
ylabel('Precision','FontSize',15);
ylim([0.5, 1]); 
xlim([0, 1]);

grid on;

plot(result(:,2,1),result(:,1,1),'DisplayName','Logistic Regression Ensemble','LineWidth',3);
plot(result(:,2,2),result(:,1,2),'DisplayName','SVM','LineWidth',3);
plot(result(:,2,3),result(:,1,3),'DisplayName','Random Forest','LineWidth',3);
plot(result(:,2,4),result(:,1,4),'DisplayName','Adaboost','LineWidth',3);
plot(result(:,2,5),result(:,1,5),'DisplayName','Fully Trained Neural Network','LineWidth',3);

lgd = legend('show');
lgd.FontSize = 18;