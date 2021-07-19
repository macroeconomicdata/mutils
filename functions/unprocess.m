function [X_sa, X_nsa] = unprocess(Xtimetable, lib, X_level, Tnd, X_saf, X_scale, X_center)
%% Description
% Unprocess data that has been processed using the process() function
%% Inputs
% Xtimetable - Input data in timetable format
% lib - lib file used in process() function
% X_level - level values from process() function
% Tnd - trend values from process() function
% X_saf - seasonal adjustment factors from process() function
% X_scale - scale parameters from process() function
% X_center - center (means) parameters from process function
%% Output
% X_sa - seasonally adjusted data
% X_nsa - seasonally unadjusted data

%% Create output timetables
[T,k] = size(Xtimetable);
X_names = Xtimetable.Properties.VariableNames; % save variable names
dates = Xtimetable.Time;
X_sa = array2timetable(NaN(T,k), 'RowTimes', dates); % initialize output for SA data
X_nsa = array2timetable(NaN(T,k), 'RowTimes', dates); % initialize output for NSA data

%% Loop through data
for j=1:length(X_names) % loop through each series
%     disp(X_names(j));
    to_do = lib(strcmp(X_names(j), lib.series_name), :); % get needed adjustments from lib file
    if size(to_do, 1) == 0 % if the data is not in lib, return an error
        error(strcat(X_names(j), " not found in lib"))
    end
    j_idx = strcmp(X_names(j), X_names); % get the index of the data in X
    
    % extract the series we are working with in array format
    % unscale data and add back in mean
    x = table2array(Xtimetable(:,j_idx))*X_scale(j_idx) + X_center(j_idx);
    x_level = table2array(X_level(:,j_idx)); % extract level data for this series
    tnd = table2array(Tnd(:,j_idx)); % trend data for this series
    x_saf = table2array(X_saf(:,j_idx)); % seasonal adjustment factors for this series
        
    % Impute missing values in trend for mixed frequency datasets:
    tnd = spline_fill_plot(tnd); % This function will not fill missing 
    % observations at the beginning or end of the data. We may want to fill
    % missing observations at the end of the data to make forecasts or
    % nowcasts. Thus we'll bring the last observation forward.
    last_idx = find(~isnan(tnd),1,'last');
    if last_idx < length(tnd)
        tnd(last_idx+1:end) = tnd(last_idx);
    end
    % Note that this sort of detrending should only be used for near term
    % forecasting/nowcasting; i.e. applications in which the trend will not
    % have a large impact on predictions. 
    
    x = x + tnd;  % add back in low frequency trends      
    
    if logical(to_do.take_diffs) % did the series get differenced
        x_out = NaN(numel(x), 1); % initialize level output
        for t = 2:numel(x)
            if ~isnan(x_level(t-1))
                x_out(t) = x_level(t-1) + x(t);
            else % if previous level was not observed 
                % for multiple horizon forecasts in levels
                x_out(t) = x_out(t-1) + x(t); % prediction at multiple horizons
            end
        end
    else
        x_out = x;
    end
    
    x_sa = x_out;
    if logical(to_do.needs_SA) % this will give seasonally unadjusted data
        x_out = x_out + x_saf; % seasonally unadjusted means adding back in seasonal factors
    end    
    
    if logical(to_do.take_logs) % if we took logs, take exponential
        x_out = exp(x_out);
        x_sa = exp(x_sa);
    end    
    % put data into output tables
    X_sa{:, j} = x_sa;
    X_nsa{:,j} = x_out; 
    
end