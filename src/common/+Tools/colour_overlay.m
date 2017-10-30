function [ newIm ] = colour_overlay( im,pList,colour )
 
        if strcmp(colour,'red')
            dim = 1;
        elseif strcmp(colour,'green')
            dim = 2;
        elseif strcmp(colour,'blue')
            dim = 3;
        end

        for j=1:size(pList,1)
            point = round(pList(j,:));
            im(point(2),point(1),:) = [0,0,0];
            im(point(2),point(1),dim) = 255;
        end
        
        newIm = im;
end

