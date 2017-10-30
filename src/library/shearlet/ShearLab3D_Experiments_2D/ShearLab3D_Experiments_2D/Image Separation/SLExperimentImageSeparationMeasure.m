function [mPoints, mCurves, thresholds] = SLExperimentImageSeparationMeasure(imgPointsRec,imgCurvesRec,imgPoints,imgCurves)
%SLPAPERIMAGEINPATINGMEASURE Summary of this function goes here
%   Detailed explanation goes here
    

    g = fspecial('gaussian');
    
    thresholds = 0:255;
    
    mPoints = zeros(1,length(thresholds));
    mCurves = zeros(1,length(thresholds));
    
    for thresh = thresholds
        mPoints(thresh+1) =  sqrt(sum(sum(abs(imfilter(imgPoints,g,'same') - imfilter(255*(imgPointsRec > thresh),g,'same')).^2)))/sqrt(sum(sum(abs(imfilter(imgPoints,g,'same')).^2)));
        mCurves(thresh+1) =  sqrt(sum(sum(abs(imfilter(imgCurves,g,'same') - imfilter(255*(imgCurvesRec > thresh),g,'same')).^2)))/sqrt(sum(sum(abs(imfilter(imgCurves,g,'same')).^2)));
    end    
end

