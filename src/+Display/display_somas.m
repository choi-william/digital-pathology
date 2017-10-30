% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi
% 
% Displays subimages of cells in the somaList array
%

function [] = display_somas( somaList )
    %Displays soma subarray

    length = size(somaList,2);
    width = ceil(sqrt(length));
    height = ceil(length/width);
    
    figure;
    for i=1:length
        if i == round((length/100)*ceil(100*i/length))
            fprintf('%d%%\n',round(i*100/length));
        end
        
        soma = somaList{i};
        
        A(i) = size(soma.subImage,1)*size(soma.subImage,2);
        B(i) = size(soma.subImage,1)/size(soma.subImage,2);
        
        subplot(height,width,i), 
        subimage(soma.subImage);
        set(gca,'visible','off');
    end 
end

