function [irf, irf_upper, irf_lower] = IRF_local(X, lags, horz, ridge, chol_id, unit_var)

%% Description
% Estimate local impulse response functions
%% Inputs
% X - input data in array format
% lags - number of lags in the model
% horz - maximum horizon for impulse response functions
% ridge - ridge parameter to shrink parameter estimates towards zero in
%         estimations
% chol_id - logical, should we identify shocks using a cholesky 
%           decomposition?
% unit_var - logical, should we scale shocks to have one unit variance?
%% Output
% irf - impulse responses organized as response (row), shock (column),
%       period (slice) using zero indexing (i.e. entry is contemporaneous).
% irf_upper - one standard deviation upper bound on irf
% irf_lower - one standard deviation lower bound on irf

%% Sample data to test the function
% clear
% B = [.7, -.1, .1, 0, .1, 0; -.1, .5, 0, .1, 0, .1];
% Q = [1, .5; .5, 1];
% X = sim_VAR(200, B, Q);
% lags = 3;
% horz = 24;
% ridge = 0;

%% Create output arrays
X = X';
k = size(X,2);
Z = stack_obs(X, lags, true); % true for drop last
X = X(lags+1:end,:);
irf = zeros(k,k,horz+1);
irf_upper = zeros(k,k,horz+1); % upper bound
irf_lower = zeros(k,k,horz+1);

%% Estimation
[B, Q, sd_B] = OLS_HAC(Z, X, ridge, true); % The VAR (horz = 1)
% [B, Q, sd_b] = OLS(Z, X, ridge, true); % The VAR (horz = 1)

if unit_var
    H = chol(Q, 'lower');
else
    if chol_id
% --- for one unit shocks --------
       P = chol(Q,'lower');
       Di = diag(diag(P).^-1); % This is used to scale shocks
       H = P*Di; % One unit shock
% --------------------------
% Hi = H\eye(2);
% Hi*Q*Hi'
% D = diag(diag(P));
% D*D

% ---- for standard deviation ---------
%        Di = diag(Q).^.5; % standard deviation
%        Di = diag(Di./diag(P)); %Matrix to scale shocks
%        H = P*Di; % One unit shock
% -----------------------------
% D = diag( diag(P)./(diag(Q).^.5) )
% D*D
    else
       % One unit correlated shocks
       Di = diag(diag(Q).^-1);
       H = Q*Di;
    end
end


% IRF at horizon zero
irf(:,:,1) = H; % contemporaneous IRF
irf_upper(:,:,1) = H; % contemporaneous IRF
irf_lower(:,:,1) = H; % contemporaneous IRF
% IRF at horizon of one
irf(:,:,2) = B(2:k+1,:)'*H; % OLS returns the transpose of our normal B
irf_upper(:,:,2) = (B(2:k+1,:) + sd_B(2:k+1,:))'*H;
irf_lower(:,:,2) = (B(2:k+1,:) - sd_B(2:k+1,:))'*H;
% For longer horizons build a loop
for j=2:horz
    % put X one more step ahead
    Z = Z(1:end-1,:);
    X = X(2:end,:);
    [B, ~, sd_B] = OLS_HAC(Z, X, ridge, true); % The VAR (horz = 1)
    irf(:,:,j+1) = B(2:k+1,:)'*H; % OLS returns the transpose of our normal B
    irf_upper(:,:,j+1) = (B(2:k+1,:) + sd_B(2:k+1,:))'*H;
    irf_lower(:,:,j+1) = (B(2:k+1,:) - sd_B(2:k+1,:))'*H;
end
end