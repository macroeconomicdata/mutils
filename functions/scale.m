function [X, x_mean, x_scale] = scale(X)
%% Description
% scale data to zero mean and sd 1
%% Function
T = size(X,1);
x_mean = mean(X,1, 'omitnan');
X = X - kron(x_mean, ones(T,1));
x_scale = sqrt(mean(X.^2, 1, 'omitnan'));
X = X./kron(x_scale, ones(T,1));
end