function [Xf, Xp, T] = detrend(Y, varargin)
%% Description
% Detrend data using a loess regression and remove outliers.
%% Input: 
% Optional arguments are: span, sd, reps
% Y - Matrix of data to dentrend
% span - A value specifying the fraction of data to use with the 
%        fitting procedure in the loess regression 
% sd - Standard deviation threshold for outliers
% reps - Number of repetitions to use in removing outliers
%% Output:
% Xf - Data with trend and outliers removed for fitting model
% Xp - Data with trend removed but containing outliers for predictions
% T - low frequency trends

if nargin == 1
    span = 0.6;
    sd = 4;
    reps = 3;
elseif nargin == 2
    span = varargin{1};
    sd = 4;
    reps = 3;
elseif nargin == 3
    span = varargin{1};
    sd = varargin{2};
    reps = 3;
else
    span = varargin{1};
    sd = varargin{2};
    reps = varargin{3};
end
[r,k] = size(Y);
Xf = zeros(r,k);
Xp = zeros(r,k);
T = zeros(r,k);
for j = 1:k   
    y = Y(:,j);
    for rep = 1:reps
        t = fLOESS(y, span); % temp trend
        yt = y - t; % detrending removes mean too (more or less)
        sd_y = sqrt(mean(yt.^2, 'omitnan')); % standard dev of yt
        out_idx = abs(yt) > sd*sd_y ; %remove elements more than sd standard deviations
        y(out_idx) = NaN;        
    end
    Xf(:,j) = yt;
    Xp(:,j) = Y(:,j) - t;
    T(:,j) = t;
end

end