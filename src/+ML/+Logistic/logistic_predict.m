function [average] = logistic_predict(bigB,X)
    Nmodels = size(bigB,1);
    Nobjects = size(X,1);
    average = zeros(Nobjects,1);
    for i=1:Nmodels  
        average = average + mnrval(bigB(i,:)',X)/Nmodels;
    end
end

