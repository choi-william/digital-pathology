%sigma = 20; % noise level

N = 150; % the number of random points
iterations = 100; %number of iterations during iterative thresholding
gamma = 3; %parameter used for soft thresholding during total variation correction
stopFactor = 3; %factor used for determining the lowest thresholdg during iterative thresholding
scalesWavelet = 4; %number of scales of the stationary wavelet transform
freqWeights = [.1, .1, 2, 2]; %weights used for reiweighting the frequency domain using an atrous decomposition

sizeX = 256; %size of data
sizeY = 256; %size of data

testSL2D1 = 0; %test shearlet system sl2d1 (4 scales, redundancy 25)
testSL2D2 = 1; %test shearlet system sl2d2 (4 scales, redundancy 49)

saveImages = 0; %save separated signals to hard disk
saveResults = 0;% save quantitative results to hard disk


nExperiment = 1;

results = zeros(sizeX,2,2);

timeElapsed = zeros(1,2);

%SL2D1
if testSL2D1
    sl2d1 = SLgetShearletSystem2D(0,sizeX,sizeY,4,[0 0 1 1]);
end
%SL2D2
if testSL2D2
    sl2d2 = SLgetShearletSystem2D(0,sizeX,sizeY,4,[1 1 2 2]);
end

for i = 1:nExperiment
    %generate test image
    %[img,imgCurves,imgPoints] = SLgetSeparationTestImage(N);
    load imgCurves;
    load imgPoints;
    load imgSeparation;
    %SL2D1
    if testSL2D1
        tic;
        [imgCurvesRec, imgPointsRec] = SLExperimentSeparate(img,scalesWavelet,iterations,stopFactor,gamma,freqWeights,sl2d1);
        timeElapsed(1) = toc;
        
        imgPointsRec = (imgPointsRec - min(imgPointsRec(:)))*(255/max(max(imgPointsRec - min(imgPointsRec(:)))));
        imgCurvesRec = (imgCurvesRec - min(imgCurvesRec(:)))*(255/max(max(imgCurvesRec - min(imgCurvesRec(:)))));
        

        
        [mPoints,mCurves,thresholds] = SLExperimentImageSeparationMeasure(imgPointsRec,imgCurvesRec,imgPoints,imgCurves);

        results(:,1,1) = mPoints;
        results(:,2,1) = mCurves;
        
        [C,idxPoints] = min(mPoints);
        [C,idxCurves] = min(mCurves);
        
        imgPointssl2d1 = 255*(imgPointsRec > thresholds(idxPoints));
        imgCurvessl2d1 = 255*(imgCurvesRec > thresholds(idxCurves));

        if saveImages
            save results/sl2d1_curves imgCurvessl2d1;
            save results/sl2d1_points  imgPointssl2d1;
        end;
    end
    %SL2D2
    if testSL2D2
        tic;
        [imgCurvesRec, imgPointsRec] = SLExperimentSeparate(img,scalesWavelet,iterations,stopFactor,gamma,freqWeights,sl2d2);

        timeElapsed(2) = toc;
        
        imgPointsRec = (imgPointsRec - min(imgPointsRec(:)))*(255/max(max(imgPointsRec - min(imgPointsRec(:)))));
        imgCurvesRec = (imgCurvesRec - min(imgCurvesRec(:)))*(255/max(max(imgCurvesRec - min(imgCurvesRec(:)))));

        
        [mPoints,mCurves,thresholds] = SLExperimentImageSeparationMeasure(imgPointsRec,imgCurvesRec,imgPoints,imgCurves);
        
        results(:,1,2) = mPoints;
        results(:,2,2) = mCurves;    
        
        [C,idxPoints] = min(mPoints);
        [C,idxCurves] = min(mCurves);
        
        imgPointssl2d2 = 255*(imgPointsRec > thresholds(idxPoints));
        imgCurvessl2d2 = 255*(imgCurvesRec > thresholds(idxCurves));

        if saveImages
            save results/sl2d2_curves imgCurvessl2d2;
            save results/sl2d2_points  imgPointssl2d2;
        end;
    end
       
end

figure;
hold on;
plot(squeeze(results(:,1,1)),'Color','green');
plot(squeeze(results(:,1,2)),'Color','red');

figure;
hold on;
plot(squeeze(results(:,2,1)),'Color','green');
plot(squeeze(results(:,2,2)),'Color','red');

if saveResults
    save results_separation_2d results;
    save results_separation_2d_time timeElapsed;
end
