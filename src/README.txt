All questions about the below can be sent to adkyriazis@gmail.com

This should act as a road map for how to train the automated pipeline.

NOTE: This should not be used literally line-by-line, as further care needs to be taken. Please additionally read the documentation for each file being run.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
WHITE MATTER SEGMENTATION DETECTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TODO

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CELL DETECTION ANALYSIS TRAINING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

1. run init.m 
-resets the configuration parameters, and sets path info.

2. Execute White Matter segmentation 
-result is a collection of folders for each slide

3. Sample the White Matter patches to get a smaller collection
execute Tools.interface_output_sampler

4. Take sampled WM patches (1.tif to N.tif), put them in the +Annotation_cell/images folder

5. Label microglia positions by running the following until it says you are done:
execute Annotation_cell.manual_label_new_image

5b. Optionally perform a second labellin
-rename +Annotation_cell/cell_detection_analysis_utility/labelling/annotation_data.mat to annotation_data_[NAME].mat
-execute Annotation_cell.combine_data

6. Check if annotation worked properly
execute Annotation_cell.display_truth('tom'); or asma/tom/union/intersect

7. Split WM patches into train / test
execute Tools.train_test_sampler; %be careful to change the parameters in the file

8. Perform gradient descent to optimize segmentation parameters
execute Tools.GradDescent.learn('intersect','algorithm','train');
-Possibly need to rerun after finishing with a lower learning rate, to optimize even better.

9. Insert the results of the gradient descent into the configuration file
-Go to Config.get_config, and fix the values of LOWER_SIZE_BOUND and MUMFORD_SHAH_LAMBDA 
-run init.m  %to update the config values

10. Make cell sets for CNN training
execute ML.prepare_training('union', 1.0); %union/asma/tom/intersect
-do less than 1.0 if you want to report results on a validation set

11. Make classification model. Open the location saved in (11)
execute ML.NN.output_classifier;

12. Update cell classifier path in Config.get_config based on saved classifier in (12)
-also confirm 'USE_DEEP_FILTER' is set to 1 in Config.get_config;
-run init.m  %to update the config values

13. test model a few times for fun, and to make sure things are kind of working
execute Verify.evaluate_single_random;

14. Run a full set analysis:
execute Verify.evaluate_all('union', 'algorithm', 'validate') %asma/tom/union/intersect/algorithm, train/test/validate

15. Run and view full Precision-recall curve 
execute Verify.save_PR_results('test'); %test/train but probably you want 'test'
execute Verify.view_PR_results; %prompts a dialogue to open the previous

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MORPHOLOGY ANALYSIS TRAINING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

16. Get cell set for training data
execute Annotation_morph.output_cells %saves a collection of cells
execute Annotation_morph.sample_images %samples cells from the above generated collection

17. Put these sampled images into +Annotation_morph/morphology_annotation_utility/images

18. Label cell data
execute +Annotation_morph/morphology_annotation_utility/manual_label_new_image.m 
-do until you are told you are finished

19. Evaluate how good classification is with an SVM
execute Morph.try_classifier(0.6,5); %tests a classifier with a threshold of 0.6 and with 5 iterations

20. Do an extensive analysis by varying threshold
execute Morph.save_ROC_results %generates an ROC curve
execute Morph.view_ROC_results %views an ROC curve

21. Train a classifier for the pipeline
execute Morph.train_classifer %save it at some location

22. Update morph classifier path in Config.get_config
-run init.m  %to update the config values


%%%%%%%%%%%%%%%%%%%%
RUNNING THE PIPELINE
%%%%%%%%%%%%%%%%%%%%

For a single slide:

execute Pipeline.pathology_analysis(0); %0 for counting AND morphology, 1 for counting only 

For a batch of slides:

execute Pipeline.batch_pathology_analysis(0) %0 for counting AND morphology, 1 for counting only 












