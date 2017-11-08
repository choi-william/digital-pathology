% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Evaluates all previously annotated images to determine effectiveness
% of segmentation algorithm

function [GT,TP,FP,FN] = evaluate_all(label_set, prediction_set,set_type)

    if ~exist('set_type','var')
        set_type = 'validate';
    end   
    if ~exist('label_set','var')
        label_set = 'intersect';
    end   
    if ~exist('prediction_set','var')
        prediction_set = 'algorithm';
    end   
    
    training_dpids = [];
    load('+ML/deep_learning_model_2.mat');
    
    training_set_dpids = find_dpids('train');
    
    %%%
    %GET LABEL DATA
    %%%%
    switch label_set
        case 'tom'
            load('+Annotation/annotation_data_tom.mat');
        case 'asma'
            load('+Annotation/annotation_data_asma.mat');
        case 'intersect'
            load('+Annotation/annotation_data_intersect.mat');
        case 'union'
            load('+Annotation/annotation_data_union.mat');
        case 'algorithm'
            %only training folder
            dpids = training_set_dpids;
            
            if strcmp(set_type,'validate')
                dpids = setdiff(dpids,training_dpids);
            elseif strcmp(set_type,'train')
                dpids = intersect(dpids,training_dpids);                
            end
                        
            %remove bad images
            dpids = remove_edge_images(dpids);
            
            data = get_extraction_data(dpids);
        otherwise
            error('invalid parameter');
    end
    label_dpids = dpids;
    label_data = data;
    
    %%%
    %GET PREDICTION DATA
    %%%
    switch prediction_set
        case 'tom'
            load('+Annotation/annotation_data_tom.mat');
        case 'asma'
            load('+Annotation/annotation_data_asma.mat');
        case 'intersect'
            load('+Annotation/annotation_data_intersect.mat');
        case 'union'
            load('+Annotation/annotation_data_union.mat');
        case 'algorithm'
            %only training folder
            dpids = training_set_dpids;
            
            if strcmp(set_type,'validate')
                dpids = setdiff(dpids,training_dpids);
            elseif strcmp(set_type,'train')
                dpids = intersect(dpids,training_dpids);                
            end
            
            %remove bad images
            dpids = remove_edge_images(dpids);
            
            data = get_extraction_data(dpids);
        otherwise
            error('invalid parameter');
    end
    prediction_dpids = dpids;
    prediction_data = data;
    
    %discard testing set
    label_dpids = intersect(label_dpids,training_set_dpids);
    label_data = label_data(ismember(label_data(:,1),label_dpids),:);
    
    prediction_dpids = intersect(prediction_dpids,training_set_dpids);
    prediction_data = prediction_data(ismember(prediction_data(:,1),prediction_dpids),:);    
    
    %now make sure we are only working on the validation set
 
    if strcmp(set_type,'validate')
        label_dpids = setdiff(label_dpids,training_dpids);    
        prediction_dpids = setdiff(prediction_dpids,training_dpids);
    elseif strcmp(set_type,'train')
        label_dpids = intersect(label_dpids,training_dpids);    
        prediction_dpids = intersect(prediction_dpids,training_dpids);            
    else
        error('BAD');
    end
    
    label_data = label_data(ismember(label_data(:,1),label_dpids),:);
    prediction_data = prediction_data(ismember(prediction_data(:,1),prediction_dpids),:);
    
    %only take the common dpids between them;
    common_dpids = intersect(label_dpids,prediction_dpids);
    label_data = label_data(ismember(label_data(:,1),common_dpids),:);
    prediction_data = prediction_data(ismember(prediction_data(:,1),common_dpids),:);
    
    [GT,TP,FP,FN] = Verify.compare_data(common_dpids,label_data,prediction_data);
end
