clear;
%% setup
iterations = 300; %number of iterations
stopFactor = 0.005; % the highest coefficent times stopFactor is the lowest threshold used during iterative thresholding.
images = {'data_inpainting_2d/lena.jpg'}; %images used in the experiment
masks = {'data_inpainting_2d/mask_rand.png'}; %masks used in the experiment
sizeX = 512; sizeY = 512; %size of images
testSL2D1 = 0; %test the shearlet system sl2d2
testSL2D2 = 1; %test the shearlet system sl2d2
useGPU = 0; %use CUDA

saveImage = 0; %save inpainted images to hard disk
savePSNR = 0; %save psnr results to hard disk



results = zeros(size(images,2),length(masks),2);
timeElapsed = zeros(2,2);
if useGPU
    g = gpuDevice;
    wait(g);
end;

%SL2D1
if testSL2D1
    tic;
    sl2d1 = SLgetShearletSystem2D(useGPU,sizeX,sizeY,4,[0 0 1 1]);
    if useGPU
        wait(g);
    end;
    timeElapsed(1,1) = toc;   
end
%SL2D2
if testSL2D2
    tic;
    sl2d2 = SLgetShearletSystem2D(useGPU,sizeX,sizeY,4,[1 1 2 2]);
    if useGPU
        wait(g);
    end;
    timeElapsed(2,1) = toc;
end

%% expriment
for i_img = 1:size(images,2)
    img = double(imread(images{i_img}));
    for i_mask = 1:size(masks,2)
        mask = (imread(masks{i_mask}) > 254); 

        imgMasked = img.*mask;

        if useGPU
            wait(g);
        end;

        %SL2D1
        if testSL2D1
            tic;
            if useGPU
                imgInpainted = gather(real(SLExperimentInpaint2D(gpuArray(imgMasked),gpuArray(mask),iterations,stopFactor,sl2d1)));
                wait(g);
            else
                imgInpainted = real(SLExperimentInpaint2D(imgMasked,mask,iterations,stopFactor,sl2d1));
            end;
            timeElapsed(2,1) = toc;
            if saveImage
                save results/sl2d1_text imgInpainted;
            end;
            results(i_img,i_mask,1) = results(i_img,i_mask,1) + SLcomputePSNR(imgInpainted,img);
        end
        display('Sl2D1');
        %SL2D2
        if testSL2D2
            tic;
            if useGPU
                imgInpainted = gather(real(SLExperimentInpaint2D(gpuArray(imgMasked),gpuArray(mask),iterations,stopFactor,sl2d2)));
                wait(g);
            else
                imgInpainted = real(SLExperimentInpaint2D(imgMasked,mask,iterations,stopFactor,sl2d2));  
            end;
            timeElapsed(2,2) = toc;
            if saveImage
                save results/sl2d2_text imgInpainted;
            end;
            results(i_img,i_mask,2) = results(i_img,i_mask,2) + SLcomputePSNR(imgInpainted,img);
        end
        display('Sl2D2');
        if saveImage
            save results/img img;
            save results/imgMasked imgMasked;
        end;                
    end
end  


if savePSNR
    save results_inpainting_2d results;
    save results_inpainting_2d_time timeElapsed;
end;
disp(results)
