% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi
% 
% A preparation that all cells go through after they are discovered. This
% sets some key properties in the class that are important for further
% analysis
%

function [dpsomas ] = prepare_soma( dpsoma )

        flag = 0;
        
        MIN_CLUMP_AREA = 500;

        dpsoma = somaBoundBox(dpsoma,0); %adds box properties to the soma        
        dpsoma.cnnBox = Tools.get_block(dpsoma.referenceDPImage.image,round(dpsoma.centroid));

        % now try to resolve clumps
        
        if (dpsoma.isClump == 0 && dpsoma.area > MIN_CLUMP_AREA)
            [flag,somas] = resolve_clump(dpsoma); 
        end
        
        if (flag == 1)
            dpsomas = somas;
        else
            dpsomas = {dpsoma}; 
        end
end

