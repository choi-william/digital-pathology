function [decisions,result_labels] = ada_train()

    load('../data/formatted/meta.mat'); % to get training_dpids
    load('../data/formatted/features_alexnet.mat'); %to get feature_layer
    
    X = (features-mean(features))./std(features);
    Y = labels;
    
    %format X
    TRAINING_TESTING_SPLIT = 0.9;
    
    n = size(X,1);
    d = size(X,2);
    
    Ntrees = 100;

    decisions = [];
    result_labels = [];
    average = zeros(2,2);
    iterations = 10;
    for k=1:iterations
        
        random_indeces = randperm(n);
        train_indeces = random_indeces(1:(floor(n*TRAINING_TESTING_SPLIT)));
        test_indeces = random_indeces((floor(n*TRAINING_TESTING_SPLIT)+1):end);

        Xtrain = X(train_indeces,:);
        Ytrain = Y(train_indeces,:);

        Xtest = X(test_indeces,:);
        Ytest = Y(test_indeces,:);
        
        classifier = fitensemble(Xtrain,Ytrain,'AdaBoostM1',Ntrees,'Tree');
        
        [~,Yprob] = predict(classifier, Xtest);
        Yprob = (Yprob(:,1)/(2*max(abs(Yprob(:,1)))))+0.5;
        
        assert(~any(Yprob<0));
        assert(~any(Yprob>1));

        decisions = [decisions Yprob];
        result_labels = [result_labels Ytest];
        Yclass = Yprob > 0.65;
        for i=1:length(Yclass)
            if Yclass(i) == 1
                predictedLabels(i) = "falsePositives";
            elseif Yclass(i) ==0
                predictedLabels(i) = "truePositives";
            end
        end

        confMat = confusionmat(Ytest, categorical(string(predictedLabels)));
        average = average + bsxfun(@rdivide,confMat,sum(confMat,2))/iterations;
        fprintf('done iteration %d of %d\n',k,iterations);

    end
    average
    %save('+ML/deep_learning_model.mat','classifier','FEATURE_LAYER','training_dpids');

end
