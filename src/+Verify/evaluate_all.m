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
    load('+ML/deep_learning_model.mat');
    
    training_set_dpids = find_dpids('train');
    testing_set_dpids = find_dpids('test');
    
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
            elseif strcmp(set_type,'test')
                dpids = testing_set_dpids;
            else
                error('invalid evaluation set');
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
            elseif strcmp(set_type,'test')
                dpids = testing_set_dpids;
            else
                error('invalid evaluation set');
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

    
    %now make sure we are only working on the validation set
 
    if strcmp(set_type,'validate')
        %take entire training set
        label_dpids = intersect(label_dpids,training_set_dpids);
        prediction_dpids = intersect(prediction_dpids,training_set_dpids);
        
        %take validation part of training set
        label_dpids = setdiff(label_dpids,training_dpids);    
        prediction_dpids = setdiff(prediction_dpids,training_dpids);
    elseif strcmp(set_type,'train')
        %take entire training set
        label_dpids = intersect(label_dpids,training_set_dpids);
        prediction_dpids = intersect(prediction_dpids,training_set_dpids);
        
        %take training part of training set
        label_dpids = intersect(label_dpids,training_dpids);    
        prediction_dpids = intersect(prediction_dpids,training_dpids); 
    elseif strcmp(set_type,'test')
        
        %get entire testing set
        label_dpids = intersect(label_dpids,testing_set_dpids);
        prediction_dpids = intersect(prediction_dpids,testing_set_dpids);
    else
        error('BAD');
    end
    
    %get only data contained in dpids
    if ~isempty(label_data)
        label_data = label_data(ismember(label_data(:,1),label_dpids),:);
    end
    if ~isempty(prediction_data)
        prediction_data = prediction_data(ismember(prediction_data(:,1),prediction_dpids),:);
    end
    %only take the common dpids between them;
    common_dpids = intersect(label_dpids,prediction_dpids);
    if ~isempty(label_data)
        label_data = label_data(ismember(label_data(:,1),common_dpids),:);
    end
    if ~isempty(prediction_data)
        prediction_data = prediction_data(ismember(prediction_data(:,1),common_dpids),:);
    end
    
    [GT,TP,FP,FN] = Verify.compare_data(common_dpids,label_data,prediction_data);
    %fprintf('Precision: %f, Recall: %f',TP/(TP+FP),TP/(TP+FN));
end
