clear;
%% setup

sigmas = [30,40]; %different standard deviations of Gaussian white noise  used in the experiment
thresholdingFactor = [0 2.5 2.5 2.5 3.8]; %factors associated with the thresholds on different scales of the shearlet transform
images = {'data_denoising_2d/barbara.jpg'}; %the images used in the experiment
testSL2D1 = 1; %test the system SL2D1 (4 scales, redundancy 25)
testSL2D2 = 1; %test the system SL2D2 (4 scales, redundancy 49)
useGPU = 0; %use CUDA

saveImage = 0; %save denoised images on hard disk
savePSNR = 0; %save PSNR results on hard disk

if useGPU
    g = gpuDevice;
end

results = zeros(size(images,2),length(sigmas),2);
noisypsnr = zeros(size(images,2),length(sigmas));
timeElapsed = zeros(2,2);



%% expriment
for i_img = 1:size(images,2)

    %% initialize dictionaries
    image = images{i_img};

    X = imread(image);
    X = double(X);

    if useGPU
        wait(g);
    end;

    %SL2D1        
    if testSL2D1
        tic;
        sl2d1 = SLgetShearletSystem2D(useGPU,size(X,1),size(X,2),4,[0 0 1 1]);
        if useGPU
            wait(g)
        end;
        timeElapsed(1,1) = toc;
    end        
    %SL2D2
    if testSL2D2
        tic;
        sl2d2 = SLgetShearletSystem2D(useGPU,size(X,1),size(X,2),4,[1 1 2 2]);
        if useGPU
            wait(g);
        end;
        timeElapsed(1,2) = toc;
    end

    %% do experiments
    for i_sigma = 1:length(sigmas)

        sigma = sigmas(i_sigma);

        %add noise
        Xnoisy = X + sigma*randn(size(X));
        noisypsnr(i_img,i_sigma) = SLcomputePSNR(X,Xnoisy);

        if useGPU
            wait(g);
        end;

        %% SL2D1        
        if testSL2D1
            tic;       
            %compute the shearlet transform of noisy image
            if useGPU
                coeffssl2d1 = SLsheardec2D(gpuArray(Xnoisy),sl2d1);
            else
                coeffssl2d1 = SLsheardec2D(Xnoisy,sl2d1);
            end;
            
            %apply hard thresholding on shearlet coefficients
            for j = 1:sl2d1.nShearlets
                idx = sl2d1.shearletIdxs(j,:);
                coeffssl2d1(:,:,j) = coeffssl2d1(:,:,j).*(abs(coeffssl2d1(:,:,j)) >= thresholdingFactor(idx(2)+1)*sigma*sl2d1.RMS(j));
            end
            
            %compute reconstruction
            Xrec = SLshearrec2D(coeffssl2d1,sl2d1);
            if useGPU
                Xrec = gather(Xrec);
                wait(g);
            end;
            timeElapsed(2,1)= toc;
            if saveImage
                save results/sl2d1 Xrec;
            end;
            results(i_img,i_sigma,1) = results(i_img,i_sigma,1) + SLcomputePSNR(Xrec,X);
        end
        disp('SL2D1');
        %% SL2D2
        if testSL2D2
            tic;
            %compute the shearlet transform of noisy image
            if useGPU
                coeffssl2d2 = SLsheardec2D(gpuArray(Xnoisy),sl2d2);
            else
                coeffssl2d2 = SLsheardec2D(Xnoisy,sl2d2);
            end;                
            
            %apply hard thresholding on shearlet coefficients
            for j = 1:sl2d2.nShearlets
                idx = sl2d2.shearletIdxs(j,:);
                coeffssl2d2(:,:,j) = coeffssl2d2(:,:,j).*(abs(coeffssl2d2(:,:,j)) >= thresholdingFactor(idx(2)+1)*sl2d2.RMS(j)*sigma);
            end
            
            %compute reconstruction
            Xrec = SLshearrec2D(coeffssl2d2,sl2d2);
            if useGPU
                Xrec = gather(Xrec);
                wait(g);
            end;
            timeElapsed(2,2)= toc;
            if saveImage
                save results/sl2d2 Xrec;
            end;
            results(i_img,i_sigma,2) = results(i_img,i_sigma,2)+ SLcomputePSNR(Xrec,X);
        end;
        disp('SL2D2');


        disp([i_img, i_sigma]);
    end
end  

if saveImage
    save results/Xnoisy Xnoisy;
    save results/X X;
end;

if savePSNR
    save results_denoising_2d results;
    save results_denoising_2d_time timeElapsed;
end;
disp(results)
