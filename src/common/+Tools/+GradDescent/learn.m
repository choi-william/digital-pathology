% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% Custom made gradient descent model used to optimize parameters. If you
% are going to use this, make sure you have a good understanding of the
% parameters and that you correctly set the cost function in the private
% folder


function [P_f, C ] = learn()

    run init.m %reset parameters

    %iterations is number of iterations
    %p_jump is the scale of the basic jump unit for each parameters
    %P_o is the initial parameters
    %bounds are the min and max bounds of each parameters
    %step_length represents the maximum step traversal represented as a
    %   decimal percentage of bound size
    
%     global_config.LOWER_SIZE_BOUND = 30;
%     global_config.MUMFORD_SHAH_LAMBDA = 0.05;
%     global_config.DEEP_FILTER_THRESHOLD = 0.5;   

%     Config.set_config('MIN_CLUMP_AREA',P(1));
%     Config.set_config('CLUMP_MUMFORD_SHAH_LAMBDA',P(2));
%     Config.set_config('CLUMP_THRESHOLD',P(3));
    
    P_o = [26, 0.067, 0.67];
    p_jump = [2,0.01,0.05];
    max = [100,0.5,1];
    min = [0,0,0];
    bounds = [min; max;];
    step_length = [0.01,0.01,0.01];
    
    iterations = 50;

    P = zeros(iterations,size(P_o,2));
    P(1,:) = P_o; %initial parameters
    
    C = zeros(iterations,1);
    G = zeros(size(P_o,2),1);
    
    B = bounds(2,:) - bounds(1,:);
    
    for i=1:iterations
       [the_cost,TP,FP,FN] = cost(P(i,:));
       C(i) = the_cost;
       fprintf('Score (i=%d): %f with (%d,%d,%d)\n',i,C(i),TP,FP,FN);
       P(i,:)
       for j = 1:size(P_o,2) %calculate gradients
           b=zeros(1,size(p_jump,2));
           b(j) = 1;
           dP = b.*p_jump;
           G(j) = (cost(P(i,:)+dP)-C(i))/(sum(dP));
       end
       G = G.*B'; %to correct for gradient biasing
       G = G.*B'; %to correct for how parameters are adjusted
       
       if (norm(G) == 0)
           fprintf('hit a gradient 0 point\n');
           break;
       end
       
       G = (G).*step_length'/norm(G./B');
       
       if (i == iterations)
           P_f = P(i,:);
           break;
       end
       
       P(i+1,:) = P(i,:) - G';
       
       for j = 1:size(P_o,2)
          if (P(i+1,j) < bounds(1,j))
             P(i+1,j) = bounds(1,j); 
          end
          if (P(i+1,j) > bounds(2,j))
             P(i+1,j) = bounds(2,j);
          end
       end
    end
end

