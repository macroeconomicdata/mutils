function months = get_months(y, X)
%% Description
% Get the months that are observed in X at the end of the sample for use in
% UMIDAS()
%% Inputs
% y - quarterly LHS variable
% X - monthly RHS variable
%% Output
% months - months that are observed
%% Function
last_obs = find(isfinite(y), 1, 'last');
[T,k] = size(X);
through = max([last_obs + 3, T]);
months = zeros(k,1);
if through>0
    tmp = X(last_obs+1:through,:);
    for j=1:k
        months(j) = find(isfinite(tmp(:,j)), 1, 'last');
    end
end
end

    


