function FEVD = fevd(irf)
%% Description
% Return forecast error variance decompositions from the output of IRF()
%% Inputs
% irf - impulse responses from irf()
%% Output
% FEVD - forecast error variance decomposition
%% Function
[k, ~, horz] = size(irf);
%Calculating the variance decomposition for periods 1 through horz:
VD = zeros(k,k, horz);
for i = 1:k %error in this variable
    for j = 1:k %due to shocks in this variable
        for h = 1:horz %at this horizon
            vd        = irf(j,i,1:h); % error in columns, shocks in rows
            VD(j,i,h) = sum(vd.^2);
        end
    end
end
% This is the total forecast error in each variable at each horizon
MSE = sum(VD,2); % the MSE for the forecast of i h periods ahead.   
FEVD = zeros(k,k, horz);
for i = 1:k % error in this variable
    for j = 1:k % due to shocks in this variable
        FEVD(j,i,:) = VD(j,i,:)./MSE(i,1,:);
    end
end

