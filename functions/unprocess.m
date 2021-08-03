function [X_sa, X_nsa] = unprocess(Xtimetable, lib, X_level, Tnd, X_saf, X_scale, X_center)
%% Description
% Undo the processing done by the function process() to convert predictions
% back to their original units

%% Inputs
% Xtimetable: Predictions of model variables in timetable format
% lib: library file used in the process() function
% X_level: log level values of observations from process()
% Tnd: low frequency trend values of observations from process()
% X_saf: seasonal adjustment factors from process()
% X_scale: scale values from process()
% X_center: center (mean) values from process()

%% Output
% X_sa: seasonally adjusted data in orignal (level) format
% X_nsa: seasonally unadjusted data in original (level) format

[T,k] = size(Xtimetable);
X_names = Xtimetable.Properties.VariableNames; % save variable names
in_lib = ismember(X_names, lib.series_name);
if ~all(in_lib)
    error(strcat(X_names(find(~in_lib,1,'first')), " not found in lib"))
end
lib = lib(ismember(lib.series_name, X_names),:);
frequencies = unique(lib.frequency);

dates = Xtimetable.Time;
X_sa = array2timetable(NaN(T,k), 'RowTimes', dates); % initialize output for SA data
X_nsa = array2timetable(NaN(T,k), 'RowTimes', dates); % initialize output for NSA data

for j=1:length(X_names) % loop through each series
    disp(X_names(j));
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
    
    if strcmp(to_do.frequency, 'quarterly')
        if(ismember('weekly', frequencies) && ~ismember('daily', frequencies))
            dates_j = dateshift(dates, 'start', 'week');
            dates_j = unique(dateshift(dates_j,'end','quarter')); % end of quarter dates
            dates_j = dateshift(dates_j, 'end', 'week');
        else
            dates_j = unique(dateshift(dates,'end','quarter')); % end of quarter dates
        end        
        x = x(ismember(dates, dates_j)); % quarterly data
        x_level = x_level(ismember(dates, dates_j));
        tnd = tnd(ismember(dates, dates_j));
        x_saf = x_saf(ismember(dates, dates_j));
    elseif strcmp(to_do.frequency, 'monthly')
        if(ismember('weekly', frequencies) && ~ismember('daily', frequencies))
            dates_j = dateshift(dates, 'start', 'week');
            dates_j = unique(dateshift(dates_j,'end','month')); % end of month dates
            dates_j = dateshift(dates_j, 'end', 'week');
        else
            dates_j = unique(dateshift(dates,'end','month')); % end of month dates
        end        
        x = x(ismember(dates, dates_j)); % monthly data
        x_level = x_level(ismember(dates, dates_j));
        tnd = tnd(ismember(dates, dates_j));
        x_saf = x_saf(ismember(dates, dates_j));
    elseif strcmp(to_do.frequency, 'weekly')
        dates_j = unique(dateshift(dates,'end','week')); % end of week dates
        x = x(ismember(dates, dates_j)); % weekly data
        x_level = x_level(ismember(dates, dates_j));
        tnd = tnd(ismember(dates, dates_j));
        x_saf = x_saf(ismember(dates, dates_j));
    else % ie daily
        dates_j = dates;
    end

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
    l_idx = ismember(dates, dates_j); 
    
    bob = X_sa{l_idx, j} ;
    
    X_sa{l_idx, j} = x_sa;
    X_nsa{l_idx,j} = x_out; 
    
end