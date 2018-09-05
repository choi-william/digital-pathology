% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Gets particular config value, specified by the value's key
% This file also holds the default values that are loaded in upon running
% init.m

function [value] = get_config(param)
    global global_config;

    if isempty(global_config)
        
        %set the defaults

        %make sure to run init.m to reset the changes
        global_config = [];
        global_config.LOWER_SIZE_BOUND = 12.11; %22.48;
        global_config.MUMFORD_SHAH_LAMBDA = 0.0727;%0.1590;
        global_config.WHITE_DISCARD_THRESHOLD = 0.9;
        global_config.MIN_CLUMP_AREA = 500;
        global_config.MAX_CLUMP_AREA = 10000;
        global_config.CLUMP_ADJUST_THRESHOLD = 0.5;
        global_config.CLUMP_MUMFORD_SHAH_LAMBDA = 0.05;
        global_config.CLUMP_THRESHOLD = 0.9;  
        global_config.CLUMP_THRESHOLD_MIN_SIZE = 60;
        global_config.USE_DEEP_FILTER = 1;   
        global_config.DEEP_FILTER_THRESHOLD = 0.7;   
        global_config.MORPH_DECISION_THRESHOLD = 0.6;
        
        global_config.STRICT_CELL_CONDITION = 0.9;
        
        global_config.CELL_CLASSIFIER_PATH = '+ML/classifiers/deep_learning_model_v4.mat';   
        global_config.MORPHOLOGY_CLASSIFIER_PATH = '+Morph/classifiers/morph_classifier_v1.mat';   
        
    end
    if exist('param','var')
        value = global_config.(param);
    else
        value = [];
    end
end

