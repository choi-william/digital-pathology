% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% A structure containing feature vectors that are relevant for
% classification


classdef DPFeatures
    % defines a soma's defining features
    
    properties
        area
        thresh
        circularity

        subImage
        subImageName

        classification
    end
    
    methods
        function obj= DPFeatures(dpsoma)
           obj.area = dpsoma.area;
           obj.thresh = dpsoma.preThreshIntensity;
           obj.circularity = dpsoma.circularity;
           
           if (dpsoma.isCorrect == 1)
                obj.classification = 'tp';
           elseif (dpsoma.isCorrect == 0)
                obj.classification = 'fp';         
          elseif (dpsoma.isCorrect == -1)
                obj.classification = 'na';         
           end             
        end
    end
end

