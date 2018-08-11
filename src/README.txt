%give any questions about the below to adkyriazis@gmail.com
%This should act as a road map for how to go from training to having a full
%model. This should not be used literally line-by-line as care needs to be
%put into each file to make sure it will do what you want.

run init.m %calls default config values and sets path stuff

%Do WM segmentation (result is a collection of interfaceOutput folders)

%Sample interface output to get collection of N WM patches
InterfaceOutputSampler;

%Take all sampled WM patches, put them in the +Annotation_cell/images folder

%label all Annotation data
Annotation_cell.manual_label_new_image

%make sure outputted annotation_data goes in +Annotation_cell/

%Optionally perform a second labelling

%create union and intersect set of cell data (if you used two labellings)
Annotation_cell.combine_data

%sample a few times to see if annotation worked properly
Annotation_cell.display_truth('tom'); %or asma,tom,union,intersect

%split WM patches into train / test
TrainTestSampler;

%VERY IMPORTANT - MAKE SURE THAT the ground truth set is properly set in 
%Verify.evaluate_image_performance in the load() command

%grad descent to fix some parameters
Config.set_config('USE_DEEP_FILTER',0); %without the deep filter
Tools.GradDescent.learn('intersect','algorithm','train'); %make sure that common/+Tools/+GradDescent/private/cost.m is optimizing on the right data.
%The result of the gradient descent will need to be manually inserted into
%teh configuration file. Go to Config.get_config, and fix the values of 
%global_config.LOWER_SIZE_BOUND and global_config.MUMFORD_SHAH_LAMBDA based
%on the gradient descent result.

run init.m  %to update the config values

%make cell sets (put in desired location X)
ML.prepare_training; 

%make classification model (open location X), save classification model
ML.NN.output_classifier;
%update cell classifier path in Config.get_config

run init.m  %to update the config values

%test model a few times for fun
Config.set_config('USE_DEEP_FILTER',1);
Verify.evaluate_single_random;

%run testing script
Verify.evaluate_PR('test'); %First make sure that it is saving its intermediate results somewhere appropriate
% instead of 'test' could use validate, or train (validate will be on all
% images in training set that the CNN did not train on, 'train' will be on
% all images in training set the CNN did train on

%MORPHOLOGY
Annotation_morph.output_cells %saves a collection of cells into /images2
Annotation_morph.sample_images %take a new N size collection into /sampled2

%put these sampled images into +Annotation_morph/morphology_annotation_utility/images
%use +Annotation_morph/morphology_annotation_utility/manual_label_new_image.m
%to get labelling file and put that in +Annotation_morph/

%Use either of the following functions to evaluate the classifier
Morph.train_classifer_thresh %generates an ROC curve
Morph.train_classifer_deterministic %only uses a single decision threshold

Morph.train_classifer %to actually save the classifier somewhere.
%update morph classifier path in Config.get_config

run init.m  %to update the config values











