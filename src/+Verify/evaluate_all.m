% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Evaluates all previously annotated images to determine effectiveness
% of segmentation algorithm

function [] = evaluate_all()
    PARALLEL_PROCESSING = 0;
    
    tic
    
    if (PARALLEL_PROCESSING) % don't forget to switch FOR/PARFOR below
        parpool; % matlabpool;
    end % 

    %We will need to divide the dpids into sections
    
    %mapping from ddpid to brain slide function
    % slide = mapping(ddpid)

    data=[];
	dpids=[];
	load('+Annotation/annotation_data_combined.mat');

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

    iteration_length = size(testing_dpids,1);
	total_GT = zeros(iteration_length,1);
	total_TP = zeros(iteration_length,1);
	total_FP = zeros(iteration_length,1);
	total_FN = zeros(iteration_length,1);

	for i=1:iteration_length
		dpid = testing_dpids(i);

		[GT,TP,FP,FN] = Verify.evaluate_image_performance(dpid);

		total_GT(i)=GT;
		total_TP(i)=TP;
		total_FP(i)=FP;
		total_FN(i)=FN;
        
        fprintf('done %d out of %d\n',i,iteration_length);
        %then above ^ each total would be an array indexed by slide
    end

    sum(total_GT)
    sum(total_TP)
    sum(total_FP)
    sum(total_FN)
    
    if (PARALLEL_PROCESSING)
        delete(gcp); % matlabpool close;
    end
    
    toc
end