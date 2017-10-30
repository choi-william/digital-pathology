NMethods = 5;

% [ld,ll] = ML.Logistic.logistic_train();
% fprintf('done Logistic');
% [sd,sl] = ML.SVM.svm_train();
% fprintf('done SVM');
% [rd,rl] = ML.RF.rf_train();
% fprintf('done RF');
% [ad,al] = ML.Adaboost.ada_train();
% fprintf('done ADA');
% [nd,nl] = ML.NN.nn_train();
% fprintf('done neural network');
% 
% decisions = {ld,sd,rd,ad,nd};
% labels = {ll,sl,rl,al,nl};
% 
% save('+ML/assess_models_intermediate.mat','decisions','labels');

load('+ML/assess_models_intermediate.mat','decisions','labels');

TH = 0:0.01:1;

result = zeros(length(TH),2,NMethods);

for b = 1:NMethods
    dec = decisions{b};
    lab = labels{b};

    for k = 1:length(TH)
        average = zeros(2,2);
        for j = 1:size(dec,2)
            Yclass = dec(:,j) >= TH(k);
            for i=1:length(Yclass)
                if Yclass(i) == 1
                    predictedLabels(i) = "falsePositives";
                elseif Yclass(i) ==0
                    predictedLabels(i) = "truePositives";
                end
            end
            confMat = confusionmat(lab(:,j), categorical(string(predictedLabels)));
            average = average + bsxfun(@rdivide,confMat,sum(confMat,2))/size(dec,2);
        end

        TP = average(2,2);
        FP = average(1,2);
        FN = average(2,1);
        
        precision = TP/(TP+FP);
        recall = TP/(TP+FN);

        if isnan(precision)
           precision = 1; 
        end

        result(k,1,b) = precision;
        result(k,2,b) = recall;
    end
    fprintf('done %d of %d\n',b,NMethods);
end

figure;
hold on;
title('Precision and Recall','FontSize',20);
xlabel('Recall','FontSize',15);
ylabel('Precision','FontSize',15);
ylim([0.5, 1]); 
xlim([0, 1]);

grid on;

plot(result(:,2,1),result(:,1,1),'DisplayName','Logistic Regression Ensemble','LineWidth',2);
plot(result(:,2,2),result(:,1,2),'DisplayName','SVM','LineWidth',2);
plot(result(:,2,3),result(:,1,3),'DisplayName','Random Forest','LineWidth',2);
plot(result(:,2,4),result(:,1,4),'DisplayName','Adaboost','LineWidth',2);
plot(result(:,2,5),result(:,1,5),'DisplayName','Neural Network','LineWidth',2);

legend('show');