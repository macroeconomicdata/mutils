% First we will clear up our workspace; make sure you have saved everything
% you need!
close all
clear 
%% Add paths for functions and data
addpath 'functions' % this contains functions we will use from 
% https://github.com/macroeconomicdata
addpath(genpath('toolbox')) % this is where the X-13 toolbox is located
% Location of macroeconomicdata.com macro dropbox folder
macro_folder = 'C:\Users\seton\Dropbox\macroeconomicdata\macro';
addpath(macro_folder)

%% Load data for USA
Xtable = readtable('usa_data_sa.csv');
% Check that the refference date is in fact formatted as a date:
class(Xtable.ref_date) % datetime
%% Load Library
lib = readtable('library.csv');
% Select only entries for the US:
lib = lib(lib.country == "united states", :);
% If you want to look at everything in there:
% lib.series_name
%% Select data
% For this example we'll use the following series:
selected = {'gdp constant prices', 'personal consumption expenditures',...
    'non farm payrolls', 'industrial production mom'};
% Get the data in which we're interested
gdp_data = Xtable(ismember(Xtable.series_name, selected), :);
% We'll also only use data since 1992:
gdp_data = gdp_data(gdp_data.ref_date >= '1992-01-01',:);

%% Process data
% This processes data using the information about the series in the library
% file. However, we'll need to tell the function whether to detrend data or
% standardize data. 
rm_trend = true;
standardize = true;
[Xf, Xp, Tnd, X_saf, X_level, X_scale, X_center] = ...
    process(gdp_data, lib, rm_trend, standardize);

%% Plot processed data
% There's nothing better than eyeball econometrics. We'll plot the data
% without outliers, which is Xf; Xp includes outliers (f is for fit, p is
% for predict).
X = table2array(Xf);
% We'll have to fill in missing values to plot GDP
X(:,1) = spline_fill_plot(X(:,1));
figure(1)
plot(Xf.Time, X)
legend(Xf.Properties.VariableNames)

%% Nowcast GDP: In Sample
% We can construct a simple unrestricted MIDAS model for GDP using the
% UMIDAS() function. We'll begin by looking at the model excluding outliers
verbose = true; % print parameters
intercept = false; % the data is scaled and centered
include_months = [3, 3, 3]; % include all three months in the quarter for
% all three series. 1 is include only month 1; 2 is include months 1 and 2.
ridge = 1; % we'll use some shrinkage towards zero here
lags = 1; % include 1 lag of GDP in the model
[fit, ~, B] = UMIDAS(Xf(:,1), Xf(:,2:end), lags, ridge, include_months,...
    intercept, verbose);
q_idx = ismember(month(Xf.Time), [3,6,9,12]); % quarterly index
% End of quarter values for plotting
x_plot = Xf.("gdp constant prices")(q_idx);
figure(2)
plot(Xf.Time(q_idx), [x_plot, fit])
legend({'True Values', 'Fitted Values'})

%% Backtesting using Publication Dates
% To backtest this model we'll construct a loop over our backtest dates.
StartDate = datetime('2005-01-20');
EndDate = datetime('2019-12-31');
% Backtest quarterly from the 15th of the 1st month of the quarter
backtest_dates = StartDate:calquarters(1):EndDate;
T = length(backtest_dates);
pred = zeros(T, 1); % store predictions
pred_date = NaT(T,1); % store date (index) for predictions
% rm_trend = true; % detrend data when processing
% standardize = true; % standardize data when processing
verbose = false; % don't print output at each backtest period
for j=1:T
    [Xf, Xp, Tnd, ~, ~, X_scale, X_center] = ...
        process(gdp_data, lib, rm_trend, standardize, backtest_dates(j));
    % which months should we include in the model?
    include_months = get_months(Xp{:,1}, Xp{:,2:end});
    % estimate parameters excluding outliers
    [~, ~, B] = UMIDAS(Xf(:,1), Xf(:,2:end), lags, ridge, include_months,...
        intercept, verbose);
    % get point estimates including outliers
    [~, ~, ~, RHS, lhs, Time] = UMIDAS(Xp(:,1), Xp(:,2:end), lags, ridge, include_months,...
        intercept, verbose);
    % Undo scaling, centering, and detrending to store values
    fit = (RHS*B)*X_scale(1) + X_center(1) + Tnd{ismember(Tnd.Time, Time),:};
    pidx = find(isfinite(lhs), 1, 'last')+1; % one step ahead prediction 
    pred(j) = fit(pidx); % prediction for first missing obs
    pred_date(j) = Time(pidx);  % store corresponding date
end

% Get true values
[Xf, Xp, Tnd, X_saf, X_level, X_scale, X_center] = ...
        process(gdp_data, lib, false, false);
true_vals = Xp{ismember(Xp.Time, pred_date),1};

figure(3)
plot(pred_date, [true_vals, pred])
legend({'True Values', 'Out of Sample Predictions'})








