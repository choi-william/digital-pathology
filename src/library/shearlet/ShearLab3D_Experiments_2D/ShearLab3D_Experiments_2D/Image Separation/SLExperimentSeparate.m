function [imgCurves, imgPoints] = SLExperimentSeparate(img,lvlWavelets,iterations,stopFactor,gamma,freqWeights,shearletSystem)
% This routine performs image separation to separate two geometrically 
% different objects (points + curves).
% This routine builds up on MCA2_Bcr.m (in MCALab110 ) written by J. M. Fadili. 

    
    N = length(img);

    %% re weighting of frequency bands
    coeffs = atrousdec(img,'maxflat',length(freqWeights)-1);
    for  j = 1:length(freqWeights)
        coeffs{j} = freqWeights(j)*coeffs{j};
    end
    imgReWeighted = atrousrec(coeffs,'maxflat');

    %% Compute minimal threshold deltaMin, at which the iteration stops
    coeffsWaveletOP = FWT2_PO(imgReWeighted,log2(N)-1,MakeONFilter('Daubechies',4));
    hh = coeffsWaveletOP(N/2+1:N/2+floor(N/2),N/2+1:N/2+floor(N/2)); %consider only highpass
    sigma = MAD(hh(:));
    deltaMin = stopFactor*sigma;

    %estimate a starting thresholding parameter delta 
    %we compute all coefficients for the directional and the wavelet system
    coeffsDirectional = SLnormalizeCoefficients2D(SLsheardec2D(imgReWeighted,shearletSystem),shearletSystem);
    coeffsWavelet = swt2(imgReWeighted,lvlWavelets,'sym4');
    delta = min([max(abs(coeffsDirectional(:))), max(abs(coeffsWavelet(:)))]);
   
    
    %% Compute an update factor lambda (deltaNew = deltaOld*lambda;)
    lambda=(delta/deltaMin)^(1/(1-iterations)); % Exponential decrease.

    %% Approximately solve l0 minimization
    imgSep = zeros(N,N,2); %initialize separated images with 0

    for i = 1:iterations
        %Directional Dictionaries
        res = imgReWeighted - (imgSep(:,:,1)+imgSep(:,:,2));
        resWavelet = res+imgSep(:,:,1);

        coeffsDirectional = SLsheardec2D(resWavelet,shearletSystem);
        coeffsDirectional = coeffsDirectional.*(abs(SLnormalizeCoefficients2D(coeffsDirectional,shearletSystem)) > 1.4*delta);    
        imgSep(:,:,1) = SLshearrec2D(coeffsDirectional,shearletSystem);    
        
        %apply soft-thresholding with the (undecimated) Haar wavelet transform 
        imgSep(:,:,1) = TVCorrection(imgSep(:,:,1),gamma);

        %Wavelet Dictionary
        resDirectional = res + imgSep(:,:,2);
        coeffsWavelet = swt2(resDirectional,lvlWavelets,'sym4');
        coeffsWavelet = coeffsWavelet.*(abs(coeffsWavelet) > 1.4*delta);
        imgSep(:,:,2) = iswt2(coeffsWavelet,'sym4');
        %apply soft-thresholding with the (undecimated) Haar wavelet transform 
        imgSep(:,:,2) = TVCorrection(imgSep(:,:,2),gamma);

        %Updating thresholding parameter (Exponential decrease).
        delta=delta*lambda; 
    end

    imgCurves = imgSep(:,:,1); 
    imgPoints = imgSep(:,:,2);
    %aviobj = close(aviobj);
    %close(f1);    
end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = TVCorrection(x,gamma)
    % Total variation implemented using the approximate (exact in 1D) equivalence between the TV norm and the l_1 norm of the Haar (heaviside) coefficients.

    %qmf = MakeONFilter('Haar');
    %[ll,wc] = mrdwt(x,qmf,1);
    wc = swt2(x,1,'haar');
    wc = SoftThresh(wc,gamma);
    y = iswt2(wc,'haar');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%