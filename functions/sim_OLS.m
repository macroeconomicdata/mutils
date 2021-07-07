function [X,Y] = sim_OLS(T, B, q)
%% Description
% Simulate OLS data to test the OLS function
%% Inputs
% T - number of observations
% B - Parameter matrix
% q - variance matrix for shocks to paremters
%% Output
% X - RHS data
% Y - LHS data
%% Sample inputs:
% T = 200
% B = [.3, 1;.5, -.5;1, 0;0, .2;2, -1;-.5, .1;.8, .3;-1, 1.1];
% q = [1, .5; .5, .8];
%% Funciton
[k,m] = size(B);
if(~all(size(q) == m))
    error("Sizes of B and q do not agree")
end
E = randn(T,m)*chol(q);
X = randn(T, k); % RHS variables
Y = X*B + E;
end