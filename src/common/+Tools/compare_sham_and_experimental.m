% University of British Columbia, Vancouver, 2018
%   Alex Kyriazis

% Takes a folder of analysis files and reports averaged data

filePath = uigetdir('','Choose the folder containing the images to be analyzed.');
matList = dir(strcat(filePath,'/*.mat'));

densities = [];
for i=1:size(matList,1)
    [pathstr,name,ext] = fileparts(matList(i).name);
    PATH=strcat(filePath,'/',name,ext);
    
    load(PATH);
    
    a = outputData1~=-1;
    b = outputData1~=-2;
    c = boolean(a.*b);
    counts = outputData1(c);
    densities = [densities; counts/1.6123e+04*10^6/100];
    
    
    fprintf('%s has %f +- %f average microglia count with %d patches\n',name,mean(densities),std(densities),length(densities));
end

fprintf('\n\n--------------------\n\n');
for i=1:size(matList,1)
    [pathstr,name,ext] = fileparts(matList(i).name);
    PATH=strcat(filePath,'/',name,ext);
    
    load(PATH);
    
    a = outputData2~=-1;
    b = outputData2~=-2;
    c = boolean(a.*b);
    average_morph = outputData2(c);
    fprintf('%s has average amoeboid ratio: %f \n',name,1-mean(average_morph));
end
