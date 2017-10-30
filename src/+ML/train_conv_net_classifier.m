% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Trains a convolutional neural network on images of false positive
% and true positive cell classes. Requires a call to 'prepare_training.m'

run init.m

TRAINING_TESTING_SPLIT = 0.7;
out_path = uigetdir('+ML/','Choose training folder');

categories = {'falsePositives', 'truePositives'};

imds = imageDatastore(fullfile(out_path, categories), 'LabelSource', 'foldernames');

tbl = countEachLabel(imds);

minSetCount = min(tbl{:,2}); % determine the smallest amount of images in a category

% Use splitEachLabel method to trim the set.
imds = splitEachLabel(imds, minSetCount, 'randomize');

% Notice that each set now has exactly the same number of images.
countEachLabel(imds)

% Find the first instance of an image for each category
falsePositives = find(imds.Labels == 'falsePositives', 1);
truePositives = find(imds.Labels == 'truePositives', 1);

cnnMatFile = 'assets/imagenet-caffe-alex.mat';

% Load MatConvNet network into a SeriesNetwork
convnet = helperImportMatConvNet(cnnMatFile);

% View the CNN architecture
convnet.Layers;

% Inspect the first layer
convnet.Layers(1);

% Inspect the last layer
convnet.Layers(end);

% Number of class names for ImageNet classification task
numel(convnet.Layers(end).ClassNames);

% Set the ImageDatastore ReadFcn
imds.ReadFcn = @(filename)readAndPreprocessImage(filename);

[trainingSet, testSet] = splitEachLabel(imds, TRAINING_TESTING_SPLIT, 'randomize');

% Get the network weights for the second convolutional layer
w1 = convnet.Layers(2).Weights;

% Scale and resize the weights for visualization
w1 = mat2gray(w1);
w1 = imresize(w1,5);

% Display a montage of network weights. There are 96 individual sets of
% weights in the first layer.
%     figure
%     montage(w1)
%     title('First convolutional layer weights')

featureLayer = 'fc6';
trainingFeatures = activations(convnet, trainingSet, featureLayer, ...
   'MiniBatchSize', 32, 'OutputAs', 'rows');

% Get training labels from the trainingSet
trainingLabels = trainingSet.Labels;

L = getRegressionLabels(trainingSet.Labels);
% Train multiclass SVM classifier using a fast linear solver, and set
% 'ObservationsIn' to 'columns' to match the arrangement used for training
% features.

classifier = fitcecoc(trainingFeatures, L, ...
    'Learners', 'Linear', 'Coding', 'onevsall', 'ObservationsIn', 'rows');
%classifier = fitensemble(trainingFeatures,trainingLabels,'AdaBoostM1',100,'tree', 'ObservationsIn', 'rows');
%classifier = TreeBagger(100,trainingFeatures,trainingLabels,'oobpred','on','minleaf',1)

% Extract test features using the CNN
testFeatures = activations(convnet, testSet, featureLayer, ...
    'MiniBatchSize',32, 'OutputAs', 'rows');

% Pass CNN image features to trained classifier
predictedLabels = predict(classifier, testFeatures);

% Get the known labels
testLabels = testSet.Labels;

% Tabulate the results using a confusion matrix.
confMat = confusionmat(testLabels, predictedLabels);

% Convert confusion matrix into percentage form
confMat = bsxfun(@rdivide,confMat,sum(confMat,2))

load('+ML/meta.mat'); % to get training_dpids
save('+ML/deep_learning_model.mat','classifier','featureLayer','training_dpids');

function Iout = readAndPreprocessImage(filename)

    I = imread(filename);

    % Some images may be grayscale. Replicate the image 3 times to
    % create an RGB image.
    if ismatrix(I)
        I = cat(3,I,I,I);
    end

    Iout = imresize(I, [227 227]);
end

function L = getRegressionLabels(classifier_labels)
    L = zeros(length(classifier_labels),1);
    for i=1:length(classifier_labels)
        if classifier_labels(i) == 'falsePositives'
            L(i) = -1;
        elseif classifier_labels(i) == 'truePositives'
            L(i) = 1;    
        else
            error('dat aint right, label wrong');
        end
    end
end