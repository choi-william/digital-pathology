% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Evaluates all previously annotated images to determine effectiveness
% of segmentation algorithm

function [] = evaluate_all()

    %We will need to divide the dpids into sections
    
    %mapping from ddpid to brain slide function
    % slide = mapping(ddpid)

	data=[];
	dpids=[];
	load('+Annotation/annotation_data.mat');

    found_dpids = [];
    files = dir('../data/train/');
    k= 1;
    while k <= length(files)
        if endsWith(files(k).name,'.tif')
            filename = strip(files(k).name,'left','0');
            num = str2num(filename(1:end-4));
            found_dpids = [found_dpids num];
        end
        k = k + 1;
    end

    dpids = intersect(found_dpids,dpids);
    data = data(ismember(data(:,1),found_dpids),:);
    
	classifier = [];
	training_dpids = [];
	load('+ML/deep_learning_model.mat');

	testing_dpids = setdiff(dpids,training_dpids);

	total_GT = 0;
	total_TP = 0;
	total_FP = 0;
	total_FN = 0;

	for i=1:size(testing_dpids,1)
		dpid = testing_dpids(i);

		[GT,TP,FP,FN] = Verify.evaluate_image_performance(dpid);

		total_GT=total_GT+GT;
		total_TP=total_TP+TP;
		total_FP=total_FP+FP;
		total_FN=total_GT+FN;
        
        fprintf('done %d out of %d\n',i,size(testing_dpids,1));
        %then above ^ each total would be an array indexed by slide
    end

    total_GT
    total_TP
    total_FP
    total_FN
end