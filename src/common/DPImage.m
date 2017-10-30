% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% A representation of an entire analyzed image and its properties


classdef DPImage
    % Digital Pathology Image (DPImage)
    %   A representation of an image relevant to this project that 
    %   also contains relevant metadata
    
    properties
        image = 0 %raw image data (3D array)
        flipped = 0; %boolean representing whether image is flipped or not
        
        %file metadata
        filename
        filepath
        id %unique identifier in our image naming system
        originalName

        %verification data
        testPoints = 0; %list of coordinate of cells for training data
        roiMask = 0; %an ROI mask that covers the image (for training)
        
        %average intensity
        avInt = 0;
        
        %soma
        preThresh = 0; %after smoothing and before binarizing
        rawThresh;
        somaMask; %binarized version of image
        
        %slide metadata
        mag %image magnification (multiplication factor)
        stain
        time
        age
        date
        group
        
        %injury parameters
        elapsedTime %elapsed time since injury (hours) (unimplemented)
        impactEnergy %injury impact energy (J) (unimplemented)
    end
    
    methods
        function obj = DPImage(id)

            global config;
            obj.id = id;
            filename = strcat('../data/train/',num2str(id),'.tif');

            imPath = filename;     

            obj.filename = filename;
            obj.filepath = filename;
            obj.image = imread(filename);
            obj.image = obj.image(:,:,1:3);


            if (size(obj.image,2) > size(obj.image,1))
               obj.image = permute(obj.image, [2 1 3]);
               obj.roiMask = obj.roiMask';
               if (size(obj.testPoints,2) == 2)
                  obj.testPoints = [obj.testPoints(:,2), obj.testPoints(:,1)]; 
               end
            end

            obj.filename = filename;
            obj.filepath = filename;
            obj.image = imread(filename);
            obj.image = obj.image(:,:,1:3);

            blue = obj.image(:,:,3);
            obj.avInt = mean(blue(:));

            if (size(obj.image,2) > size(obj.image,1))
               obj.image = permute(obj.image, [2 1 3]);
               obj.roiMask = obj.roiMask';
               if (size(obj.testPoints,2) == 2)
                  obj.testPoints = [obj.testPoints(:,2), obj.testPoints(:,1)]; 
               end
            end
        end
    end
    
end

