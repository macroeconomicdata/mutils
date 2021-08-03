function [B, Sig, Sig_B, fit] = VAR(X, lags, varargin) % ridge, intercept, verbose
%% Description
% Estimate a frequentest VAR with the option to use a ridge regression
%% Inputs
% X - data as an array
% lags - the number of lags to include in RHS variables
% Optional arguments: 
%     ridge - ridge parameter to shrink parameter esitmates towards zero
%     intercept - logical, should we include an intercept term?
%     verbose - logical, should we print results?
%% Output
% B - parameter estimates
% Sig - Covariance matrix of shocks to observations


if nargin == 2
    ridge = 0;
    intercept = false;
    verbose = false;
elseif nargin == 3
    ridge = varargin{1};
    intercept = false;
    verbose = false;
elseif nargin == 4
    ridge = varargin{1};
    intercept = varargin{2};
    verbose  = false;
elseif nargin == 5
    ridge = varargin{1};
    intercept = varargin{2};
    verbose  = varargin{3};
else
    ridge = varargin{1};
    intercept = varargin{2};
    verbose  = varargin{3};
end

Z = stack_obs(X, lags, true);
X = X(lags+1:end,:);

[B, Sig, ~, ~, Sig_B] = OLS(Z, X, ridge, intercept, verbose);
if intercept
    fit = [ones(size(Z,1),1), Z]*B;
else
    fit = Z*B;
end


end