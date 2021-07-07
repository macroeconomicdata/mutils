function X = sim_VAR(T, B, Q)
%% Description
% Simulate VAR data
%% Inputs
% T - number of periods
% B - transition matrix
% Q - shocks to observations
%% Function
[k,kp] = size(B);
A = comp_form(B);
% eig(A);
X = zeros(kp, T+1);
P = chol(Q, 'lower');
E = P*randn(k,T+1);
for t=2:T+1
    X(:,t) = A*X(:,t-1) + [E(:,t); zeros(kp-k,1)];
end
X = X(1:k,2:end);
end


