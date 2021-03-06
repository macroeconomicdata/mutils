function [Xf, Xp, Tnd, X_saf, X_level, X_scale, X_center] = process(Xtable, lib, varargin)
%% Description

% Complete all data pre-processing based on entries in lib for data in long
% format

%% Inputs
% Xtable - Data and dates in table format
% lib - table containing instructions on what to do for each series
% as_of - optional 'as of' date for backtesting; all data published after
%         'as of' will be dropped

%% Output
% Xf - data X for fitting moddles, i.e. with no outliers
% Xp - data X for maxing predictions, i.e. including outliers
% T - low frequency trends
% X_saf - seasonal adjustment factors
% X_scale - values used to scale data X
% X_center - values used to center data X (i.e. means)

if nargin == 2
    rm_trend = true;
    standardize = false;
elseif nargin == 3
    rm_trend = varargin{1};
    standardize = false;    
elseif nargin == 4
    rm_trend = varargin{1};
    standardize = varargin{2};    
elseif nargin == 5
    rm_trend = varargin{1};
    standardize = varargin{2};   
    Xtable = Xtable(Xtable.pub_date <= varargin{3}, :);
end

%% Create output tables
X_names = unique(Xtable.series_name); % save variable names
in_lib = ismember(X_names, lib.series_name);
if ~all(in_lib)
    error(strcat(X_names(find(~in_lib,1,'first')), " not found in lib"))
end
lib = lib(ismember(lib.series_name, X_names),:);
frequencies = unique(lib.frequency);

StartDate = min(Xtable.ref_date);
EndDate = max(Xtable.ref_date);

if any(strcmp(frequencies, 'yearly'))
    EndDate = dateshift(EndDate, 'end', 'year');
elseif any(strcmp(frequencies, 'quarterly'))
    EndDate = dateshift(EndDate, 'end', 'quarter');
elseif any(strcmp(frequencies, 'monthly'))
    EndDate = dateshift(EndDate, 'end', 'month');
end

if any(strcmp(frequencies, 'daily'))
    dates = StartDate:caldays(1):EndDate;
    frq = 'day';
elseif any(strcmp(frequencies, 'weekly'))
    StartDate = dateshift(StartDate, 'end', 'week');
    dates = StartDate:calweeks(1):EndDate;
    frq = 'week';    
elseif any(strcmp(frequencies, 'monthly'))
    StartDate = dateshift(StartDate, 'end', 'month');
    dates = StartDate:calmonths(1):EndDate;
    frq = 'month';
elseif any(strcmp(frequencies, 'quarterly'))
    StartDate = dateshift(StartDate, 'end', 'quarter');
    dates = StartDate:calquarters(1):EndDate;
    frq = 'quarter';
end

c = length(X_names); % size of data
r = length(dates);
% Initalize output
Xf = array2timetable(NaN(r,c), 'RowTimes', dates);  % This will be the data used to fit the model: no outliers, seasonaly adjusted, detrended
Xp = array2timetable(NaN(r,c), 'RowTimes', dates); % We can use this data for predictions --- it will include outliers (but is detrended and SA)
Tnd = array2timetable(NaN(r,c), 'RowTimes', dates); % We will store our low frequency trends here
X_saf = array2timetable(NaN(r,c), 'RowTimes', dates); % We will store seasonal adjustment factors here
X_level = array2timetable(NaN(r,c), 'RowTimes', dates); % We will store seasonal adjustment factors here
X_scale = zeros(c,1); % Scaling factor for data
X_center = zeros(c,1); % Mean of data

%% Loop through data
for j=1:length(X_names) % loop through each series
    % disp(X_names(j));
    to_do = lib(strcmp(X_names(j), lib.series_name), :); % get needed adjustments from lib file
    tx = table2timetable( Xtable(strcmp(Xtable.series_name, X_names(j)),...
        {'ref_date', 'value'} )); % the specific series for this iteration  
    if strcmp(to_do.frequency,'quarterly')
        tx = retime(tx,'quarterly', 'mean'); 
    end
    if strcmp(to_do.frequency,'monthly')
        tx = retime(tx,'monthly', 'mean'); 
    end  
    if strcmp(to_do.frequency,'weekly')
        tx = retime(tx,'weekly', 'mean'); 
    end  
    x = table2array(tx);
    dates_j = tx.Properties.RowTimes;
    if max(dates_j) < EndDate % && any(strcmp({'monthly', 'quarterly'},to_do.frequency))
        if strcmp(to_do.frequency,'quarterly')
            seq = max(dates_j):calquarters(1):EndDate;
        elseif strcmp(to_do.frequency,'monthly')
            seq = max(dates_j):calmonths(1):EndDate;
        elseif strcmp(to_do.frequency,'weekly')
            seq = max(dates_j):calweeks(1):EndDate;
        elseif strcmp(to_do.frequency,'daily')
            seq = max(dates_j):caldays(1):EndDate;
        end
        seq = seq(2:end)';
        dates_j = [dates_j; seq];
        x = [x; NaN(length(seq),1)];
    end    
    is_nan = isnan(x);
    if to_do.take_logs % take logs if needed
        x = log(x);
    end
    if to_do.needs_SA % seasonally adjust if needed
        if( strcmp(to_do.frequency, 'monthly')) % if monthly include holiday regressors
            spec = makespec('ADDITIVE', 'AO', 'PICKBEST','X11','DIAG'); %'TDAYS', 'AO'
            try
                x1 = x13(dates_j, x, spec);
                x = x1.d11.d11; % d11 is the seasonally adjusted series by X11
                % By default seasonal adjustment fills missing values with expected
                % values. We don't want this, so we'll put the NaN entries back in.
                x(is_nan) = NaN;
                x_saf = x1.d16.d16; % seasonal adjustment factors  
            catch
                warning('Seasonal adjustment failed');
                % x1 = x11(x, 12, 'additive');
                % x = x1.d11; % data;
                % x_saf = x1.d10; % seasonal factors
                x_saf = zeros(size(x,1),1);
            end
        elseif strcmp(to_do.frequency, 'quarterly')
            try
                x1 = x13(dates_j, x, makespec('ADDITIVE', 'AO', 'PICKBEST', 'X11', 'DIAG')); %'TDAYS', 'AO',
                x = x1.d11.d11; % d11 is the seasonally adjusted series by X11
                % By default seasonal adjustment fills missing values with expected
                % values. We don't want this, so we'll put the NaN entries back in.
                x(is_nan) = NaN;
                x_saf = x1.d16.d16; % seasonal adjustment factors  
            catch 
                warning('Seasonal adjustment failed');
                % x1 = x11(x, 4, 'additive');
                % x = x1.d11; % data;
                % x_saf = x1.d10; % seasonal factors
                x_saf = zeros(size(x,1),1);
            end
        end      
    else
        x_saf = zeros(size(x,1),1); % otherwise seasonal adjustment factor is 0
    end
    if logical(to_do.take_diffs) % difference 
        x_level = x;
        x = [NaN; diff(x)]; % take differences, keeping same length
    else
        x_level = zeros(numel(x),1);
    end
    if logical(rm_trend)
        [x, xp, t] = detrend(x); % detrend and remove outliers
    else 
        xp = x; 
        t = zeros(size(x,1),1); % otherwise no trend
    end
    if logical(standardize)
        [x, x_center, x_scale] = scale(x); % standardize data
        xp = (xp - x_center)/x_scale;
    else % else no mean removal and scaling
        x_center = 0;
        x_scale = 1;
    end
    % Format dates to line up
    if strcmp(to_do.frequency, 'yearly')
        dates_j = dateshift(dates_j,'end','year'); % end of year dates
    elseif strcmp(to_do.frequency, 'quarterly')
        dates_j = dateshift(dates_j,'end','quarter'); % end of quarter dates
    elseif strcmp(to_do.frequency, 'monthly')
        dates_j = dateshift(dates_j,'end','month'); % end of month dates
    end
    if strcmp(frq, 'week')
        dates_j = dateshift(dates_j, 'end', 'week');
    end
    r_idx = ismember(dates_j, dates); % right index
    l_idx = ismember(dates, dates_j); % left index
    % Finally, we'll fill in the necessary values
    % Xf, Xp, T, X_saf, X_scale, X_center
    Xf{l_idx,j} = x(r_idx);
    Xp{l_idx,j} = xp(r_idx);
    Tnd{l_idx,j} = t(r_idx);
    X_saf{l_idx,j} = x_saf(r_idx);
    X_level{l_idx,j} = x_level(r_idx); % level values
    X_scale(j) = x_scale;
    X_center(j) = x_center;
end
%% Name output
Xf.Properties.VariableNames = X_names;
Xp.Properties.VariableNames = X_names;
X_saf.Properties.VariableNames = X_names;
Tnd.Properties.VariableNames = X_names;
end



