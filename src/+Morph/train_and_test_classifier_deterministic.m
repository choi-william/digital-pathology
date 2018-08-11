% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis

% Trains a classification model that operates with a single threshold.
% be sure to specify the threshold


tic;
[features,labels] = Morph.extract_data();
toc

t = templateSVM('Standardize',1);

labels(labels==2)=1;
labels(labels==3)=4;

N = size(features,1);
k = N
ITERATIONS=2;

P = [];
Y = [];

THRESH = 0.6; %change this
for j=1:ITERATIONS
    B = reshape(randperm(N),[N/k,k]);
    for i=1:k

        xtest = features(B(:,i),:);
        ytest = labels(B(:,i));

        xtrain = features(setdiff(1:N,B(:,i)),:);
        ytrain = labels(setdiff(1:N,B(:,i)));

        Mdl = fitcecoc(xtrain,ytrain,'Learners',t);

        P = [P; predict(Mdl,xtest)];
        
        [~,p] = predict( Mdl, xtest);
        Yprob = -p(1);
        
        P = [P; (Yprob>THRESH)*3+1];
        Y = [Y; ytest];  
    end
    fprintf('Done %d of %d points\n',j,ITERATIONS);
end

confMat = confusionmat(Y, P);
result = bsxfun(@rdivide,confMat,sum(confMat,2))
