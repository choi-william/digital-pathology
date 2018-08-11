% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis

% Randomly samples the largest set of cells that are uniform in morphology class.

function new_set = get_set()
    load('+Annotation_morph/annotation_morph_data.mat');
    
%     data(data(:,2)==2,:) = [];
%     data(data(:,2)==3,:) = [];
%     data(data(:,2)==2,2) = 1;
%     data(data(:,2)==3,2) = 4;

    data(data(:,2)==0,:) = [];
    uv = unique(data(:,2)); %classes
    n = histc(data(:,2),uv); %number for each class
    [m,i] = min(n); %number of smallest class, class number
    minmode = uv(i); %class number of smallest class
    

    new_data = [];

%     for i=1:length(uv)
    for i=uv'
        set = data(data(:,2)==i,:);
        randind = randperm(length(set));
        set = set(randind,:);

        new_data = [new_data; set(1:m,:)];
    end

    new_set = new_data(randperm(length(new_data)),:);
%     new_set = data;
end