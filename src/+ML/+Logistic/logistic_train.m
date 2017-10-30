function [decisions,result_labels] = logistic_train()

    load('../data/formatted/meta.mat'); % to get training_dpids
    load('../data/formatted/features_alexnet.mat'); %to get feature_layer
    
    X = (features-mean(features))./std(features);
    Y = labels;

    %format X
    TRAINING_TESTING_SPLIT = 0.9;
    
    n = size(X,1);
    d = size(X,2);

    %use these numbers for the nn features
    N_MODELS = 100;
    D_MODEL = 100;

    decisions = [];
    result_labels = [];
    average = zeros(2,2);
    iterations = 1/(1-TRAINING_TESTING_SPLIT);
    for k=1:iterations
        random_indeces = randperm(n);
        train_indeces = random_indeces(1:(floor(n*TRAINING_TESTING_SPLIT)));
        test_indeces = random_indeces((floor(n*TRAINING_TESTING_SPLIT)+1):end);

        Xtrain = X(train_indeces,:);
        Ytrain = Y(train_indeces,:);

        Xtest = X(test_indeces,:);
        Ytest = Y(test_indeces,:);

        bigB = zeros(N_MODELS,d+1);
        for i=1:N_MODELS
            a = randperm(d);
            a = a(1:D_MODEL);

            B = mnrfit(double(Xtrain(:,a)),Ytrain);

            fullB = zeros(1,d+1);
            fullB(1,a+1) = B(2:end);
            fullB(1,1) = B(1);
            bigB(i,:) = fullB;
        end

        Yprob = ML.Logistic.logistic_predict(bigB,Xtest);
        decisions = [decisions Yprob(:,1)];
        result_labels = [result_labels Ytest];
        Yclass = Yprob(:,1) > 0.65;
        for i=1:length(Yclass)
            if Yclass(i) == 1
                predictedLabels(i) = "falsePositives";
            elseif Yclass(i) ==0
                predictedLabels(i) = "truePositives";
            end
        end

        [confMat,order] = confusionmat(Ytest, categorical(predictedLabels));
        confMat = bsxfun(@rdivide,confMat,sum(confMat,2));
        
        average = average + confMat/iterations;
        
        fprintf('done iteration %d of %d\n',k,iterations);
        %save('+ML/deep_learning_model.mat','classifier','FEATURE_LAYER','training_dpids');
    end
    average
end