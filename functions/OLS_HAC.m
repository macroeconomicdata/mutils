function [beta, sigma, sd_beta, t_val] = OLS_HAC(X,Y, varargin) % ridge, intercept, verbose, cnames
%% Description
% Heteroskedasticity and autocorrelation consistent OLS estimation
%% Input:
% optional arguments are: intercept, ridge, verbose, cnames
% X - RHS data
% Y - LHS data
% intercept - logical, should we include an intercept term?
% ridge - ridge parameter to shrink parameter estimates towards zero
% verbose - logical, should results be printed?
% cnames - column names for printing if verbose = true
%% Output
% beta - parameter estimates
% sigma - error variance
% sd_beta - standard deviation of parameter estimates
% t_val - normalized parameter estimates
% sig_beta - variance matrix for parameter estimates
%% Set Defaults
if nargin == 2
    intercept = false;
    ridge = 0;
    verbose = false;
    cnames = (1:size(X,2))';
elseif nargin == 3
    ridge = varargin{1};
    intercept = false;
    verbose = false;
    cnames = (1:size(X,2))';
elseif nargin == 4
    ridge = varargin{1};
    intercept = varargin{2};
    verbose  = false;
    if intercept
        cnames = (0:size(X,2))';
    else
        cnames = (1:size(X,2))';
    end    
elseif nargin == 5
    ridge = varargin{1};
    intercept = varargin{2};
    verbose  = varargin{3};
    if intercept
        cnames = (0:size(X,2))';
    else
        cnames = (1:size(X,2))';
    end    
else
    ridge = varargin{1};
    intercept = varargin{2};
    verbose  = varargin{3};
    if intercept
        cnames = ['intercept'; varargin{4}];
    else
        cnames = varargin{4};
    end     
end

%% Format Data
ind = all(isfinite(X),2) & all(isfinite(Y), 2); % All data must be observed
X = X(ind,:);
Y = Y(ind,:);
[T, k] = size(X);
if(intercept)
    X = [ones(T,1),X];
    k = k+1;
    Ridge = ridge*eye(k);
    Ridge(1,1) = 0; % don't shrink intercept term
else
    Ridge = ridge*eye(k);
end
m = size(Y,2);
%% Estimation
XX = (X'*X + Ridge)\eye(k);
beta = XX*(X'*Y);
E = Y - X*beta;
sigma = (E'*E)/(T - k); % adjust for degrees of freedom
sd_beta = zeros(k,m);
for j=1:m
    sd_beta(:,j) = diag(XX*X'*diag(E(:,j).^2)*X*XX).^.5;
end
t_val = beta./sd_beta; % normalized means
% p_val = 2*(1 - tcdf(abs(t_val),T-k)); % two sided test if you have the toolbox
%% Print Results
if(verbose)
    if size(cnames,1) ~= size(beta,1)
        warning('Size of cnames is not correct; not printing output')
    else
        disp(table(cnames, beta, sd_beta, t_val,...
           'VariableNames', {' ', 'Coefficients', 'SE', 't value'}))
    end
end
end
