function [f g segment recon timeVec costsTally]=combinatorial_mumford_shah(img,alpha,nu,mu,initial,dispFlag)
%function [f g segment recon timeVec costsTally]=
%   combinatorial_mumford_shah(img,alpha,nu,mu,initial,dispFlag)
%Combinatorial Mumford-Shah function
%
%Inputs:    img - Input image
%           alpha - Data term parameter
%           nu - Boundary length parameter
%           mu - Smoothness term parameter
%           initial - Optional initial contour (default is a box in the
%               center) supplied as a binary mask of the same size as the image
%           dispFlag - Optional flag to display intermediate results 
%               (Default: 0)
%           convSeg - Optional input indicating to stop iterating if the
%               segmentation matches convSeg
%
%Outputs:   f - Final f
%           g - Final g
%           segment - Final segmentation
%           recon - Final reconstruction
%           timeVec - Time per iteration
%           costsTally - MS energy at each iteration
%
%If this code is used for publication, please cite:
%Leo Grady and Christopher Alvino, "The Piecewise Smooth 
%Mumford-Shah Functional on an Arbitrary Graph", IEEE Trans. on 
%Image Processing, Vol. 18, No. 11, Nov. 2009.
%
%Copyright and License
%
%Combinatorial_mumford_shah Version 1.0, 5/14. Copyright (c) 2012
%by Leo Grady and Christopher Alvino, Siemens Corporate Research, %leo.grady@siemens.com. All Rights Reserved. 
%
%Combinatorial_mumford_shah License:
%
%Your use or distribution of Combinatorial_mumford_shah or any 
%derivative code implies that you agree to this License. 
%THIS MATERIAL IS PROVIDED AS IS, WITH ABSOLUTELY NO WARRANTY 
%EXPRESSED OR IMPLIED. ANY USE IS AT YOUR OWN RISK. 
%Permission is hereby granted to use or copy this program, 
%provided that the Copyright, this License, and the Availability %of the original version is retained on all copies. User 
%documentation of any code that uses this code or any derivative %code must cite the Copyright, this License, the Availability 
%note, and "Used by permission." If this code or any derivative 
%code is accessible from within MATLAB, then typing "help 
%Combinatorial_mumford_shah" must cite the Copyright, and "type 
%Combinatorial_mumford_shah" must also cite this License and the %Availability note. Permission to modify the code and to 
%distribute modified code is granted, provided the Copyright, 
%this License, and the Availability note are retained, and a 
%notice that the code was modified is included. This software is %provided to you free of charge. 
%
%
%Originally 1/15/08 - Leo Grady and Christopher Alvino

%This code minimizes the functional
%Q(f,gamma) = alpha*((1-r)^T*(g-I)^2 + r^T*(f-I)^2) +
%.5*(f*A^T* (diag(|A|*r)) *A*f) + .5*(g*A^T* (diag(|A|*(1-r))) *A*g) +
%nu*1^T*|A*r|
%Where: f - Interior smoothed function to be estimated
%       g - Exterior smoothed function to be estimated
%       r -  Region indicator vector, with a '1' indicating that the
%           node is present in the region and '0' otherwise
%       I - Original image
%       alpha - Weighting parameter
%       A - Edge-node incidence matrix (combinatorial gradient operator)
%       nu - Weighting parameter
%       1 - Vector of all ones
%
%
%The energy, in terms of 'r' is:
%max-flow/min-cut - Connected to '0': alpha*(f-I)^2 + |A|^T*(A*f).^2
%                   Connected to '1': alpha*(g-I)^2 + |A|^T*(A*g).^2
%
%                   Edges all have penalty equal to nu multiplied by the
%                   Euclidean weighting adjustment
%
%The energy, in terms of 'f' is:
%2*alpha*r^T*(f-I) + 2*L(r)*f
%(L(r) + alpha*eye(r))f = alpha*I(r)
%
%The energy, in terms of 'g' is:
%2*alpha*(eye-R)*(g-I) + 2*(L*g)(1-r)
%(L_out + alpha*eye)g = alpha*I


%Read image size
[X Y Z]=size(img);

%Check validity of inputs
returnFlag=0;
if(Z>1)
    disp('Single-channel (greyscale) images only.  Exiting...')
    returnFlag=1;
end
if((X<1)||(Y<1))
    disp('Null image.  Exiting...');
    returnFlag=1;
end
if(alpha<0)
    disp('Alpha parameter must be positive.  Exiting...');
    returnFlag=1;
end
if(nu<0)
    disp('Nu parameter must be positive.  Exiting...');
    returnFlag=1;
end
if(mu<0)
    disp('Mu parameter must be positive.  Exiting...');
    returnFlag=1;
end
[X2 Y2 Z2]=size(initial);
if(((X2~=X)||(Y2~=Y))&&(~isempty(initial)))
    disp('Initial contour must be a binary mask of the same size as the image.');
    disp('Use "[]" as input for a default initialization of a box in the center of the image.  Exiting...');
    returnFlag=1;
end
if(returnFlag)
    [f g segment recon timeVec costsTally]=deal([]);
    return;
end

if((nargin<5)||isempty(initial))
    initial=zeros(X,Y);
    initial(round(X/4):round(3*X/4),round(Y/4):round(3*Y/4))=1;
end
if(nargin<6)
    dispFlag=0;
end

%Set parameters
iterations=50; %Maximum iterations
alpha=alpha/mu; %data fidelity
nu=nu/mu; %boundary length

%Set up image
img=reshape(normalize(img(:)),[X Y]); %Normalize image to range [0,1]
if(dispFlag)
    show(img)
    title('Original image');
end

%Build 4-connected lattice graph
[points edges]=lattice(X,Y);
L=laplacian(edges);
W=adjacency(edges);
N=size(points,1);
M=size(edges,1);
A=incidence(edges);

%Build approximate Euclidean-weighted graph for boundary cut
[pointsEuclid edgesEuclid weightsEuclid] = l2_graph(Y,X,2);
AEuclid=incidence(edgesEuclid,weightsEuclid);

%Initialize variables
r=initial(:);
if(dispFlag) %Show initial contour
    [imgMasks,segOutline,imgMarkup]=segoutput(img,r);
    show(imgMarkup);
    title('Initial contour');
    drawnow    
end

%Alternate 'f', 'g' and 'gamma' updates until convergence (or max iterations)
%rOld=round(rand(X,Y)); %Set dummy last contour for first iteration
for k=1:iterations,
    if(k~=1) %If first iteration, estimate functions before contour
        %Find 'r'
        add1=alpha*(f-img(:)).^2 + abs(A)'*((A*f).^2);
        add0=alpha*(g-img(:)).^2 + abs(A)'*((A*g).^2);
        fact=1e6/max([add0;add1;(nu*weightsEuclid)]); %Used to keep the inputs integer valued and maximize dynamic range usage

        %Solve max-flow/min-cut
        tic
        rOld=r;
        r=qpbo_mex(edgesEuclid,round(fact.*nu*weightsEuclid),round(fact.*[add0,add1]));
        timeVec(k)=toc;            
        if(dispFlag) %Display current contour after update
            [imgMasks,segOutline,imgMarkup]=segoutput(img,r);
            show(imgMarkup);
            title(strcat('Current best labeling - Iteration: ',num2str(k)));
            drawnow
        end
    end

    %Determine region/outside indices
    region=find(r==1);
    outside=find(r==0);

    %Update f, given a gamma (contour)
    sfI=speye(length(region));
    Lr=adjacency(edges);
    Lr=Lr(region,region);
    Lr=diag(sparse(sum(Lr)))-Lr;
    imgF=img(region);
    f=zeros(N,1);
    f(region)=(alpha*sfI+Lr)\(alpha*imgF);
    fTmp=zeros(N,1); fTmp(region)=f(region);
    fTmp2=W*fTmp;
    fTmp=zeros(N,1); fTmp(region)=1;
    fTmp2=fTmp2./(eps+W*fTmp);
    dummy=W*fTmp;
    bOutside=find(dummy(outside));
    f=dirichletboundary(L,[region;outside(bOutside)],[f(region);fTmp2(outside(bOutside))]);      
    if(dispFlag)
        show(reshape(f,[X Y]));
        title('Current best inside function');
    end
   
    %Update g, given a gamma (contour)
    sgI=speye(length(outside));
    Lg=adjacency(edges);
    Lg=Lg(outside,outside);
    Lg=diag(sparse(sum(Lg)))-Lg;
    imgG=img(outside);
    g=zeros(N,1);
    g(outside)=(alpha*sgI+Lg)\(alpha*imgG);
    gTmp=zeros(N,1); gTmp(outside)=g(outside);
    gTmp2=W*gTmp;
    gTmp=zeros(N,1); gTmp(outside)=1;
    gTmp2=gTmp2./(eps+W*gTmp);
    dummy=W*gTmp;
    fOutside=find(dummy(region));
    g=dirichletboundary(L,[outside;region(fOutside)],[g(outside);gTmp2(region(fOutside))]);   
    if(dispFlag)
        show(reshape(g,[X Y]));
        title('Current best outside function');            
        recon = (r).*f + (1-r).*g;
        drawnow
    end
    
    %Compute Mumford-Shah energy of current solution
    weights=abs(A)*r;
    Lf=.5*laplacian(edges,weights);
    weights=abs(A)*(1-r);
    Lg=.5*laplacian(edges,weights);
    cost1 = alpha*((1-r)'*((g-img(:)).^2) + r'*((f-img(:)).^2)); %Data fidelity
    cost2 = ((f'*Lf*f) + (g'*Lg*g)); %Smoothness
    cost3 = nu*sum(abs(AEuclid*r)); %Boundary length
 
    costsTally(k) = cost1+cost2+cost3; %Update energy tracking
    
    %Evaluate energy decrease
    if(k == 1)
        pctDecrease = 0;
    else
        pctDecrease = (costsTally(k-1)-costsTally(k))/costsTally(k-1);
    end
    fprintf('Iteration:%g - Fidel:%g, Smooth:%g, Length:%g, Total: %g, Cost descrease:%7.2f%%\n',k,cost1,cost2,cost3,costsTally(k),pctDecrease*100);
    
    %If contour didn't change from previous iteration, exit
    if(k~=1)
        if(sum(rOld(:)==r(:))==N)
            break;
        end
    end
end
if(k==iterations)
    disp('Maximum iterations reached.  Exiting...');
end

% truncate costs tally
costsTally = costsTally(1:k);

%Display 'f'
if(dispFlag)
    show(reshape(f,[X Y]))
    title('Inside function');
end

%Display contour
if(dispFlag)
    [imgMasks,segOutline,imgMarkup]=segoutput(img,r);
    show(imgMarkup);
    title('Region');
end

%Display combined reconstruction
recon = (r).*f + (1-r).*g;
if(dispFlag)
    show(reshape(recon,[X Y]));
    title('Reconstruction');
end

%Assign outputs
segment=r;
f=reshape(f,[X Y]);
g=reshape(g,[X Y]);
recon=reshape(recon,[X Y]);
segment=reshape(segment,[X Y]);