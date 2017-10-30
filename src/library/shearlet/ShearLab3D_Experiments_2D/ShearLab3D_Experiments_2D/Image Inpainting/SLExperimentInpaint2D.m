function imgInpainted = SLExperimentInpaint2D(imgMasked,mask,iterations,stopFactor,shearletSystem)
% This routine perfomrs image inpainting using the shearlet transform.
% It uses simple iterative thresholding algorithm which appears in 
% "Image decomposition via the combination of sparse representation and 
%  a variational approach", J. Starck et al.,
%  IEEE Trans. Image Proc. vol. 14, 2005.
%
% iterations: max numbr of iterations
% stop: smallest threshold considered
% 
%

    %initialize thresholding parameter
    coeffsNormalized = SLnormalizeCoefficients2D(SLsheardec2D(imgMasked,shearletSystem),shearletSystem);
    delta = max(abs(coeffsNormalized(:)));
    if shearletSystem.useGPU    
        lambda=gpuArray((stopFactor)^(1/(iterations-1)));
        imgInpainted = gpuArray(0);
    else
        lambda=(stopFactor)^(1/(iterations-1));
        imgInpainted = 0;
    end
       
    %iterative thresholding
    for it = 1:iterations
        res = mask.*(imgMasked-imgInpainted);
        coeffs = SLsheardec2D(imgInpainted+res,shearletSystem);
        coeffs = coeffs.*(abs(SLnormalizeCoefficients2D(coeffs,shearletSystem))>delta);
        imgInpainted = SLshearrec2D(coeffs,shearletSystem);  
        delta=delta*lambda;        
    end    
end
