function [zz] = stack_obs(z,p, drop_last)
%% Description
% stack observations in VAR or DFM form
%% Inputs
% z - data to stack
% p - number of lags
% drop last - logical, should we drop the last RHS values? Set to true for
% a VAR model; in this case the model will be z = B*ZZ + e. Set to false
% for the observation equation of dyanmic factor models (variables will be
% contemporaneous, not lagged). 
    if nargin == 2 || ~drop_last
        [r,c] = size(z);
        zz = zeros(r-p+1, c*p);
        j = 1;
        for i = 1:p
                zz(:,j:j+c-1) = z((p-i+1):r-i+1,:);
                j = j+c;
        end
    else
       [r,c] = size(z);
        zz = zeros(r-p, c*p);
        j = 1;
        for i = 1:p
                zz(:,j:j+c-1) = z((p-i+1):r-i,:);
                j = j+c;
        end     
    end
end