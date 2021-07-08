function [fit, err, B, RHS, lhs, Time, sigma, sig_beta, t_val] = UMIDAS(yf, Xf, lags, ridge, include_months, intercept, verbose)

% Simple unrestricted MIDAS estimation for monthly/quarterly data

%% Input:
% yf - LHS quarterly variable as timetable
% Xf - RHS monthly variables as timetable
% lags - number of lags of LHS variable to use
% ridge - ridge regression parameter
% include_months - specifically list which months to include for quarterly
%           nowcasts; "auto" (or an character string) looks at the pattern 
%           of missing data at the  end of the sample.
% intercept - logical, include an intercept term?
% verbose - logical, print parameter estimates?

%% Output:
% fit - fitted values
% err - errors
% B - parameter
% RHS - RHS variables
% lhs - lhs variables
% Time - Time corresponding to lhs variables
% sigma - variance (not sd!)
% sig_beta - standard deviation of parameters
% t_val - t values of parameters


%% Check that times line up

if any(yf.Time ~= Xf.Time)
    error('Times of yf and Xf do not agree')
end

% Currently all inputs are required
% if nargin == 3
%     ridge = 0;
%     intercept = false;
%     include_months = [1,2,3];
%     verbose = true;
% elseif nargin == 4
%     intercept = false;
%     include_months = [1,2,3];
%     verbose = true;
% elseif nargin == 5
%     intercept = true;
% elseif nargin == 6
%     verbose = true;
% end

%% Estimate parameters

X = table2array(Xf);
y = table2array(yf);
months=month(Xf.Time);
first_obs = find(ismember(months, [1,4,7,10]), 1); % begin at beginning of quarter
y = y(first_obs:end,:);
X = X(first_obs:end,:);
months = months(first_obs:end,:);

M1=X(ismember(months,[1,4,7,10]), include_months >= 1 );

T = size(M1,1);

M2=X(ismember(months,[2,5,8,11]), include_months >= 2);
if size(M2,1) < T
    M2 = [M2; NaN(1, size(M2,2))]; % add a NaN val if Q2 is missing
end

M3=X(ismember(months,[3,6,9,12]),  include_months >= 3);
if size(M3,1) < T
   M3 = [M3; NaN(1, size(M3,2))]; % add a NaN val if Q3 is missing
end

lhs_idx = ismember(months,[3,6,9,12]); 
Time = yf.Time(lhs_idx);
lhs = y(lhs_idx, :); % End of quarter values
if size(lhs,1) < T
        lhs = [lhs; NaN(1, 1)]; % add a NaN val quarter val is missing
        Time = [Time; Time(end) + calquarters(1)];
end
    
if lags > 0  
    y_lag = [NaN(lags, lags); stack_obs(lhs, lags, true)];
    RHS=[y_lag,M1,M2,M3];
else
    RHS=[M1,M2,M3];
end

if intercept
    RHS = [ones(size(RHS,1),1), RHS];
end

[B, sigma, sig_beta, t_val]=OLS(RHS,lhs,ridge, false, verbose);

%% Get fitted values

fit = RHS*B;
err = lhs - fit;

end

